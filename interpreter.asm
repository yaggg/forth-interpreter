%include "lib.inc"
%include "core-functions.inc"

global _start

%define pc r15
%define rstack r13

section .bss
resq 1023
rstack_start: resq 1
input_buf: resb 1024

section .text

_start:
   mov rstack, rstack_start
   mov pc, main_stub
   jmp next
