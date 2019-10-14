const std = @import("std");

/// Determines the virtual machine memory size.
const memory_size = 32;

/// Represents the kind of the opcode.
const OpcodeKind = enum {
    Loadi, // Loadi rx l1
    Addi, // Addi rx ra l1
    Compare, // Compare rx ra rb
    Jump, // Jump l1
    Branch, // Branch ra l1
    Exit // Exit
};

/// Represents an opcode with 3 operands.
const Opcode = struct {
    kind: OpcodeKind,
    op1: i64 = 0,
    op2: i64 = 0,
    op3: i64 = 0,
};

/// Performs a jump to a given location.
fn jump(pc: *usize, offset: i64) void {
    if (offset >= 0) {
        pc.* += @intCast(usize, offset);
    } else {
        pc.* -= @intCast(usize, -offset);
    }
}

/// Entry point.
pub fn main() anyerror!void {
    // Program memory (registers)
    var memory = comptime ([_]i64{ 0 } ** memory_size);
    // Program code to execute.
    var code = [_]Opcode{
        Opcode{ .kind = .Loadi, .op1 = 0, .op2 = 20 }, // r0 = 20;
        Opcode{ .kind = .Loadi, .op1 = 1, .op2 = 0 }, // r1 = 0;
        Opcode{ .kind = .Compare, .op1 = 2, .op2 = 0, .op3 = 1 }, // r2 = r0 == r1;
        Opcode{ .kind = .Branch, .op1 = 2, .op2 = 2 }, // if (r2 == 0) goto +2;
        Opcode{ .kind = .Addi, .op1 = 1, .op2 = 1, .op3 = 1 }, // r0 = r0 + 1;
        Opcode{ .kind = .Jump, .op1 = -4 }, // goto -4;
        Opcode{ .kind = .Exit }
    };
    // Program Counter.
    var pc: usize = 0;
    // The VM itself.
    while (true) {
        const op = code[pc];
        std.debug.warn("({}) Kind = {}\n\tr0={}\tr1={}\tr2={}\n", pc, op.kind, memory[0], memory[1], memory[2]);
        switch (op.kind) {
            .Loadi => memory[@intCast(usize, op.op1)] = op.op2,
            .Addi => memory[@intCast(usize, op.op1)] = memory[@intCast(usize, op.op2)] + op.op3,
            .Compare => memory[@intCast(usize, op.op1)] =
                @intCast(i64, @boolToInt(memory[@intCast(usize, op.op2)] == memory[@intCast(usize, op.op3)])),
            .Jump => jump(&pc, op.op1),
            .Branch => if (memory[@intCast(usize, op.op1)] != 0) { jump(&pc, op.op2); },
            .Exit => break,
        }
        pc += 1;
    }
    std.debug.warn("Finished!");
}
