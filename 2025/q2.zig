const std = @import("std");
const data = @embedFile("./q2.txt");

fn numDigits(_x: u64) u64 {
    var count: u64 = 0;
    var x = _x;
    while (x != 0) {
        x = @divTrunc(x, 10);
        count += 1;
    }
    return count;
}

pub fn main() !void {
    const start_time = std.time.Instant.now() catch unreachable;

    var p1_result: u64 = 0;
    var p2_result: u64 = 0;
    var lines = std.mem.tokenizeScalar(u8, data, ',');

    while (lines.next()) |line| {
        var parts = std.mem.splitScalar(u8, line, '-');
        const first_id = std.fmt.parseInt(u64, parts.next().?, 10) catch unreachable;
        const second_id = std.fmt.parseInt(u64, parts.next().?, 10) catch unreachable;

        for (first_id..second_id+1) |i| {
            const num_digits = numDigits(i);

            var seq_len = num_digits / 2;
            while (seq_len >= 1) : (seq_len -= 1) {
                if (num_digits % seq_len != 0) continue;

                const repeats = num_digits / seq_len;
                const sequence = i % std.math.pow(u64, 10, seq_len);
                var repeated_num: u64 = 0;
                for (0..repeats) |r| {
                    repeated_num += sequence * std.math.pow(u64, 10, r * seq_len);
                }
                if (repeated_num == i) {
                    if (repeats == 2) {
                        p1_result += i;
                    }
                    p2_result += i;
                    break;
                }
            }
        }
    }
    const end_time = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 1: {d}, Part 2: {d}\n", .{p1_result, p2_result});
    const duration = std.time.Instant.since(end_time, start_time);
    std.debug.print("Execution time: {d} ns\n", .{duration});
}
