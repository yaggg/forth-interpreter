%include "macro.inc"

global _start

%define pc r15
%defne w r14
%define rstack r13

section .bss
resq 1023
rstack-start: resq 1
input-buf: resb 1024

section .text

_start:
   mov rstack, rstack-start
   mov pc, xt-interpreter 
   jmp next

program-stub: dq 0
xt-interpreter: dq .interpreter
.interpreter: dq interpreter-loop

next:
   mov w, [pc]
   add pc, 8
   jmp [w]

native drop, 0, "drop"
native swap, drop, "swap"
native rot, swap, "rot"
native dup, rot, "dup"
native not, dup, "not"
native and, not, "and"
native or, and, "or"
native land, or, "land"
native lor, land, "lor"
native dot, lor, "."
native show, dot, ".S"
native exit, show, "exit"
native to-ret, exit, ">r"
native from-ret, to-ret, "r>"
native r-fetch, from-ret, "r@"
native emit, r-fetch, "emit"
native word, emit, "word"
native number, word, "number"
native branch, number, "branch"
native branch0, branch, "branch0"
native fetch, branch0, "@"
native write, fetch, "!"
native write-char, write, "c!"
native plus, write-char, "+"
native minus, plus, "-"
native multiply, minus, "*"
native divide, multiply, "/"
native mod, divide, "%"
native equals, mod, "="
native lt, equals, "<"
native gt, lt, ">"
