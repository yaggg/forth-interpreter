%include "util.inc"
%include "macro.inc"

   w_0: dq 0
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
   native branch0, branch, "branch0"
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
      
   native cfa, "cfa"
       add rdi, 8
       push rdi
       call string_length
       pop rdi
       add rax, rdi
       add rax, 2
       ret

last_word:
   native bye, "bye"
      call exit
