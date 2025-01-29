const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const content = try readContentFromFileArgument(allocator);
    defer allocator.free(content);

    const result = try nbSafeList(content);

    std.debug.print("result = {d}", .{result});
}

fn nbSafeList(content: []const u8) !i32 {
    const allocator = std.heap.page_allocator;
    var result: i32 = 0;
    var previousStart: usize = 0;
    var numbers = std.ArrayList(i32).init(allocator);
    defer numbers.deinit();

    for (content, 0..content.len) |byte, i| {
        if (byte == ' ') {
            // std.debug.print("{s}\n", .{content[previousStart..i]});
            const number = try std.fmt.parseInt(i32, content[previousStart..i], 10);
            try numbers.append(number);
            previousStart = i + 1;
        } else if (byte == '\n') {
            // std.debug.print("{s}\n", .{content[previousStart..i]});
            const number = try std.fmt.parseInt(i32, content[previousStart..i], 10);
            try numbers.append(number);
            previousStart = i + 1;
            if (isListSafe(&numbers))
                result += 1;
            numbers.clearAndFree();
        }
    }
    return result;
}

fn isListSafe(numbers: *std.ArrayList(i32)) bool {
    if (numbers.items.len < 2) return false;
    const direction: i32 = if (numbers.items[0] < numbers.items[1]) -1 else 1;
    for (0..(numbers.items.len - 1)) |i| {
        const diff: i32 = (numbers.items[i] - numbers.items[i + 1]) * direction;
        // std.debug.print("{d} - {d} = {d}\n", .{ numbers.items[i], numbers.items[i + 1], diff });
        if (diff > 3 or diff < 1)
            return false;
    }
    // std.debug.print("is Safe\n", .{});
    return true;
}

fn readContentFromFileArgument(allocator: std.mem.Allocator) ![]u8 {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) return error.ExpectedArgument;

    // for (args) |arg| {
    // std.debug.print("{s}\n", .{arg});
    // }

    return try readFile(args[1], allocator);
}

fn readFile(filename: []u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 240000);
}
