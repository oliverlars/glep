
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

ir_add :: (dst: IR_Operand, a: IR_Operand, b: IR_Operand) -> IR_Instruction {
	return IR_Instruction.{ .Add, dst, a, b };
}

ir_alloca :: (size: u64) -> IR_Instruction {
	operand := IR_Operand.{ kind = .Constant, type = IR_U64, constant = size };
	instruction: IR_Instruction;
	instruction.op = .Alloca;
	instruction.a = operand;
	return instruction;
}

compile :: (ir: *IR, tu: *Node_Translation_Unit) {

}