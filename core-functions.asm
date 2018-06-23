%include "util.inc"
%include "macro.inc"

native drop, "drop"
   pop rax
   jmp next

native swap, "swap"
   pop rax
   pop rdx
   push rax
   push rdx
   jmp next

native rot, "rot"
   pop rax
   pop rdx
   pop rcx
   push rax
   push rcx
   push rdx
   jmp next
 
native dup, "dup"
   push qword[rsp]
   jmp next

native not, "not"
   pop rax
   test rax, rax
   jz .zero
   xor rax, rax
   push rax
   jmp next

.zero:
   mov rax, 1
   push rax
   jmp next

native and, "and"
   pop rax
   pop rdx
   and rax, rdx
   push rax
   jmp next

native or, "or"
   pop rax
   pop rdx
   or rax, rdx
   push rax
   jmp next

native land, "land"
   pop rax
   pop rdx
   test rax, rax
   jz .no
   push rdx
   jmp next

.no:
   push rax
   jmp next
  
native lor, "lor"
   pop rax
   pop rdx
   test rax, rax
   jnz .yes
   push rdx
   jmp next

.yes:
   push rax
   jmp next

native show_stack, ".S"
   mov rcx, rsp

.loop:
   cmp rcx, [stack_start]
   je next
   mov rdi, [rcx]
   push rcx
   call print_int
   call print_newline
   pop rcx
   add rcx, 8
   jmp .loop 

native to_ret, ">r"
    pop rax
    sub rstack, 8
    mov qword [rstack], rax 
    jmp next

native from_ret, "r>"
    mov rax, qword[rstack]
    add rstack, 8
    push rax
    jmp next

native ret_fetch, "r@"
    push qword [rstack]
    jmp next

native colon, ":"
   mov r8, [here]              ; put previous address firstly
   mov r9, [last_word]         ;
   mov qword[r8], r9           ;
   mov qword[last_word], r8    ; set last word to current
   add qword[here], 8          ; update here

   mov rdi, input_buf          ; read new word's name 
   mov rsi, 1024               ;
   call read_word              ;
   mov rdi, rax                ; 
   mov rsi, [here]             ; 
   mov rdx, 1024               ;
   push rsi                    ;
   call string_copy            ; put it into word defitinion
   pop rsi                     ;

   mov rdi, rsi                ; 
   call string_length          ;
   add qword[here], rax        ;
   add qword[here], 2          ; update here
   mov r8, [here]              ;
   mov qword[r8], docol_impl   ; put docol here
   add qword[here], 8          ; update here
   mov qword[state], 1         ; change state to compilation
   jmp next                    ;
   
native semicolon, ";", 1
   mov r8, [here]              ;
   mov qword[r8], xt_exit      ; put xt_exit at the end 
   add qword[here], 8          ; update here
   mov qword[state], 0         ; change state back
   jmp next                    ;

native branch, "branch"
   mov pc, [pc]
   jmp next

native branch0, "branch0"
   pop rax
   test rax, rax
   jnz .skip
   mov pc, [pc]
   jmp next

.skip:
   add pc, 8
   jmp next
 
native emit, "emit"
   pop rdi
   call print_char
   jmp next

native word, "word"
   mov rdi, input_buf
   mov rsi, 1024
   call read_word
   mov rdi, rax
   pop rsi 
   mov rdx, 1024
   call string_copy
   push rdx
   jmp next

native exit, "exit"
   mov pc, [rstack]
   add rstack, 8
   jmp next 

native docol, "docol"
   sub rstack, 8
   mov [rstack], pc
   add w, 8
   mov pc, w
   jmp next

native lit, "lit"
   push qword [pc]
   add pc, 8
   jmp next
 
native fetch, "@"
   pop rax
   mov r10, [rax] 
   push r10
   jmp next

native write, "!"
   pop rax
   pop r10
   mov [r10], rax 
   jmp next

native write_char, "c!"
   pop rax
   pop r10
   mov byte[r10], al
   jmp next

native plus, "+"
   pop r10
   pop rax 
   add rax, r10
   push rax
   jmp next
 
native minus, "-"
   pop r10
   pop rax 
   sub rax, r10
   push rax
   jmp next
   
native multiply, "*"
   pop r10
   pop rax 
   imul r10
   push rax
   jmp next
  
native divide, "/"
   pop r10
   pop rax 
   xor rdx, rdx
   idiv r10
   push rax
   jmp next
  
native mod, "%"
   pop r10
   pop rax 
   xor rdx, rdx
   idiv r10
   push rdx
   jmp next

native equals, "="
   pop rsi
   pop rdi
   cmp rdi, rsi
   je .equals
   push 0
   jmp next

.equals:
   push 1
   jmp next

native lt, "<"
   pop rsi
   pop rdi
   cmp rsi, rdi
   jg .greather
   push 0
   jmp next

.greather:
   push 1
   jmp next

native gt, ">"
   pop rsi
   pop rdi
   cmp rdi, rsi
   jg .greather
   push 0
   jmp next

.greather:
   push 1
   jmp next

native dot, "."
   pop rdi
   call print_int
   call print_newline
   jmp next 

native find_word, "find_word"
   pop rsi
   mov rdi, last_word

.loop:
   push rdi
   lea rdi, [rdi + 8]
   push rsi
   call string_equals
   pop rsi
   pop rdi
   cmp rax, 0
   je .find
   mov rdi, [rdi]
   cmp rdi, 0
   je .fail 
   jmp .loop

.find:
   mov rax, rdi
   jmp .return

.fail:
   mov rax, 0

.return:
   push rax
   jmp next

native cfa, "cfa"
   pop rdi
   lea rdi, [rdi + 8]
   push rdi
   call string_length
   pop rdi
   lea rax, [rdi + rax + 2]
   push rax
   jmp next

native bye, "bye"
   call exit

native inbuf, "inbuf"
   mov rdi, input_buf             
   mov rsi, 1024                  
   call read_word                 
   push rax
   jmp next                       

native exec, "exec"
   pop rax
   mov w, rax 
   jmp [rax]

native count, "count"
   pop rdi
   call string_length             
   push rax
   jmp next

native number, "number"
   pop rdi
   call parse_int                 
   push rdx
   push rax
   jmp next

native prints, "prints"
   pop rdi
   call print_string
   jmp next

native put_state, "put_state"
   push qword[state]
   jmp next

native add_word, "add_word"
   pop rax
   mov r9, [here]                 ; if not immediate, put it xt here
   mov [r9], rax                  ;
   add qword[here], 8             ;
   jmp next                       ;

native immediate, "immediate"
   pop rdi
   lea rdi, [rdi + 8]
   call string_length
   lea rax, [rdi + rax + 1]
   mov rdi, rax
   xor rax, rax
   mov al, byte[rdi]
   push rax
   jmp next

native check_branch, "check_branch"
   sub qword[here], 8             ; check if prev word is branch or
   mov r8, [here]                 ; branch0
   cmp qword[r8], xt_branch       ;
   je .branch                     ;
   cmp qword[r8], xt_branch0      ;
   je .branch                     ;
   mov rax, 0
   jmp .return

.branch:
   mov rax, 1

.return: 
   push rax
   add qword[here], 8
   jmp next

colon selector, "selector"
.loop:
   dq xt_put_state
   dq xt_branch0
   dq .interpret
   dq xt_compiler
   dq xt_branch
   dq .loop

.interpret:
   dq xt_interpret
   dq xt_branch
   dq .loop

colon compiler, "compiler"
   dq xt_inbuf
   dq xt_dup
   dq xt_find_word
   dq xt_dup
   dq xt_branch0
   dq .not_word

.word:
   dq xt_swap
   dq xt_drop
   dq xt_dup
   dq xt_immediate
   dq xt_branch0
   dq .add_word
   dq xt_cfa
   dq xt_exec
   dq xt_exit 

.add_word:
   dq xt_cfa
   dq xt_add_word
   dq xt_exit

.not_word:
   dq xt_drop
   dq xt_dup
   dq xt_count
   dq xt_dup
   dq xt_branch0
   dq .empty_line
   dq xt_swap
   dq xt_dup
   dq xt_number
   dq xt_to_ret
   dq xt_rot
   dq xt_rot
   dq xt_equals
   dq xt_branch0
   dq .not_found 
   dq xt_drop
   dq xt_from_ret
   dq xt_check_branch
   dq xt_branch0
   dq .no_branch

.branch:
   dq xt_add_word 
   dq xt_exit

.no_branch:
   dq xt_lit
   dq xt_lit
   dq xt_add_word
   dq xt_branch
   dq .branch

.not_found:
   dq xt_from_ret
   dq xt_drop
   dq xt_lit, not_found
   dq xt_prints
   dq xt_prints
   dq xt_lit, 10
   dq xt_emit
   dq xt_exit

.empty_line:
   dq xt_drop
   dq xt_drop
   dq xt_exit

colon interpret, "interpret"
   dq xt_inbuf
   dq xt_dup
   dq xt_find_word
   dq xt_dup
   dq xt_branch0
   dq .not_word

.word:
   dq xt_swap
   dq xt_drop
   dq xt_cfa
   dq xt_exec
   dq xt_exit 

.not_word:
   dq xt_drop
   dq xt_dup
   dq xt_count
   dq xt_dup
   dq xt_branch0
   dq .empty_line
   dq xt_swap
   dq xt_dup
   dq xt_number
   dq xt_to_ret
   dq xt_rot
   dq xt_rot
   dq xt_equals
   dq xt_branch0
   dq .not_found 
   dq xt_drop
   dq xt_from_ret
   dq xt_exit

.not_found:
   dq xt_from_ret
   dq xt_drop
   dq xt_lit, not_found
   dq xt_prints
   dq xt_prints
   dq xt_lit, 10
   dq xt_emit
   dq xt_exit

.empty_line:
   dq xt_drop
   dq xt_drop
   dq xt_exit

