const std = @import("std");
const deps = @import("./deps.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("generate", "generate.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    deps.addAllTo(exe);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    //

    const exe2 = b.addExecutable("test", "test.zig");
    exe2.setTarget(target);
    exe2.setBuildMode(mode);
    deps.addAllTo(exe2);

    const run_cmd2 = exe2.run();
    run_cmd2.step.dependOn(b.getInstallStep());

    const run_step2 = b.step("test", "Run the test");
    run_step2.dependOn(&run_cmd2.step);
}
