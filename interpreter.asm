%include "util.inc"

global _start

%define pc r15
%define w r14
%define rstack r13

section .text

%include "core-functions.asm"

section .data

not_found: db "Unknown command", 10, 0
program_stub: dq 0
xt_interpreter: dq .interpreter
.interpreter: dq interpreter_loop

last_word: dq _lw   ; stores a pointer to the last word in dictionary
here: dq dict       ; current position in words memory; 
dp: dq mem          ; current global data pointer 

section .bss

resq 1023
rstack_start: resq 1
input_buf: resb 1024
dict:  resq 65536   ; data for words
mem: resq 65536     ; global data for user
state: resq 1       ; changes to 1 if compiling, 0 by default


section .text

_start:
   mov rstack, rstack_start
   mov pc, xt_interpreter
   jmp next

next: 
    mov w, pc
    add pc, 8
    mov w, [w]
    jmp [w]

interpreter_loop:
   mov rdi, input_buf
   mov rsi, 1024
   call read_word
   mov rsi, rax
   mov rdi, last_word
   push rsi
   call find_word_func
   pop rsi
   cmp rax, 0
   je .not_found
   mov rdi, rax
   call cfa_func
   mov [program_stub], rax
   mov pc, program_stub
   jmp next 
.not_found:
   mov rdi, rsi
   push rdi
   call string_length
   pop rdi
   cmp rax, 0
   je .return_noprint
   push rax
   call parse_int
   pop r8
   cmp rdx, r8
   jne .return
   push rax 
   jmp .return_noprint
.return:
   mov pc, xt_interpreter
   mov rdi, not_found
   call print_string
   jmp next
.return_noprint:
   mov pc, xt_interpreter
   jmp next

