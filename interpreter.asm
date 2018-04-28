%include "macro.inc"

global _start

%define pc r15
%defne w r14
%define rstack r13

section .bss
resq 1023
rstack_start: resq 1
input_buf: resb 1024

section .text

_start:
   mov rstack, rstack_start
   mov pc, xt_interpreter 
   jmp next

program_stub: dq 0
xt_interpreter: dq .interpreter
.interpreter: dq interpreter_loop

next:
   mov w, [pc]
   add pc, 8
   jmp [w]

interpreter_loop:
   mov rdi, input_buf
   mov rsi, 1024
   call read_word
   mov rdi, rax
   call string_length
   mov r8, rax
   cmp rax, 0
   je .return
   call find_word
   cmp rax, 0
   jne .not_found
   call cfa
   mov [program_stub], rax
   mov pc, program_stub
   jmp next 
   .not_found:
   call parse_int
   cmp r8, rdx
   jne .return
   push rax 
   .return:
      jmp next

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
native to_ret, exit, ">r"
native from_ret, to_ret, "r>"
native r_fetch, from_ret, "r@"
native emit, r_fetch, "emit"
native word, emit, "word"
native number, word, "number"
native branch, number, "branch"
native branch0, branch, "branch0"
native fetch, branch0, "@"
native write, fetch, "!"
native write_char, write, "c!"
native plus, write_char, "+"
native minus, plus, "-"
native multiply, minus, "*"
native divide, multiply, "/"
native mod, divide, "%"
native equals, mod, "="
native lt, equals, "<"
native gt, lt, ">"
native find_word, gt, "find_word"
native cfa, find_word, "cfa"
