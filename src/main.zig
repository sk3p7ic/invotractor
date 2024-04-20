const std = @import("std");
const zap = @import("zap");

fn on_req(r: zap.Request) void {
    if (r.path) |path| {
        std.debug.print("PATH: {s}\n", .{path});
    }
    if (r.query) |query| {
        std.debug.print("QUERY: {s}\n", .{query});
    }
    const markup =
        \\<html>
        \\  <head>
        \\      <title>Invotractor v0.0.1</title>
        \\  </head>
        \\  <body>
        \\      <h1>Hello, world!</h1>
        \\  </body>
        \\</html>
    ;
    r.sendBody(markup) catch return;
}

pub fn main() !void {
    var listener = zap.HttpListener.init(.{ .port = 3000, .on_request = on_req, .log = true });
    try listener.listen();
    std.debug.print("Listening on 0.0.0.0:3000\n", .{});
    zap.start(.{ .threads = 2, .workers = 2 });
}
