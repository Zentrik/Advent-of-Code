const std = @import("std");
const data = @embedFile("./q1.txt");

pub fn main() !void {
    // const start_time = std.time.nanoTimestamp();

    var dial: i16 = 50;
    var p1_result: u16 = 0;
    var p2_result: u16 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    while (lines.next()) |line| {
        const is_right = line[0] == 'R';
        const value = std.fmt.parseInt(i16, line[1..], 10) catch unreachable;

        const old_dial = dial;
        dial += if (is_right) value else -value;
        const changed_sign = (old_dial > 0 and dial <= 0);

        p2_result += @abs(@divTrunc(dial, 100)) + @intFromBool(changed_sign);
        dial = @mod(dial, 100);
        p1_result += @intFromBool(dial == 0);
    }
    std.debug.print("Part 1: {d}, Part 2: {d}\n", .{p1_result, p2_result});
    // const end_time = std.time.nanoTimestamp();
    // const duration = end_time - start_time;
    // std.debug.print("Execution time: {d} ns\n", .{duration});
}
