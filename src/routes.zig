const std = @import("std");
const zap = @import("zap");

const Allocator = std.mem.Allocator;
const ZRequest = zap.Request;

pub const ApplicationRouter = struct {
    const Self = @This();

    alloc: Allocator,

    pub fn init(allocator: Allocator) Self {
        return .{ .alloc = allocator };
    }

    pub fn getIndex(self: *Self, req: ZRequest) void {
        _ = self;
        req.sendBody(@embedFile("components/index.html")) catch return;
    }

    pub fn getNewHourlyRow(self: *Self, req: ZRequest) void {
        _ = self;
        req.sendBody(@embedFile("components/components/new-hourly-row.html")) catch return;
    }
};

pub fn not_found(req: ZRequest) void {
    req.setStatus(.not_found);
    req.sendBody("Route not found.") catch return;
}

pub fn initRouter() !zap.Router {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .thread_safe = true }){};
    var allocator = gpa.allocator();

    var router = zap.Router.init(allocator, .{ .not_found = not_found });

    var appRouter = ApplicationRouter.init(allocator);
    try router.handle_func("/", &appRouter, &ApplicationRouter.getIndex);
    try router.handle_func("/components/new-hourly-row", &appRouter, &ApplicationRouter.getNewHourlyRow);

    return router;
}
