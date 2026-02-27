.globl _main
.p2align 2

; ======== function: modify_global() ========
_modify_global:
    ; --- prologue (stack: 32 bytes) ---
    mov x9, #32
    sub sp, sp, x9
    str x30, [sp, #16]
    str x29, [sp, #24]
    add x29, sp, #0

    ; --- body ---
    ; --- params ---
    ; param 'val'
    str x0, [sp, #0]

    ; stmt: expr
    ; expr: assign (op: =)
    ; expr: load 'val'
    ; lvalue: local 'val' at sp+0
    mov x12, #0
    add x9, sp, x12
    ldr w9, [x9]
    ; push intermediate -> sp+8
    str w9, [sp, #8]
    ; lvalue: global 'g_int'
    adrp x9, _g_int@PAGE
    add x9, x9, _g_int@PAGEOFF
    ; pop intermediate <- sp+8
    ldr w10, [sp, #8]
    ; assign: store to [x9]
    str w10, [x9]

    _modify_global_epilogue:
    ; --- epilogue ---
    ldr x30, [sp, #16]
    ldr x29, [sp, #24]
    mov x9, #32
    add sp, sp, x9
    ret

; ======== function: read_global() ========
_read_global:
    ; --- prologue (stack: 16 bytes) ---
    mov x9, #16
    sub sp, sp, x9
    str x30, [sp, #0]
    str x29, [sp, #8]
    add x29, sp, #0

    ; --- body ---

    ; stmt: return
    ; expr: load 'g_int'
    ; lvalue: global 'g_int'
    adrp x9, _g_int@PAGE
    add x9, x9, _g_int@PAGEOFF
    ldr w9, [x9]
    mov x0, x9
    b _read_global_epilogue

    _read_global_epilogue:
    ; --- epilogue ---
    ldr x30, [sp, #0]
    ldr x29, [sp, #8]
    mov x9, #16
    add sp, sp, x9
    ret

; ======== function: main() ========
_main:
    ; --- prologue (stack: 64 bytes) ---
    mov x9, #64
    sub sp, sp, x9
    str x30, [sp, #48]
    str x29, [sp, #56]
    add x29, sp, #0

    ; --- body ---
    ; --- params ---
    ; param 'argc'
    str x0, [sp, #0]
    ; param 'args'
    str x1, [sp, #8]

    ; stmt: expr
    ; expr: call printf() (1 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str@PAGE
    add x9, x9, l_.str@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; load args into registers
    ldr x0, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0

    ; stmt: expr
    ; expr: cast (Integral -> Integral)

    ; stmt: if
    ; expr: binary '=='
    ; expr: load 'g_int'
    ; lvalue: global 'g_int'
    adrp x9, _g_int@PAGE
    add x9, x9, _g_int@PAGEOFF
    ldr w9, [x9]
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 42
    movz w9, #42
    movk w9, #0, lsl #16
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    cmp w10, w9
    cset w9, eq
    cbz w9, _IF_ON_FALSE0
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    b _IF_END0
    _IF_ON_FALSE0:
    ; expr: binary ','
    ; expr: cast (Integral -> Integral)
    ; expr: call printf() (4 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.1@PAGE
    add x9, x9, l_.str.1@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; arg 1 eval
    ; expr: string literal
    adrp x9, l_.str.2@PAGE
    add x9, x9, l_.str.2@PAGEOFF
    ; push intermediate -> sp+24
    str x9, [sp, #24]
    ; arg 2 eval
    ; expr: number literal 22
    movz w9, #22
    movk w9, #0, lsl #16
    ; push intermediate -> sp+32
    str w9, [sp, #32]
    ; arg 3 eval
    ; expr: string literal
    adrp x9, l_.str.3@PAGE
    add x9, x9, l_.str.3@PAGEOFF
    ; push intermediate -> sp+40
    str x9, [sp, #40]
    ; load args into registers
    ldr x0, [sp, #16]
    ldr x10, [sp, #24]
    str x10, [sp, #0]
    ldr x10, [sp, #32]
    str x10, [sp, #8]
    ldr x10, [sp, #40]
    str x10, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: call abort() (0 args)
    ; load args into registers
    ; call abort
    bl _abort
    ; return value from abort
    mov w9, w0
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    _IF_END0:

    ; stmt: expr
    ; expr: call printf() (1 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.4@PAGE
    add x9, x9, l_.str.4@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; load args into registers
    ldr x0, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0

    ; stmt: expr
    ; expr: cast (Integral -> Integral)

    ; stmt: if
    ; expr: binary '&&'
    ; expr: binary '>'
    ; expr: load 'g_double'
    ; lvalue: global 'g_double'
    adrp x9, _g_double@PAGE
    add x9, x9, _g_double@PAGEOFF
    ldr d9, [x9]
    ; push intermediate -> sp+16
    str d9, [sp, #16]
    ; expr: cast (Floating -> Floating)
    ; expr: number literal 4614230552474550272
    movz x9, #0, lsl #0
    movk x9, #32768, lsl #16
    movk x9, #2621, lsl #32
    movk x9, #16393, lsl #48
    fmov d9, x9
    ; pop intermediate <- sp+16
    ldr d10, [sp, #16]
    fcmp d10, d9
    cset w9, gt
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    cbz w9, _IF_ON_FALSE2
    ; expr: binary '<'
    ; expr: load 'g_double'
    ; lvalue: global 'g_double'
    adrp x9, _g_double@PAGE
    add x9, x9, _g_double@PAGEOFF
    ldr d9, [x9]
    ; push intermediate -> sp+24
    str d9, [sp, #24]
    ; expr: cast (Floating -> Floating)
    ; expr: number literal 4614275588427874304
    movz x9, #0, lsl #0
    movk x9, #16384, lsl #16
    movk x9, #13107, lsl #32
    movk x9, #16393, lsl #48
    fmov d9, x9
    ; pop intermediate <- sp+24
    ldr d10, [sp, #24]
    fcmp d10, d9
    cset w9, lt
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    cmp w9, #0
    cset w9, ne
    b _IF_END2
    _IF_ON_FALSE2:
    mov w9, #0
    _IF_END2:
    cbz w9, _IF_ON_FALSE1
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    b _IF_END1
    _IF_ON_FALSE1:
    ; expr: binary ','
    ; expr: cast (Integral -> Integral)
    ; expr: call printf() (4 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.1@PAGE
    add x9, x9, l_.str.1@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; arg 1 eval
    ; expr: string literal
    adrp x9, l_.str.2@PAGE
    add x9, x9, l_.str.2@PAGEOFF
    ; push intermediate -> sp+24
    str x9, [sp, #24]
    ; arg 2 eval
    ; expr: number literal 28
    movz w9, #28
    movk w9, #0, lsl #16
    ; push intermediate -> sp+32
    str w9, [sp, #32]
    ; arg 3 eval
    ; expr: string literal
    adrp x9, l_.str.5@PAGE
    add x9, x9, l_.str.5@PAGEOFF
    ; push intermediate -> sp+40
    str x9, [sp, #40]
    ; load args into registers
    ldr x0, [sp, #16]
    ldr x10, [sp, #24]
    str x10, [sp, #0]
    ldr x10, [sp, #32]
    str x10, [sp, #8]
    ldr x10, [sp, #40]
    str x10, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: call abort() (0 args)
    ; load args into registers
    ; call abort
    bl _abort
    ; return value from abort
    mov w9, w0
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    _IF_END1:

    ; stmt: expr
    ; expr: call printf() (1 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.6@PAGE
    add x9, x9, l_.str.6@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; load args into registers
    ldr x0, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0

    ; stmt: expr
    ; expr: cast (Integral -> Integral)

    ; stmt: if
    ; expr: binary '=='
    ; expr: array access
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: load 'g_arr'
    ; lvalue: global 'g_arr'
    adrp x9, _g_arr@PAGE
    add x9, x9, _g_arr@PAGEOFF
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    ; element size = 4
    sxtw x10, w10
    movz x11, #4, lsl #0
    movk x11, #0, lsl #16
    movk x11, #0, lsl #32
    movk x11, #0, lsl #48
    mul x10, x10, x11
    add x9, x9, x10
    ldr w9, [x9]
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 10
    movz w9, #10
    movk w9, #0, lsl #16
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    cmp w10, w9
    cset w9, eq
    cbz w9, _IF_ON_FALSE3
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    b _IF_END3
    _IF_ON_FALSE3:
    ; expr: binary ','
    ; expr: cast (Integral -> Integral)
    ; expr: call printf() (4 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.1@PAGE
    add x9, x9, l_.str.1@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; arg 1 eval
    ; expr: string literal
    adrp x9, l_.str.2@PAGE
    add x9, x9, l_.str.2@PAGEOFF
    ; push intermediate -> sp+24
    str x9, [sp, #24]
    ; arg 2 eval
    ; expr: number literal 34
    movz w9, #34
    movk w9, #0, lsl #16
    ; push intermediate -> sp+32
    str w9, [sp, #32]
    ; arg 3 eval
    ; expr: string literal
    adrp x9, l_.str.7@PAGE
    add x9, x9, l_.str.7@PAGEOFF
    ; push intermediate -> sp+40
    str x9, [sp, #40]
    ; load args into registers
    ldr x0, [sp, #16]
    ldr x10, [sp, #24]
    str x10, [sp, #0]
    ldr x10, [sp, #32]
    str x10, [sp, #8]
    ldr x10, [sp, #40]
    str x10, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: call abort() (0 args)
    ; load args into registers
    ; call abort
    bl _abort
    ; return value from abort
    mov w9, w0
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    _IF_END3:

    ; stmt: expr
    ; expr: cast (Integral -> Integral)

    ; stmt: if
    ; expr: binary '=='
    ; expr: array access
    ; expr: number literal 1
    movz w9, #1
    movk w9, #0, lsl #16
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: load 'g_arr'
    ; lvalue: global 'g_arr'
    adrp x9, _g_arr@PAGE
    add x9, x9, _g_arr@PAGEOFF
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    ; element size = 4
    sxtw x10, w10
    movz x11, #4, lsl #0
    movk x11, #0, lsl #16
    movk x11, #0, lsl #32
    movk x11, #0, lsl #48
    mul x10, x10, x11
    add x9, x9, x10
    ldr w9, [x9]
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 20
    movz w9, #20
    movk w9, #0, lsl #16
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    cmp w10, w9
    cset w9, eq
    cbz w9, _IF_ON_FALSE4
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    b _IF_END4
    _IF_ON_FALSE4:
    ; expr: binary ','
    ; expr: cast (Integral -> Integral)
    ; expr: call printf() (4 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.1@PAGE
    add x9, x9, l_.str.1@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; arg 1 eval
    ; expr: string literal
    adrp x9, l_.str.2@PAGE
    add x9, x9, l_.str.2@PAGEOFF
    ; push intermediate -> sp+24
    str x9, [sp, #24]
    ; arg 2 eval
    ; expr: number literal 35
    movz w9, #35
    movk w9, #0, lsl #16
    ; push intermediate -> sp+32
    str w9, [sp, #32]
    ; arg 3 eval
    ; expr: string literal
    adrp x9, l_.str.8@PAGE
    add x9, x9, l_.str.8@PAGEOFF
    ; push intermediate -> sp+40
    str x9, [sp, #40]
    ; load args into registers
    ldr x0, [sp, #16]
    ldr x10, [sp, #24]
    str x10, [sp, #0]
    ldr x10, [sp, #32]
    str x10, [sp, #8]
    ldr x10, [sp, #40]
    str x10, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: call abort() (0 args)
    ; load args into registers
    ; call abort
    bl _abort
    ; return value from abort
    mov w9, w0
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    _IF_END4:

    ; stmt: expr
    ; expr: cast (Integral -> Integral)

    ; stmt: if
    ; expr: binary '=='
    ; expr: array access
    ; expr: number literal 2
    movz w9, #2
    movk w9, #0, lsl #16
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: load 'g_arr'
    ; lvalue: global 'g_arr'
    adrp x9, _g_arr@PAGE
    add x9, x9, _g_arr@PAGEOFF
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    ; element size = 4
    sxtw x10, w10
    movz x11, #4, lsl #0
    movk x11, #0, lsl #16
    movk x11, #0, lsl #32
    movk x11, #0, lsl #48
    mul x10, x10, x11
    add x9, x9, x10
    ldr w9, [x9]
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 30
    movz w9, #30
    movk w9, #0, lsl #16
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    cmp w10, w9
    cset w9, eq
    cbz w9, _IF_ON_FALSE5
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    b _IF_END5
    _IF_ON_FALSE5:
    ; expr: binary ','
    ; expr: cast (Integral -> Integral)
    ; expr: call printf() (4 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.1@PAGE
    add x9, x9, l_.str.1@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; arg 1 eval
    ; expr: string literal
    adrp x9, l_.str.2@PAGE
    add x9, x9, l_.str.2@PAGEOFF
    ; push intermediate -> sp+24
    str x9, [sp, #24]
    ; arg 2 eval
    ; expr: number literal 36
    movz w9, #36
    movk w9, #0, lsl #16
    ; push intermediate -> sp+32
    str w9, [sp, #32]
    ; arg 3 eval
    ; expr: string literal
    adrp x9, l_.str.9@PAGE
    add x9, x9, l_.str.9@PAGEOFF
    ; push intermediate -> sp+40
    str x9, [sp, #40]
    ; load args into registers
    ldr x0, [sp, #16]
    ldr x10, [sp, #24]
    str x10, [sp, #0]
    ldr x10, [sp, #32]
    str x10, [sp, #8]
    ldr x10, [sp, #40]
    str x10, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: call abort() (0 args)
    ; load args into registers
    ; call abort
    bl _abort
    ; return value from abort
    mov w9, w0
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    _IF_END5:

    ; stmt: expr
    ; expr: call printf() (1 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.10@PAGE
    add x9, x9, l_.str.10@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; load args into registers
    ldr x0, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0

    ; stmt: expr
    ; expr: call modify_global() (1 args)
    ; arg 0 eval
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 99
    movz w9, #99
    movk w9, #0, lsl #16
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; load args into registers
    ldr w0, [sp, #16]
    ; call modify_global
    bl _modify_global
    ; return value from modify_global
    mov w9, w0

    ; stmt: expr
    ; expr: cast (Integral -> Integral)

    ; stmt: if
    ; expr: binary '=='
    ; expr: load 'g_int'
    ; lvalue: global 'g_int'
    adrp x9, _g_int@PAGE
    add x9, x9, _g_int@PAGEOFF
    ldr w9, [x9]
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 99
    movz w9, #99
    movk w9, #0, lsl #16
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    cmp w10, w9
    cset w9, eq
    cbz w9, _IF_ON_FALSE6
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    b _IF_END6
    _IF_ON_FALSE6:
    ; expr: binary ','
    ; expr: cast (Integral -> Integral)
    ; expr: call printf() (4 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.1@PAGE
    add x9, x9, l_.str.1@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; arg 1 eval
    ; expr: string literal
    adrp x9, l_.str.2@PAGE
    add x9, x9, l_.str.2@PAGEOFF
    ; push intermediate -> sp+24
    str x9, [sp, #24]
    ; arg 2 eval
    ; expr: number literal 43
    movz w9, #43
    movk w9, #0, lsl #16
    ; push intermediate -> sp+32
    str w9, [sp, #32]
    ; arg 3 eval
    ; expr: string literal
    adrp x9, l_.str.11@PAGE
    add x9, x9, l_.str.11@PAGEOFF
    ; push intermediate -> sp+40
    str x9, [sp, #40]
    ; load args into registers
    ldr x0, [sp, #16]
    ldr x10, [sp, #24]
    str x10, [sp, #0]
    ldr x10, [sp, #32]
    str x10, [sp, #8]
    ldr x10, [sp, #40]
    str x10, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: call abort() (0 args)
    ; load args into registers
    ; call abort
    bl _abort
    ; return value from abort
    mov w9, w0
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    _IF_END6:

    ; stmt: expr
    ; expr: cast (Integral -> Integral)

    ; stmt: if
    ; expr: binary '=='
    ; expr: call read_global() (0 args)
    ; load args into registers
    ; call read_global
    bl _read_global
    ; return value from read_global
    mov w9, w0
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 99
    movz w9, #99
    movk w9, #0, lsl #16
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    cmp w10, w9
    cset w9, eq
    cbz w9, _IF_ON_FALSE7
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    b _IF_END7
    _IF_ON_FALSE7:
    ; expr: binary ','
    ; expr: cast (Integral -> Integral)
    ; expr: call printf() (4 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.1@PAGE
    add x9, x9, l_.str.1@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; arg 1 eval
    ; expr: string literal
    adrp x9, l_.str.2@PAGE
    add x9, x9, l_.str.2@PAGEOFF
    ; push intermediate -> sp+24
    str x9, [sp, #24]
    ; arg 2 eval
    ; expr: number literal 44
    movz w9, #44
    movk w9, #0, lsl #16
    ; push intermediate -> sp+32
    str w9, [sp, #32]
    ; arg 3 eval
    ; expr: string literal
    adrp x9, l_.str.12@PAGE
    add x9, x9, l_.str.12@PAGEOFF
    ; push intermediate -> sp+40
    str x9, [sp, #40]
    ; load args into registers
    ldr x0, [sp, #16]
    ldr x10, [sp, #24]
    str x10, [sp, #0]
    ldr x10, [sp, #32]
    str x10, [sp, #8]
    ldr x10, [sp, #40]
    str x10, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: call abort() (0 args)
    ; load args into registers
    ; call abort
    bl _abort
    ; return value from abort
    mov w9, w0
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    _IF_END7:

    ; stmt: expr
    ; expr: call printf() (1 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.13@PAGE
    add x9, x9, l_.str.13@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; load args into registers
    ldr x0, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0

    ; stmt: expr
    ; expr: cast (Integral -> Integral)

    ; stmt: if
    ; expr: binary '=='
    ; expr: load 'g_zero'
    ; lvalue: global 'g_zero'
    adrp x9, _g_zero@PAGE
    add x9, x9, _g_zero@PAGEOFF
    ldr w9, [x9]
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    cmp w10, w9
    cset w9, eq
    cbz w9, _IF_ON_FALSE8
    ; expr: cast (Integral -> Integral)
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    b _IF_END8
    _IF_ON_FALSE8:
    ; expr: binary ','
    ; expr: cast (Integral -> Integral)
    ; expr: call printf() (4 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.1@PAGE
    add x9, x9, l_.str.1@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; arg 1 eval
    ; expr: string literal
    adrp x9, l_.str.2@PAGE
    add x9, x9, l_.str.2@PAGEOFF
    ; push intermediate -> sp+24
    str x9, [sp, #24]
    ; arg 2 eval
    ; expr: number literal 50
    movz w9, #50
    movk w9, #0, lsl #16
    ; push intermediate -> sp+32
    str w9, [sp, #32]
    ; arg 3 eval
    ; expr: string literal
    adrp x9, l_.str.14@PAGE
    add x9, x9, l_.str.14@PAGEOFF
    ; push intermediate -> sp+40
    str x9, [sp, #40]
    ; load args into registers
    ldr x0, [sp, #16]
    ldr x10, [sp, #24]
    str x10, [sp, #0]
    ldr x10, [sp, #32]
    str x10, [sp, #8]
    ldr x10, [sp, #40]
    str x10, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0
    ; push intermediate -> sp+16
    str w9, [sp, #16]
    ; expr: call abort() (0 args)
    ; load args into registers
    ; call abort
    bl _abort
    ; return value from abort
    mov w9, w0
    ; pop intermediate <- sp+16
    ldr w10, [sp, #16]
    _IF_END8:

    ; stmt: expr
    ; expr: call printf() (1 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.15@PAGE
    add x9, x9, l_.str.15@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; load args into registers
    ldr x0, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0

    ; stmt: expr
    ; expr: call printf() (1 args)
    ; arg 0 eval
    ; expr: string literal
    adrp x9, l_.str.16@PAGE
    add x9, x9, l_.str.16@PAGEOFF
    ; push intermediate -> sp+16
    str x9, [sp, #16]
    ; load args into registers
    ldr x0, [sp, #16]
    ; call printf
    bl _printf
    ; return value from printf
    mov w9, w0

    ; stmt: return
    ; expr: number literal 0
    movz w9, #0
    movk w9, #0, lsl #16
    mov x0, x9
    b _main_epilogue

    _main_epilogue:
    ; --- epilogue ---
    ldr x30, [sp, #48]
    ldr x29, [sp, #56]
    mov x9, #64
    add sp, sp, x9
    ret
l_.str.2:
    .asciz "/Users/olivercruickshank/glep/tests/test_globals.c"
l_.str.4:
    .asciz "  global int read: PASS\n"
l_.str.1:
    .asciz "%s:%d: failed assertion `%s'\n"
l_.str.12:
    .asciz "read_global()==99"
l_.str.14:
    .asciz "g_zero==0"
l_.str.10:
    .asciz "  global array read: PASS\n"
l_.str.11:
    .asciz "g_int==99"
l_.str:
    .asciz "=== test_globals ===\n"
l_.str.16:
    .asciz "=== test_globals: ALL PASS ===\n"
l_.str.6:
    .asciz "  global double read: PASS\n"
l_.str.15:
    .asciz "  zero-init global: PASS\n"
l_.str.3:
    .asciz "g_int==42"
l_.str.13:
    .asciz "  global modify via function: PASS\n"
l_.str.5:
    .asciz "g_double>3.13&&g_double<3.15"
l_.str.8:
    .asciz "g_arr[1]==20"
l_.str.7:
    .asciz "g_arr[0]==10"
l_.str.9:
    .asciz "g_arr[2]==30"
.data
.globl ___stdinp
.globl ___stdoutp
.globl ___stderrp
.globl _sys_nerr
.globl _sys_errlist
.globl _g_int
_g_int:
    .byte 42
    .byte 0
    .byte 0
    .byte 0
.globl _g_double
_g_double:
    .byte 0
    .byte 0
    .byte 0
    .byte 96
    .byte 184
    .byte 30
    .byte 9
    .byte 64
.globl _g_arr
_g_arr:
    .byte 10
    .byte 0
    .byte 0
    .byte 0
    .byte 20
    .byte 0
    .byte 0
    .byte 0
    .byte 30
    .byte 0
    .byte 0
    .byte 0
.globl _g_zero
_g_zero:
    .byte 0
    .byte 0
    .byte 0
    .byte 0
