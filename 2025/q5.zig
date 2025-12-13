const std = @import("std");
const data = @embedFile("q5.txt");

const Range = struct {
    start: u64,
    end: u64,

    fn LessThan(_: void, a: Range, b: Range) bool {
        if (a.start < b.start) return true;
        if (a.start > b.start) return false;
        return a.end < b.end;
    }
};


pub fn main() !void {
    const RUNS = 10_000;
    const start_time = std.time.Instant.now() catch unreachable;

    var p1_result: u64 = 0;
    var p2_result: u64 = 0;

    for (0..RUNS) |_| {
        var line_groups = std.mem.tokenizeSequence(u8, data, "\n\n");

        var buffer: [32000]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        const allocator = fba.allocator();

        var ranges_list = std.array_list.Aligned(Range, null).empty;
        defer ranges_list.deinit(allocator);

        var unparsed_ranges = std.mem.tokenizeScalar(u8, line_groups.next().?, '\n');
        while (unparsed_ranges.next()) |line| {
            const idx = std.mem.findScalar(u8, line, '-').?;
            ranges_list.append(allocator, .{
                .start = std.fmt.parseInt(u64, line[0..idx], 10) catch unreachable,
                .end = std.fmt.parseInt(u64, line[idx + 1..], 10) catch unreachable,
            }) catch unreachable;
        }

        std.mem.sortUnstable(Range, ranges_list.items, {}, Range.LessThan);


        var nonoverlapping_ranges = std.ArrayList(Range){};
        defer nonoverlapping_ranges.deinit(allocator);
        nonoverlapping_ranges.ensureTotalCapacity(allocator, ranges_list.items.len) catch unreachable;
        nonoverlapping_ranges.append(allocator, ranges_list.items[0]) catch unreachable;

        for (ranges_list.items) |range| {
            const last_range = &nonoverlapping_ranges.items[nonoverlapping_ranges.items.len - 1];
            if (range.start > last_range.end) {
                p2_result += last_range.end - last_range.start + 1;
                nonoverlapping_ranges.append(allocator, range) catch unreachable;
            } else if (range.end > last_range.end) {
                last_range.end = range.end;
            }
        }

        p2_result += nonoverlapping_ranges.getLast().end - nonoverlapping_ranges.getLast().start + 1;

        var unparsed_ids = std.mem.tokenizeScalar(u8, line_groups.next().?, '\n');
        while (unparsed_ids.next()) |line| {
            const id = std.fmt.parseInt(u64, line, 10) catch unreachable;

            var is_fresh = false;

            for (nonoverlapping_ranges.items) |range| {
                if (id >= range.start and id <= range.end) {
                    is_fresh = true;
                    break;
                }
            }
            p1_result += @intFromBool(is_fresh);
        }
    }
    const end_time = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 1: {d}, Part 2: {d}\n", .{p1_result / RUNS, p2_result / RUNS});
    const duration = std.time.Instant.since(end_time, start_time) / RUNS;
    std.debug.print("Execution time: {d} ns\n", .{duration});
}