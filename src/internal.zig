const std = @import("std");
const string = []const u8;
const zfetch = @import("zfetch");
const UrlValues = @import("UrlValues");
const zuri = @import("uri");
const hzzp = @import("hzzp");
const extras = @import("extras");

const shared = @import("./shared.zig");

pub fn AllOf(comptime xs: []const type) type {
    var fields: []const std.builtin.TypeInfo.StructField = &.{};
    inline for (xs) |item| {
        fields = fields ++ std.meta.fields(item);
    }
    return Struct(fields);
}

fn Struct(comptime fields: []const std.builtin.TypeInfo.StructField) type {
    return @Type(.{ .Struct = .{ .layout = .Auto, .fields = fields, .decls = &.{}, .is_tuple = false } });
}

pub const Method = enum {
    get,
    head,
    post,
    put,
    patch,
    delete,
};

pub fn name(comptime Top: type, comptime This: type) []const u8 {
    inline for (std.meta.declarations(Top)) |item| {
        if (item.is_pub and @field(Top, item.name) == This) {
            return item.name;
        }
    }
    @compileError("not found");
}

pub fn Fn(comptime method: Method, comptime endpoint: []const u8, comptime P: type, comptime Q: type, comptime B: type, comptime R: type) type {
    return struct {
        pub usingnamespace switch (method) {
            .get => struct {
                pub const get = real;
            },
            .head => struct {
                pub const head = real;
            },
            .post => struct {
                pub const post = real;
            },
            .put => struct {
                pub const put = real;
            },
            .patch => struct {
                pub const patch = real;
            },
            .delete => struct {
                pub const delete = real;
            },
        };

        const real = inner;

        fn inner(alloc: std.mem.Allocator, argsP: P, argsQ: Q, argsB: B) !R {
            @setEvalBranchQuota(1_000_000);

            const stream = try std.net.connectUnixSocket("/var/run/docker.sock");

            const endpoint_actual = comptime replace(replace(endpoint, '{', "{["), '}', "]s}");
            const url = try std.fmt.allocPrint(alloc, "http://localhost" ++ "/" ++ shared.version ++ endpoint_actual, if (P != void) argsP else .{});

            var paramsQ = try newUrlValues(alloc, Q, argsQ);
            defer paramsQ.inner.deinit();

            const full_url = try std.mem.concat(alloc, u8, &.{ url, "?", try paramsQ.encode() });
            std.log.debug("{s} {s}", .{ @tagName(fixMethod(method)), full_url });

            const req = try newRequest(alloc, stream, full_url);
            defer req.deinit();

            var paramsB = try newUrlValues(alloc, B, argsB);
            defer paramsB.inner.deinit();

            var headers = zfetch.Headers.init(alloc);
            try headers.appendValue("Content-Type", "application/x-www-form-urlencoded");

            try req.do(fixMethod(method), headers, if (paramsB.inner.count() == 0) null else try paramsB.encode());
            const r = req.reader();
            const body_content = try r.readAllAlloc(alloc, 1024 * 1024 * 5);
            const code = try std.fmt.allocPrint(alloc, "{d}", .{req.status.code});
            std.log.debug("{d}", .{req.status.code});
            std.log.debug("{s}", .{body_content});

            inline for (std.meta.fields(R)) |item| {
                if (std.mem.eql(u8, item.name, code)) {
                    var jstream = std.json.TokenStream.init(body_content);
                    const res = try std.json.parse(extras.FieldType(R, @field(std.meta.FieldEnum(R), item.name)), &jstream, .{
                        .allocator = alloc,
                        .ignore_unknown_fields = true,
                    });
                    return @unionInit(R, item.name, res);
                }
            }
            @panic(code);
        }
    };
}

fn replace(comptime haystack: []const u8, comptime needle: u8, comptime replacement: []const u8) []const u8 {
    comptime var res: []const u8 = &.{};
    inline for (haystack) |c| {
        if (c == needle) {
            res = res ++ replacement;
        } else {
            const temp: []const u8 = &.{c};
            res = res ++ temp;
        }
    }
    return res;
}

fn newUrlValues(alloc: std.mem.Allocator, comptime T: type, args: T) !*UrlValues {
    var params = try alloc.create(UrlValues);
    params.* = UrlValues.init(alloc);
    inline for (meta_fields(T)) |item| {
        const U = item.field_type;
        const key = item.name;
        const value = @field(args, item.name);

        if (comptime std.meta.trait.isZigString(U)) {
            try params.add(key, value);
        } else if (U == bool) {
            try params.add(key, if (value) "true" else "false");
        } else if (U == i32) {
            try params.add(key, try std.fmt.allocPrint(alloc, "{d}", .{value}));
        } else {
            @compileError(@typeName(U));
        }
    }
    return params;
}

fn meta_fields(comptime T: type) []const std.builtin.TypeInfo.StructField {
    return switch (@typeInfo(T)) {
        .Struct => std.meta.fields(T),
        .Void => &.{},
        else => |v| @compileError(@tagName(v)),
    };
}

fn newRequest(allocator: std.mem.Allocator, stream: std.net.Stream, url: string) !*zfetch.Request {
    const uri = try zuri.parse(url);

    const protocol = zfetch.Protocol.http;

    var req = try allocator.create(zfetch.Request);
    errdefer allocator.destroy(req);

    if (uri.host == null) return error.MissingHost;

    req.allocator = allocator;
    req.socket = zfetch.Connection{
        .allocator = allocator,
        .hostname = uri.host.?,
        .protocol = protocol,
        .port = 80,
        .socket = stream,
    };

    req.buffer = try allocator.alloc(u8, std.mem.page_size);
    errdefer allocator.free(req.buffer);

    req.url = url;
    req.uri = uri;

    req.buffered_reader = try allocator.create(BufferedReader);
    errdefer allocator.destroy(req.buffered_reader);
    req.buffered_reader.* = .{ .unbuffered_reader = req.socket.reader() };

    req.buffered_writer = try allocator.create(BufferedWriter);
    errdefer allocator.destroy(req.buffered_writer);
    req.buffered_writer.* = .{ .unbuffered_writer = req.socket.writer() };

    req.client = HttpClient.init(req.buffer, req.buffered_reader.reader(), req.buffered_writer.writer());

    req.headers = hzzp.Headers.init(allocator);
    req.status = zfetch.Request.Status{
        .code = 0,
        .reason = "",
    };

    return req;
}

fn fixMethod(m: Method) zfetch.Method {
    return switch (m) {
        .get => .GET,
        .head => .HEAD,
        .post => .POST,
        .put => .PUT,
        .patch => .PATCH,
        .delete => .DELETE,
    };
}

const HttpClient = hzzp.base.client.BaseClient(BufferedReader.Reader, BufferedWriter.Writer);
const BufferedReader = std.io.BufferedReader(std.mem.page_size, zfetch.Connection.Reader);
const BufferedWriter = std.io.BufferedWriter(std.mem.page_size, zfetch.Connection.Writer);
