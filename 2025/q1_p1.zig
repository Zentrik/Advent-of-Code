const std = @import("std");
const data = @embedFile("./q1.txt");

pub fn main() !void {
    var dial: i16 = 50;
    var result: u16 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    while (lines.next()) |line| {
        const is_right = line[0] == 'R';
        const value = std.fmt.parseInt(i16, line[1..], 10) catch {
            // std.debug.print("Failed to parse line: {s}\n", .{line});
            unreachable();
        };
        dial += if (is_right) value else -value;

        result += @intFromBool(@rem(dial, 100) == 0);
    }

    std.debug.print("Final result: {d}\n", .{result});
}
