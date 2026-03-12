#import "Basic";
#import "File";

Function_Info :: struct {
	is_alloca: []bool;
	alloca_offsets: []int;
	vreg_offsets: []int;
	alloca_size: int;
	stack_space: int;
}

Emitter :: struct {
	ir: *IR;
	builder: String_Builder;
}

emit :: (emitter: *Emitter, fmt: string, args: ..Any) {
	to_append := tprint(fmt, ..args);
	append(*emitter.builder, to_append);
	append(*emitter.builder, "\n");
}

scratch_name :: (type: IR_Operand_Type, scratch: int) -> string {
	if type.kind == .Float {
		if type.size_in_bytes == 4 return tprint("s%", scratch);
		return tprint("d%", scratch);
	}
	if type.size_in_bytes <= 4 return tprint("w%", scratch);
	return tprint("x%", scratch);
}

value_from_operand :: (emitter: *Emitter, op: IR_Operand, info: Function_Info, scratch: int) -> string {
	if op.kind == .None return "";

	if op.kind == .Constant {
		if op.type.size_in_bytes <= 4 {
			emit(emitter, "movz w%, #%", scratch, op.constant & 0xFFFF);
			high := (op.constant >> 16) & 0xFFFF;
			if high != 0 emit(emitter, "movk w%, #%, lsl #16", scratch, high);
		} else {
			emit(emitter, "movz x%, #%, lsl #0",  scratch, op.constant & 0xFFFF);
			w1 := (op.constant >> 16) & 0xFFFF;
			w2 := (op.constant >> 32) & 0xFFFF;
			w3 := (op.constant >> 48) & 0xFFFF;
			if w1 != 0 emit(emitter, "movk x%, #%, lsl #16", scratch, w1);
			if w2 != 0 emit(emitter, "movk x%, #%, lsl #32", scratch, w2);
			if w3 != 0 emit(emitter, "movk x%, #%, lsl #48", scratch, w3);
		}
		dst := scratch_name(op.type, scratch);
		if op.type.kind == .Float {
			emit(emitter, "fmov %, x%", dst, scratch);
		}
		return dst;
	}

	if info.is_alloca[op.register] {
		offset := info.alloca_offsets[op.register];
		emit(emitter, "add x%, sp, #%", scratch, offset);
		return tprint("x%", scratch);
	} else if op.kind == .Register {
		offset := info.vreg_offsets[op.register];
		name := scratch_name(op.type, scratch);
		emit(emitter, "ldr %, [sp, #%]", name, offset);
		return name;
	}

	assert(false, "How the frick");
	return "";
}

address_from_operand :: (emitter: *Emitter, op: IR_Operand, info: Function_Info, scratch: int) -> string {
	if op.kind == .None return "";

	if info.is_alloca[op.register] {
		offset := info.alloca_offsets[op.register];
		emit(emitter, "add x%, sp, #%", scratch, offset);
		return tprint("x%", scratch);
	} else {
		offset := info.vreg_offsets[op.register];
		name := scratch_name(op.type, scratch);
		emit(emitter, "ldr %, [sp, #%]", name, offset);
		return name;
	}

	return "";
}

// Store a value from scratch register back to the vreg's spill slot.
// Only for value vregs (not allocas — those are addresses, not stored back).
store_result :: (emitter: *Emitter, op: IR_Operand, info: Function_Info, scratch: int) {
	if op.kind != .Register return;
	if info.is_alloca[op.register] return;
	name := scratch_name(op.type, scratch);
	offset := info.vreg_offsets[op.register];
	emit(emitter, "str %, [sp, #%]", name, offset);
}

register_name :: (op: IR_Operand, reg: int) -> string {
	if op.type.kind == .Float {
		if op.type.size_in_bytes == 4 return tprint("s%", reg);
		return tprint("d%", reg);
	}
	if op.type.size_in_bytes <= 4 return tprint("w%", reg);
	return tprint("x%", reg);
}

lower :: (emitter: *Emitter) {

	for function: emitter.ir.functions {
		emit(emitter, "_%:", function.name);
		
		info: Function_Info;
		info.is_alloca = NewArray(function.registers_needed, bool);
		info.alloca_offsets = NewArray(function.registers_needed, int);
		info.vreg_offsets = NewArray(function.registers_needed, int);

		alloca_size := 0;
		for function.instructions {
			if it.op == .Alloca {
				info.is_alloca[it.dst.register] = true;
				info.alloca_offsets[it.dst.register] = alloca_size;
				alloca_size += it.a.constant.(int);
			}
		}
		alloca_size = (alloca_size + 15) & ~15;
		info.alloca_size = alloca_size;

		for 0..function.registers_needed-1 {
			info.vreg_offsets[it] = alloca_size + it * 8;
		}

		vreg_spill_size := function.registers_needed * 8;
		link_and_frame := 16;
		stack_space := (alloca_size + vreg_spill_size + link_and_frame + 15) & ~15;
		info.stack_space = stack_space;

		// Prologue
		emit(emitter, "sub sp, sp, #%", stack_space);
		emit(emitter, "str x29, [sp, #%]", stack_space - link_and_frame);
		emit(emitter, "str x30, [sp, #%]", stack_space - link_and_frame + 8);
		emit(emitter, "add x29, sp, #%", stack_space - link_and_frame);


		param_alloca_index := 0;
		reg_int := 0;
		reg_float := 0;
		for i: 0..function.params.count-1 {
			alloca_inst := function.instructions[i];
			offset := info.alloca_offsets[alloca_inst.dst.register];
			if function.params[i].kind == .Float {
				emit(emitter, "str d%, [sp, #%]", reg_float, offset);
				reg_float += 1;
			} else {
				emit(emitter, "str x%, [sp, #%]", reg_int, offset);
				reg_int += 1;
			}
		}

		// Emit instructions
		// Scratch registers: x9/w9 for dst, x10/w10 for a, x11/w11 for b
		for function.instructions {
			if it.op == .Param then continue;
			if it.op == .Alloca then continue;

			if it.op == {
				case .Address;
					dst := scratch_name(it.dst.type, 9);
					if it.a.kind == .Label {
						emit(emitter, "adrp x9, _%@PAGE", it.a.label);
						emit(emitter, "add x9, x9, _%@PAGEOFF", it.a.label);
					} else if it.a.kind == .Register {
						// Address of an alloca vreg
						offset := info.alloca_offsets[it.a.register];
						emit(emitter, "add x9, sp, #%", offset);
					}
					store_result(emitter, it.dst, info, 9);

				case .Call;
					param_count := it.b.constant.(int);
					param_start := it_index-1;
					param_end := param_start - param_count;
					reg_int := 0;
					reg_float := 0;
					param_index := 0;
					for 0..param_count-1 {
						param := function.instructions[param_start - param_index];
						// Materialise param value into x12/w12 as temp scratch
						src := value_from_operand(emitter, param.a, info, 12);
						if param.a.type.kind == .Float {
							emit(emitter, "fmov %, %", register_name(param.a, reg_float), src);
							reg_float += 1;
						} else {
							reg_dst := register_name(param.a, reg_int);
							emit(emitter, "mov %, %", reg_dst, src);
							reg_int += 1;
						}
						param_index += 1;
					}

					// Assume any more Param instructions are now variadic
					variadic_count := 0;
					while function.instructions[param_start - param_index].op == .Param {
						param := function.instructions[param_start - param_index];
						src := value_from_operand(emitter, param.a, info, 12);
						emit(emitter, "str %, [sp, #%]", src, variadic_count*8);
						param_index += 1;
						variadic_count += 1;
					}

					emit(emitter, "bl _%", it.a.label);
					if it.dst.kind != .None {
						// Move return value from x0/d0 to scratch, then store
						dst := scratch_name(it.dst.type, 9);
						if it.dst.type.kind == .Float {
							emit(emitter, "fmov %, d0", dst);
						} else {
							emit(emitter, "mov %, %", dst, register_name(it.dst, 0));
						}
						store_result(emitter, it.dst, info, 9);
					}

				case .Load;
					a := address_from_operand(emitter, it.a, info, 10);
					dst := scratch_name(it.dst.type, 9);
					emit(emitter, "ldr %, [%]", dst, a);
					store_result(emitter, it.dst, info, 9);

				case .Store;
					a := address_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					emit(emitter, "str %, [%]", b, a);

				case .Copy;
					a := value_from_operand(emitter, it.a, info, 10);
					dst := scratch_name(it.dst.type, 9);
					if it.dst.type.kind == .Float {
						emit(emitter, "fmov %, %", dst, a);
					} else {
						emit(emitter, "mov %, %", dst, a);
					}
					store_result(emitter, it.dst, info, 9);
				
				case .Or;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.a.type.kind == .Float {
						emit(emitter, "fcmp %, %", a, b);
						emit(emitter, "cset %, ls", dst);
					} else {
						emit(emitter, "cmp %, %", a, b);
						if it.a.type.unsigned {
							emit(emitter, "cset %, ls", dst);
						} else {
							emit(emitter, "cset %, le", dst);
						}
					}
					store_result(emitter, it.dst, info, 9);

				case .Lt;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.a.type.kind == .Float {
						emit(emitter, "fcmp %, %", a, b);
						emit(emitter, "cset %, mi", dst);
					} else {
						emit(emitter, "cmp %, %", a, b);
						if it.a.type.unsigned {
							emit(emitter, "cset %, lo", dst);
						} else {
							emit(emitter, "cset %, lt", dst);
						}
					}
					store_result(emitter, it.dst, info, 9);

				case .Le;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.a.type.kind == .Float {
						emit(emitter, "fcmp %, %", a, b);
						emit(emitter, "cset %, ls", dst);
					} else {
						emit(emitter, "cmp %, %", a, b);
						if it.a.type.unsigned {
							emit(emitter, "cset %, ls", dst);
						} else {
							emit(emitter, "cset %, le", dst);
						}
					}
					store_result(emitter, it.dst, info, 9);

				case .Eq;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.a.type.kind == .Float {
						emit(emitter, "fcmp %, %", a, b);
					} else {
						emit(emitter, "cmp %, %", a, b);
					}
					emit(emitter, "cset %, eq", dst);
					store_result(emitter, it.dst, info, 9);

				case .Ne;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.a.type.kind == .Float {
						emit(emitter, "fcmp %, %", a, b);
					} else {
						emit(emitter, "cmp %, %", a, b);
					}
					emit(emitter, "cset %, ne", dst);
					store_result(emitter, it.dst, info, 9);

				case .Add;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.dst.type.kind == .Float {
						emit(emitter, "fadd %, %, %", dst, a, b);
					} else {
						emit(emitter, "add %, %, %", dst, a, b);
					}
					store_result(emitter, it.dst, info, 9);

				case .Sub;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.dst.type.kind == .Float {
						emit(emitter, "fsub %, %, %", dst, a, b);
					} else {
						emit(emitter, "sub %, %, %", dst, a, b);
					}
					store_result(emitter, it.dst, info, 9);

				case .Mul;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.dst.type.kind == .Float {
						emit(emitter, "fmul %, %, %", dst, a, b);
					} else {
						emit(emitter, "mul %, %, %", dst, a, b);
					}
					store_result(emitter, it.dst, info, 9);

				case .Div;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.dst.type.kind == .Float {
						emit(emitter, "fdiv %, %, %", dst, a, b);
					} else if it.dst.type.unsigned {
						emit(emitter, "udiv %, %, %", dst, a, b);
					} else {
						emit(emitter, "sdiv %, %, %", dst, a, b);
					}
					store_result(emitter, it.dst, info, 9);

				case .Mod;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.dst.type.unsigned {
						emit(emitter, "udiv %, %, %", dst, a, b);
					} else {
						emit(emitter, "sdiv %, %, %", dst, a, b);
					}
					emit(emitter, "msub %, %, %, %", dst, dst, b, a);
					store_result(emitter, it.dst, info, 9);

				case .Neg;
					a := value_from_operand(emitter, it.a, info, 10);
					dst := scratch_name(it.dst.type, 9);
					if it.dst.type.kind == .Float {
						emit(emitter, "fneg %, %", dst, a);
					} else {
						emit(emitter, "neg %, %", dst, a);
					}
					store_result(emitter, it.dst, info, 9);

				case .Not;
					a := value_from_operand(emitter, it.a, info, 10);
					dst := scratch_name(it.dst.type, 9);
					emit(emitter, "mvn %, %", dst, a);
					store_result(emitter, it.dst, info, 9);

				case .Label;
					emit(emitter, "%:", it.a.label);

				case .Goto;
					emit(emitter, "b %", it.a.label);

				case .Ifz;
					a := value_from_operand(emitter, it.a, info, 10);
					emit(emitter, "cbz %, %", a, it.b.label);
				
				case .If;
					a := value_from_operand(emitter, it.a, info, 10);
					emit(emitter, "cbnz %, %", a, it.b.label);

				case .Return;
					if it.a.kind != .None {
						a := value_from_operand(emitter, it.a, info, 10);
						if it.a.type.kind == .Float {
							emit(emitter, "fmov d0, %", a);
						} else {
							emit(emitter, "mov %, %", register_name(it.a, 0), a);
						}
					}
					// Epilogue
					emit(emitter, "ldr x29, [sp, #%]", stack_space - link_and_frame);
					emit(emitter, "ldr x30, [sp, #%]", stack_space - link_and_frame + 8);
					emit(emitter, "add sp, sp, #%", stack_space);
					emit(emitter, "ret");

				case .Cast;
					a := value_from_operand(emitter, it.a, info, 10);
					dst := scratch_name(it.dst.type, 9);
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
						} else {
							emit(emitter, "mov %, %", dst, a);
						}
					} else if dst_type.kind == .Float && src_type.kind == .Float {
						if dst_type.size_in_bytes != src_type.size_in_bytes {
							emit(emitter, "fcvt %, %", dst, a);
						} else {
							emit(emitter, "fmov %, %", dst, a);
						}
					}
					store_result(emitter, it.dst, info, 9);
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

lower_to_arm64e :: (ir: *IR) -> Emitter {
	emitter: Emitter;

	emitter.ir = ir;

	lower(*emitter);

	return emitter;
}
