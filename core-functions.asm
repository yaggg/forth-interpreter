%include "util.inc"
%include "macro.inc"

   native drop, 'drop'
   native swap, 'swap'
   native rot, 'rot'
   native dup, 'dup'
   native not, 'not'
   native and, 'and'
   native or, 'or'
   native land, 'land'
   native lor, 'lor'
   native dot, '.'
      pop rdi
      call print_int
      ret
   native show, '.S'
   native exit, 'exit'
   native to_ret, '>r'
   native from_ret, 'r>'
   native r_fetch, 'r@'
   native emit, 'emit'
   native word, 'word'
   native number, 'number'
   native branch, 'branch'
   native branch0, branch, 'branch0'
   native fetch, '@'
   native write, '!'
   native write_char, 'c!'
   native plus, '+'
   native minus, '-'
   native multiply, '*'
   native divide, '/'
   native mod, '%'
   native equals, '='
   native lt, '<'
   native gt, '>'

   native find_word, 'find_word'
       
      
   native cfa, 'cfa'
       add rdi, 8
       push rdi
       call string_length
       pop rdi
       add rax, rdi
       add rax, 2
       ret

   native bye, 'bye'
      call exit
