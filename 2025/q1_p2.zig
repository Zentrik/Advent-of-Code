const std = @import("std");
const data = @embedFile("./q1.txt");

pub fn main() !void {
    var dial: i16 = 50;
    var result: u16 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    while (lines.next()) |line| {
        const is_right = line[0] == 'R';
        const value = std.fmt.parseInt(i16, line[1..], 10) catch {
            std.debug.print("Failed to parse line: {s}\n", .{line});
            unreachable();
        };
        const old_dial = dial;
        dial += if (is_right) value else -value;
        const changed_sign = (old_dial > 0 and dial <= 0) or (old_dial < 0 and dial >= 0);

        result += @abs(@divTrunc(dial, 100)) + @intFromBool(changed_sign);
        dial = @mod(dial, 100);
        // std.debug.print("Current dial: {d}, result: {d}\n", .{dial, result});
    }
    std.debug.print("Final result: {d}\n", .{result});
}
