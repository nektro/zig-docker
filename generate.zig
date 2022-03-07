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
            std.debug.print("|", .{});

            try w.writeAll("\npub const ");
            try w.writeAll(item.key);
            try w.writeAll(" = ");
            try printType(alloc, w, item.value.mapping);
            try w.writeAll(";\n");
        }
        std.debug.print("\n", .{});
    }

    {
        std.debug.print("paths:\n", .{});
        for (doc.mapping.get("paths").?.mapping.items) |item| {
            std.debug.print("|", .{});

            try w.writeAll("\npub const ");
            try printId(w, item.key);
            try w.writeAll(" = struct {\n");
            try printEndpoint(alloc, w, item.value.mapping);
            try w.writeAll("};\n");
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
    if (m.get("schema")) |cap| {
        return printType(alloc, w, cap.mapping);
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
                    try printId(w, item.key);
                    try w.writeAll(": ");
                    if (reqs.len > 0) {
                        if (!contains(reqs, item.key)) try w.writeAll("?");
                    }
                    try printType(alloc, w, item.value.mapping);
                    if (reqs.len > 0) {
                        if (!contains(reqs, item.key)) try w.writeAll(" = null");
                    }
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
                try printId(w, item.string);
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
    return false;
}

fn printId(w: std.fs.File.Writer, id: string) !void {
    try std.zig.fmtId(id).format("", .{}, w);
}

fn printEndpoint(alloc: std.mem.Allocator, w: std.fs.File.Writer, m: yaml.Mapping) !void {
    for (m.items) |item| {
        try printMethod(alloc, w, item.key, item.value.mapping);
    }
}

fn printMethod(alloc: std.mem.Allocator, w: std.fs.File.Writer, method: string, m: yaml.Mapping) !void {
    try printParamStruct(alloc, w, m, method, "path");
    try printParamStruct(alloc, w, m, method, "query");
    try printParamStruct(alloc, w, m, method, "body");

    {
        try w.writeAll("    pub const ");
        try capitalize(w, method);
        try w.writeAll("R = union(enum) {\n");
        for (m.getT("responses", .mapping).?.items) |item| {
            try w.print("        @\"{s}\": ", .{item.key});
            const mm: yaml.Mapping = item.value.mapping;
            const produces = try m.get_string_array(alloc, "produces");

            if (mm.get("type") != null or mm.get("schema") != null) {
                try printType(alloc, w, mm);
            } else if ((contains(produces, "application/octet-stream") or contains(produces, "text/plain")) and std.mem.eql(u8, item.key, "200")) {
                try w.writeAll("[]const u8");
            } else if (mm.items.len == 1 and mm.get("description") != null) {
                try w.writeAll("void");
            } else if (std.mem.eql(u8, mm.getT("description", .string).?, "no error")) {
                try w.writeAll("void");
            } else {
                @panic("");
            }

            try w.writeAll(",\n");
        }
        try w.writeAll("    };\n");
    }

    // TODO internal namespace things

    try w.writeAll("\n");
}

fn capitalize(w: std.fs.File.Writer, s: string) !void {
    try w.writeAll(&.{std.ascii.toUpper(s[0])});
    try w.writeAll(s[1..]);
}

fn hasParamsOf(m: yaml.Mapping, kind: string) bool {
    for (m.getT("parameters", .sequence).?) |item| {
        if (std.mem.eql(u8, item.mapping.get_string("in"), kind)) {
            return true;
        }
    }
    return false;
}

fn printParamStruct(alloc: std.mem.Allocator, w: std.fs.File.Writer, m: yaml.Mapping, method: string, ty: string) !void {
    if (hasParamsOf(m, ty)) {
        try w.writeAll("    pub const ");
        try capitalize(w, method);
        try w.writeAll(&.{std.ascii.toUpper(ty[0])});
        try w.writeAll(" = struct {");
        var n: usize = 0;
        for (m.getT("parameters", .sequence).?) |item| {
            const mm: yaml.Mapping = item.mapping;
            if (std.mem.eql(u8, mm.get_string("in"), ty)) {
                defer n += 1;
                if (n > 0) try w.writeAll(", ");
                try printId(w, mm.get_string("name"));
                try w.writeAll(": ");
                try printType(alloc, w, mm);

                if (mm.get("default")) |cap| {
                    try w.writeAll(" = ");
                    try printDefault(w, cap.string, mm.get_string("type"));
                }
            }
        }
        try w.writeAll("};\n");
    }
}

fn printDefault(w: std.fs.File.Writer, def: string, ty: string) !void {
    if (std.mem.eql(u8, ty, "boolean")) return try w.writeAll(def);
    if (std.mem.eql(u8, ty, "string")) return try w.print("\"{}\"", .{std.zig.fmtEscapes(def)});
    if (std.mem.eql(u8, ty, "integer")) return try w.writeAll(def);
    @panic(ty);
}

fn codeHasNoContent(code: string) bool {
    if (std.mem.eql(u8, code, "204")) return true;
    @panic(code);
}
