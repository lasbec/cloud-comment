const std = @import("std");
const pcloud = @import("pcloud.zig");

comptime {
    _ = pcloud.PCloudApi;
}

pub fn main() !void {
    const address = try std.net.Address.parseIp("0.0.0.0", 8080);
    var server = try address.listen(.{ .reuse_address = true });
    defer server.deinit();

    while (true) {
        const connection = try server.accept();
        handle(connection) catch {};
    }
}

fn handle(connection: std.net.Server.Connection) !void {
    defer connection.stream.close();

    var buffer: [2048]u8 = undefined;
    const bytes = try connection.stream.read(&buffer);
    const request = buffer[0..bytes];
    const path = requestPath(request) orelse "/";

    if (std.mem.eql(u8, path, "/api/session")) {
        try writeResponse(connection.stream, "application/json", "{\"authenticated\":false}\n");
        return;
    }

    var path_buffer: [512]u8 = undefined;
    const safe_path = if (std.mem.eql(u8, path, "/") or std.mem.indexOf(u8, path, "..") != null)
        "public/index.html"
    else
        try std.fmt.bufPrint(&path_buffer, "public{s}", .{path});

    const file = std.fs.cwd().openFile(safe_path, .{}) catch {
        try writeResponse(connection.stream, "text/html; charset=utf-8", "not found\n");
        return;
    };
    defer file.close();

    const body = try file.readToEndAlloc(std.heap.page_allocator, 1024 * 1024);
    defer std.heap.page_allocator.free(body);
    try writeResponse(connection.stream, contentType(safe_path), body);
}

fn requestPath(request: []const u8) ?[]const u8 {
    if (!std.mem.startsWith(u8, request, "GET ")) return null;
    const rest = request[4..];
    const end = std.mem.indexOfScalar(u8, rest, ' ') orelse return null;
    return rest[0..end];
}

fn contentType(path: []const u8) []const u8 {
    if (std.mem.endsWith(u8, path, ".js")) return "text/javascript; charset=utf-8";
    if (std.mem.endsWith(u8, path, ".css")) return "text/css; charset=utf-8";
    if (std.mem.endsWith(u8, path, ".svg")) return "image/svg+xml";
    if (std.mem.endsWith(u8, path, ".json")) return "application/json";
    return "text/html; charset=utf-8";
}

fn writeResponse(stream: std.net.Stream, mime: []const u8, body: []const u8) !void {
    try stream.writer().print(
        "HTTP/1.1 200 OK\r\nContent-Type: {s}\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n{s}",
        .{ mime, body.len, body },
    );
}
