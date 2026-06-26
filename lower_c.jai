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
	indent: int;
}

emitln :: (emitter: *Emitter, fmt: string, args: ..Any) {
	to_append := tprint(fmt, ..args);
	for 0..emitter.indent-1 {
		append(*emitter.builder, "    ");
	}
	append(*emitter.builder, to_append);
	append(*emitter.builder, "\n");
}

emit :: (emitter: *Emitter, fmt: string, args: ..Any) {
	to_append := tprint(fmt, ..args);
	append(*emitter.builder, to_append);
}

indent :: (emitter: *Emitter) {
	emitter.indent += 1;
}

unindent :: (emitter: *Emitter) {
	emitter.indent -= 1;
}

ctype_from_ir_type :: (ir_type: IR_Operand_Type) -> string {
	if ir_type.kind == .Float {
		if ir_type.size_in_bytes == 4 {
			return "float";
		} else {
			return "double";
		}
	} else {
		result: string;
		if ir_type.pointer {
			// The IR treats pointers as byte addresses: it adds scaled
			// integer offsets to them and stores them in vregs. Emit them
			// as an integer carrier in C, and cast at load/store sites.
			return "unsigned long long";
		}
		if ir_type.unsigned {
			result = "unsigned ";
		}
		if ir_type.size_in_bytes == {
			case 1;
				result = tprint("%char", result);
			case 2;
				result = tprint("%short", result);
			case 4;
				result = tprint("%int", result);
			case 8;
				result = tprint("%long long", result);
		}
		return result;
	}

	return "";
}

materialise :: (operand: IR_Operand) -> string {
	if operand.kind == {
		case .Constant;
			if operand.type.kind == .Float {
				if operand.type.size_in_bytes == 8 {
					as_f64: float64;
					memcpy(*as_f64, *operand.constant, 8);
					return tprint("%", FormatFloat.{value=as_f64, zero_removal=.ONE_ZERO_AFTER_DECIMAL});
				} else {
					as_f32: float32;
					as_u32 := operand.constant.(u32);
					memcpy(*as_f32, *as_u32, 4);
					s := tprint("%", FormatFloat.{value=as_f32, zero_removal=.ONE_ZERO_AFTER_DECIMAL});
					return tprint("%f", s);
				}
			} else {
				if operand.type.unsigned {
					return tprint("%llu", operand.constant);
				} else {
					return tprint("%ll", operand.constant);
				}
			}
		case .Register;
			return tprint("v%", operand.register);
		case .Label;
			return operand.label;
	}
	return "";
}

lower :: (emitter: *Emitter) {
	for global: emitter.ir.globals {
		alignment := max(global.alignment, 1);
		builder: String_Builder;
		emitln(emitter, "__attribute__((aligned(%))) struct { \n", alignment);
		indent(emitter);
		if global.relocations.count > 0 {
			relocation_index := 0;
			bytes_start := 0;
			for byte_index: 0..global.bytes.count-1 {
				if relocation_index < global.relocations.count &&
				   global.relocations[relocation_index].byte_start {
					emitln(emitter, "char _bytes%[%]; void *_r%;", relocation_index, byte_index - bytes_start, relocation_index);
					bytes_start = byte_index;
					relocation_index += 1;
				}
			}
		} else {
			emitln(emitter, "char b0[%];", global.size_in_bytes);
		}
		unindent(emitter);
		unindent(emitter);
		emit(emitter, "\n}");
		if global.bytes.count > 0 {
			emitln(emitter, " _g% = {", it_index);
			// emitln(emitter, ".bytes = {");
			// indent(emitter);
			// for byte: global.bytes {
			// 	if it_index < global.bytes.count - 1 {
			// 		emit(emitter, "%, ", byte);
			// 	} else {
			// 		emit(emitter, "% ", byte);
			// 	}
			// }
			// unindent(emitter);
			// emit(emitter, "},\n");
			for relocation: global.relocations {
				relocation_index: int;
				for global: emitter.ir.globals {
					if global.name == relocation.name {
						relocation_index = it_index;
					}
				}
				emit(emitter, "._r% = _g%.bytes + %,\n", it_index, relocation_index, relocation.offset);
			}
			bytes_start := 0;
			emit(emitter, "\n}\n");
		} else {
			emitln(emitter, " _g%", it_index);
		}
		emit(emitter, ";\n");
		emit(emitter, "void *% = _g%.bytes;\n", global.name, it_index);
	}
	emit(emitter, "unsigned long long memset(unsigned long long, int, unsigned int);\n");
	emit(emitter, "unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);\n");
	emit(emitter, "int noop = 0;\n");
	for emitter.ir.extern_vars {
		emit(emitter, "extern char %[];\n", it);
	}

	// Pre-pass: emit each <name>_return typedef once, even if both an
	// external (forward decl) and a function definition share the name.
	emitted_returns: Table(string, bool);
	emit_return_typedef :: (emitter: *Emitter, seen: *Table(string, bool), name: string, results: []IR_Operand_Type) {
		if results.count <= 1 return;
		if table_contains(seen, name) return;
		table_set(seen, name, true);
		emitln(emitter, "typedef struct %_return {", name);
		for r, i: results {
			emit(emitter, "% r%;", ctype_from_ir_type(r), i);
		}
		emit(emitter, "} %_return;\n", name);
	}
	for external: emitter.ir.externals {
		emit_return_typedef(emitter, *emitted_returns, external.name, external.results);
	}
	for function: emitter.ir.functions {
		fn_key := ifx function.name == "main" then "entry" else function.name;
		emit_return_typedef(emitter, *emitted_returns, fn_key, function.results);
	}

	for external: emitter.ir.externals {
		name := external.name;
		// Skip names already declared in the prelude above; otherwise clang
		// errors on conflicting types when system headers re-declare them.
		if name == "memset" || name == "memcpy" continue;
		if external.results.count == 0 {
			emit(emitter, "void %(", name);
		} else if external.results.count == 1 {
			ctype := ctype_from_ir_type(external.results[0]);
			emit(emitter, "% %(", ctype, name);
		} else {
			emit(emitter, "%_return %(", name, name);
		}
		for external.params {
			if it_index < external.params.count - 1 {
				emit(emitter, "%,", ctype_from_ir_type(it));
			} else {
				emit(emitter, "%", ctype_from_ir_type(it));
			}
		}
		if external.variadic {
			emit(emitter, ", ...");
		}
		emit(emitter, ");\n");
	}
	for function: emitter.ir.functions {
		name := function.name;
		if name == "main" {
			name = "entry";
		}
		if function.linkage == .EXTERNAL {
			emit(emitter, "extern ");
		} else {
			emit(emitter, "static ");
		}
		if function.results.count == 0 {
			emit(emitter, "void ");
			emit(emitter, "%(", name);
		} else if function.results.count == 1 {
				ctype := ctype_from_ir_type(function.results[0]);
				emit(emitter, "% ", ctype);
				emit(emitter, "%(", name);
		} else {
			emit(emitter, "%_return %(", name, name);
		}
		if function.instructions.count > 0 {
			param_index := 0;
			for function.instructions {
				if it.op != .LoadParam then continue;
				if it.op == .LoadParam {
					param := tprint("% %", ctype_from_ir_type(it.dst.type), materialise(it.dst));
					param_index += 1;
					if param_index >= function.params.count {
						emit(emitter, "%", param);
						break;
					} else {
						emit(emitter, "%,\n", param);
					}
				}
			}
			if function.variadic {
				emit(emitter, ", ...");
			}
			emitln(emitter, ") {");
			indent(emitter);
			seen: [..] bool;
			array_resize(*seen, function.registers_needed);
			for function.instructions {
				if it.op == .LoadParam then continue;
				if it.dst.kind == .Register && !seen[it.dst.register] {
					seen[it.dst.register] = true;
					emitln(emitter, "% v%;", ctype_from_ir_type(it.dst.type), it.dst.register);
				}
			}
			for function.instructions {
				if it.op == .Alloca {
					emitln(emitter, "char alloca_v%[%] __attribute__((aligned(16)));", it.dst.register, it.a.constant);
					emitln(emitter, "v% = (unsigned long long)alloca_v%;", it.dst.register, it.dst.register);
				}
			}
			current_order := "5";
			for function.instructions {
				if it.op == {
					case .DebugLabel;
						emitln(emitter, "// %", it.a.label);
					case .MemoryOrderRelaxed; current_order = "0";
					case .MemoryOrderConsume; current_order = "1";
					case .MemoryOrderAcquire; current_order = "2";
					case .MemoryOrderRelease; current_order = "3";
					case .MemoryOrderAcqRel;  current_order = "4";
					case .MemoryOrderSeqCst;  current_order = "5";
					case .AtomicLoad;
						pointee := ctype_from_ir_type(it.dst.type);
						emitln(emitter, "v% = __c11_atomic_load((_Atomic %*)%, %);",
							it.dst.register, pointee, materialise(it.a), current_order);
					case .AtomicStore;
						pointee := ctype_from_ir_type(it.b.type);
						emitln(emitter, "__c11_atomic_store((_Atomic %*)%, %, %);",
							pointee, materialise(it.a), materialise(it.b), current_order);
					case .AtomicFetchAdd;
						pointee := ctype_from_ir_type(it.dst.type);
						emitln(emitter, "v% = __c11_atomic_fetch_add((_Atomic %*)%, %, %);",
							it.dst.register, pointee, materialise(it.a), materialise(it.b), current_order);
					case .VAStart;
						emitln(emitter, "__builtin_va_start(*(__builtin_va_list*)%, %);",
							materialise(it.a), materialise(it.b));
					case .VAEnd;
						emitln(emitter, "__builtin_va_end(*(__builtin_va_list*)%);",
							materialise(it.a));
					case .VACopy;
						emitln(emitter, "__builtin_va_copy(*(__builtin_va_list*)%, *(__builtin_va_list*)%);",
							materialise(it.a), materialise(it.b));
					case .Mod;
						emitln(emitter, "v% = % \% %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Add;
						emitln(emitter, "v% = % + %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Sub;
						emitln(emitter, "v% = % - %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Mul;
						emitln(emitter, "v% = % * %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Div;
						emitln(emitter, "v% = % / %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Neg;
						emitln(emitter, "v% = -%;", it.dst.register, materialise(it.a));
					case .Not;
						emitln(emitter, "v% = !%;", it.dst.register, materialise(it.a));
					case .Eq;
						emitln(emitter, "v% = % == %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Ne;
						emitln(emitter, "v% = % != %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Le;
						emitln(emitter, "v% = % <= %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Lt;
						emitln(emitter, "v% = % < %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Shr;
						emitln(emitter, "v% = % >> %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Shl;
						emitln(emitter, "v% = % << %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Xor;
						emitln(emitter, "v% = % ^ %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .And;
						emitln(emitter, "v% = % & %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Or;
						emitln(emitter, "v% = % | %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Copy;
						emitln(emitter, "v% = %;", it.dst.register, materialise(it.a));
					case .Goto;
						emitln(emitter, "goto %;", materialise(it.a));
					case .Label;
						emitln(emitter, "%: (void)noop;", materialise(it.a));
					case .Ifz;
						emitln(emitter, "if(% == 0) goto %;", materialise(it.a), materialise(it.b));
					case .If;
						emitln(emitter, "if(% != 0) goto %;", materialise(it.a), materialise(it.b));
					case .Return;
						if it.a.kind != .None {
							if function.results.count > 1 {
								emitln(emitter, "return *((%_return*)%);", name, materialise(it.a));
							} else {
								emitln(emitter, "return %;", materialise(it.a));
							}
						} else {
							emitln(emitter, "return;");
						}
					case .Cast;
						emitln(emitter, "v% = (%)%;", it.dst.register, ctype_from_ir_type(it.dst.type), materialise(it.a));
					case .Load;
						emitln(emitter, "v% = *((%*)v%);", it.dst.register, ctype_from_ir_type(it.dst.type), it.a.register);
					case .Store;
						emitln(emitter, "*((%*)v%) = %;", ctype_from_ir_type(it.b.type), it.a.register, materialise(it.b));
					case .Address;
						if it.a.kind == .Register {
							emitln(emitter, "v% = v%;", it.dst.register, it.a.register);
						} else {
							// Labels bind char[] globals, extern char[] vars, or
							// function names — all decay to pointers in C, so
							// `name` already gives the address. No `&` needed.
							emitln(emitter, "v% = (unsigned long long)%;", it.dst.register, materialise(it.a));
						}
					case .Alloca;
					case .Call;
						for 0..emitter.indent-1 { append(*emitter.builder, "    "); }
						is_indirect := it.a.kind == .Register;
						callee_name := it.a.label;
						callee_expr: string;
						if is_indirect {
							ret_ctype := ifx it.dst.kind == .Register then ctype_from_ir_type(it.dst.type) else "void";
							callee_expr = tprint("((% (*)())%)", ret_ctype, materialise(it.a));
						} else {
							callee_expr = callee_name;
						}
						callee_is_struct_return := false;
						if !is_indirect {
							for f: emitter.ir.functions {
								if f.name == callee_name {
									callee_is_struct_return = f.results.count > 1;
									break;
								}
							}
							if !callee_is_struct_return {
								for ext: emitter.ir.externals {
									if ext.name == callee_name {
										callee_is_struct_return = ext.results.count > 1;
										break;
									}
								}
							}
						}
						if it.dst.kind == .Register {
							if callee_is_struct_return {
								emit(emitter, "*((%_return*)v%) = %(", callee_name, it.dst.register, callee_expr);
							} else {
								emit(emitter, "v% = %(", it.dst.register, callee_expr);
							}
						} else {
							emit(emitter, "%(", callee_expr);
						}
						arg_index := 0;
						arg_count := 0;
						while it_index + arg_count + 1 < function.instructions.count &&
							  function.instructions[it_index + arg_count + 1].op == .Param {
							arg_count += 1;
						}
						while arg_index < arg_count {
							arg := function.instructions[arg_index + it_index + 1];
							if arg_index < arg_count - 1 {
								emit(emitter, "%, ", materialise(arg.a));
							} else {
								emit(emitter, "%", materialise(arg.a));
							}
							arg_index += 1;
						}
						emitln(emitter, ");");
					case .Param;
				}
				}
				unindent(emitter);
				emitln(emitter, "}");
		} else {
			emitln(emitter, ");");
		}
	}
	entry: *IR_Function;
	for * emitter.ir.functions {
		if it.name == "main" {
			entry = it;
			break;
		}
	}
	emit(emitter, "int main(int argc, char **args) { ");
	if entry && entry.results.count == 1 {
		emit(emitter, "return ");
	}
	emit(emitter, "entry(");
	if entry {
		for entry.params {
			if it_index > 0 emit(emitter, ", ");
			if it_index == 0 {
				emit(emitter, "argc");
			} else if it_index == 1 {
				emit(emitter, "(unsigned long long)args");
			} else {
				emit(emitter, "0");
			}
		}
	}
	emit(emitter, ");");
	if !entry || entry.results.count != 1 {
		emit(emitter, " return 0;");
	}
	emit(emitter, " }");
}

lower :: (ir: *IR) -> Emitter {
	emitter: Emitter;

	emitter.ir = ir;

	lower(*emitter);

	return emitter;
}
