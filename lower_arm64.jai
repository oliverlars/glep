#import "Basic";
#import "File";

#load "ir.jai";

Compiler :: struct {
	ir: *IR;

	builder: String_Builder;
}

emit :: (compiler: *Compiler, fmt: string, ...) {
	to_append := tprint(fmt, ..args);
	append(*compiler.builder, to_append);
	append(*compiler.builder, "\n");
}

lower :: (compiler: *Compiler) {

	for ir.instructions {
		if it.op == {
			case .Load;
			case .Store;
			case .Copy;
			case .Add;
				
			case .Return;
		}
	}

}


main :: () {
	compiler: Compiler;

	

	lower(*compiler);

	write_entire_file("ir.s", builder_to_string(compiler.builder));
}