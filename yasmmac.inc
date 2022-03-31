%define crlf  0x0D, 0x0A
 
%macro exit 0
;
;  Baigia programą 
;
   mov ah, 0x4c
   int 0x21
%endmacro

%macro FPUPBCD 0
;
;  Apibrėžia PBCD 0 
;
   dt 0x00000000000000000000
%endmacro


%macro macPutChar 1
;
;  Išveda nurodytą simbolį ant ekrano naudojant 2-ą DOS funkciją, pvz. macPutChar 'A'
;
   push dx
   push ax
   mov dl, %1
   mov ah, 02
   int 0x21
   pop ax
   pop dx
%endmacro

%macro macPutString 1+
;
;  Spausdina nurodytą tekstą ant ekrano naudojant 9-ą DOS funkciją, pvz. macPutString "Labas", 0x0D, 0x0A, '$'
;
   push ax
   push dx 
   jmp  %%pab 
 %%tekstas:        
   db      %1 
 %%pab: 
   mov     dx, %%tekstas 
   mov     ah, 09 
   int     0x21 
   pop dx      
   pop ax
%endmacro

%macro macNewLine 0
;
;  Spausdina naują eilutę ant ekrano naudojant 9-ą DOS funkciją, pvz. macNewLine
;
   push ax
   push dx 
   jmp  %%pab 
 %%tekstas:        
   db      crlf, '$' 
 %%pab: 
   mov     dx, %%tekstas 
   mov     ah, 09 
   int     0x21 
   pop dx      
   pop ax
%endmacro

%macro macPushAll 0
;
;  Saugome registrus 
;
    push    ax
    push    bx
    push    cx
    push    dx
    
    push    ds
    push    es
    push    si
    push    di
    
    push    bp

%endmacro


%macro macPopAll 0
;
;  Saugome registrus
;
    pop    bp
    pop    di
    pop    si
    pop    es
    
    pop    ds
    pop    dx
    pop    cx
    pop    bx
    
    pop    ax
%endmacro


