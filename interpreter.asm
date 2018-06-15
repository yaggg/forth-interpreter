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
xt_selector: dq .selector
.selector: dq selector 

last_word: dq _lw   ; stores a pointer to the last word in dictionary
here: dq dict       ; current position in words memory; 
dp: dq mem          ; current global data pointer 

section .bss

resq 1023
rstack_start: resq 1
dict:  resq 65536   ; data for words
mem: resq 65536     ; global data for user
state: resq 1       ; changes to 1 if compiling, 0 by default
input_buf: resb 1024


section .text

_start:
   mov rstack, rstack_start
   mov pc, xt_selector
   jmp next

next: 
    mov w, pc
    add pc, 8
    mov w, [w]
    jmp [w]

selector:
   mov rax, [state]
   test rax, rax
   je interpreter_loop
   jmp compiler_loop



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
   mov pc, xt_selector
   mov rdi, not_found
   call print_string
   jmp next
.return_noprint:
   mov pc, xt_selector
   jmp next

compiler_loop:
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
   push rdi
   call cfa_func
   pop rdi
   mov r8, rax
   call check_immediate 
   test rax, rax
   jne .immediate
   mov [here], r8
   add qword[here], 8
   mov pc, xt_selector
   jmp next
.immediate:
   mov [program_stub], r8
   mov pc, program_stub
   jmp next
.not_found:
   mov rdi, rsi
   push rdi
   call string_length
   pop rdi
   cmp rax, 0
   je .return_empty_line
   push rax
   call parse_int
   pop r8
   cmp rdx, r8
   jne .return_not_found
   sub qword[here], 8
   mov r8, [here]
   cmp r8, xt_branch
   je .branch
   cmp r8, xt_branch0
   je .branch
   add qword[here], 8
   mov qword[here], xt_lit
   add qword[here], 8
   mov [here], rax
   add qword[here], 8
   mov pc, xt_selector
   jmp next
.branch:
   add qword[here], 8
   mov [here], rax
   add qword[here], 8
   mov pc, xt_selector
   jmp next
.return_not_found:
   mov pc, xt_selector
   mov rdi, not_found
   call print_string
   jmp next
.return_empty_line:
   mov pc, xt_selector
   jmp next
