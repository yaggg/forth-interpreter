%ifndef _MACRO_
%define _MACRO_

%define last_word 0

%macro native 2
    section .data
    w_%1: dq last_word
    db %2, 0
    
    %define last_word w_%1 
    xt_%1:  dq %1_impl

    section .text
    %1_impl:
%endmacro

%macro colon 2
    dq %1, %2, 0
%endmacro

%endif
