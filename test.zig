const std = @import("std");
const docker = @import("docker");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const list = try docker.@"/containers/json".get(alloc, .{
        .limit = 0,
        .filters = "",
    });

    for (list.@"200") |item| {
        std.log.info("{s} {s} {s} {d} {s} {any} {s}", .{ item.Id[0..20], item.Image, item.Command, item.Created, item.Status, item.Ports, item.Names });
    }
}
