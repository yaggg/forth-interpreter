%ifndef _MACRO_
%define _MACRO__

macro native 2
section .data
w_%1:
   db %2, 0
xt_%1:
   dq %1_impl
%1_impl:
%endmacro

%macro colon 2
dq %1, %2, 0
%endmacro

%endif
