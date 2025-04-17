const std = @import("std");

fn readFromStdin(allocator: std.mem.Allocator) ![]u8 {
    var stdin_file = std.io.getStdIn().reader();
    return try stdin_file.readAllAlloc(allocator, std.math.maxInt(usize));
}

fn concatArgs(allocator: std.mem.Allocator, args: [][:0]u8) ![]u8 {
    var string = std.ArrayList(u8).init(allocator);
    defer string.deinit();

    for (args[1..]) |a| {
        try string.appendSlice(a);
    }

    return allocator.dupe(u8, string.items);
}

fn checkString(s: []const u8) bool {
    return std.unicode.utf8ValidateSlice(s);
}

test "valid utf-8 string" {
    const result = checkString("valid utf-8 string");
    try std.testing.expectEqual(result, true);
}

test "invalid utf-8 string" {
    const result = checkString("\xff\xfe");
    try std.testing.expectEqual(result, false);
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var string: []u8 = undefined;
    var check: bool = false;

    if (args.len == 2) {
        string = args[1];
    } else if (args.len > 2) {
        string = try concatArgs(allocator, args);
    } else {
        string = try readFromStdin(allocator);

        if (string.len == 0) {
            std.debug.print("No args or stdin provided.\n", .{});
            return;
        }
    }

    check = checkString(string);

    if (args.len != 2) {
        defer allocator.free(string);
    }

    try stdout.print("The string is {s}.\n", .{if (check) "valid" else "not valid"});
    try bw.flush();
}
