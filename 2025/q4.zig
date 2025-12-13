const std = @import("std");
const _data = @embedFile("q4.txt");
const N = std.mem.findScalar(u8, _data, '\n').?;
const M = @divExact(_data.len, N+1);

pub fn main() !void {
    const RUNS = 1_000;
    const start_time = std.time.Instant.now() catch unreachable;

    var p1_result: u64 = 0;
    var p2_result: u64 = 0;

    // allocate a mutable copy of the embedded file so we can modify it
    var buffer: [_data.len]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var data = allocator.alloc(u8, _data.len) catch unreachable;
    defer allocator.free(data);

    for (0..RUNS) |_| {
        @memcpy(data,  _data);

        for (0..M) |j| {
            for (0..N) |i| {
                const c = data[j * (N+1) + i];
                const is_roll = c == '@';

                var adjacent_rolls: i8 = -1;
                for (@max(@as(isize, @intCast(j))-1,0)..@min(j+2, M)) |aj| {
                    for (@max(@as(isize, @intCast(i))-1,0)..@min(i+2, N)) |ai| {
                        adjacent_rolls += @intFromBool(data[aj * (N+1) + ai] == '@');
                    }
                }

                p1_result += @intFromBool(is_roll and adjacent_rolls < 4);
            }
        }

        var modified_data = true;
        while (modified_data) {
            modified_data = false;

            for (0..M) |j| {
                for (0..N) |i| {
                    const c = data[j * (N+1) + i];
                    const is_roll = c == '@';

                    var adjacent_rolls: i8 = -1;
                    inline for(0..3) |dj| {
                        inline for(0..3) |di| {
                            const aj = @as(isize, @intCast(j + dj)) - 1;
                            const ai = @as(isize, @intCast(i + di)) - 1;
                            if (aj >= 0 and aj < M and ai >= 0 and ai < N) {
                                adjacent_rolls += @intFromBool(data[@as(usize, @intCast(aj)) * (N+1) + @as(usize, @intCast(ai))] == '@');
                            }
                        }
                    }
                    // for (@max(@as(isize, @intCast(j))-1,0)..@min(j+2, M)) |aj| {
                    //     for (@max(@as(isize, @intCast(i))-1,0)..@min(i+2, N)) |ai| {
                    //         adjacent_rolls += @intFromBool(data[aj * (N+1) + ai] == '@');
                    //     }
                    // }

                    p2_result += @intFromBool(is_roll and adjacent_rolls < 4);
                    data[j * (N+1) + i] = if (is_roll and adjacent_rolls < 4) '.' else c;
                    modified_data |= is_roll and adjacent_rolls < 4;
                }
            }
        }
    }
    const end_time = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 1: {d}, Part 2: {d}\n", .{p1_result / RUNS, p2_result / RUNS});
    const duration = std.time.Instant.since(end_time, start_time) / RUNS;
    std.debug.print("Execution time: {d} ns\n", .{duration});

}
