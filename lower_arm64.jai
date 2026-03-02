#import "Basic";
#import "File";

Emitter :: struct {
	ir: *IR;
	builder: String_Builder;

	register: int;

	param_index: int;
}

emit :: (emitter: *Emitter, fmt: string, args: ..Any) {
	to_append := tprint(fmt, ..args);
	append(*emitter.builder, to_append);
	append(*emitter.builder, "\n");
}

register_from_operand :: (op_type: IR_Operand_Type, reg: int) -> string {
	if op_type.kind == .Float {
		if op_type.size_in_bytes == {
			case 4;
				return tprint("s%", reg);
			case 8;
				return tprint("d%", reg);
		}
	} else if op_type.kind == .Integer {
		if op_type.size_in_bytes == {
			case 1; #through;
			case 2; #through;
			case 4;
				return tprint("w%", reg);
			case 8;
				return tprint("x%", reg);
		}
	}
	return "";
}

emit_load_into :: (emitter: *Emitter, op: IR_Operand, register_number: int) {
	if op.kind == .None then return;
	if op.kind == .Constant {
		if op.type.size_in_bytes <= 4 {
			low := op.constant & 0xFFFF;
			high := (op.constant >> 16) & 0xFFFF;
			emit(emitter, "movz w%, #%", register_number, low);
			emit(emitter, "movk w%, #%, lsl #16", register_number, high);
		} else {
			emit(emitter, "movz x%, #%, lsl #0",  register_number, op.constant & 0xFFFF);
			emit(emitter, "movk x%, #%, lsl #16", register_number, (op.constant >> 16) & 0xFFFF);
			emit(emitter, "movk x%, #%, lsl #32", register_number, (op.constant >> 32) & 0xFFFF);
			emit(emitter, "movk x%, #%, lsl #48", register_number, (op.constant >> 48) & 0xFFFF);
		}
	} else if op.kind == .Register {
		// Each value occupies 8 bytes regardless
		stack_slot := 8 * op.register;
		if op.register >= 4096 {
			emit(emitter, "mov x17, sp");
			emit(emitter, "add x17, x17, #%", stack_slot);	
			emit(emitter, "ldr %, [x17]", register_from_operand(op.type, register_number));
		} else {
			emit(emitter, "ldr %, [sp, #%]", register_from_operand(op.type, register_number), stack_slot);
		}
	}
}

emit_store_into :: (emitter: *Emitter, op: IR_Operand, register_number: int) {
	if op.kind == .None then return;
	register := register_from_operand(op.type, register_number);
	emit(emitter, "mov x17, #%", 8 * op.register);
	emit(emitter, "add x17, sp, x17");
	emit(emitter, "str %, [x17]", register);
}

stack_space_needed :: (function: *IR_Function) -> int {
	// We spill everything so the highest virtual register in a given
	// function marks the highest stack offset we need
	alloca_count := 0;
	highest_register := 0;
	for function.instructions {
		highest_register = max(highest_register, it.a.register);
		highest_register = max(highest_register, it.b.register);
		highest_register = max(highest_register, it.dst.register);

		// Alloca always only uses 1 operand (a) and it's always
		// an integer constant so we can just use it directly
		if it.op == .Alloca {
			alloca_count += it.a.constant.(int);
		}
	}

	return (highest_register + 1)*8 + alloca_count;
}

lower :: (emitter: *Emitter) {
	for function: emitter.ir.functions {
		emitter.register = 0;
		emit(emitter, "_%:", function.name);
		stack_space := (stack_space_needed(*function) + 15 ) & ~15;
		link_and_frame := 16;
		stack_space += link_and_frame;
		emit(emitter, "mov x9, #%", stack_space);
		emit(emitter, "sub sp, sp, x9");
		emit(emitter, "str x29, [sp, #%]", stack_space - link_and_frame);
		emit(emitter, "str x30, [sp, #%]", stack_space - link_and_frame + 8);
		emit(emitter, "mov x29, sp");
		for function.instructions { 
			// We just search backwards when doing a call and then
			// process the param instructions then
			if it.op == .Param then continue;

			is_binary :: (op: IR_Operator) -> bool {
				return op == .Add || op == .Sub || op == .Mul || op == .Div || op == .Mod
					|| op == .And || op == .Or  || op == .Xor || op == .Shl || op == .Shr
					|| op == .Lt  || op == .Le  || op == .Eq  || op == .Ne;
			}

			is_unary :: (op: IR_Operator) -> bool {
				return op == .Copy || op == .Cast || op == .Neg || op == .Not;
			}


			if is_binary(it.op) {
				emit_load_into(emitter, it.a, 10);
				emit_load_into(emitter, it.b, 11);
			}
			
			if is_unary(it.op) {
				emit_load_into(emitter, it.a, 10);
			}

			dst := register_from_operand(it.dst.type, 9);
			a := register_from_operand(it.a.type, 10);
			b := register_from_operand(it.b.type, 11);

			if it.op == {
				case .Address;
					if it.a.kind == .Label {
						emit(emitter, "adrp x9, _%@PAGE", it.a.label);
						emit(emitter, "add x9, x9, _%@PAGEOFF", it.a.label);
					}
					emit_store_into(emitter, it.dst, 9);
				case .Call;
					param_end := it_index;
					param_start := param_end - it.b.constant.(int);
					reg_int := 0;
					reg_float := 0;
					for param_index: param_start..param_end - 1 {
						param := function.instructions[param_index];
						if param.a.type.kind == .Float {
							emit_load_into(emitter, param.a, reg_float);
							reg_float += 1;
						} else {
							emit_load_into(emitter, param.a, reg_int);
							reg_int += 1;
						}
					}
					emit(emitter, "bl _%", it.a.label);
					if it.dst.kind != .None {
						if it.dst.type.kind == .Float {
							emit(emitter, "fmov %, %", register_from_operand(it.dst.type, 9), register_from_operand(it.dst.type, 0));
						} else {
							emit(emitter, "mov %, %", register_from_operand(it.dst.type, 9), register_from_operand(it.dst.type, 0));
						}
						emit_store_into(emitter, it.dst, 9);
					}
				case .Load;
					emit_load_into(emitter, it.a, 10);
					emit(emitter, "ldr %, [%]", dst, a);
					emit_store_into(emitter, it.dst, 9);
				case .Store;
					emit_load_into(emitter, it.a, 10);
					emit_load_into(emitter, it.b, 11);
					emit(emitter, "str %, [%]", b, a);
				case .Copy;
					emit(emitter, "mov %, %", dst, a);
					emit_store_into(emitter, it.dst, 9);
				case .Add;
					if it.dst.type.kind == .Float {
						emit(emitter, "fadd %, %, %", dst, a, b);
					} else {
						emit(emitter, "add %, %, %", dst, a, b);
					}
					emit_store_into(emitter, it.dst, 9);
				case .Sub;
					if it.dst.type.kind == .Float {
						emit(emitter, "fsub %, %, %", dst, a, b);
					} else {
						emit(emitter, "sub %, %, %", dst, a, b);
					}
					emit_store_into(emitter, it.dst, 9);
				case .Mul;
					if it.dst.type.kind == .Float {
						emit(emitter, "fmul %, %, %", dst, a, b);
					} else {
						emit(emitter, "mul %, %, %", dst, a, b);
					}
					emit_store_into(emitter, it.dst, 9);
				case .Div;
					if it.dst.type.kind == .Float {
						emit(emitter, "fdiv %, %, %", dst, a, b);
					} else if it.dst.type.unsigned {
						emit(emitter, "udiv %, %, %", dst, a, b);
					} else {
						emit(emitter, "sdiv %, %, %", dst, a, b);
					}
					emit_store_into(emitter, it.dst, 9);
				case .Label;
					emit(emitter, "%:", it.a.label);
				case .Return;
					emit_load_into(emitter, it.a, 10);
					if it.a.type.kind == .Float {
						emit(emitter, "fmov %, %", register_from_operand(it.a.type, 0), a);
					} else if it.a.kind != .None {
						emit(emitter, "mov %, %", register_from_operand(it.a.type, 0), a);
					}
					emit(emitter, "ldr x29, [sp, #%]", stack_space - link_and_frame);
					emit(emitter, "ldr x30, [sp, #%]", stack_space - link_and_frame + 8);
					emit(emitter, "mov x9, #%", stack_space);
					emit(emitter, "add sp, sp, x9");
					emit(emitter, "ret");
			}
		}
	}

	for emitter.ir.globals {
		emit(emitter, "_%:", it.name);
		for byte: it.bytes {
			emit(emitter, ".byte %", byte);
		}
	}

	for function: emitter.ir.functions {
		emit(emitter, ".globl _%", function.name);
	}
}


lower_to_arm64e :: (ir: *IR) {
	emitter: Emitter;

	emitter.ir = ir;


	lower(*emitter);

	write_entire_file("ir.s", builder_to_string(*emitter.builder));
}