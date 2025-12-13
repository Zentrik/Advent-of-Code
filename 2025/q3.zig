const std = @import("std");
const data = @embedFile("q3.txt");

fn findMax(slice: []const u8) struct {max: u8, max_index: usize} {
    var max: u8 = 0;
    var max_index: usize = 0;
    for (slice, 0..) |c, i| {
        if (c > max) {
            max = c;
            max_index = i;
        }
    }
    return .{.max=max, .max_index=max_index};
}

pub fn main() !void {
    const RUNS = 10_000;
    const start_time = std.time.Instant.now() catch unreachable;

    var p1_result: u64 = 0;
    var p2_result: u64 = 0;

    for (0..RUNS) |_| {
        var lines = std.mem.tokenizeScalar(u8, data, '\n');

        while (lines.next()) |line| {
            var p1_largest_digit: u8 = 0;
            var p1_second_largest_digit: u8 = 0;
            for (line, 0..) |c, i| {
                const digit = c - '0';

                const new_largest_digit = digit > p1_largest_digit and i != line.len - 1;
                p1_second_largest_digit = if (new_largest_digit) 0 else @max(p1_second_largest_digit, digit);
                p1_largest_digit = if (new_largest_digit) digit else p1_largest_digit;
            }
            p1_result += p1_largest_digit * 10 + p1_second_largest_digit;

            var p2_index: usize = 0;
            var p2_joltage: u64 = 0;
            for (0..12) |i| {
                const result = findMax(line[p2_index..line.len-(11-i)]);
                p2_joltage = p2_joltage * 10 + (result.max - '0');
                p2_index += result.max_index + 1;
            }
            p2_result += p2_joltage;
        }
    }
    const end_time = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 1: {d}, Part 2: {d}\n", .{p1_result / RUNS, p2_result / RUNS});
    const duration = std.time.Instant.since(end_time, start_time) / RUNS;
    std.debug.print("Execution time: {d} ns\n", .{duration});
}
