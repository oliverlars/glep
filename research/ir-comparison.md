# Intermediate Representations for a Small C Compiler

## The Options

### 1. Three-Address Code (TAC)

Each instruction has at most three addresses: two operands, one result. Expressions get flattened into `x = y op z` steps with explicit temporaries.

```
t1 = b * c
t2 = a + t1
x  = t2
```

**Simplicity:** Dead simple. Just flatten the AST into temporaries with a recursive walk.
**Reasoning:** Very easy to read — it looks like simple pseudocode.
**Register allocation:** Need to build use-def chains yourself. Variables can be reassigned, so liveness analysis is a separate pass.
**Optimizations:** Constant folding, dead code elimination, CSE are all straightforward. But no SSA property means you need extra bookkeeping for dataflow.

**References:**
- Dragon Book (Aho, Lam, Sethi, Ullman) — the canonical reference
- [Stanford CS143 TAC examples](https://web.stanford.edu/class/archive/cs/cs143/cs143.1128/handouts/240%20TAC%20Examples.pdf)

---

### 2. SSA (Static Single Assignment)

Each variable assigned exactly once. When control flow merges, phi functions select values. Every use has exactly one definition, making dataflow analysis trivial.

```
%t1 =w mul %b, %c
%x  =w add %a, %t1
ret %x
```

With control flow:
```
@entry
  %x0 =w copy 0
  jnz %cond, @then, @else
@then
  %x1 =w add %x0, 1
  jmp @merge
@else
  %x2 =w add %x0, 2
  jmp @merge
@merge
  %x3 =w phi @then %x1, @else %x2
```

**Simplicity:** The Braun algorithm (what QBE uses) constructs SSA directly from the AST without computing dominance frontiers. Removes most of the traditional complexity.
**Reasoning:** One definition per variable. If you see `%x3`, there is exactly one place it was defined. Phi functions take getting used to but are logical.
**Register allocation:** Trivially good — each SSA name is a natural candidate for a register. Linear scan works well.
**Optimizations:** Constant propagation, dead code elimination, copy propagation, and GVN all become simple because use-def chains are free.

**References:**
- [Simple and Efficient Construction of SSA — Braun et al. (2013)](https://c9x.me/compile/bib/braun13cc.pdf) — the key paper. Build SSA without dominance frontiers.
- [SSA is Functional Programming — Appel](https://www.cs.princeton.edu/~appel/papers/ssafun.pdf)
- [Understanding SSA Forms — yossarian.net](https://blog.yossarian.net/2020/10/23/Understanding-static-single-assignment-forms)

---

### 3. A-Normal Form (ANF)

From functional PL. All arguments to operations must be "atomic" (constants or variables), so intermediates are let-bound. Evaluation order is explicit in the nesting.

```
let t1 = b * c in
let x  = a + t1 in
...
```

**Simplicity:** Conceptually close to TAC. Each let-binding is one instruction.
**Reasoning:** Very clear — reads top to bottom.
**Register allocation:** Similar to TAC. Need liveness analysis.
**Optimizations:** Same as TAC. But ANF is not closed under reduction — optimising can break the normal form, requiring re-normalisation.

**Bad fit for C.** No natural way to model gotos, loops, or mutation. Designed for functional languages.

**References:**
- [The Essence of Compiling with Continuations — Flanagan et al. (1993)](https://dl.acm.org/doi/10.1145/155090.155113)
- [A-Normalization: Why and How — Matt Might](https://matt.might.net/articles/a-normalization/)

---

### 4. CPS (Continuation Passing Style)

Every function takes an extra "continuation" argument — what to do next. No function ever returns. Control flow is explicit in the continuation structure.

```
mul(b, c, fn(t1) =>
  add(a, t1, fn(x) =>
    ...))
```

**Simplicity:** High conceptual overhead. Deeply rooted in lambda calculus.
**Reasoning:** Hard to read for imperative programmers. Powerful but alien.
**Register allocation:** Formally equivalent to SSA, so same benefits — but wrapped in more abstraction.
**Optimizations:** All SSA optimisations apply (they are mathematically equivalent). Tail calls and contification fall out naturally.

**Bad fit for C.** CPS transformation is non-trivial, closures are awkward, and it is far more machinery than a C compiler needs.

**References:**
- [Compiling with Continuations — Appel (1992)](https://www.cambridge.org/core/books/compiling-with-continuations/7CA9C36DCE78AD82218E745F43A4E740)
- [A Correspondence Between CPS and SSA — Kelsey](https://bernsteinbear.com/assets/img/kelsey-ssa-cps.pdf)

---

### 5. Sea of Nodes

Graph-based IR where data and control flow are edges in a single graph. Nodes float freely, ordered only by their actual dependencies. Used in HotSpot C2 and V8 TurboFan.

```
[Param:a] ---\
              +--> [Add] --> [result: x]
[Mul] -------/
 ^  ^
 |  |
[Param:b] [Param:c]
```

**Simplicity:** Extremely complex. V8 is actively abandoning it.
**Reasoning:** Graphs are hard to read and debug. V8 found effect chains to be "very error-prone".
**Register allocation:** Requires scheduling back to a linear order first, which is itself a hard problem.
**Optimizations:** Code motion and CSE fall out of the graph structure. But C has so many side effects that most nodes end up pinned to the control chain anyway.

**Do not use this.** No small compiler uses it. V8 found 2x compilation slowdowns and is replacing it with a CFG-based IR (Turboshaft).

**References:**
- [A Simple Graph-Based IR — Click & Paleczny (1995)](https://www.oracle.com/technetwork/java/javase/tech/c2-ir95-150110.pdf)
- [Land ahoy: leaving the Sea of Nodes — V8 blog](https://v8.dev/blog/leaving-the-sea-of-nodes)
- [SeaOfNodes/Simple — pedagogical implementation by Cliff Click](https://github.com/SeaOfNodes/Simple)

---

### 6. Stack-Based IR

Operations on an implicit operand stack. Push operands, operations pop inputs and push results. Used by JVM, WebAssembly, CPython.

```
push a
push b
push c
mul
add
store x
```

**Simplicity:** Trivial to generate — just do a post-order AST walk.
**Reasoning:** Easy to follow if you think in terms of a stack. But data dependencies are implicit in stack position.
**Register allocation:** The stack *is* the allocation, but converting to register-based machine code (ARM64) requires a separate pass that essentially re-does register allocation.
**Optimizations:** Hard. Dataflow analysis requires reconstructing what is where on the stack. TCC uses this approach and produces notably poor code.

**References:**
- [WebAssembly Specification](https://webassembly.github.io/spec/core/)
- [Intermediate Representations — Ray Toal](https://cs.lmu.edu/~ray/notes/ir/)

---

### 7. QBE's IR

A textual SSA IR with four base types (`w` 32-bit, `l` 64-bit, `s` float, `d` double), sigils (`%` temporaries, `$` globals, `@` labels, `:` aggregates), and three-address instructions. Designed to be the minimum viable SSA backend.

```
function w $compute(w %a, w %b, w %c) {
@start
    %t1 =w mul %b, %c
    %x  =w add %a, %t1
    ret %x
}
```

**Simplicity:** ~12k lines of C for the entire backend. Textual format is human-readable. Uses the Braun algorithm — no dominance frontiers needed.
**Reasoning:** Reads like annotated assembly. Types on every instruction. Very clear.
**Register allocation:** Linear scan on SSA form. Smart spilling with loop analysis.
**Optimizations:** Copy elimination, sparse conditional constant propagation, dead instruction elimination. Gets ~70% of LLVM's code quality.

**This is the gold standard for a small compiler.** Study this one most closely.

**References:**
- [QBE — c9x.me/compile](https://c9x.me/compile/)
- [QBE IL Documentation](https://c9x.me/compile/doc/il.html)
- [QBE FOSDEM 2022 slides (Drew DeVault)](https://archive.fosdem.org/2022/schedule/event/lg_qbe/attachments/slides/4878/export/events/attachments/lg_qbe/slides/4878/qbe.pdf)

---

## What Small C Compilers Actually Do

| Compiler | IR | Lines | Notes |
|----------|-----|------:|-------|
| chibicc  | None (AST -> asm) | ~9k | No optimisation. Author (Rui Ueyama) also wrote 8cc. |
| 8cc      | None (AST -> asm) | ~6k | Ueyama later said he'd "introduce an IR early on" if rewriting. |
| tcc      | None (value stack) | ~20k | Fastest compile, worst codegen. One-pass. |
| lcc      | DAGs + BURG tree matching | ~12k | Retargetable. Pattern-based instruction selection. |
| cproc    | QBE IL (SSA) | ~6k frontend | Emits QBE IL, delegates backend to QBE entirely. |
| QBE      | Textual SSA | ~12k | Backend only. The reference for minimal SSA. |

Key insight: **8cc's author explicitly regrets not having an IR.** The codegen pass "is probably doing too much and too complicated." This is exactly the same situation glep is in.

---

## Comparison Matrix

|                        | TAC | SSA | ANF | CPS | Sea of Nodes | Stack | QBE IL |
|------------------------|-----|-----|-----|-----|-------------|-------|--------|
| **Implementation size** | Tiny | Small | Tiny | Medium | Huge | Tiny | Small |
| **Conceptual complexity** | Low | Low-Med | Low | High | Very High | Low | Low-Med |
| **Fits C well**        | Yes | Yes | No | No | Overkill | Yes | Yes |
| **Regalloc quality**   | OK | Good | OK | Good | Good | Poor | Good |
| **Optimisation potential** | Basic | Strong | Basic | Strong | Strong | Weak | Strong |
| **Readability**        | Great | Good | Good | Poor | Poor | OK | Great |

---

## Formal Equivalences

SSA, CPS, and ANF are mathematically equivalent:
- Phi functions in SSA = lambda parameters in CPS = let-bindings in ANF
- Basic blocks in SSA = continuation definitions in CPS

This means you get the same optimisation power regardless of which you pick. The difference is purely syntactic and ergonomic.

**References:**
- [SSA is Functional Programming — Appel (1998)](https://www.cs.princeton.edu/~appel/papers/ssafun.pdf)
- [Compiling with Continuations, or without? Whatever. — Cong et al. (2019)](https://www.cs.purdue.edu/homes/rompf/papers/cong-icfp19.pdf)

---

## Recommendation

For glep (small C compiler, ARM64, ~6k lines):

**Use a simple SSA IR modelled on QBE's IL.** Specifically:

1. Read the [QBE IL documentation](https://c9x.me/compile/doc/il.html) — it is short and well-written
2. Read the [Braun et al. paper](https://c9x.me/compile/bib/braun13cc.pdf) for SSA construction
3. Study [cproc](https://sr.ht/~mcf/cproc/) for how a C frontend emits QBE IL
4. You don't need the full QBE — a subset with typed instructions, basic blocks, phi functions, and 4 types (`w`, `l`, `s`, `d`) is enough to flatten your AST and make codegen straightforward

Alternatively, if you want the absolute minimum: **plain TAC** (three-address code without SSA) is even simpler and still solves the core problem of flattening expressions out of the AST before codegen. You can always promote it to SSA later with the Braun algorithm.
