;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procParseUInt16:
   ; Išskiria iš buferio, kurio adresas DX'e sveiką skaičių int16 tipo
   ; Rezultatas patalpinamas AX'e. BX'e - adresas, kur buvo sustota (pvz. taepas)  
   ; SVARBU: skaitomas skaičius turi būti korektiškas
   push dx
   push cx
   push si
   push di
   mov bx, dx
   mov ax, 0
   mov si, 0              ; number of digits 
   mov cl, 0              ; 0 - if nonnegative, 1 - otherwise
   ; eating spaces:
   .leading_spaces:
      cmp [bx], byte ' '
      jne .next1
      inc bx
      jmp .leading_spaces
    
   .next1:
      cmp [bx], byte 0          ; the end of the string?
      jne .next2
      jmp .endParsing
   .next2:
   .digits:
      cmp [bx], byte '0'          
      jb  .lessThanNumeric
      cmp [bx], byte '9'          
      jbe  .updateAX
      .lessThanNumeric: 
         jmp .endParsing
      .updateAX:
         mov dx, 10
         mul dx
         mov dh, 0 
         mov dl, [bx]
         sub dl, '0'
         add ax, dx
         inc si
      inc bx 
      jmp .digits
   .endParsing:
      cmp si, 0                   ; empty string?
      je .setErrorAndReturn
      clc
      cmp cl, 1
      je .negateAndReturn
      jmp .return
   
   .negateAndReturn:
      neg ax
      jmp .return
          
   .setErrorAndReturn:
      stc

   .return:        
   pop di
   pop si
   pop cx
   pop dx
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procParseInt16:
   ; Išskiria iš buferio, kurio adresas DX'e sveiką skaičių int16 tipo
   ; Rezultatas patalpinamas AX'e. BX'e - adresas, kur buvo sustota (pvz. taepas)  
   ; SVARBU: skaitomas skaičius turi būti korektiškas
   push dx
   push cx
   push si
   push di
   mov bx, dx
   mov ax, 0
   mov si, 0              ; number of digits 
   mov cl, 0              ; 0 - if nonnegative, 1 - otherwise
   ; eating spaces:
   .leading_spaces:
      cmp [bx], byte ' '
      jne .next1
      inc bx
      jmp .leading_spaces
    
   .next1:
      cmp [bx], byte 0          ; the end of the string?
      jne .next2
      jmp .endParsing
   .next2:
      cmp [bx], byte '-'   ; the minus
      jne .digits
      mov cl, 1            ; negative number
      inc bx
   
   .digits:
      cmp [bx], byte '0'          
      jb  .lessThanNumeric
      cmp [bx], byte '9'          
      jbe  .updateAX
      .lessThanNumeric: 
         jmp .endParsing
      .updateAX:
         mov dx, 10
         mul dx
         mov dh, 0 
         mov dl, [bx]
         sub dl, '0'
         add ax, dx
         inc si
      inc bx 
      jmp .digits
   .endParsing:
      cmp si, 0                   ; empty string?
      je .setErrorAndReturn
      clc
      cmp cl, 1
      je .negateAndReturn
      jmp .return
   
   .negateAndReturn:
      neg ax
      jmp .return
          
   .setErrorAndReturn:
      stc

   .return:        
   pop di
   pop si
   pop cx
   pop dx
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procInt16ToStr:
   ; Konvertuoja reikšmę iš AX į ASCIIZ eilutę (10-nėje sistemoje)
   ; AX - int16 (nuo -32768 iki 32767), kurį reikia konvertuoti; 
   ; DX  - adresas, kur bus patalipntas rezultatas
   ;      
   push di    
   push si
   push cx
   push bx
   push dx
   mov bx, dx
   mov cx, 0     
   mov si, 0         
   cmp ax, word 0
   jge .next
     mov cl, 1
     mov [bx], byte '-'
     inc bx
     neg ax

  
  .next:
     mov dx, 0
     mov di, 10
     div di
     add dl, '0'
     mov [bx], dl
     inc bx
     inc si
     cmp ax, 0
     je .setSign
     jmp .next
    
  .setSign:
     


  .reverse:
  ;   inc bx
     mov [bx], byte 0             ; asciiz
     dec bx

     pop dx
     push dx
     mov di, dx 
    
     cmp cl, 1
     jne .Ok
     inc di
     
     .Ok:
     mov ax, si
     shr ax, 1
     mov cx, ax
     cmp cx, 0
     je .return
     
     .loopByDigits:
        mov al, [di]
        mov ah, [bx]
        mov [di], ah
        mov [bx], al
        dec bx
        inc di
        loop .loopByDigits

  .return: 
  pop dx
  pop bx
  pop cx
  pop si
  pop di
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procUInt16ToStr:
   ; Konvertuoja reikšmę iš AX į ASCIIZ eilutę (10-nėje sistemoje)
   ; AX - int16 (nuo -32768 iki 32767), kurį reikia konvertuoti; 
   ; DX  - adresas, kur bus patalipntas rezultatas
   ;      
   push di    
   push si
   push cx
   push bx
   push dx
   mov bx, dx
   mov cx, 0     
   mov si, 0         

  .next:
     mov dx, 0
     mov di, 10
     div di
     add dl, '0'
     mov [bx], dl
     inc bx
     inc si
     cmp ax, 0
     je .setSign
     jmp .next
    
  .setSign:
     


  .reverse:
  ;   inc bx
     mov [bx], byte 0             ; asciiz
     dec bx

     pop dx
     push dx
     mov di, dx 
    
     cmp cl, 1
     jne .Ok
     inc di
     
     .Ok:
     mov ax, si
     shr ax, 1
     mov cx, ax
     cmp cx, 0
     je .return
     
     .loopByDigits:
        mov al, [di]
        mov ah, [bx]
        mov [di], ah
        mov [bx], al
        dec bx
        inc di
        loop .loopByDigits

  .return: 
  pop dx
  pop bx
  pop cx
  pop si
  pop di
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procGetStr:
   ; skaito  eilutę iš klaviatūros ir padaro ją ASCIIZ
   ; įvestis:  dx - buferio adresas; al - ilgiausios galimos sekos ilgis; 
   ; išvestis: dx - asciiz sekos adresas; 
   ; CF yra 1, jeigu buvo klaidų
   push bx
   push cx
   push dx
   mov bx, dx
   mov [bx], al
   mov ah, 0x0a
   int 0x21
   inc bx
   mov ch, 0
   mov cl, [bx]
   inc bx
   .loopBySymbols:
       mov al, [bx]
       mov [bx-2], al
       inc bx
       loop .loopBySymbols 
   mov [bx-2], byte 0
   pop dx
   pop cx
   pop bx
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procGetInt16:
   ; skaito  sveiką skaičių  iš klaviatūros ir gražina jį AX'e (nuo -32768 iki 32767)
   jmp .kodas
 .buferis:
      db '                      '
 .kodas:
   push bx
   push cx
   push dx
   mov dx, .buferis 
   mov al, 10
   call procGetStr
   call procParseInt16  
   pop dx
   pop cx
   pop bx
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procGetUInt16:
   ; skaito beženklį sveiką skaičių  iš klaviatūros ir gražina jį AX'e (nuo 0 iki 65535)
   jmp .kodas
 .buferis:
      db '                      '
 .kodas:
   push bx
   push cx
   push dx
   mov dx, .buferis 
   mov al, 10
   call procGetStr
   call procParseUInt16  
   pop dx
   pop cx
   pop bx
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procPutStr:
   ; spausdina asciiz eilutę į stdout 
   ; DX - asciiz eilutė;
   push bx
   push dx 
   push ax
   mov bx, dx
   .loopBySymbols:
      mov dl, [bx]
      cmp dl, 0
      je .return
        mov ah, 0x02
        int 0x21
        inc bx
      jmp .loopBySymbols
	
   .return:
      pop ax
      pop dx
      pop bx
      ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procPutInt16:
   ; spausdina int16 ant ekrano
   ; input:  ax - sveikas skaičius (nuo -32768 iki 32767)

   jmp .kodas
 .buferis: 
   db 00,00,00,00,00,00,00,00,00,00,00,00 
 .kodas:
   push bx
   push dx 
   push ax
   mov dx, .buferis
   call procInt16ToStr
   call procPutStr 
   pop ax
   pop dx
   pop bx
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procPutUInt16:
   ; spausdina int16 ant ekrano
   ; input:  ax - beženklis sveikas skaičius (nuo 0 iki 65535)

   jmp .kodas
 .buferis: 
   db 00,00,00,00,00,00,00,00,00,00,00,00 
 .kodas:
   push bx
   push dx 
   push ax
   mov dx, .buferis
   call procUInt16ToStr
   call procPutStr 
   pop ax
   pop dx
   pop bx
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procNewLine:
   ; prints \n 
   jmp .begin
   .localData:
   db 0x0D, 0x0A, 0x00
   
   .begin: 
  
   push dx 
   push ax
   mov dx, .localData
   call procPutStr
   pop ax
   pop dx
   ret 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procPutHexWord:
; Spausdina 16-tainį žodį, kuris paduodamas AX'e
;

   jmp .begin
   .localData:
   db '     $', 0
   
   .begin: 
   push dx 
   push ax
   push cx
   push bx
   push si
   mov bx, ax
   mov cx, 4
   mov si, 0
   .loop4:   
      mov dx, bx
      and dh, 0xF0
      times 4 shr dh, 1
      mov dl, dh 
      add dl, '0'
      cmp dl, '9'
      jle .print
         sub  dl, '0'
         add  dl, ('A'-10)
      .print:
      mov [.localData + si + 2], dl
      times 4 shl bx, 1
      inc si 
      loop .loop4
   
   mov dx, .localData
   call procPutStr
   pop si
   pop bx
   pop cx
   pop ax
   pop dx
   ret 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procPutHexByte:
; Spausdina 16-tainį baitą, kuris paduodamas AL'e
;

   jmp .begin
   .localData:
   db '0x  ', 0
   
   .begin: 
   push dx 
   push ax
   push cx
   push bx
   push si
   mov bx, ax
   mov cx, 2
   mov si, 0
   .loop4:   
      mov dx, bx
      and dh, 0xF0
      times 4 shr dh, 1
      mov dl, dh 
      add dl, '0'
      cmp dl, '9'
      jle .print
         sub  dl, '0'
         add  dl, ('A'-10)
      .print:
      mov [.localData + si + 2], dl
      times 4 shl bx, 1
      inc si 
      loop .loop4
   
   mov dx, .localData + 2
   call procPutStr
   pop si
   pop bx
   pop cx
   pop ax
   pop dx
   ret 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Darbas su FPU PBCD skaičiais
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procFPBCD2ASCIIZ:
; Input/output:  
;   si - FPU PBCD number
;   di -  buffer for ACIIZ
    push ax
    push si
    push di
    push cx
    push bx
    
    add si, 9
    mov al, [si]    
    and al, 0x80
    cmp al, 0
    je .skaitmenys
    mov [di], byte '-'
    inc di
    dec si
    
    .skaitmenys:
    mov bx, 0
    mov cx, 9
    mov al, [si]
    mov ah, al
    and ah, 0xF0
    shr ah, 4
    cmp ah, 00
    je .kitasSk1
    add ah, '0'
    mov [di], ah
    inc di
    mov bx, 1
    
    .kitasSk1:
    and al, 0x0F
    cmp bx, 1    
    je .nenulinisSk2
    cmp al, 0
    jne .nenulinisSk2
    jmp  .kitasSk2   
    .nenulinisSk2:
    add al, '0'
    mov [di], al
    inc di
    mov bx, 1
    .kitasSk2:
    dec si
    cmp bx, 1    
    je .kitiSkaitmenys
    
    loop .skaitmenys
    
    .kitiSkaitmenys:
    mov al, [si]
    mov ah, al
    shr ah, 4
    add ah, '0'
    mov [di], ah
    inc di
    add al, '0'
    mov [di], al
    inc di
    dec si
    loop .kitiSkaitmenys    
    
    cmp bx, 1    
    je .pab
    mov [di], byte '0'
    
    .pab:
    pop bx
    pop cx
    pop di
    pop si
    pop ax
    
    ret


procPutPBCD:
; dx - FPU PBCD adresas
  push bx
  push ax
  push dx
  push cx

  mov cx, 10
  mov bx, dx
  add bx, 9

  mov dl, '0'
  mov ah, 02
  int 0x21

  mov dl, 'x'
  mov ah, 02
  int 0x21


  .ciklas:
  mov al, [bx]
  call procPutHexByte
  dec bx
  loop .ciklas



  pop cx
  pop dx
  pop ax
  pop bx 
  ret

procPutFPBCD:
; Input:  
;   si - FPU PBCD number
    jmp .toliau
    .buffer:
    times 25 db 00
    .toliau
    push si
    push di
    push dx
    
    mov di, .buffer
    call procFPBCD2ASCIIZ
    mov dx, di
    call procPutStr
    
    pop dx
    pop di
    pop si
    
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Darbas su failais
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procFOpenForReading:
; Atidaro failą skaitymui
; Įvestis: dx - ASCIIZ pavadinimas
; Išvestis: bx - failo deskriptorius, jei CF == 0
;           CF = 1, jeigu klaida    
   push ax 
   mov ah, 0x3D
   mov al, 0x00
   int 0x21
   mov bx, ax
   pop ax
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procFOpenForWriting:
; Atidaro failą rašymui
; Įvestis: dx - ASCIIZ pavadinimas
; Išvestis: bx - failo deskriptorius, jei CF == 0
;           CF = 1, jeigu klaida    
   push ax 
   mov ah, 0x3D
   mov al, 0x01
   int 0x21
   mov bx, ax
   pop ax
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procFOpenForReadingAndWriting:
; Atidaro failą rašymui/skaitymui
; Įvestis: dx - ASCIIZ pavadinimas
; Išvestis: bx - failo deskriptorius, jei CF == 0
;           CF = 1, jeigu klaida    
   push ax 
   mov ah, 0x3D
   mov al, 0x02
   int 0x21
   mov bx, ax
   pop ax
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procFCreateOrTruncate:
; Atidaro failą rašymui/skaitymui
; Įvestis: dx - ASCIIZ pavadinimas
; Išvestis: bx - failo dekskriptorius, jei CF == 0
;           CF = 1, jeigu klaida    
   push ax 
   push cx
   mov cx, 0
   mov ah, 0x3C
   int 0x21
   mov bx, ax
   pop cx
   pop ax
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procFClose:
; Uždaro failą
; Įvestis: bx - failo deskriptorius
; Išvestis: Ok,  jeigu CF == 0
;           Jeigu CF = 1, tai klaida    
   push ax 
   mov ah, 0x3E
   int 0x21
   pop ax
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procFRead:
; Skaito failą
; Įvestis: bx - failo deskriptorius, dx - buferis, cx - kiek baitų nuskaityti
; Išvestis: ax - kiek faktiškai nuskaitė,  jeigu CF == 0; ax == 0, jeigu failo pabaiga
;           Jeigu CF = 1, tai klaida    
   mov ah, 0x3F
   int 0x21
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procFGetChar:
; Skaito 1 baitą iš failo
; Įvestis: bx - failo deskriptorius 
; Išvestis: ax - ar  nuskaitė (0 ar 1),  jeigu CF == 0; ax == 0, jeigu failo pabaiga
;           Jeigu CF = 1, tai klaida    
;           cl - baitas 
   push dx
   mov cx, 1
   mov dx, .baitas
   mov ah, 0x3F
   int 0x21
   mov cl, [.baitas]
   pop dx
   ret
   .baitas:
   db 00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


procFWrite:
; Rašo į failą
; Įvestis: bx - failo deskriptorius, dx - buferis, cx - kiek baitų nuskaityti
; Išvestis: ax - kiek faktiškai įrašė,  jeigu CF == 0; ax == 0, jeigu nėra vietos diske
;           Jeigu CF = 1, tai klaida    
   mov ah, 0x40
   int 0x21
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


procFPutChar:
; Rašo simbolį failą
; Įvestis: bx - failo deskriptorius, al - rašomas baitas
; Išvestis: ax - kiek faktiškai įrašė,  jeigu CF == 0; ax == 0, jeigu nėra vietos
;           Jeigu CF = 1, tai klaida    
   push dx
   push cx
   mov cx, 1
   mov [.baitas], al
   mov dx, .baitas
   mov ah, 0x40
   int 0x21
   pop cx
   pop dx
   ret
   .baitas:
   db 00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


procFSeekFromBeginning:
; Nustato failo rodyklę
; Įvestis: bx - failo deskriptorius, cx:dx - kiek baitų 
; Išvestis: dx:ax - nauja pozicija,  jeigu CF == 0
;           Jeigu CF = 1, tai klaida   
   mov al, 00 
   mov ah, 0x42
   int 0x21
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Paprasta grafika
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procSetGraphicsMode:
; Nustato grafinį režimą, 320x200x256
   push ax 
   mov ah, 00
   mov al, 0x13
   int 0x10
   pop ax
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procSetTextMode:
; Nustato tekstinį režimą, 80x25
   push ax 
   mov ah, 00
   mov al, 0x03
   int 0x10
   pop ax
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procPutPixel:
;  deda nurodytos spalvos pikselį nurodytoje vietoje
;  cl - color
;  si - x
;  di - y
   push ax 
   push cx
   push si
   push di
   push dx
   push es
   mov ax, di
   mov dx, 320
   mul dx
   add si, ax
   mov ax, 0xa000
   mov es, ax 
   mov byte [es:si], cl
   pop es
   pop dx
   pop di
   pop si
   pop cx
   pop ax
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
procWaitForEsc:
; Laukia Esc paspaudimo
  .ciklas: 
  mov ah,0
  int 0x16        ; Ka paspaudeme

  cmp ah, 0x01    ; Esc scan kodas
  jne .ciklas
  call procSetTextMode
  ret

