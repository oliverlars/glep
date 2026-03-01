
#import "Basic";

IR_Operator :: enum {
	Add;
	Sub;
	Mul;
	Div;
	Mod;
	And;
	Or;
	Xor;
	Shl;
	Shr;
	Neg;
	Not;
	Lt;
	Le;
	Eq;
	Ne;
	Copy;
	Cast;
	Load;
	Store;
	Address;
	Label;
	Goto;
	If;
	Ifz;
	Param;
	Call;
	Alloca;
	Return;
}

IR_Instruction :: struct {
	op: IR_Operator;

	dst: IR_Operand;
	a:   IR_Operand;
	b:   IR_Operand;
}

IR_Operand_Kind :: enum {
	None;
	Constant;
	Label;
	Register;
}

IR_Operand_Type :: struct {
	kind: enum {
		Integer;
		Float;
	};
	size_in_bytes: int;
	unsigned: bool;
}

IR_U8  :: IR_Operand_Type.{.Integer, 1, true};
IR_U16 :: IR_Operand_Type.{.Integer, 2, true};
IR_U32 :: IR_Operand_Type.{.Integer, 4, true};
IR_U64 :: IR_Operand_Type.{.Integer, 8, true};
IR_S8  :: IR_Operand_Type.{.Integer, 1, false};
IR_S16 :: IR_Operand_Type.{.Integer, 2, false};
IR_S32 :: IR_Operand_Type.{.Integer, 4, false};
IR_S64 :: IR_Operand_Type.{.Integer, 8, false};
IR_F32 :: IR_Operand_Type.{.Float, 4, false};
IR_F64 :: IR_Operand_Type.{.Float, 8, false};

IR_Operand :: struct {
	kind: IR_Operand_Kind;
	type: IR_Operand_Type;
	constant: u64;
	register: int;
	label: string;
}


IR_Global :: struct {
	name: string;
	bytes: []u8;
	alignment: int;
}

IR_Function :: struct {
	name: string;
	params: [..]IR_Operand_Type;
	instructions: [..]IR_Instruction;
}

IR :: struct {
	functions: [..]IR_Function;
	globals: [..]IR_Global;
}

emit :: (function: *IR_Function, ins: IR_Instruction) {
	array_add(*function.instructions, ins);
}


ir_alloca :: (size: u64) -> IR_Instruction {
	operand := IR_Operand.{ kind = .Constant, type = IR_U64, constant = size };
	instruction: IR_Instruction;
	instruction.op = .Alloca;
	instruction.a = operand;
	return instruction;
}

ir_label :: (name: string) -> IR_Instruction {
	operand := IR_Operand.{ kind = .Label, label = name };
	instruction: IR_Instruction;
	instruction.op = .Label;
	instruction.a = operand;
	return instruction;
}

ir_add :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Add, dst, a, b };
}

ir_sub :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Sub, dst, a, b };
}

ir_mul :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Mul, dst, a, b };
}

ir_div :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Div, dst, a, b };
}

ir_mod :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Mod, dst, a, b };
}

ir_and :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .And, dst, a, b };
}

ir_or :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Or, dst, a, b };
}

ir_xor :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Xor, dst, a, b };
}

ir_shl :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Shl, dst, a, b };
}

ir_shr :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Shr, dst, a, b };
}

ir_lt :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Lt, dst, a, b };
}

ir_le :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Le, dst, a, b };
}

ir_eq :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Eq, dst, a, b };
}

ir_ne :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Ne, dst, a, b };
}

ir_neg :: (dst: IR_Operand, a: IR_Operand) -> IR_Instruction {
	return .{ .Neg, dst, a, .{} };
}

ir_not :: (dst: IR_Operand, a: IR_Operand) -> IR_Instruction {
	return .{ .Not, dst, a, .{} };
}

ir_copy :: (dst: IR_Operand, a: IR_Operand) -> IR_Instruction {
	return .{ .Copy, dst, a, .{} };
}

ir_cast :: (dst: IR_Operand, a: IR_Operand) -> IR_Instruction {
	return .{ .Cast, dst, a, .{} };
}

ir_load :: (dst: IR_Operand, addr: IR_Operand) -> IR_Instruction {
	return .{ .Load, dst, addr, .{} };
}

ir_store :: (addr: IR_Operand, value: IR_Operand) -> IR_Instruction {
	return .{ .Store, .{}, addr, value };
}

ir_address :: (dst: IR_Operand, a: IR_Operand) -> IR_Instruction {
	return .{ .Address, dst, a, .{} };
}

ir_goto :: (name: string) -> IR_Instruction {
	return .{ .Goto, .{}, .{ kind = .Label, label = name }, .{} };
}

ir_if :: (cond: IR_Operand, name: string) -> IR_Instruction {
	return .{ .If, .{}, cond, .{ kind = .Label, label = name } };
}

ir_ifz :: (cond: IR_Operand, name: string) -> IR_Instruction {
	return .{ .Ifz, .{}, cond, .{ kind = .Label, label = name } };
}

ir_param :: (a: IR_Operand) -> IR_Instruction {
	return .{ .Param, .{}, a, .{} };
}

ir_call :: (dst: IR_Operand, func: string, arg_count: u64) -> IR_Instruction {
	return .{ .Call, dst, .{ kind = .Label, label = func }, .{ kind = .Constant, type = IR_U64, constant = arg_count } };
}

ir_return :: (a: IR_Operand) -> IR_Instruction {
	return .{ .Return, .{}, a, .{} };
}

ir_constant :: (value: u64, type: IR_Operand_Type) -> IR_Operand {
	return .{ kind = .Constant, type = type, constant = value };
}

ir_register :: (reg: int, type: IR_Operand_Type) -> IR_Operand {
	return .{ kind = .Register, type = type, register = reg };
}

ir_label_operand :: (name: string) -> IR_Operand {
	return .{ kind = .Label, label = name };
}

ir_none :: () -> IR_Operand {
	return .{};
}

ir_test :: () -> IR {
	ir: IR;

	f: IR_Function;
	f.name = "main";

	t0 := IR_Operand.{ kind = .Register, type = IR_S32, register = 0 };
	two := IR_Operand.{ kind = .Constant, type = IR_S32, constant = 2 };

	add := ir_add(t0, two, two);
	emit(*f, add);
	emit(*f, ir_return(t0));

	array_add(*ir.functions, f);

	return ir;
}