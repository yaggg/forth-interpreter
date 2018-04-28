%macro native 3
section .data
w_%1:
   dq prev: %2
   db %3, 0
   db 0
xt_%1:
   dq %1_impl
%endmacro

%macro colon 2
dq %1, %2, 0
%endmacro


