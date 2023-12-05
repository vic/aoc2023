const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    const input = try readFileAll(allocator, args[1]);
    try day3(allocator, input);
}

fn readFileAll(allocator: Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();
    return file.readToEndAlloc(allocator, 1024 * 1024);
}

const Allocator = std.mem.Allocator;

const ConstantInput = *const []const u8;

const NumIdx = struct {
    fromIdx: usize,
    toIdx: usize,
    pub fn text(self: NumIdx, input: ConstantInput) []const u8 {
        const num = input.*[self.fromIdx .. self.toIdx + 1];
        return num;
    }
    pub fn value(self: NumIdx, input: ConstantInput) !u32 {
        return std.fmt.parseUnsigned(u32, self.text(input), 10);
    }
};

const NumMap = std.AutoArrayHashMap(NumIdx, u32);

const Pos = struct {
    x: usize,
    y: usize,
    idx: usize,

    width: usize,
    input: ConstantInput,

    pub fn init(input: ConstantInput) Pos {
        const nlIndex = std.mem.indexOfScalar(u8, input.*, '\n') orelse unreachable;
        return .{ .x = 0, .y = 0, .idx = 0, .input = input, .width = nlIndex };
    }

    pub fn isAtDigit(self: Pos) bool {
        return isIndexAtDigit(self.input, self.idx);
    }

    fn isIndexAtDigit(input: ConstantInput, idx: usize) bool {
        return std.ascii.isDigit(input.*[idx]);
    }

    fn isAtSpace(self: Pos) bool {
        return isIndexAtSpace(self.input, self.idx);
    }

    fn isIndexAtSpace(input: ConstantInput, idx: usize) bool {
        return input.*[idx] == '.';
    }

    fn isIndexAtNewline(input: ConstantInput, idx: usize) bool {
        return input.*[idx] == '\n';
    }

    pub fn isAtPart(self: Pos) bool {
        return isIndexAtPart(self.input, self.idx);
    }

    pub fn isAtEngine(self: Pos) bool {
        return isIndexAtEngine(self.input, self.idx);
    }

    fn isIndexAtEngine(input: ConstantInput, idx: usize) bool {
        return input.*[idx] == '*';
    }

    fn isIndexAtPart(input: ConstantInput, idx: usize) bool {
        return !(isIndexAtDigit(input, idx) or
            isIndexAtSpace(input, idx) or
            isIndexAtNewline(input, idx));
    }

    pub fn next(self: Pos) ?Pos {
        if (self.idx + 1 == self.input.len) {
            return null;
        }
        if (isIndexAtNewline(self.input, self.idx)) {
            return .{ .x = 0, .y = self.y + 1, .idx = self.idx + 1, .input = self.input, .width = self.width };
        }
        return .{ .x = self.x + 1, .y = self.y, .idx = self.idx + 1, .input = self.input, .width = self.width };
    }

    pub fn prev(self: Pos) ?Pos {
        if (self.idx == 0) {
            return null;
        }
        if (self.x == 0) { // at start of line
            if (!isIndexAtNewline(self.input, self.idx - 1)) {
                return null;
            }
            return .{ .x = self.width, .y = self.y - 1, .idx = self.idx - 1, .input = self.input, .width = self.width };
        }
        return .{ .x = self.x - 1, .y = self.y, .idx = self.idx - 1, .input = self.input, .width = self.width };
    }

    pub fn up(self: Pos) ?Pos {
        var pos: ?Pos = self.prev();
        while (pos != null) {
            if (pos.?.y < self.y - 1) {
                return null;
            }
            if (pos.?.y == self.y - 1 and pos.?.x == self.x) {
                return pos;
            }
            pos = pos.?.prev();
        }
        return null;
    }

    pub fn upleft(self: Pos) ?Pos {
        var pos: ?Pos = self.prev();
        while (pos != null) {
            if (pos.?.y < self.y - 1) {
                return null;
            }
            if (pos.?.y == self.y - 1 and pos.?.x == self.x - 1) {
                return pos;
            }
            pos = pos.?.prev();
        }
        return null;
    }

    pub fn upright(self: Pos) ?Pos {
        var pos: ?Pos = self.prev();
        while (pos != null) {
            if (pos.?.y < self.y - 1) {
                return null;
            }
            if (pos.?.y == self.y - 1 and pos.?.x == self.x + 1) {
                return pos;
            }
            pos = pos.?.prev();
        }
        return null;
    }

    pub fn down(self: Pos) ?Pos {
        var pos: ?Pos = self.next();
        while (pos != null) {
            if (pos.?.y > self.y + 1) {
                return null;
            }
            if (pos.?.y == self.y + 1 and pos.?.x == self.x) {
                return pos;
            }
            pos = pos.?.next();
        }
        return null;
    }

    pub fn downleft(self: Pos) ?Pos {
        if (self.x == 0) {
            return null;
        }
        var pos: ?Pos = self.next();
        while (pos != null) {
            if (pos.?.y > self.y + 1) {
                return null;
            }
            if (pos.?.y == self.y + 1 and pos.?.x == self.x - 1) {
                return pos;
            }
            pos = pos.?.next();
        }
        return null;
    }

    pub fn downright(self: Pos) ?Pos {
        var pos: ?Pos = self.next();
        while (pos != null) {
            if (pos.?.y > self.y + 1) {
                return null;
            }
            if (pos.?.y == self.y + 1 and pos.?.x == self.x + 1) {
                return pos;
            }
            pos = pos.?.next();
        }
        return null;
    }

    pub fn left(self: Pos) ?Pos {
        var pos: ?Pos = self.prev();
        while (pos != null) {
            if (pos.?.y != self.y) {
                return null;
            }
            if (pos.?.x == self.x - 1) {
                return pos;
            }
            pos = pos.?.prev();
        }
        return null;
    }

    pub fn right(self: Pos) ?Pos {
        var pos: ?Pos = self.next();
        while (pos != null) {
            if (pos.?.y != self.y) {
                return null;
            }
            if (pos.?.x == self.x + 1) {
                return pos;
            }
            pos = pos.?.next();
        }
        return null;
    }

    pub fn numIdx(self: Pos) ?NumIdx {
        var start: ?Pos = self;
        while (true) {
            if (!start.?.isAtDigit()) {
                return null;
            }
            const previous = start.?.prev();
            if (previous == null or !previous.?.isAtDigit()) {
                break;
            }
            start = previous;
        }
        var end: ?Pos = self;
        while (true) {
            const _next = end.?.next();
            if (!_next.?.isAtDigit()) {
                break;
            }
            end = _next;
        }
        return .{ .fromIdx = start.?.idx, .toIdx = end.?.idx };
    }

    pub fn neigbourNumsMap(self: Pos, allocator: Allocator) !NumMap {
        var map = NumMap.init(allocator);
        if (self.up()) |_up| {
            if (_up.numIdx()) |idx| {
                const val = try idx.value(self.input);
                try map.put(idx, val);
            }
        }
        if (self.upleft()) |_upleft| {
            if (_upleft.numIdx()) |idx| {
                const val = try idx.value(self.input);
                try map.put(idx, val);
            }
        }
        if (self.upright()) |_upright| {
            if (_upright.numIdx()) |idx| {
                const val = try idx.value(self.input);
                try map.put(idx, val);
            }
        }
        if (self.down()) |_down| {
            if (_down.numIdx()) |idx| {
                const val = try idx.value(self.input);
                try map.put(idx, val);
            }
        }
        if (self.downleft()) |_downleft| {
            if (_downleft.numIdx()) |idx| {
                const val = try idx.value(self.input);
                try map.put(idx, val);
            }
        }
        if (self.downright()) |_downright| {
            if (_downright.numIdx()) |idx| {
                const val = try idx.value(self.input);
                try map.put(idx, val);
            }
        }
        if (self.left()) |_left| {
            if (_left.numIdx()) |idx| {
                const val = try idx.value(self.input);
                try map.put(idx, val);
            }
        }
        if (self.right()) |_right| {
            if (_right.numIdx()) |idx| {
                const val = try idx.value(self.input);
                try map.put(idx, val);
            }
        }
        return map;
    }

    pub fn neighbourSum(self: Pos, allocator: Allocator) !u32 {
        const map = try neigbourNumsMap(self, allocator);
        var total: u32 = 0;
        for (map.values()) |value| {
            total += value;
        }
        return total;
    }

    pub fn engineRatio(self: Pos, allocator: Allocator) !u32 {
        const map = try neigbourNumsMap(self, allocator);
        var total: u32 = 1;
        if (map.keys().len != 2) {
            return 0;
        }
        for (map.values()) |value| {
            total *= value;
        }
        return total;
    }
};

fn partsTotal(allocator: Allocator, input: []const u8) !void {
    var pos: ?Pos = Pos.init(&input);
    var total: u32 = 0;
    while (pos != null) {
        if (pos.?.isAtPart()) {
            total += try pos.?.neighbourSum(allocator);
        }
        pos = pos.?.next();
    }
    std.debug.print("partsTotal {d}\n", .{total});
}

fn gearRatiosTotal(allocator: Allocator, input: []const u8) !void {
    var pos: ?Pos = Pos.init(&input);
    var total: u32 = 0;
    while (pos != null) {
        if (pos.?.isAtEngine()) {
            total += try pos.?.engineRatio(allocator);
        }
        pos = pos.?.next();
    }
    std.debug.print("engineTotal {d}\n", .{total});
}

pub fn day3(allocator: Allocator, input: []const u8) !void {
    try partsTotal(allocator, input);
    try gearRatiosTotal(allocator, input);
}
