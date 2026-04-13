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
				if ir_type.pointer {
					result = tprint("void *");
				} else {
					result = tprint("%long long", result);
				}
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
		emit(emitter, "char %[%] = {\n", global.name, global.bytes.count);
		for global.bytes {
			if it_index < global.bytes.count - 1 {
				emit(emitter, "%, ", it);
			} else {
				emit(emitter, "% ", it);
			}
		}
		emit(emitter, "\n};\n", global.name);
	}
	emit(emitter, "int memset(void *, int, unsigned int);\n");
	emit(emitter, "int memcpy(void *, void *, unsigned int);\n");
	emit(emitter, "int noop = 0;\n");
	for external: emitter.ir.externals {
		name := external.name;
		if external.results.count == 1 {
			ctype := ctype_from_ir_type(external.results[0]);
			emit(emitter, "% %(", ctype, name);
		} else {
			emitln(emitter, "typedef struct %_return {", name);
			for result_member: external.results { 
				ctype := ctype_from_ir_type(result_member);
				emit(emitter, "% r%;", ctype, it_index);
			}
			emit(emitter, "} %_return;", name);
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
		if function.results.count == 1 {
				ctype := ctype_from_ir_type(function.results[0]);
				emit(emitter, "% ", ctype);
				emit(emitter, "%(", name);
		} else {
			emitln(emitter, "typedef struct %_return {", name);
			for result_member: function.results { 
				ctype := ctype_from_ir_type(result_member);
				emit(emitter, "% r%;", ctype, it_index);
			}
			emit(emitter, "} %_return;", name);
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
				if it.op == {
					case .Add;
						a := ifx it.a.type.pointer then tprint("((char*)%)", materialise(it.a)) else tprint("%", materialise(it.a));
						b := ifx it.b.type.pointer then tprint("((char*)%)", materialise(it.b)) else tprint("%", materialise(it.b));
						emitln(emitter, "v% = % + %;", it.dst.register, a, b);
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
						emitln(emitter, "v% = % << %;", it.dst.register, materialise(it.a), materialise(it.b));
					case .Shl;
						emitln(emitter, "v% = % >> %;", it.dst.register, materialise(it.a), materialise(it.b));
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
						emitln(emitter, "v% = (void*)&%;", it.dst.register, materialise(it.a));
					case .Alloca;
						emitln(emitter, "char alloca_v%[%];", it.dst.register, it.a.constant);
						emitln(emitter, "v% = (void*)alloca_v%;", it.dst.register, it.dst.register);
					case .Call;
						for 0..emitter.indent-1 { append(*emitter.builder, "    "); }
						callee_name := it.a.label;
						callee_is_struct_return := false;
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
						if it.dst.kind == .Register {
							if callee_is_struct_return {
								emit(emitter, "*((%_return*)v%) = %(", callee_name, it.dst.register, callee_name);
							} else {
								emit(emitter, "v% = %(", it.dst.register, callee_name);
							}
						} else {
							emit(emitter, "%(", callee_name);
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
	emit(emitter, "int main(int argc, char **args) { entry(argc, args); }");
}

lower :: (ir: *IR) -> Emitter {
	emitter: Emitter;

	emitter.ir = ir;

	lower(*emitter);

	return emitter;
}
