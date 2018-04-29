%include "macro.inc"

   global _start

   extern exit
   extern string_length
   extern print_string
   extern print_char  
   extern print_newline
   extern print_uint
   extern print_int
   extern string_equals
   extern read_char
   extern read_word
   extern parse_uint
   extern parse_int
   extern string_copy 

%define pc r15
%define w r14
%define rstack r13

section .data
not_found: db "Unknown command", 10, 0

program_stub: dq 0
xt_interpreter: dq .interpreter
.interpreter: dq interpreter_loop

section .bss
resq 1023
rstack_start: resq 1
input_buf: resb 1024

section .text

_start:
   mov rstack, rstack_start
   mov pc, xt_interpreter
   jmp next

next:                  ; inner interpreter, fetches next word to execute
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
   call find_word_impl
   pop rsi
   cmp rax, 0
   je .not_found
   mov rdi, rax
   call cfa_impl
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
      pop rax
      cmp rdx, rax
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


   w_0: dq 0
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
      add rdi, 8
      push rsi
      push rdi
      call string_equals
      cmp rax, 0
      je .next
      pop rdi
      pop rsi
      sub rdi, 8
      mov rax, rdi
      ret
      .next:
          pop rdi
          pop rsi
          sub rdi, 8
          mov rdi, [rdi] 
          cmp rdi, 0  
          je .failed 
          call find_word_impl 
          ret
      .failed:
          mov rax, 0
          ret
      
   native cfa, find_word, "cfa"
       add rdi, 8
       push rdi
       call string_length
       pop rdi
       add rax, rdi
       add rax, 2
       ret

last_word:
   native bye, cfa, "bye"
      call exit
 
