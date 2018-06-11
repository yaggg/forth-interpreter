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

   native dot, "."
      pop rdi
      call print_int
      ret

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
   native multiply, "*"
   native divide, "/"
   native mod, "%"
   native equals, "="
   native lt, "<"
   native gt, ">"

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
       cmp rdi, 0
       je .fail 
       mov rdi, [rdi]
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

