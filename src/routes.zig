const std = @import("std");
const zap = @import("zap");
const Mustache = @import("zap").Mustache;

const hourly = @import("tables/hourly.zig");

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

    pub fn getNewHourlyRowForm(self: *Self, req: ZRequest) void {
        _ = self;
        req.sendBody(@embedFile("components/components/new-hourly-row.html")) catch return;
    }

    pub fn addHourlyRow(self: *Self, req: ZRequest) void {
        _ = self;
        const row: []const u8 = req.body orelse return;
        std.debug.print("Body: '{s}'\n{s}\n", .{ row, req.method.? });
        const data = hourly.HourlyTableRecord.fromHtmlBody(row) catch |err| {
            std.debug.print("Body Parse Error: {?}\n", .{err});
            return;
        };
        const stringified = hourly.FormattedHourlyTableRecord.fromHourlyTableRecord(data) catch |err| {
            std.debug.print("Body Stringification Error: {?}\n", .{err});
            return;
        };
        var stache = Mustache.fromData(@embedFile("components/components/hourly-row.mustache.html")) catch |err| {
            std.debug.print("Mustache Init Error: {?}\n", .{err});
            return;
        };
        defer stache.deinit();
        const markup = stache.build(.{ .desc = stringified.desc, .rate = stringified.rate, .hour = stringified.hour, .total = stringified.total });
        defer markup.deinit();
        if (markup.str()) |s| {
            std.debug.print("Sending a formatted response.\n", .{});
            req.sendBody(s) catch return;
        } else {
            std.debug.print("Could not send a formatted response.\n", .{});
            req.sendBody("<div>mustacheBuild() failed!</div>") catch return;
        }
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
    try router.handle_func("/components/new-hourly-row", &appRouter, &ApplicationRouter.getNewHourlyRowForm);
    try router.handle_func("/api/add-row", &appRouter, &ApplicationRouter.addHourlyRow);

    return router;
}
