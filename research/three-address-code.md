# Three-Address Code: From AST to ARM64

## What Three-Address Code Is

Three-address code (TAC) is a flat list of instructions where each instruction has at most **one operator**, **two source operands**, and **one destination**. The name comes from the fact that each instruction references at most three "addresses" (names for values).

The key insight: your AST is a tree of nested expressions. TAC flattens that tree into a sequence of simple steps by introducing **temporaries** for every intermediate result.

Given:
```c
x = a + b * c - d;
```

The AST is:
```
      =
     / \
    x    -
        / \
       +    d
      / \
     a    *
         / \
        b   c
```

TAC flattens this to:
```
t0 = b * c
t1 = a + t0
t2 = t1 - d
x  = t2
```

Each line is trivial. No nesting. A backend can process these one at a time.

## The Instruction Set

A minimal TAC for C needs roughly these instruction kinds:

```
// Arithmetic / logic
t = a + b
t = a - b
t = a * b
t = a / b
t = a % b
t = a & b
t = a | b
t = a ^ b
t = a << b
t = a >> b

// Unary
t = -a
t = ~a
t = !a

// Comparison (result is 0 or 1)
t = a < b
t = a <= b
t = a == b
t = a != b

// Data movement
t = a              // copy
t = (int)a         // cast (with explicit source and target types)
t = *a             // load from pointer
*a = b             // store through pointer
t = &a             // address-of

// Control flow
label L
goto L
if a goto L        // conditional branch (a is truthy)
ifz a goto L       // conditional branch (a is zero)

// Function calls
param a            // push argument
t = call f, n      // call f with n arguments, result in t

// Return
return a
```

That is the entire language. ~25 instruction kinds covers all of C's semantics.

## Representation

Each instruction is a struct. There are many ways to do this; here is a straightforward one:

```c
typedef enum {
    TAC_ADD, TAC_SUB, TAC_MUL, TAC_DIV, TAC_MOD,
    TAC_AND, TAC_OR, TAC_XOR, TAC_SHL, TAC_SHR,
    TAC_NEG, TAC_NOT, TAC_LNOT,
    TAC_LT, TAC_LE, TAC_EQ, TAC_NE,
    TAC_COPY, TAC_CAST,
    TAC_LOAD, TAC_STORE, TAC_ADDR,
    TAC_LABEL, TAC_GOTO, TAC_IF, TAC_IFZ,
    TAC_PARAM, TAC_CALL,
    TAC_RETURN,
} Tac_Op;

typedef enum {
    OPERAND_NONE,
    OPERAND_TEMP,       // compiler-generated temporary: t0, t1, ...
    OPERAND_VAR,        // source-level variable
    OPERAND_INT_CONST,  // integer literal
    OPERAND_FP_CONST,   // floating-point literal
    OPERAND_LABEL,      // label reference
} Operand_Kind;

typedef struct {
    Operand_Kind kind;
    Type *type;           // int, double, pointer, etc.
    union {
        int temp_id;      // for OPERAND_TEMP
        char *name;       // for OPERAND_VAR / OPERAND_LABEL
        int64_t ival;     // for OPERAND_INT_CONST
        double fval;      // for OPERAND_FP_CONST
    };
} Operand;

typedef struct {
    Tac_Op op;
    Operand dst;          // result (not all instructions have one)
    Operand src1;
    Operand src2;
} Tac_Instr;
```

A function's TAC is just a dynamic array of `Tac_Instr`. That is the entire data structure.

## Lowering an AST to TAC

The core is a recursive function that walks an expression and returns the operand holding the result. Each recursive call may append instructions to the output list and returns a fresh temporary.

### Expression Lowering

```
function lower_expr(node) -> Operand:
    match node:
        Number(value):
            return Operand::Const(value)

        Identifier(name):
            return Operand::Var(name)

        Binary(op, left, right):
            l = lower_expr(left)
            r = lower_expr(right)
            t = fresh_temp()
            emit(op, dst=t, src1=l, src2=r)
            return t

        Unary(op, expr):
            e = lower_expr(expr)
            t = fresh_temp()
            emit(op, dst=t, src1=e)
            return t

        Assign(target, value):
            v = lower_expr(value)
            // If target is a simple variable:
            emit(COPY, dst=Var(target.name), src1=v)
            return v
            // If target is a dereference (*p = v):
            addr = lower_expr(target.inner)
            emit(STORE, dst=addr, src1=v)
            return v

        Deref(expr):
            addr = lower_expr(expr)
            t = fresh_temp()
            emit(LOAD, dst=t, src1=addr)
            return t

        AddrOf(expr):
            // expr must be an lvalue
            t = fresh_temp()
            emit(ADDR, dst=t, src1=Var(expr.name))
            return t

        Cast(type, expr):
            e = lower_expr(expr)
            t = fresh_temp()
            emit(CAST, dst=t, src1=e)   // t.type = target type
            return t

        Call(func_name, args):
            for each arg in args:
                a = lower_expr(arg)
                emit(PARAM, src1=a)
            t = fresh_temp()
            emit(CALL, dst=t, src1=Label(func_name), src2=Const(len(args)))
            return t

        Ternary(cond, on_true, on_false):
            c = lower_expr(cond)
            Lfalse = fresh_label()
            Lend   = fresh_label()
            result = fresh_temp()
            emit(IFZ, src1=c, src2=Label(Lfalse))
            tv = lower_expr(on_true)
            emit(COPY, dst=result, src1=tv)
            emit(GOTO, src1=Label(Lend))
            emit(LABEL, src1=Label(Lfalse))
            fv = lower_expr(on_false)
            emit(COPY, dst=result, src1=fv)
            emit(LABEL, src1=Label(Lend))
            return result
```

### Statement Lowering

```
function lower_stmt(node):
    match node:
        ExprStmt(expr):
            lower_expr(expr)   // result discarded

        Return(expr):
            v = lower_expr(expr)
            emit(RETURN, src1=v)

        If(cond, then_body, else_body):
            c = lower_expr(cond)
            Lelse = fresh_label()
            Lend  = fresh_label()
            emit(IFZ, src1=c, src2=Label(Lelse))
            lower_stmt(then_body)
            emit(GOTO, src1=Label(Lend))
            emit(LABEL, src1=Label(Lelse))
            if else_body:
                lower_stmt(else_body)
            emit(LABEL, src1=Label(Lend))

        While(cond, body):
            Ltop  = fresh_label()
            Lend  = fresh_label()
            emit(LABEL, src1=Label(Ltop))
            c = lower_expr(cond)
            emit(IFZ, src1=c, src2=Label(Lend))
            lower_stmt(body)
            emit(GOTO, src1=Label(Ltop))
            emit(LABEL, src1=Label(Lend))

        For(init, cond, step, body):
            // Desugar: init; while(cond) { body; step; }
            if init: lower_stmt(init)
            Ltop  = fresh_label()
            Lend  = fresh_label()
            emit(LABEL, src1=Label(Ltop))
            if cond:
                c = lower_expr(cond)
                emit(IFZ, src1=c, src2=Label(Lend))
            lower_stmt(body)
            if step: lower_expr(step)
            emit(GOTO, src1=Label(Ltop))
            emit(LABEL, src1=Label(Lend))

        Block(stmts):
            for each s in stmts:
                lower_stmt(s)

        DeclWithInit(name, type, init_expr):
            // Allocate stack space (tracked separately)
            if init_expr:
                v = lower_expr(init_expr)
                emit(COPY, dst=Var(name), src1=v)
```

### Worked Example

```c
int foo(int a, int b) {
    int x = a + 1;
    if (x > b) {
        return x * 2;
    }
    return b - x;
}
```

Produces:
```
function foo(a: i32, b: i32) -> i32:
    t0 = a + 1
    x  = t0
    t1 = x > b
    ifz t1 goto L0
    t2 = x * 2
    return t2
  L0:
    t3 = b - x
    return t3
```

## From TAC to ARM64

### The Mental Model

Each TAC instruction becomes 1-3 ARM64 instructions. The backend iterates the TAC list linearly. The two problems to solve are:

1. **Where is each operand?** Register, stack slot, or immediate.
2. **How do functions call each other?** The AAPCS64 calling convention.

### A Simple Register Allocator

The simplest approach that produces reasonable code: **map temporaries to registers, spill to stack when you run out.**

ARM64 has:
- `x0`-`x7` — argument/result registers (caller-saved)
- `x8` — indirect result (struct returns)
- `x9`-`x15` — scratch registers (caller-saved)
- `x19`-`x28` — callee-saved
- `d0`-`d7` — floating-point argument/result registers
- `d8`-`d15` — callee-saved floats
- `d16`-`d31` — scratch floats

A trivial allocator:
- Keep a pool of available registers (e.g. `x9`-`x15`, `x19`-`x28` for integers).
- When a new temporary is created, pop a register from the pool.
- When a temporary is last used (its "death point"), return the register to the pool.
- If the pool is empty, spill the least-recently-used temporary to a stack slot, freeing its register.

You compute liveness in one backward pass over the TAC: scan from bottom to top, marking each operand as "alive" from its last use to its definition.

A better approach (still simple): **linear scan register allocation.** Sort the live intervals by start point, walk forward, and assign registers greedily. When you run out, spill the interval that ends latest. This is what QBE does and it produces good code.

### AAPCS64 Calling Convention

The ARM64 calling convention (AAPCS64) dictates how functions receive arguments and return values.

**Integer arguments:** First 8 go in `x0`-`x7` (or `w0`-`w7` for 32-bit). Remaining go on the stack, 8-byte aligned.

**Floating-point arguments:** First 8 go in `d0`-`d7` (or `s0`-`s7` for float). Integer and float arguments are counted **independently** — `foo(int a, double b, int c)` puts `a` in `x0`, `b` in `d0`, `c` in `x1`.

**Return values:** Integer in `x0` (or `w0`). Float/double in `d0` (or `s0`). Structs <= 16 bytes returned in `x0`/`x1`. Larger structs returned indirectly via a pointer in `x8`.

**Caller-saved vs callee-saved:**
- Caller-saved (volatile): `x0`-`x18`, `d0`-`d7`, `d16`-`d31`. The callee may destroy these.
- Callee-saved (non-volatile): `x19`-`x28`, `d8`-`d15`. The callee must preserve these.
- `x29` is the frame pointer, `x30` is the link register (return address).

**Stack frame layout:**
```
[higher addresses]
    caller's frame
    ...
    argument 9 (if any)       <- sp on entry, 16-byte aligned
    argument 8 (if any)
    saved x30 (link register)
    saved x29 (frame pointer) <- x29 points here
    saved callee-saved regs
    local variables
    spill slots
    [outgoing stack args]     <- sp during function body, 16-byte aligned
[lower addresses]
```

### Translating Each TAC Instruction

Below, `reg(x)` means "the register or stack location holding operand x". For simplicity, assume all operands are in registers (the allocator handles spills separately).

**Arithmetic:**
```
TAC:    t2 = t0 + t1
ARM64:  add  x10, x9, x11       // where t0->x9, t1->x11, t2->x10

TAC:    t2 = t0 * t1            // integer
ARM64:  mul  x10, x9, x11

TAC:    t2 = t0 + t1            // double
ARM64:  fadd d2, d0, d1
```

**Comparison:**
```
TAC:    t1 = t0 < 10
ARM64:  cmp  x9, #10
        cset x10, lt            // x10 = 1 if less-than, 0 otherwise
```

**Copy / move:**
```
TAC:    t1 = t0
ARM64:  mov  x10, x9

TAC:    t0 = 42
ARM64:  mov  x9, #42
```

**Cast (int to double):**
```
TAC:    t1 = (double)t0
ARM64:  scvtf d1, x9            // signed int -> double

TAC:    t1 = (int)t0
ARM64:  fcvtzs x10, d0          // double -> signed int (truncate)
```

**Load / store:**
```
TAC:    t1 = *t0                 // load
ARM64:  ldr  x10, [x9]

TAC:    *t0 = t1                 // store
ARM64:  str  x10, [x9]
```

**Address of a local (at frame offset -24):**
```
TAC:    t0 = &x
ARM64:  add  x9, x29, #-24      // or sub x9, x29, #24
```

**Conditional branch:**
```
TAC:    ifz t0 goto L1
ARM64:  cbz  x9, L1             // branch if zero

TAC:    if t0 goto L1
ARM64:  cbnz x9, L1             // branch if nonzero
```

**Unconditional branch:**
```
TAC:    goto L1
ARM64:  b    L1
```

**Label:**
```
TAC:    label L1
ARM64:  L1:
```

**Function call:**

For a call like `result = foo(a, b, c)` where a, b, c are integers:
```
// Move arguments into the ABI registers
TAC:    param a
TAC:    param b
TAC:    param c
TAC:    result = call foo, 3

ARM64:  mov  x0, [reg for a]    // first integer arg -> x0
        mov  x1, [reg for b]    // second -> x1
        mov  x2, [reg for c]    // third -> x2
        bl   foo                // branch-and-link (call)
        mov  [reg for result], x0   // return value is in x0
```

For mixed args like `foo(int a, double b, int c)`:
```
ARM64:  mov  x0, [reg for a]    // 1st int arg -> x0
        fmov d0, [reg for b]    // 1st float arg -> d0
        mov  x1, [reg for c]    // 2nd int arg -> x1
        bl   foo
```

When there are more than 8 integer or 8 float args, the extras go on the stack:
```
// 9th integer argument at [sp]
str  x_extra, [sp]
// 10th integer argument at [sp, #8]
str  x_extra2, [sp, #8]
bl   many_args_func
```

**Saving caller-saved registers around calls:**

Before `bl`, any live temporaries in caller-saved registers (`x0`-`x18`, `d0`-`d7`, `d16`-`d31`) must be saved. After the call, they are restored. The simplest approach: spill all live caller-saved temporaries to the stack before every call, reload after.

A better approach: the register allocator knows which temporaries are live across calls and assigns them to callee-saved registers (`x19`-`x28`, `d8`-`d15`) in the first place.

**Return:**
```
TAC:    return t0               // integer
ARM64:  mov  x0, x9             // put result in x0
        // epilogue: restore callee-saved regs, restore sp, ret
        ldp  x29, x30, [sp], #frame_size
        ret

TAC:    return t0               // double
ARM64:  fmov d0, d1             // put result in d0
        ldp  x29, x30, [sp], #frame_size
        ret
```

### Function Prologue and Epilogue

**Prologue** (at function entry):
```arm64
// Save frame pointer and link register
stp  x29, x30, [sp, #-frame_size]!  // pre-index: sp -= frame_size, then store
mov  x29, sp                         // set up frame pointer

// Save any callee-saved registers you use
stp  x19, x20, [sp, #16]
stp  x21, x22, [sp, #32]
// etc.

// Move arguments from ABI registers to their assigned locations
// (only needed if the allocator assigned them elsewhere)
mov  x19, x0    // save arg 'a' to a callee-saved reg
mov  x20, x1    // save arg 'b'
```

**Epilogue** (before return):
```arm64
// Restore callee-saved registers
ldp  x19, x20, [sp, #16]
ldp  x21, x22, [sp, #32]

// Restore frame pointer, link register, deallocate frame
ldp  x29, x30, [sp], #frame_size    // post-index: load, then sp += frame_size
ret
```

The frame size must be a multiple of 16 (AAPCS64 requires 16-byte stack alignment at all times).

### Putting It All Together

A complete example. Given:

```c
double lerp(double a, double b, double t) {
    return a + (b - a) * t;
}
```

**Step 1 — Lower to TAC:**
```
function lerp(a: f64, b: f64, t: f64) -> f64:
    t0 = b - a
    t1 = t0 * t
    t2 = a + t1
    return t2
```

**Step 2 — Register allocation:**
- `a` -> `d0` (argument register, also used in body)
- `b` -> `d1` (argument register, dead after first instruction)
- `t` -> `d2` (argument register, dead after second instruction)
- `t0` -> `d1` (reuse, b is dead)
- `t1` -> `d1` (reuse, t0 is dead)
- `t2` -> `d0` (reuse, a is dead; also happens to be the return register)

**Step 3 — Emit ARM64:**
```arm64
_lerp:
    ; prologue (leaf function, no frame needed)
    ; a=d0, b=d1, t=d2

    fsub d1, d1, d0     ; t0 = b - a
    fmul d1, d1, d2     ; t1 = t0 * t
    fadd d0, d0, d1     ; t2 = a + t1  (result already in d0)
    ret
```

Three instructions. No stack frame because it is a leaf function (does not call anything) and uses no callee-saved registers.

A more complex example with a call:

```c
int compute(int x, int y) {
    int a = x * 2;
    int b = helper(a, y);
    return a + b;
}
```

**TAC:**
```
function compute(x: i32, y: i32) -> i32:
    t0 = x * 2
    a  = t0
    param a
    param y
    b  = call helper, 2
    t1 = a + b
    return t1
```

**Register allocation:**
- `x` arrives in `x0`, `y` arrives in `x1`
- `t0`/`a` = `x19` (callee-saved, because it must survive the call to `helper`)
- `y` must also survive to be passed to `helper`. It is already in `x1` which is caller-saved. Save it to `x20`.
- After `call helper`, result `b` is in `x0`. Copy to `x9`.
- `t1` = `x0` (can write directly to return register)

**ARM64:**
```arm64
_compute:
    stp  x29, x30, [sp, #-32]!  ; save fp, lr, allocate frame
    mov  x29, sp
    stp  x19, x20, [sp, #16]    ; save callee-saved regs we use

    lsl  x19, x0, #1            ; a = x * 2  (x19 survives the call)
    mov  x20, x1                ; save y     (x20 survives the call)

    mov  x0, x19                ; arg 0 = a
    mov  x1, x20                ; arg 1 = y
    bl   _helper                ; b = helper(a, y), result in x0

    add  x0, x19, x0            ; return a + b (result in x0)

    ldp  x19, x20, [sp, #16]   ; restore callee-saved
    ldp  x29, x30, [sp], #32   ; restore fp, lr, deallocate
    ret
```

### Variadic Functions

For variadic functions (like `printf`), AAPCS64 requires that all variadic arguments are passed on the stack (or in registers, depending on the platform variant). On Apple ARM64 (arm64e), **all variadic arguments go on the stack**, regardless of type. The fixed arguments still go in registers as normal.

```c
printf("%d %f\n", 42, 3.14);
```

```arm64
    ; Fixed arg: format string in x0
    adrp x0, fmt@PAGE
    add  x0, x0, fmt@PAGEOFF

    ; Variadic args go on stack (Apple ABI)
    mov  x9, #42
    str  x9, [sp]              ; first variadic arg (int)
    fmov d0, #3.14
    str  d0, [sp, #8]          ; second variadic arg (double)

    bl   _printf
```

### Struct Passing

Small structs (<= 16 bytes, no more than 4 float members) are passed in registers. Larger structs are passed by pointer.

**Returning structs:**
- <= 16 bytes: packed into `x0`/`x1` (or `d0`-`d3` for HFA — homogeneous floating-point aggregates)
- \> 16 bytes: caller allocates space, passes pointer in `x8`. Callee writes to `[x8]`.

```c
typedef struct { int x, y; } Point;   // 8 bytes, fits in x0

Point make_point(int a, int b) {
    return (Point){a, b};
}
```

```arm64
_make_point:
    ; a in w0, b in w1
    ; Pack into x0: low 32 bits = x, high 32 bits = y
    orr  x0, x0, x1, lsl #32
    ret
```

## Summary

The pipeline is:

```
AST  --[lower]-->  TAC  --[allocate regs]-->  TAC with registers  --[emit]-->  ARM64
```

**Lowering** is a recursive tree walk that flattens expressions into temporaries. Each AST node type has a small, self-contained lowering rule.

**Register allocation** maps temporaries to physical registers. Start with something trivial (spill everything, or a simple linear scan) and improve later.

**Emission** is a linear scan over the TAC list. Each instruction maps to 1-3 ARM64 instructions. The AAPCS64 calling convention dictates where arguments and return values go.

The entire backend — allocation, emission, prologue/epilogue — stays simple because it only ever sees flat three-address instructions. It never has to pattern-match nested expression trees or figure out evaluation order. That complexity lives entirely in the lowering pass, where it is a natural fit for recursive tree traversal.
