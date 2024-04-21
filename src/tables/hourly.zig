const std = @import("std");

pub const HourlyTableRecord = struct {
    const Self = @This();

    desc: []const u8,
    hour: u8,
    rate: f32,
    total: f32,

    pub fn fromHtmlBody(body: []const u8) !Self {
        var desc: []const u8 = "Error";
        var hour: u8 = 0;
        var rate: f32 = 0.0;
        var terms = std.mem.tokenize(u8, body, "&");
        while (terms.next()) |term| {
            var kv = std.mem.tokenize(u8, term, "=");
            const key = kv.next().?;
            const val = kv.next().?;
            if (std.mem.eql(u8, key, "desc")) {
                desc = try std.Uri.unescapeString(std.heap.page_allocator, val);
            }
            if (std.mem.eql(u8, key, "hour")) {
                hour = try std.fmt.parseInt(u8, val, 10);
            }
            if (std.mem.eql(u8, key, "rate")) {
                rate = try std.fmt.parseFloat(f32, val);
            }
        }
        return .{ .desc = desc, .hour = hour, .rate = rate, .total = @as(f32, @floatFromInt(hour)) * rate };
    }
};

pub const FormattedHourlyTableRecord = struct {
    const Self = @This();

    desc: []const u8,
    hour: []const u8,
    rate: []const u8,
    total: []const u8,

    pub fn fromHourlyTableRecord(r: HourlyTableRecord) !Self {
        const hour = try std.fmt.allocPrint(std.heap.page_allocator, "{d:.2}", .{r.hour});
        const rate = try std.fmt.allocPrint(std.heap.page_allocator, "${d:.2}", .{r.rate});
        const total = try std.fmt.allocPrint(std.heap.page_allocator, "${d:.2}", .{r.total});
        return .{ .desc = r.desc, .hour = hour, .rate = rate, .total = total };
    }
};
