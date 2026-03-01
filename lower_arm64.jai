#import "Basic";
#import "File";

Emitter :: struct {
	ir: *IR;
	builder: String_Builder;

	register: int;
}

emit :: (emitter: *Emitter, fmt: string, args: ..Any) {
	to_append := tprint(fmt, ..args);
	append(*emitter.builder, to_append);
	append(*emitter.builder, "\n");
}

register_number :: (emitter: *Emitter) -> int {
	emitter.register = (emitter.register + 1) % 3;
	return emitter.register + 9;
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

emit_load_into :: (emitter: *Emitter, op: IR_Operand) {
	reg := register_number(emitter);
	if op.kind == .Constant {
		if op.type.size_in_bytes <= 4 {
			low := op.constant & 0xFFFF;
			high := (op.constant >> 16) & 0xFFFF;
			emit(emitter, "movz w%, #%", reg, low);
			emit(emitter, "movk w%, #%, lsl #16", reg, high);
		} else {
			emit(emitter, "movz x%, #%, lsl #0",  reg, op.constant & 0xFFFF);
			emit(emitter, "movk x%, #%, lsl #16", reg, (op.constant >> 16) & 0xFFFF);
			emit(emitter, "movk x%, #%, lsl #32", reg, (op.constant >> 32) & 0xFFFF);
			emit(emitter, "movk x%, #%, lsl #48", reg, (op.constant >> 48) & 0xFFFF);
		}
	} else if op.kind == .Register {
		// Each value occupies 8 bytes regardless
		stack_slot := 8 * op.register;
		if op.register >= 4096 {
			emit(emitter, "mov x17, sp");
			emit(emitter, "add x17, x17, #%", stack_slot);	
			emit(emitter, "ldr %, [x17]", register_from_operand(op.type, reg));
		} else {
			emit(emitter, "ldr %, [sp, #%]", register_from_operand(op.type, reg), stack_slot);
		}
	}
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

	return highest_register*8 + alloca_count;
}

lower :: (emitter: *Emitter) {
	for function: emitter.ir.functions {
		emit(emitter, "_%:", function.name);
		stack_space := (stack_space_needed(*function) + 15 ) & ~15;
		link_and_frame := 16; // two 8 byte values
		stack_space += link_and_frame;
		emit(emitter, "mov x9, #%", stack_space);
		emit(emitter, "sub sp, sp, x9");
		emit(emitter, "str x30, [sp, #%]", stack_space - link_and_frame);
		emit(emitter, "str x29, [sp, #%]", stack_space - link_and_frame + 8);
		emit(emitter, "mov x29, sp");
		for function.instructions{
			if it.op == {
				case .Load;
					emit_load_into(emitter, it.a);
				case .Store;
				case .Copy;
				case .Add;
					emit_load_into(emitter, it.a);
					emit_load_into(emitter, it.b);
					emit(emitter, "add x9, x9, x10");
				case .Return;
					emit(emitter, "ldr x30, [sp, #%]", stack_space - link_and_frame);
					emit(emitter, "ldr x29, [sp, #%]", stack_space - link_and_frame + 8);
					emit(emitter, "mov x9, #%", stack_space);
					emit(emitter, "add sp, sp, x9");
					emit(emitter, "ret");
			}
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