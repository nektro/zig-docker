const std = @import("std");
const docker = @import("docker");

pub const zfetch_backend = .std;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const list = try docker.@"/containers/json".get(alloc, {}, .{
        .limit = 0,
        .filters = "",
    }, {});

    for (list.@"200") |item| {
        std.log.info("{s} {s} {s} {d} {s} {s} {s}", .{ item.Id, item.Image, item.Command, item.Created, item.Status, item.Ports, item.Names });
    }
}
