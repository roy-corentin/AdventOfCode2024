const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) return error.ExpectedArgument;

    for (args) |arg| {
        std.debug.print("{s}\n", .{arg});
    }

    const content = try readFile(args[1], allocator);
    defer allocator.free(content);

    std.debug.print("{s}", .{content});
}

fn readFile(filename: []u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 240000);
}
