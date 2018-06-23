%include "util.inc"

global _start

%define pc r15
%define w r14
%define rstack r13

;----------------------------------
section .text

%include "core-functions.asm"

;----------------------------------
section .data

not_found: db "Unknown command", 10, 0

program_stub: dq xt_selector      ; here will be word to interpret
last_word: dq _lw                 ; pointer to the last word
here: dq dict                     ; current position in words memory
pointer: dq mem                   ; current global data pointer 
stack_start: dq 0                 ; start of data stack

;----------------------------------
section .bss

resq 1023
rstack_start: resq 1              ; return adress stack

dict: resq 65536                  ; dynamic part of dictionary 
mem: resq 65536                   ; user data
state: resq 1                     ; 1 if compiling, 0 otherwise 
input_buf: resb 1024              ; for user input

;----------------------------------
section .text

_start:
   mov rstack, rstack_start
   mov [stack_start], rsp
   mov pc, program_stub 
   jmp next

next: 
    mov w, pc
    add pc, 8
    mov w, [w]
    jmp [w]
