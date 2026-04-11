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
					return tprint("%", as_f64);
				} else {
					as_f32: float32;
					as_u32 := operand.constant.(u32);
					memcpy(*as_f32, *as_u32, 4);
					return tprint("%", as_f32);
				}
			} else {
				return tprint("%", operand.constant);
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
		emit(emitter, "char %[] = {\n", global.name);
		for global.bytes {
			if it_index < global.bytes.count - 1 {
				emit(emitter, "%, ", it);
			} else {
				emit(emitter, "% ", it);
			}
		}
		emit(emitter, "\n};\n", global.name);
	}
	for external: emitter.ir.externals {
		name := external.name;
		if external.results.count == 1 {
			ctype := ctype_from_ir_type(external.results[0]);
			emit(emitter, "% ", ctype);
		} else {
			emitln(emitter, "typedef struct %_return {");
			for result_member: external.results { 
				ctype := ctype_from_ir_type(result_member);
				emit(emitter, "% r%;", ctype, it_index);
			}
			emit(emitter, "} %_return;", name);
		}
		emit(emitter, "%(", name);
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
		if function.results.count == 1 {
				ctype := ctype_from_ir_type(function.results[0]);
				emit(emitter, "% ", ctype);
		} else {
			emitln(emitter, "typedef struct %_return {");
			for result_member: function.results { 
				ctype := ctype_from_ir_type(result_member);
				emit(emitter, "% r%;", ctype, it_index);
			}
			emit(emitter, "} %_return;", name);
		}
		emit(emitter, "%(", name);
		if function.instructions.count > 0 {
			for function.instructions {
				if it.op == .LoadParam {
					param := tprint("% v%", ctype_from_ir_type(it.dst.type), materialise(it.dst));
					if it_index >= function.params.count {
						emit(emitter, "%", param);
						break;
					} else {
						emit(emitter, "%,\n", param);
					}
				}
			}
			emitln(emitter, ") {");
			indent(emitter);
			for function.instructions {
				if it.op == {
					case .Add;
						emitln(emitter, "% v% = % + %;", ctype_from_ir_type(it.dst.type), it.dst.register, materialise(it.a), materialise(it.b));
					case .Load;
						emitln(emitter, "% v% = *((%*)v%);", ctype_from_ir_type(it.dst.type), it.dst.register, ctype_from_ir_type(it.dst.type), it.a.register);
					case .Store;
						emitln(emitter, "*((%*)v%) = %;", ctype_from_ir_type(it.b.type), it.a.register, materialise(it.b));
					case .Address;
						emitln(emitter, "void *v% = (void*)&%;", it.dst.register, materialise(it.a));
					case .Alloca;
						emitln(emitter, "char alloca_v%[%];", it.dst.register, it.a.constant);
						emitln(emitter, "void *v% = (void*)alloca_v%;", it.dst.register, it.dst.register);
					case .Call;
						for 0..emitter.indent-1 { append(*emitter.builder, "    "); }
						emit(emitter, "%(", it.a.label);
						arg_index := 0;
						arg_count := 0;
						while arg_count + it_index + 1 < function.instructions.count &&
							  function.instructions[it_index + arg_index + 1].op == .Param {
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
}

lower :: (ir: *IR) -> Emitter {
	emitter: Emitter;

	emitter.ir = ir;

	lower(*emitter);

	return emitter;
}
