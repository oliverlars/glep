#import "Basic";
#import "File";

#import "Sort";


Live_Range :: struct {
	register: int;
	started: bool;
	start: int;
	end: int;
}



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

resolve_register :: (emitter: *Emitter, op: IR_Operand, scratch: int) -> string {
	reg := op.register;
	if op.kind == .Constant {
		emit_constant(emitter, op, reg);
	}

	if op.type.kind == .Float {
		if op.type.size_in_bytes == {
			case 4;
				return tprint("s%", reg);
			case 8;
				return tprint("d%", reg);
		}
	} else if op.type.kind == .Integer {
		if op.type.size_in_bytes == {
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

register_name :: (op: IR_Operand, reg: int) -> string {
	if op.type.kind == .Float {
		if op.type.size_in_bytes == {
			case 4;
				return tprint("s%", reg);
			case 8;
				return tprint("d%", reg);
		}
	} else if op.type.kind == .Integer {
		if op.type.size_in_bytes == {
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


emit_constant :: (emitter: *Emitter, op: IR_Operand, register_number: int) {
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
	}
}

/*



if op.kind == .Register {
		// Each value occupies 8 bytes regardless
		stack_slot := 8 * op.register;
		if op.register >= 4096 {
			emit(emitter, "mov x17, sp");
			emit(emitter, "add x17, x17, #%", stack_slot);	
			emit(emitter, "ldr %, [x17]", resolve_register(op, register_number));
		} else {
			emit(emitter, "ldr %, [sp, #%]", resolve_register(op, register_number), stack_slot);
		}
	}



*/

emit_store_into :: (emitter: *Emitter, op: IR_Operand, register_number: int) {
	if op.kind == .None then return;
	register := resolve_register(emitter, op, register_number);
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
	callee_saved_registers := 10*8;
	return (highest_register + 1)*8 + alloca_count + callee_saved_registers;
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
		for 1..10 {
			emit(emitter, "str x%, [sp, #%]", 19 + it - 1, stack_space - link_and_frame - 8 - (it-1)*8);
		}

		for function.instructions {
			// We just search backwards when doing a call and then
			// process the param instructions then
			if it.op == .Param then continue;

			if it.op == .SpillLoad {
				dst := resolve_register(emitter, it.dst, it.dst.register);
				emit(emitter, "mov x17, #%", it.a.constant);
				emit(emitter, "add x17, sp, x17");
				emit(emitter, "ldr %, [x17]", dst);
				continue;
			}
			
			if it.op == .SpillStore {
				dst := resolve_register(emitter, it.dst, it.dst.register);
				emit(emitter, "mov x17, #%", it.a.constant);
				emit(emitter, "add x17, sp, x17");
				emit(emitter, "str %, [x17]", dst);
				continue;
			}

			dst := resolve_register(emitter, it.dst, 9);
			a := resolve_register(emitter, it.a, 10);
			b := resolve_register(emitter, it.b, 11);

			if it.op == {
				case .Address;
					if it.a.kind == .Label {
						emit(emitter, "adrp %, _%@PAGE", dst, it.a.label);
						emit(emitter, "add %, %, _%@PAGEOFF", dst, dst, it.a.label);
					} else if it.a.kind == .Register {
						emit(emitter, "mov %, sp", dst);
						emit(emitter, "add %, %, #%", dst, dst, it.a.register * 8);
					}
				case .Call;
					param_end := it_index;
					param_start := param_end - it.b.constant.(int);
					reg_int := 0;
					reg_float := 0;
					for param_index: param_start..param_end - 1 {
						param := function.instructions[param_index];
						reg_src := resolve_register(emitter, param.a, param.a.register);
						if param.a.type.kind == .Float {
							reg_dst := register_name(param.a, reg_float);
							emit(emitter, "fmov %, %", reg_dst, reg_src);
							reg_float += 1;
						} else {
							reg_dst := register_name(param.a, reg_int);
							emit(emitter, "mov %, %", reg_dst, reg_src);
							reg_int += 1;
						}
					}
					emit(emitter, "bl _%", it.a.label);
					if it.dst.kind != .None {
						if it.dst.type.kind == .Float {
							emit(emitter, "fmov %, %", dst, resolve_register(emitter, it.dst, 0));
						} else {
							emit(emitter, "mov %, %", dst, resolve_register(emitter, it.dst, 0));
						}
					}
				case .Load;
					emit(emitter, "ldr %, [%]", dst, a);
				case .Store;
					emit(emitter, "str %, [%]", b, a);
				case .Copy;
					emit(emitter, "mov %, %", dst, a);
				case .Add;
					if it.dst.type.kind == .Float {
						emit(emitter, "fadd %, %, %", dst, a, b);
					} else {
						emit(emitter, "add %, %, %", dst, a, b);
					}
				case .Sub;
					if it.dst.type.kind == .Float {
						emit(emitter, "fsub %, %, %", dst, a, b);
					} else {
						emit(emitter, "sub %, %, %", dst, a, b);
					}
				case .Mul;
					if it.dst.type.kind == .Float {
						emit(emitter, "fmul %, %, %", dst, a, b);
					} else {
						emit(emitter, "mul %, %, %", dst, a, b);
					}
				case .Div;
					if it.dst.type.kind == .Float {
						emit(emitter, "fdiv %, %, %", dst, a, b);
					} else if it.dst.type.unsigned {
						emit(emitter, "udiv %, %, %", dst, a, b);
					} else {
						emit(emitter, "sdiv %, %, %", dst, a, b);
					}
				case .Label;
					emit(emitter, "%:", it.a.label);
				case .Return;
					if it.a.type.kind == .Float {
						emit(emitter, "fmov %, %", resolve_register(emitter, it.a, 0), a);
					} else if it.a.kind != .None {
						emit(emitter, "mov %, %", resolve_register(emitter, it.a, 0), a);
					}
					emit(emitter, "ldr x29, [sp, #%]", stack_space - link_and_frame);
					emit(emitter, "ldr x30, [sp, #%]", stack_space - link_and_frame + 8);
					emit(emitter, "mov x9, #%", stack_space);
					for 1..10 {
						emit(emitter, "ldr x%, [sp, #%]", 19 + it - 1, stack_space - link_and_frame - 8 - (it-1)*8);
					}
					emit(emitter, "add sp, sp, x9");
					emit(emitter, "ret");
				case .Cast;
					dst_type := it.dst.type;
					src_type := it.a.type;
					if dst_type.kind == .Float && src_type.kind == .Integer {
						if src_type.unsigned {
							emit(emitter, "ucvtf %, %", dst, a);
						} else {
							emit(emitter, "scvtf %, %", dst, a);
						}
					} else if dst_type.kind == .Integer && src_type.kind == .Float {
						if dst_type.unsigned {
							emit(emitter, "fcvtzu %, %", dst, a);
						} else {
							emit(emitter, "fcvtzs %, %", dst, a);
						}
					} else if dst_type.kind == .Integer && src_type.kind == .Integer {
						if dst_type.size_in_bytes > src_type.size_in_bytes {
							if src_type.unsigned {
								emit(emitter, "mov %, %", dst, a);
							} else if src_type.size_in_bytes == {
								case 1;
									emit(emitter, "sxtb %, %", dst, a);
								case 2;
									emit(emitter, "sxth %, %", dst, a);
								case 4;
									emit(emitter, "sxtw %, %", dst, a);
							}
						}
					} else if dst_type.kind == .Float && src_type.kind == .Float {
						if dst_type.size_in_bytes != src_type.size_in_bytes {
							emit(emitter, "fcvt %, %", dst, a);
						}
					} 
					emit(emitter, "mov %, %", dst, a);
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
		for function.instructions {
			print("% % % %\n", it.op, it.dst, it.a, it.b);
		}
	}

}



add_live_range :: (intervals: []Live_Range, operand: IR_Operand, at: int) {
	if operand.kind == .Register {
		if intervals[operand.register].started {
			intervals[operand.register].end = at;
		} else {
			intervals[operand.register].start = at;
			intervals[operand.register].end = at;
			intervals[operand.register].started = true;
			intervals[operand.register].register = operand.register;
		}
	}
}


register_allocation :: (ir: *IR) {
	
	for *function: ir.functions {

		intervals := NewArray(function.registers_needed, Live_Range);
		virtual_to_physical := NewArray(function.registers_needed, int);

		for function.instructions {
			add_live_range(intervals, it.dst, it_index);
			add_live_range(intervals, it.a, it_index);
			add_live_range(intervals, it.b, it_index);
		}

		for intervals {
			if !it.started then remove it;
		}

		for intervals {
			print("Live interval: %\n", it);
		}

		// x19-x28
		Active_Range :: struct {
			interval: Live_Range;
			active: bool;
		}
		
		quick_sort(intervals, x => x.start);
		active_ranges: [10]Active_Range;

		for interval: intervals {
			for 0..active_ranges.count-1 {
				if active_ranges[it].interval.end < interval.start {
					active_ranges[it].active = false;
				}
			}

			for 0..active_ranges.count-1 {
				if !active_ranges[it].active {
					active_ranges[it].active = true;
					active_ranges[it].interval = interval;
					virtual_to_physical[interval.register] = 19 + it;
					break;
				}
			}
		}
		
		
		instructions: [..]IR_Instruction;
		for function.instructions {
			instruction := it;

			if it.a.kind == .Register &&
			virtual_to_physical[it.a.register] >= 19 {
				instruction.a.register = virtual_to_physical[it.a.register];
			} else if it.a.kind == .Register {
				array_add(*instructions, ir_spill_load(ir_register(10, it.a.type), ir_constant(it.a.register.(u64)*8, IR_S32)));
				instruction.a.register = 10;
			}

			if it.b.kind == .Register &&
			virtual_to_physical[it.b.register] >= 19 {
				instruction.b.register = virtual_to_physical[it.b.register];
			} else if it.b.kind == .Register {
				array_add(*instructions, ir_spill_load(ir_register(11, it.b.type), ir_constant(it.b.register.(u64)*8, IR_S32)));
				instruction.b.register = 11;
			}

			if it.dst.kind == .Register &&
			virtual_to_physical[it.dst.register] >= 19 {
				instruction.dst.register = virtual_to_physical[it.dst.register];
			}

			if it.dst.kind == .Constant {
				instruction.dst.register = 9;
			}

			if it.a.kind == .Constant {
				instruction.a.register = 10;
			}

			if it.b.kind == .Constant {
				instruction.b.register = 11;
			}

			array_add(*instructions, instruction);

			if it.dst.kind == .Register &&
			virtual_to_physical[it.dst.register] < 19 {
				array_add(*instructions, ir_spill_store(ir_register(9, it.dst.type), ir_constant(it.dst.register.(u64)*8, IR_S32)));
			}
		}
		function.instructions = instructions;
	}
}


lower_to_arm64e :: (ir: *IR) -> Emitter {
	emitter: Emitter;

	emitter.ir = ir;

	register_allocation(emitter.ir);

	lower(*emitter);

	return emitter;
}