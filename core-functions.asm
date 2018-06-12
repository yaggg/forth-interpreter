%include "util.inc"
%include "macro.inc"

   native drop, "drop"
   native swap, "swap"
   native rot, "rot"
   native dup, "dup"
   native not, "not"
   native and, "and"
   native or, "or"
   native land, "land"
   native lor, "lor"
   native show, ".S"
   native exit, "exit"
   native to_ret, ">r"
   native from_ret, "r>"
   native r_fetch, "r@"
   native emit, "emit"
   native word, "word"
   native number, "number"
   native branch, "branch"
   native branch0, "branch0"
   native fetch, "@"
   native write, "!"
   native write_char, "c!"
   native plus, "+"

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
       call find_word_func
       jmp next

   native cfa, "cfa"
       call cfa_func
       jmp next

   native bye, "bye"
      call exit

;---------------------------------------

   find_word_func:
   .loop:
       push rdi
       lea rdi, [rdi + 8]
       call string_equals
       pop rdi
       cmp rax, 0
       je .find
       mov rdi, [rdi]
       cmp rdi, 0
       je .fail 
       jmp .loop
       .find:
           mov rax, rdi
           ret
       .fail:
           mov rax, 0
           ret

   cfa_func:
       lea rdi, [rdi + 8]
       push rdi
       call string_length
       pop rdi
       lea rax, [rdi + rax + 1]
       ret

