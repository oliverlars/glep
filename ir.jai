
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
	LoadParam;
	Call;
	Alloca;
	Return;
	MemoryOrderRelaxed;
	MemoryOrderConsume;
	MemoryOrderAcquire;
	MemoryOrderRelease;
	MemoryOrderAcqRel;
	MemoryOrderSeqCst;
	AtomicLoad;
	AtomicStore;
	AtomicFetchAdd;
	VAStart;
	VAEnd;
	VACopy;
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
	// Mainly for the C backend
	pointer: bool;
}

IR_U8  :: IR_Operand_Type.{ kind = .Integer, size_in_bytes = 1, unsigned = true, pointer = false};
IR_U16 :: IR_Operand_Type.{ kind = .Integer, size_in_bytes = 2, unsigned = true, pointer = false};
IR_U32 :: IR_Operand_Type.{ kind = .Integer, size_in_bytes = 4, unsigned = true, pointer = false};
IR_U64 :: IR_Operand_Type.{ kind = .Integer, size_in_bytes = 8, unsigned = true, pointer = false};
IR_S8  :: IR_Operand_Type.{ kind = .Integer, size_in_bytes = 1, unsigned = false, pointer = false};
IR_S16 :: IR_Operand_Type.{ kind = .Integer, size_in_bytes = 2, unsigned = false, pointer = false};
IR_S32 :: IR_Operand_Type.{ kind = .Integer, size_in_bytes = 4, unsigned = false, pointer = false};
IR_S64 :: IR_Operand_Type.{ kind = .Integer, size_in_bytes = 8, unsigned = false, pointer = false};
IR_F32 :: IR_Operand_Type.{ kind = .Float,   size_in_bytes = 4, unsigned = false, pointer = false};
IR_F64 :: IR_Operand_Type.{ kind = .Float,   size_in_bytes = 8, unsigned = false, pointer = false};
IR_PTR :: IR_Operand_Type.{ kind = .Integer, size_in_bytes = 8, unsigned = true, pointer = true};

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


IR_External :: struct {
	name: string;
	params: [..]IR_Operand_Type;
	results: [..]IR_Operand_Type;
	variadic: bool;
}

IR_Function :: struct {
	name: string;
	params: [..]IR_Operand_Type;
	results: [..]IR_Operand_Type;
	instructions: [..]IR_Instruction;
	variadic: bool;
	builder: String_Builder;
	registers_needed: int;
}

IR :: struct {
	functions: [..]IR_Function;
	externals: [..]IR_External;
	globals: [..]IR_Global;
}

ir_emit :: (function: *IR_Function, comment: string) {
	append(*function.builder, tprint("; %\n", comment));
}

ir_emit :: (function: *IR_Function, ins: IR_Instruction, at := -1) {
	
	if at >= 0 {
		array_insert_at(*function.instructions, ins, at);
	} else {
		array_add(*function.instructions, ins);
	}

	append(*function.builder, tprint("% ", ins.op));

	to_string :: (operand: IR_Operand) -> string {
		if operand.kind == .None then return "";

		if operand.kind == {
			case .Label;
				return tprint("%, ", operand.label);
			case .Constant;
				return tprint("#%, ", operand.constant);
			case .Register;
				return tprint("v%, ", operand.register);
		}
	}
	append(*function.builder, to_string(ins.dst));
	append(*function.builder, to_string(ins.a));
	append(*function.builder, to_string(ins.b));
	append(*function.builder, "\n");
}


ir_alloca :: (dst: IR_Operand, size: u64) -> IR_Instruction {
	operand := IR_Operand.{ kind = .Constant, type = IR_U64, constant = size };
	instruction: IR_Instruction;
	instruction.op = .Alloca;
	instruction.dst = dst;
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
	assert(a.type.kind == b.type.kind);
	return .{ .Add, dst, a, b };
}

ir_sub :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return .{ .Sub, dst, a, b };
}

ir_mul :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	assert(a.type.kind == b.type.kind);
	assert(a.type.size_in_bytes == b.type.size_in_bytes);
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
	assert(cond.kind != .None);
	return .{ .Ifz, .{}, cond, .{ kind = .Label, label = name } };
}

ir_param :: (a: IR_Operand) -> IR_Instruction {
	return .{ .Param, .{}, a, .{} };
}

ir_load_param :: (dst: IR_Operand, a: IR_Operand) -> IR_Instruction {
	return .{ .LoadParam, dst, a, .{}};
}

ir_call :: (dst: IR_Operand, func: string, arg_count: u64) -> IR_Instruction {
	return .{ .Call, dst, .{ kind = .Label, label = func }, .{ kind = .Constant, type = IR_U64, constant = arg_count } };
}

ir_return :: (a: IR_Operand) -> IR_Instruction {
	return .{ .Return, .{}, a, .{} };
}

ir_memory_order :: (order: int) -> IR_Instruction {
	op: IR_Operator;
	if order == {
		case 0; op = .MemoryOrderRelaxed;
		case 1; op = .MemoryOrderConsume;
		case 2; op = .MemoryOrderAcquire;
		case 3; op = .MemoryOrderRelease;
		case 4; op = .MemoryOrderAcqRel;
		case 5; op = .MemoryOrderSeqCst;
		case;   op = .MemoryOrderSeqCst;
	}
	return .{ op, .{}, .{}, .{} };
}

ir_atomic_load :: (dst: IR_Operand, ptr: IR_Operand) -> IR_Instruction {
	return .{ .AtomicLoad, dst, ptr, .{} };
}

ir_atomic_store :: (ptr: IR_Operand, val: IR_Operand) -> IR_Instruction {
	return .{ .AtomicStore, .{}, ptr, val };
}

ir_atomic_fetch_add :: (dst: IR_Operand, ptr: IR_Operand, val: IR_Operand) -> IR_Instruction {
	return .{ .AtomicFetchAdd, dst, ptr, val };
}

ir_va_start :: (ap_addr: IR_Operand, last: IR_Operand) -> IR_Instruction {
	return .{ .VAStart, .{}, ap_addr, last };
}

ir_va_end :: (ap_addr: IR_Operand) -> IR_Instruction {
	return .{ .VAEnd, .{}, ap_addr, .{} };
}

ir_va_copy :: (dst_addr: IR_Operand, src_addr: IR_Operand) -> IR_Instruction {
	return .{ .VACopy, .{}, dst_addr, src_addr };
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

ir_emit_global :: (ir: *IR, name: string, bytes: []u8, alignment: int) { 
	array_add(*ir.globals, IR_Global.{ name, bytes, alignment});
}

ir_test :: () -> IR {
	ir: IR;

	f: IR_Function;
	f.name = "main";

	t0 := IR_Operand.{ kind = .Register, type = IR_S32, register = 0 };
	thirty_three := IR_Operand.{ kind = .Constant, type = IR_S32, constant = 33 };

	newline := IR_Operand.{ kind = .Constant, type = IR_S32, constant = 10 };


	ptr_t0 := IR_Operand.{ kind = .Register, type = IR_U64, register = 0 };

	add := ir_add(t0, thirty_three, thirty_three);
	ir_emit(*f, add);
	ir_emit(*f, ir_param(t0));
	ir_emit(*f, ir_call(.{}, "putchar", 1));

	ir_emit(*f, ir_param(newline));
	ir_emit(*f, ir_call(.{}, "putchar", 1));

	str := IR_Operand.{ kind = .Label, label = "test_string" };
	ir_emit(*f, ir_address(ptr_t0, str));
	ir_emit(*f, ir_param(ptr_t0));
	ir_emit(*f, ir_call(.{}, "printf", 1));
	ir_emit(*f, ir_return(t0));

	bytes: []u8;
	bytes.data = "test_string\0";
	bytes.count = 11;
	ir_emit_global(*ir, "test_string", bytes, 8);

	array_add(*ir.functions, f);

	return ir;
}