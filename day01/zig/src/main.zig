const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    const input = try readFileAll(allocator, args[1]);
    try day1(allocator, input);
}

fn readFileAll(allocator: Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();
    return file.readToEndAlloc(allocator, 1024 * 1024);
}

const Allocator = std.mem.Allocator;

pub fn day1(allocator: Allocator, input: []const u8) !void {
    const names = [_][]const u8{
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
    };

    var lines_it = std.mem.splitScalar(u8, input, '\n');
    var total: u32 = 0;
    while (lines_it.next()) |line| {
        const len = line.len;

        var enil: []u8 = try allocator.alloc(u8, len);
        defer allocator.free(enil);
        @memcpy(enil, line);
        std.mem.reverse(u8, enil);

        std.debug.print("Line: {s} <-> {s} \t", .{ line, enil });
        const first_digit = blk: {
            for (0..len) |i| {
                if (std.ascii.isDigit(line[i])) {
                    break :blk (line[i] - '0');
                }
                const slice = line[i..];
                for (names, 0..) |name, name_idx| {
                    if (std.mem.startsWith(u8, slice, name)) {
                        break :blk @as(u32, @intCast(name_idx + 1));
                    }
                }
            }
            break :blk 0;
        };

        const last_digit = blk: {
            for (0..len) |i| {
                if (std.ascii.isDigit(enil[i])) {
                    break :blk (enil[i] - '0');
                }
                const slice = enil[i..];
                for (names, 0..) |name, name_idx| {
                    var name_rev = try allocator.alloc(u8, name.len);
                    defer allocator.free(name_rev);
                    @memcpy(name_rev, name);
                    std.mem.reverse(u8, name_rev);

                    if (std.mem.startsWith(u8, slice, name_rev)) {
                        break :blk @as(u32, @intCast(name_idx + 1));
                    }
                }
            }
            break :blk 0;
        };
        std.debug.print("{d}\t{d}\n", .{ first_digit, last_digit });
        total = total + (first_digit * 10) + last_digit;
    }

    std.debug.print("Day 1: {d}\n", .{total});
}
