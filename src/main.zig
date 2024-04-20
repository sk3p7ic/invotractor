const std = @import("std");
const zap = @import("zap");

const routes = @import("routes.zig");

const Allocator = std.mem.Allocator;
const ApplicationRouter = routes.ApplicationRouter;

fn on_req(r: zap.Request) void {
    r.sendBody(@embedFile("components/index.html")) catch return;
}

pub fn main() !void {
    var router = try routes.initRouter();
    defer router.deinit();
    var listener = zap.HttpListener.init(.{ .port = 3000, .on_request = router.on_request_handler(), .public_folder = "public", .log = true });
    try listener.listen();
    std.debug.print("Listening on 0.0.0.0:3000\n", .{});
    zap.start(.{ .threads = 2, .workers = 2 });
}
