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

sp_offset :: (emitter: *Emitter, scratch: int, offset: int) -> string {
	reg := tprint("x%", scratch);
	if offset <= 4095 {
		emit(emitter, "add %, sp, #%", reg, offset);
	} else {
		v := offset.(u64);
		emit(emitter, "movz %, #%, lsl #0", reg, v & 0xFFFF);
		if v > 0xFFFF     emit(emitter, "movk %, #%, lsl #16", reg, (v >> 16) & 0xFFFF);
		if v > 0xFFFFFFFF emit(emitter, "movk %, #%, lsl #32", reg, (v >> 32) & 0xFFFF);
		if v > 0xFFFFFFFFFFFF emit(emitter, "movk %, #%, lsl #48", reg, (v >> 48) & 0xFFFF);
		emit(emitter, "add %, sp, %", reg, reg);
	}
	return reg;
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
		dst := scratch_name(op.type, scratch);
		if op.type.size_in_bytes <= 4 {
			emit(emitter, "movz w%, #%", scratch, op.constant & 0xFFFF);
			high := (op.constant >> 16) & 0xFFFF;
			emit(emitter, "movk w%, #%, lsl #16", scratch, high);
			if op.type.kind == .Float {
				emit(emitter, "fmov %, w%", dst, scratch);
			}
		} else {
			emit(emitter, "movz x%, #%, lsl #0",  scratch, op.constant & 0xFFFF);
			w1 := (op.constant >> 16) & 0xFFFF;
			w2 := (op.constant >> 32) & 0xFFFF;
			w3 := (op.constant >> 48) & 0xFFFF;
			emit(emitter, "movk x%, #%, lsl #16", scratch, w1);
			emit(emitter, "movk x%, #%, lsl #32", scratch, w2);
			emit(emitter, "movk x%, #%, lsl #48", scratch, w3);
			if op.type.kind == .Float {
				emit(emitter, "fmov %, x%", dst, scratch);
			}
		}

		return dst;
	}

	if info.is_alloca[op.register] {
		offset := info.alloca_offsets[op.register];
		return sp_offset(emitter, scratch, offset);
	} else if op.kind == .Register {
		offset := info.vreg_offsets[op.register];
		base := sp_offset(emitter, scratch, offset);
		name := scratch_name(op.type, scratch);
		if op.type.size_in_bytes == 1 {
			emit(emitter, "ldrb %, [%]", name, base);
		} else if op.type.size_in_bytes == 2 {
			emit(emitter, "ldrh %, [%]", name, base);
		} else if op.type.size_in_bytes >= 4 {
			emit(emitter, "ldr %, [%]", name, base);
		}
		return name;
	} else if op.kind == .Label {
		emit(emitter, "adrp x%, _%@PAGE", scratch, op.label);
		emit(emitter, "add x%, x%, _%@PAGEOFF", scratch, scratch, op.label);
		name := scratch_name(op.type, scratch);
		return tprint("x%", scratch);
	}

	assert(false, "How the frick");
	return "";
}

// Store a value from scratch register back to the vreg's spill slot.
// Only for value vregs (not allocas — those are addresses, not stored back).
store_result :: (emitter: *Emitter, op: IR_Operand, info: Function_Info, scratch: int) {
	if op.kind != .Register return;
	if info.is_alloca[op.register] return;
	name := scratch_name(op.type, scratch);
	offset := info.vreg_offsets[op.register];
	base := sp_offset(emitter, 12, offset);
	emit(emitter, "str %, [%]", name, base);
}

register_name :: (op: IR_Operand, reg: int) -> string {
	if op.type.kind == .Float {
		if op.type.size_in_bytes == 4 return tprint("s%", reg);
		return tprint("d%", reg);
	}
	if op.type.size_in_bytes <= 4 return tprint("w%", reg);
	return tprint("x%", reg);
}

find_function_results :: (emitter: *Emitter, name: string) -> []IR_Operand_Type {
	for * emitter.ir.functions {
		if it.name == name return it.results;
	}
	return .{};
}

lower_binary :: (emitter: *Emitter, it: IR_Instruction, info: Function_Info, op: string) {
	a := value_from_operand(emitter, it.a, info, 10);
	b := value_from_operand(emitter, it.b, info, 11);
	dst := scratch_name(it.dst.type, 9);
	if it.dst.type.kind == .Float {
		emit(emitter, "f% %, %, %", op, dst, a, b);
	} else {
		emit(emitter, "% %, %, %", op, dst, a, b);
	}
	store_result(emitter, it.dst, info, 9);
}

lower_compare :: (emitter: *Emitter, it: IR_Instruction, info: Function_Info, op: string) {
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
}

lower :: (emitter: *Emitter) {

	emit(emitter, ".text");
	emit(emitter, ".p2align 2");

	for function: emitter.ir.functions {
		emit(emitter, "_%:", function.name);
		
		info: Function_Info;
		info.is_alloca = NewArray(function.registers_needed, bool);
		info.alloca_offsets = NewArray(function.registers_needed, int);
		info.vreg_offsets = NewArray(function.registers_needed, int);

		number_of_params := 0;
		number_of_args := 0;
		for function.instructions {
			if it.op == .Call {
				number_of_params += it.b.constant.(int);
			} else if it.op == .Param {
				number_of_args += 1;
			}
		}

		number_of_variadics := number_of_args - number_of_params;
		assert(number_of_variadics >= 0);

		alloca_size := number_of_variadics*8; // We want to start after the variadic scratch space
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
		stack_space := (alloca_size + vreg_spill_size + link_and_frame + number_of_variadics * 8 + 15) & ~15;
		info.stack_space = stack_space;

		// Prologue
		if stack_space <= 4095 {
			emit(emitter, "sub sp, sp, #%", stack_space);
		} else {
			v := stack_space.(u64);
			emit(emitter, "movz x9, #%, lsl #0", v & 0xFFFF);
			if v > 0xFFFF     emit(emitter, "movk x9, #%, lsl #16", (v >> 16) & 0xFFFF);
			if v > 0xFFFFFFFF emit(emitter, "movk x9, #%, lsl #32", (v >> 32) & 0xFFFF);
			if v > 0xFFFFFFFFFFFF emit(emitter, "movk x9, #%, lsl #48", (v >> 48) & 0xFFFF);
			emit(emitter, "sub sp, sp, x9");
		}
		base := sp_offset(emitter, 9, stack_space - link_and_frame);
		emit(emitter, "str x29, [%]", base);
		emit(emitter, "str x30, [%, #8]", base);
		emit(emitter, "mov x29, %", base);


		// Emit instructions
		// Scratch registers: x9/w9 for dst, x10/w10 for a, x11/w11 for b
		for function.instructions {
			if it.op == .Param then continue;
			if it.op == .Alloca then continue;

			if it.op == {
				case .LoadParam;
					param_n := it.a.constant.(int);
					int_count := 0;
					float_count := 0;
					for i: 0..param_n-1 {
						if function.params[i].kind == .Float {
							float_count += 1;
						} else {
							int_count += 1;
						}
					}
					dst := scratch_name(it.dst.type, 9);
					if function.params[param_n].kind == .Float {
						if function.params[param_n].size_in_bytes == 4 {
							emit(emitter, "fcvt %, d%", dst, float_count);
						} else {
							emit(emitter, "fmov %, d%", dst, float_count);
						}
					} else {
						emit(emitter, "mov %, %", dst, register_name(it.dst, int_count));
					}
					store_result(emitter, it.dst, info, 9);

				case .Address;
					dst := scratch_name(it.dst.type, 9);
					if it.a.kind == .Label {
						emit(emitter, "adrp x9, _%@PAGE", it.a.label);
						emit(emitter, "add x9, x9, _%@PAGEOFF", it.a.label);
					} else if it.a.kind == .Register {
						// Address of an alloca vreg
						offset := info.alloca_offsets[it.a.register];
						sp_offset(emitter, 9, offset);
					}
					store_result(emitter, it.dst, info, 9);

				case .Call;
					param_count := it.b.constant.(int);
					param_start := it_index + 1;
					param_end := param_start + param_count;
					reg_int := 0;
					reg_float := 0;
					param_index := 0;
					for param_start..param_end-1 {
						param := function.instructions[it];
						// Materialise param value into x12/w12 as temp scratch
						src := value_from_operand(emitter, param.a, info, 12);
						if param.a.type.kind == .Float {
							emit(emitter, "fmov %, %", register_name(param.a, reg_float), src);
							reg_float += 1;
						} else {
							is_address := param.a.kind == .Label || (param.a.kind == .Register && info.is_alloca[param.a.register]);
							if is_address {
								emit(emitter, "mov x%, %", reg_int, src);
							} else {
								emit(emitter, "mov %, %", register_name(param.a, reg_int), src);
							}
							reg_int += 1;
						}
						param_index += 1;
					}

					// Assume any more Param instructions are now variadic
					variadic_count := 0;
					while param_end + variadic_count < function.instructions.count &&
						  function.instructions[param_end + variadic_count].op == .Param {
						param := function.instructions[param_end + variadic_count];
						if param.a.type.kind == .Float && param.a.type.size_in_bytes == 4 {
							src := value_from_operand(emitter, param.a, info, 12);
							emit(emitter, "fcvt d12, %", src);
							base := sp_offset(emitter, 9, variadic_count*8);
							emit(emitter, "str d12, [%]", base);
						} else {
							src := value_from_operand(emitter, param.a, info, 12);
							base := sp_offset(emitter, 9, variadic_count*8);
							emit(emitter, "str %, [%]", src, base);
						}
						param_index += 1;
						variadic_count += 1;
					}

					emit(emitter, "bl _%", it.a.label);
					if it.dst.kind != .None {
						if it.dst.kind == .Register && info.is_alloca[it.dst.register] {
							// Struct return: store return registers into the alloca
							target_results := find_function_results(emitter, it.a.label);
							offset := info.alloca_offsets[it.dst.register];
							base := sp_offset(emitter, 9, offset);
							float_reg := 0;
							int_reg := 0;
							member_offset := 0;
							for target_results {
								if it.kind == .Float {
									if it.size_in_bytes == 4 {
										emit(emitter, "str s%, [x9, #%]", float_reg, member_offset);
									} else {
										emit(emitter, "str d%, [x9, #%]", float_reg, member_offset);
									}
									float_reg += 1;
								} else {
									if it.size_in_bytes <= 4 {
										emit(emitter, "str w%, [x9, #%]", int_reg, member_offset);
									} else {
										emit(emitter, "str x%, [x9, #%]", int_reg, member_offset);
									}
									int_reg += 1;
								}
								member_offset += it.size_in_bytes;
							}
						} else {
							// Scalar return
							dst := scratch_name(it.dst.type, 9);
							if it.dst.type.kind == .Float {
								emit(emitter, "fmov %, d0", dst);
							} else {
								emit(emitter, "mov %, %", dst, register_name(it.dst, 0));
							}
							store_result(emitter, it.dst, info, 9);
						}
					}
					it_index += param_index;
				case .Load;
					a := value_from_operand(emitter, it.a, info, 10);
					dst := scratch_name(it.dst.type, 9);
					emit(emitter, "ldr %, [%]", dst, a);
					store_result(emitter, it.dst, info, 9);

				case .Store;
					a := value_from_operand(emitter, it.a, info, 10);
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
					emit(emitter, "orr %, %, %", dst, a, b);
					store_result(emitter, it.dst, info, 9);

				case .And;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					emit(emitter, "and %, %, %", dst, a, b);
					store_result(emitter, it.dst, info, 9);

				case .Xor;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					emit(emitter, "eor %, %, %", dst, a, b);
					store_result(emitter, it.dst, info, 9);

				case .Shl;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					emit(emitter, "lsl %, %, %", dst, a, b);
					store_result(emitter, it.dst, info, 9);

				case .Shr;
					a := value_from_operand(emitter, it.a, info, 10);
					b := value_from_operand(emitter, it.b, info, 11);
					dst := scratch_name(it.dst.type, 9);
					if it.dst.type.unsigned {
						emit(emitter, "lsr %, %, %", dst, a, b);
					} else {
						emit(emitter, "asr %, %, %", dst, a, b);
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
				case .Add;
					lower_binary(emitter, it, info, "add");
				case .Sub;
					lower_binary(emitter, it, info, "sub");
				case .Mul;
					lower_binary(emitter, it, info, "mul");
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
						if function.results.count > 1 {
							// HFA struct return: operand is a pointer, load members into return registers
							a := value_from_operand(emitter, it.a, info, 10);
							float_reg := 0;
							int_reg := 0;
							member_offset := 0;
							for function.results {
								if it.kind == .Float {
									if it.size_in_bytes == 4 {
										emit(emitter, "ldr s%, [x10, #%]", float_reg, member_offset);
									} else {
										emit(emitter, "ldr d%, [x10, #%]", float_reg, member_offset);
									}
									float_reg += 1;
								} else {
									if it.size_in_bytes <= 4 {
										emit(emitter, "ldr w%, [x10, #%]", int_reg, member_offset);
									} else {
										emit(emitter, "ldr x%, [x10, #%]", int_reg, member_offset);
									}
									int_reg += 1;
								}
								member_offset += it.size_in_bytes;
							}
						} else {
							a := value_from_operand(emitter, it.a, info, 10);
							if it.a.type.kind == .Float {
								emit(emitter, "fmov d0, %", a);
							} else {
								emit(emitter, "mov %, %", register_name(it.a, 0), a);
							}
						}
					}
					// Epilogue
					base := sp_offset(emitter, 9, stack_space - link_and_frame);
					emit(emitter, "ldr x29, [%]", base);
					emit(emitter, "ldr x30, [%, #8]", base);
					if stack_space <= 4095 {
						emit(emitter, "add sp, sp, #%", stack_space);
					} else {
						v := stack_space.(u64);
						emit(emitter, "movz x9, #%, lsl #0", v & 0xFFFF);
						if v > 0xFFFF     emit(emitter, "movk x9, #%, lsl #16", (v >> 16) & 0xFFFF);
						if v > 0xFFFFFFFF emit(emitter, "movk x9, #%, lsl #32", (v >> 32) & 0xFFFF);
						if v > 0xFFFFFFFFFFFF emit(emitter, "movk x9, #%, lsl #48", (v >> 48) & 0xFFFF);
						emit(emitter, "add sp, sp, x9");
					}
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
								// Zero-extension: write to w-form of dst.
								// ARM64 always zero-extends a 32-bit write into the full 64-bit register,
								// so mov w9, w10 correctly zero-extends w10 into x9.
								w_dst := tprint("w%", 9);
								emit(emitter, "mov %, %", w_dst, a);
							} else if src_type.size_in_bytes == {
								case 1;
									emit(emitter, "sxtb %, %", dst, a);
								case 2;
									emit(emitter, "sxth %, %", dst, a);
								case 4;
									emit(emitter, "sxtw %, %", dst, a);
							}
						} else {
							// Narrowing or same size.
							// When narrowing from 64-bit to 32-bit (x10 -> w9), we must use the
							// w-form of the source to avoid the invalid "mov w9, x10".
							src := ifx (src_type.size_in_bytes == 8 && dst_type.size_in_bytes <= 4) then tprint("w%", 10) else a;
							emit(emitter, "mov %, %", dst, src);
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
		// Incase we don't specify a return statement for `void`
		epilogue_base := sp_offset(emitter, 9, stack_space - link_and_frame);
		emit(emitter, "ldr x29, [%]", epilogue_base);
		emit(emitter, "ldr x30, [%, #8]", epilogue_base);
		if stack_space <= 4095 {
			emit(emitter, "add sp, sp, #%", stack_space);
		} else {
			v := stack_space.(u64);
			emit(emitter, "movz x9, #%, lsl #0", v & 0xFFFF);
			if v > 0xFFFF     emit(emitter, "movk x9, #%, lsl #16", (v >> 16) & 0xFFFF);
			if v > 0xFFFFFFFF emit(emitter, "movk x9, #%, lsl #32", (v >> 32) & 0xFFFF);
			if v > 0xFFFFFFFFFFFF emit(emitter, "movk x9, #%, lsl #48", (v >> 48) & 0xFFFF);
			emit(emitter, "add sp, sp, x9");
		}
		emit(emitter, "ret");
	}

	emit(emitter, ".data");
	for emitter.ir.globals {
		emit(emitter, ".globl _%", it.name);
		emit(emitter, ".p2align %", it.alignment);
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
