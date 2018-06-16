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

program_stub: dq 0                ; here will be word to interpret
xt_selector: dq .selector         ;
.selector: dq selector            ;

last_word: dq _lw                 ; pointer to the last word
here: dq dict                     ; current position in words memory
pointer: dq mem                   ; current global data pointer 

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
   mov pc, xt_selector
   jmp next



next: 
    mov w, pc
    add pc, 8
    mov w, [w]
    jmp [w]



selector:
   mov rax, [state]               ; choose loop
   test rax, rax                  ;
   je interpreter_loop            ;
   jmp compiler_loop              ;



interpreter_loop:
   mov rdi, input_buf             ; read word
   mov rsi, 1024                  ;
   call read_word                 ;

   mov rsi, rax                   ; check if it in dictionary
   mov rdi, last_word             ;
   push rsi                       ;
   call find_word_func            ;
   pop rsi                        ;
   cmp rax, 0                     ;
   je .not_word                   ;

.word:
   mov rdi, rax                   ; if it present, just interpret it
   call cfa_func                  ;
   mov [program_stub], rax        ;
   mov pc, program_stub           ;
   jmp next                       ;

.not_word:
   mov rdi, rsi                   ; check if line is empty
   push rdi                       ;
   call string_length             ;
   pop rdi                        ;
   cmp rax, 0                     ;
   je .empty_line                 ;

   push rax                       ; check if it an integer
   call parse_int                 ;
   pop r8                         ;
   cmp rdx, r8                    ;
   jne .not_found                 ;
   push rax                       ;
   jmp .empty_line                ;

.not_found:
   mov pc, xt_selector            ; if no such word
   mov rdi, not_found             ;
   call print_string              ;
   jmp next                       ;

.empty_line:
   mov pc, xt_selector            ; just continue
   jmp next                       ;



compiler_loop:
   mov rdi, input_buf             ; read word
   mov rsi, 1024                  ;
   call read_word                 ;

   mov rsi, rax                   ; check if it in dictionary
   mov rdi, last_word             ;
   push rsi                       ;
   call find_word_func            ;
   pop rsi                        ;
   cmp rax, 0                     ;
   je .not_word                   ;

.word:
   mov rdi, rax                   ; if present, check if it immediate
   push rdi                       ;
   call check_immediate           ;
   pop rdi                        ;
   test al, al                    ;
   jne .immediate                 ;

.add_word:
   call cfa_func                  ; if not immediate, put it xt here
   mov r9, [here]                 ;
   mov [r9], rax                  ;
   add qword[here], 8             ;
   mov pc, xt_selector            ;
   jmp next                       ;

.immediate:
   call cfa_func                  ; if immediate, jusst interpret it
   mov [program_stub], rax        ;
   mov pc, program_stub           ;
   jmp next                       ;

.not_word:
   mov rdi, rsi                   ; check if line is empty
   push rdi                       ;
   call string_length             ;
   pop rdi                        ;
   cmp rax, 0                     ;
   je .empty_line                 ;

   push rax                       ; check if it an integer
   call parse_int                 ;
   pop r8                         ;
   cmp rdx, r8                    ;
   jne .not_found                 ;

   sub qword[here], 8             ; check if prev word is branch or
   mov r8, [here]                 ; branch0
   cmp qword[r8], xt_branch       ;
   je .branch                     ;
   cmp qword[r8], xt_branch0      ;
   je .branch                     ;

.no_branch:
   add qword[here], 8             ; if no branch, put number with lit
   mov r8, [here]                 ;
   mov qword[r8], xt_lit          ;

.branch:
   add qword[here], 8             ; anyway put command here
   mov r8, [here]                 ;
   mov [r8], rax                  ;
   add qword[here], 8             ;
   mov pc, xt_selector            ;
   jmp next

.not_found:
   mov pc, xt_selector            ; if no such word
   mov rdi, not_found             ;
   call print_string              ;
   jmp next                       ;

.empty_line:
   mov pc, xt_selector            ; just continue
   jmp next                       ;
