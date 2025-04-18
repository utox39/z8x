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

    return string.toOwnedSlice();
}

fn isUnicodeBlockTags(cp: u21) bool {
    return cp >= 0xE0000 and cp <= 0xE007F;
}

test "is a unicode block tag" {
    const result = isUnicodeBlockTags(0xE0001);
    try std.testing.expectEqual(result, true);
}

test "is not a unicode block tag" {
    const result = isUnicodeBlockTags('f');
    try std.testing.expectEqual(result, false);
}

fn findUnicodeBlockTags(allocator: std.mem.Allocator, str: []const u8) ![]u8 {
    var results = std.ArrayList(u8).init(allocator);
    defer results.deinit();

    var it = std.unicode.Utf8Iterator{ .bytes = str, .i = 0 };

    while (it.nextCodepoint()) |cp| {
        if (isUnicodeBlockTags(cp)) {
            try std.fmt.format(results.writer(), "\tUnicode Block Tag: U+{X:0>4}\n", .{cp});
        }
    }

    return results.toOwnedSlice();
}

test "contains unicode block tags" {
    const results = try findUnicodeBlockTags(std.testing.allocator, "\u{E0001}\u{E0066}\u{E007F}");
    defer std.testing.allocator.free(results);

    try std.testing.expect(results.len > 0);
}

test "does not contain unicode block tags" {
    const results = try findUnicodeBlockTags(std.testing.allocator, "test");
    defer std.testing.allocator.free(results);

    try std.testing.expect(results.len == 0);
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
    const block_tags = try findUnicodeBlockTags(allocator, string);
    if (block_tags.len > 0) {
        try stdout.print("WARNING: Tags (Unicode block) found:\n{s}", .{block_tags});
        try bw.flush();
        allocator.free(block_tags);
    }

    if (args.len != 2) {
        allocator.free(string);
    }

    try stdout.print("The string is {s}.\n", .{if (check) "valid" else "not valid"});
    try bw.flush();
}
