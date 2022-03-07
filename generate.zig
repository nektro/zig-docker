const std = @import("std");
const string = []const u8;
const yaml = @import("yaml");

pub fn main() !void {
    // const source_url = "https://docs.docker.com/engine/api/v1.41.yaml";

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    // Using local document because upstream has missing chunks
    // https://github.com/moby/moby/issues/43336
    // https://github.com/moby/moby/issues/43337
    const body_content = @embedFile("./swagger.yaml");
    const doc = try yaml.parse(alloc, body_content);

    const f = try std.fs.cwd().createFile("src/direct.zig", .{});
    const w = f.writer();

    _ = doc;
    _ = w;

    try w.writeAll("const internal = @import(\"./internal.zig\");\n");
    try w.writeAll("const string = []const u8;\n");

    {
        std.debug.print("definitions:\n", .{});
        for (doc.mapping.get("definitions").?.mapping.items) |item| {
            // std.debug.print("- {s}\n", .{item.key});
            std.debug.print("|", .{});

            try w.writeAll("\npub const ");
            try w.writeAll(item.key);
            try w.writeAll(" = ");
            try printType(alloc, w, item.value.mapping);
            try w.writeAll(";\n");
        }
        std.debug.print("\n", .{});
    }
}

const Error = std.fs.File.Writer.Error || std.mem.Allocator.Error;
fn printType(alloc: std.mem.Allocator, w: std.fs.File.Writer, m: yaml.Mapping) Error!void {
    {
        const ref = m.get_string("$ref");
        if (std.mem.startsWith(u8, ref, "#/definitions/")) return try w.writeAll(ref["#/definitions/".len..]);
    }

    {
        const of = m.get("allOf");
        if (of != null) {
            try w.writeAll("internal.AllOf(&.{");
            for (of.?.sequence) |item| {
                try printType(alloc, w, item.mapping);
                try w.writeAll(",");
            }
            try w.writeAll("})");
            return;
        }
    }

    const apitype = m.get_string("type");
    if (std.mem.eql(u8, apitype, "integer")) return try w.writeAll("i32");
    if (std.mem.eql(u8, apitype, "boolean")) return try w.writeAll("bool");
    if (std.mem.eql(u8, apitype, "number")) return try w.writeAll("f64");

    if (std.mem.eql(u8, apitype, "object")) {
        try w.writeAll("struct {");

        if (m.get("additionalProperties") == null) {
            if (m.get("properties") != null) {
                const reqs = try m.get_string_array(alloc, "required");

                for (m.get("properties").?.mapping.items) |item| {
                    try std.zig.fmtId(item.key).format("", .{}, w);
                    try w.writeAll(": ");
                    if (reqs.len > 0) {
                        if (!contains(reqs, item.key)) try w.writeAll("?");
                    }
                    try printType(alloc, w, item.value.mapping);
                    try w.writeAll(",");
                }
            }
        }

        try w.writeAll("}");
        return;
    }

    if (std.mem.eql(u8, apitype, "array")) {
        try w.writeAll("[]const ");
        try printType(alloc, w, m.get("items").?.mapping);
        return;
    }

    if (std.mem.eql(u8, apitype, "string")) {
        if (m.get("enum")) |enumcap| {
            try w.writeAll("enum {");
            for (enumcap.sequence) |item| {
                if (item.string.len == 0) continue;
                try std.zig.fmtId(item.string).format("", .{}, w);
                try w.writeAll(",");
            }
            try w.writeAll("}");
            return;
        }

        return try w.writeAll("string");
    }

    @panic(apitype);
}

fn contains(haystack: []const string, needle: string) bool {
    for (haystack) |item| {
        if (std.mem.eql(u8, item, needle)) {
            return true;
        }
    }
    return true;
}
