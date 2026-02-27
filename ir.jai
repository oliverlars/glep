
Operator :: enum {
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
	Return;
}

Instruction :: struct {
	op: Operator;

	dst: Operand;
	a:   Operand;
	b:   Operand;
}

Operand_Kind :: enum {
	None;
	Constant;
	Label;
	Register;
}

Operand_Type :: struct {
	kind: enum {
		Integer;
		Float;
	};
	size_in_bytes: int;
	unsigned: bool;
}

Operand :: struct {
	kind: Operand_Kind;
	type: Operand_Type;
	constant: u64;
	register: int;
	label: string;
}


Global :: struct {
	name: string;
	bytes: []u8;
	alignment: int;
}

Function :: struct {
	name: string;
	params: [..]Operand_Type;
	instructions: [..]Instruction;
}

IR :: struct {
	functions: [..]Function;
	globals: [..]Global;
}
