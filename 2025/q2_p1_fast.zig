const std = @import("std");
const data = @embedFile("./q2.txt");

// https://lemire.me/blog/2025/01/07/counting-the-digits-of-64-bit-integers/
fn numDigits(x: u64) u8 {
    const digits = [_]u6{19, 19, 19, 19, 18, 18, 18,
                           17, 17, 17, 16, 16, 16,
                           16, 15, 15, 15, 14, 14, 14,
                           13, 13, 13, 13, 12, 12,
                           12, 11, 11, 11, 10, 10, 10,
                           10, 9,  9,  9,  8,  8,
                           8,  7,  7,  7,  7,  6,  6,
                           6,  5,  5,  5,  4,  4,
                           4,  4,  3,  3,  3,  2,  2,
                           2,  1,  1,  1,  1,  1};
    const table = [_]u64{18446744073709551615,
                               18446744073709551615,
                               18446744073709551615,
                               18446744073709551615,
                               999999999999999999,
                               999999999999999999,
                               999999999999999999,
                               99999999999999999,
                               99999999999999999,
                               99999999999999999,
                               9999999999999999,
                               9999999999999999,
                               9999999999999999,
                               9999999999999999,
                               999999999999999,
                               999999999999999,
                               999999999999999,
                               99999999999999,
                               99999999999999,
                               99999999999999,
                               9999999999999,
                               9999999999999,
                               9999999999999,
                               9999999999999,
                               999999999999,
                               999999999999,
                               999999999999,
                               99999999999,
                               99999999999,
                               99999999999,
                               9999999999,
                               9999999999,
                               9999999999,
                               9999999999,
                               999999999,
                               999999999,
                               999999999,
                               99999999,
                               99999999,
                               99999999,
                               9999999,
                               9999999,
                               9999999,
                               9999999,
                               999999,
                               999999,
                               999999,
                               99999,
                               99999,
                               99999,
                               9999,
                               9999,
                               9999,
                               9999,
                               999,
                               999,
                               999,
                               99,
                               99,
                               99,
                               9,
                               9,
                               9,
                               9,
                               0};

    const log = @clz(x);
    return @intFromBool(x > table[log]) + digits[log];
}

// fn numDigits(_x: u64) u64 {
//     var count: u64 = 0;
//     var x = _x;
//     while (x != 0) {
//         x = @divTrunc(x, 10);
//         count += 1;
//     }
//     return count;
// }


inline fn get_p1(start_id: u64, end_id: u64) u64 {
    const num_digits = numDigits(start_id);

    var sequence: u64 = 0;
    var multiplier: u64 = 0;
    if (num_digits % 2 != 0) {
        sequence = std.math.pow(u64, 10, num_digits / 2);
        multiplier = sequence * 10;
    } else {
        sequence = start_id / std.math.pow(u64, 10, num_digits / 2);
        multiplier = std.math.pow(u64, 10, num_digits / 2);
    }

    var sum_of_invalids: u64 = 0;
    while (true) {
        const invalid_id = sequence * (multiplier + 1);
        if (invalid_id > end_id) break;
        if (invalid_id >= start_id) sum_of_invalids += invalid_id;

        sequence += 1;
        if (sequence == multiplier) {
            multiplier *= 10;
        }
    }
    return sum_of_invalids;
}


pub fn main() !void {
    const start_time = std.time.Instant.now() catch unreachable;

    var p1_result: u64 = 0;
    var lines = std.mem.tokenizeScalar(u8, data, ',');

    while (lines.next()) |line| {
        var parts = std.mem.splitScalar(u8, line, '-');
        const first_id = std.fmt.parseInt(u64, parts.next().?, 10) catch unreachable;
        const second_id = std.fmt.parseInt(u64, parts.next().?, 10) catch unreachable;

        p1_result += get_p1(first_id, second_id);
    }
    const end_time = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 1: {d}\n", .{p1_result});
    const duration = std.time.Instant.since(end_time, start_time);
    std.debug.print("Execution time: {d} ns\n", .{duration});
}
