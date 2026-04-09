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
				result = tprint("%long long", result);
		}
		return result;
	}

	return "";
}

lower :: (emitter: *Emitter) {
	for function: emitter.ir.functions {
		name := function.name;
		if function.results.count == 1 {
				ctype := ctype_from_ir_type(function.results[0]);
				emit(emitter, "% %(", ctype, name);
		} else {
			emit(emitter, "typedef struct %_return {", name);
			for result_member: function.results { 
				ctype := ctype_from_ir_type(result_member);
				emit(emitter, "% r%;", ctype, it_index);
			}
			emit(emitter, "} %_return;", name);
			emit(emitter, "%_return %(", name, name);
		}
		if function.instructions.count > 0 {
			for function.instructions {
				if it.op == .LoadParam {
					param := tprint("% v%", ctype_from_ir_type(it.dst.type), it.dst.register);
					if it_index >= function.params.count {
						emit(emitter, "%", param);
						break;
					} else {
						emit(emitter, "%,", param);
					}
				}
			}
			emit(emitter, ") ");
			emit(emitter, "{");
			for function.instructions {
				if it.op == {
					case .Add;
						emit(emitter, "% v% = v% + v%;", ctype_from_ir_type(it.dst.type), it.a.register, it.b.register);
				}
			}
			emit(emitter, "}");
		} else {
			emit(emitter, ");");
		}
	}
}

lower :: (ir: *IR) -> Emitter {
	emitter: Emitter;

	emitter.ir = ir;

	lower(*emitter);

	return emitter;
}
