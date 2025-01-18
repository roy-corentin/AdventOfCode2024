const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const content = try readContentFromFileArgument(allocator);
    defer allocator.free(content);
    var firstNumbers = std.ArrayList(i32).init(allocator);
    var secondNumbers = std.ArrayList(i32).init(allocator);
    defer firstNumbers.deinit();
    defer secondNumbers.deinit();

    try parseFileContent(content, &firstNumbers, &secondNumbers);

    var result: i64 = 0;

    for (firstNumbers.items, secondNumbers.items) |firstNumber, secondNumber| {
        if (firstNumber > secondNumber) {
            result += firstNumber - secondNumber;
        } else {
            result += secondNumber - firstNumber;
        }
    }
    std.debug.print("{d}\n", .{result});
}

fn parseFileContent(content: []u8, firstNumbers: *std.ArrayList(i32), secondNumbers: *std.ArrayList(i32)) !(void) {
    var firstNumberStartIndex: u64 = 0;
    var secondNumberStartIndex: u64 = 0;

    for (content, 0..content.len) |byte, i| {
        if (byte == ' ' and content[i - 1] != ' ') {
            const number = try std.fmt.parseInt(i32, content[firstNumberStartIndex..i], 10);
            const indexToInsert = indexGreaterThan(firstNumbers, number);
            try firstNumbers.insert(indexToInsert, number);
            secondNumberStartIndex = i + 3;
        } else if (byte == '\n') {
            const secondNumber = try std.fmt.parseInt(i32, content[secondNumberStartIndex..i], 10);
            const indexToInsert = indexGreaterThan(secondNumbers, secondNumber);
            try secondNumbers.insert(indexToInsert, secondNumber);
            firstNumberStartIndex = i + 1;
        }
    }
}

fn indexGreaterThan(list: *std.ArrayList(i32), needle: i32) usize {
    var i: usize = 0;
    for (list.items) |item| {
        if (item >= needle) return i;
        i += 1;
    }
    return i;
}

fn readContentFromFileArgument(allocator: std.mem.Allocator) ![]u8 {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) return error.ExpectedArgument;

    for (args) |arg| {
        std.debug.print("{s}\n", .{arg});
    }

    return try readFile(args[1], allocator);
}

fn readFile(filename: []u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 240000);
}
