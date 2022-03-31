
;  

%include 'yasmmac.inc'


%macro writeln   1
          push ax
          push dx
          mov ah, 09
          mov dx, %1
          int 21h
          mov ah, 09
          mov dx, naujaEilute
          int 21h
          pop dx
          pop ax          

%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro readln    1
          mov ah, 0Ah
          mov dx, %1
          int 21h
          mov ah, 09
          mov dx, naujaEilute
          int 21h
      
%endmacro

    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
org 100h   
section .text
    main:
       ; pradzioje ds ir es rodo i PSP;
       ; PSP+80h -> kiek baitu uzima komandine eilute (be programos pavadinimo)
       ; 
       call skaitykArgumenta
       jnc .rasykArgumenta
       writeln klaidosPranesimas
       jmp .Ok

       .rasykArgumenta: 
       mov dx, komEilutesArgumentas      
       call writeASCIIZ 
       
       ;Atidarome faila
       mov dx, komEilutesArgumentas      
       call atverkFaila
       jnc .skaitomeFaila
       writeln klaidosApieFailoAtidarymaPranesimas
       jmp .Ok

       .skaitomeFaila:
       mov bx, [skaitomasFailas]          
       mov dx, nuskaitytas          
       call skaitomeFaila
       jnc .failoUzdarymas
       writeln klaidosApieFailoSkaitymaPranesimas
       ;jmp .Ok

       .failoUzdarymas:
       mov bx, [skaitomasFailas]          
       call uzdarykFaila
       .Ok:
       mov ah,     4ch                            ; baigimo funkcijos numeris
       int 21h
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  atverkFaila:  
        ; dx - failo vardo adresas
        ; CF yra 1 jeigu klaida 
        push ax
        push dx

        mov ah, 3Dh
        mov al, 00h       ; skaitymui
        int 21h

        jc .pab
        mov [skaitomasFailas], ax

        .pab:  
        pop dx
        pop ax
        ret   

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  uzdarykFaila:  
        ; dx - failo vardo adresas
        ; CF yra 1 jeigu klaida 
        push ax
        push bx

        mov ah, 3Eh
        int 21h

        .pab:  
        pop dx
        pop ax
        ret     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    rasykSimboli:  
        ; al - simbolis 
        push ax
        push dx
        mov dl, al
        mov ah, 02h
        int 21h
        pop dx
        pop ax
        ret   
  
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   konvertuokI16taine:  
        ; al - baitas
        ; ax - rezultatas
        mov ah, al
        and ah, 0F0h
        shr ah, 1
        shr ah, 1
        shr ah, 1
        shr ah, 1
        and al, 0Fh

        cmp al, 09
        jle .plius0
        sub al, 10
        add al, 'A'
        jmp .AH
        .plius0:
        add al, '0'
        .AH:
             
        cmp ah, 09
        jle .darplius0
        sub ah, 10
        add ah, 'A'
        jmp .pab
        .darplius0:
        add ah, '0'
        .pab:
        xchg ah, al 
        ret     
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    analizuokKoda:  
         ; INPUT: 
         ;    al - nuskaitytas baitas
         ;    bx - failo deskriptorius - cia nenaudojas, bet potencialiai reikalingas  :)
         
         push bx
         push ax
     
		 

		 mov [dabInstrukcija], al
		 
		 cmp al, 0x0F
		 jne .galJCXZ
		 call skaitykFailoBaita
		 sub al, 0x10
		 cmp al, 0x79
		 jne .galJNOPre
		 macPutString "      jns$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 jne .tadaJNSPreNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNSPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJNOPre
		 cmp al, 0x71
		 jne .galJNPPre
		 macPutString "      jno$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNOPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJNPPre
		 cmp al, 0x7B
		 jne .galJNBEPre
		 macPutString "      jnp$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNPPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 
		 .galJNBEPre
		 cmp al, 0x77
		 jne .galJNBPre
		 macPutString "      jnbe$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNBEPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJNBPre
		 cmp al, 0x73
		 jne .galJNLEPre
		 macPutString "      jnb$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNBPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 
		 .galJNLEPre
		 cmp al, 0x7F
		 jne .galJNLPre
		 macPutString "      jnle$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNLEPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 
		 .galJNLPre
		 cmp al, 0x7D
		 jne .galJNEPre
		 macPutString "      jnl$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNLPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJNEPre
		 cmp al, 0x75
		 jne .galJSPre
		 macPutString "      jne$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNEPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJSPre
		 cmp al, 0x78
		 jne .galJOPre
		 macPutString "      js$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJSPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJOPre
		 cmp al, 0x70
		 jne .galJPPre
		 macPutString "      jo$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJOPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJPPre
		 cmp al, 0x7A
		 jne .galJBEPre
		 macPutString "      jp$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJPPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJBEPre
		 cmp al, 0x76
		 jne .galJBPre
		 macPutString "      jbe$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJBEPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJBPre
		 cmp al, 0x72
		 jne .galJLEPre
		 macPutString "      jb$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJBPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJLEPre
		 cmp al, 0x7E
		 jne .galJLPre
		 macPutString "      jle$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJLEPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJLPre
		 cmp al, 0x7C
		 jne .galJEPre
		 macPutString "      jl$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJLPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJEPre
		 cmp al, 0x74
		 jne .galRETFIlg
		 macPutString "      je$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita	
		 mov ah, al
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJEPreNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 
		 
		 
		 
		 .galJCXZ
		 cmp al, 0xE3
		 jne .galLOOPNZW
		 macPutString "      jcxz$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJCXZNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJCXZNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galLOOPNZW
		 cmp al, 0xE1
		 jne .galLOOPZW
		 macPutString "      loopzw$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaLOOPNZWNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaLOOPNZWNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galLOOPZW
		 cmp al, 0xE0
		 jne .galLOOPW
		 macPutString "      loopnzw$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaLOOPZWNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaLOOPZWNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galLOOPW
		 cmp al, 0xE2
		 jne .galJNS
		 macPutString "      loopw$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaLOOPWNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaLOOPWNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJNS
		 cmp al, 0x79
		 jne .galJNO
		 macPutString "      jns$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJNSNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNSNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJNO
		 cmp al, 0x71
		 jne .galJNP
		 macPutString "      jno$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJNONeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNONeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJNP
		 cmp al, 0x7B
		 jne .galJNBE
		 macPutString "      jnp$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJNPNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNPNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 
		 .galJNBE
		 cmp al, 0x77
		 jne .galJNB
		 macPutString "      jnbe$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJNBENeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNBENeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJNB
		 cmp al, 0x73
		 jne .galJNLE
		 macPutString "      jnb$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJNBNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNBNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 
		 .galJNLE
		 cmp al, 0x7F
		 jne .galJNL
		 macPutString "      jnle$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJNLENeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNLENeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 
		 .galJNL
		 cmp al, 0x7D
		 jne .galJNE
		 macPutString "      jnl$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJNLNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNLNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJNE
		 cmp al, 0x75
		 jne .galJS
		 macPutString "      jne$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJNENeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJNENeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJS
		 cmp al, 0x78
		 jne .galJO
		 macPutString "      js$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJSNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJSNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJO
		 cmp al, 0x70
		 jne .galJP
		 macPutString "      jo$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJONeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJONeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJP
		 cmp al, 0x7A
		 jne .galJBE
		 macPutString "      jp$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJPNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJPNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJBE
		 cmp al, 0x76
		 jne .galJB
		 macPutString "      jbe$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJBENeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJBENeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJB
		 cmp al, 0x72
		 jne .galJLE
		 macPutString "      jb$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJBNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJBNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJLE
		 cmp al, 0x7E
		 jne .galJL
		 macPutString "      jle$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJLENeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJLENeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJL
		 cmp al, 0x7C
		 jne .galJE
		 macPutString "      jl$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJLNeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJLNeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galJE
		 cmp al, 0x74
		 jne .galRETFIlg
		 macPutString "      je$"
		 ;ziuresim, ar tai teigiamas, ar ne
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 7
		 cmp al, 0x0
		 jne .tadaJENeigiamas
		 mov al, [dabInstrukcija]
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .tadaJENeigiamas
		 mov al, [dabInstrukcija]
		 not al
		 inc al
		 mov [kasBuvoAX], ax
		 mov ax, [saugomIP]
		 sub ax, [kasBuvoAX]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 .galRETFIlg
		 cmp al, 0xCA
		 jne .galRETIlg
		 macPutString "      retf $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galRETIlg
		 cmp al, 0xC2
		 jne .galJMPDirectIntersegment
		 macPutString "      ret $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 
		 .galJMPDirectIntersegment
		 cmp al, 0xEA
		 jne .galJMPDirectWithSegShort
		 macPutString "      jmp $"
		 call skaitykFailoBaita
		 mov [kasBuvoDX], al
		 call skaitykFailoBaita
		 mov [kasBuvoBH], al
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macPutChar ':'
		 mov ah, [kasBuvoBH]
		 call procPutHexByte
		 mov ah, [kasBuvoDX]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 
		 .galJMPDirectWithSegShort
		 cmp al, 0xEB
		 jne .galJMPDirectWithSeg
		 macPutString "      jmp $"
		 call skaitykFailoBaita
		 add ax, [saugomIP]
		 call procPutHexWord
		 macNewLine
		 jmp .pab
		 
		 .galJMPDirectWithSeg
		 cmp al, 0xE9
		 jne .galBAA
		 macPutString "      jmp $"
		 mov [kasBuvoDX], dx
		 call skaitykFailoBaita
		 mov dl, al
		 call skaitykFailoBaita
		 mov dh, al
		 mov [kasBuvoAX], ax
		 mov ax, dx
		 mov dx, [kasBuvoDX]
		 add ax, [saugomIP]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		 
		 
		 .galBAA
		 cmp al, 0x27
		 jne .galAAA
		 macPutString "      daa$"
		 macNewLine
		 jmp .pab
		 
		 .galAAA
		 cmp al, 0x37
		 jne .galCALLDirectIntersegment
		 macPutString "      aaa$"
		 macNewLine
		 jmp .pab
		  
		 .galCALLDirectIntersegment:
		 cmp al, 0x9A
		 jne .galCALLDirectWithinSeg
		 macPutString "      call $"
		 call skaitykFailoBaita
		 mov [kasBuvoDX], al
		 call skaitykFailoBaita
		 mov [kasBuvoBH], al
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macPutChar ':'
		 mov ah, [kasBuvoBH]
		 call procPutHexByte
		 mov ah, [kasBuvoDX]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		  
		 ;;jei kazkas nesigauna, tai didelis sansas, kad del sitos vietos :D
		 ;;taip pat gal del saugomIP gali crash'u buti
		 .galCALLDirectWithinSeg:
		 cmp al, 0xE8
		 jne .galMOVSB
		 macPutString "      call $"
		 mov [kasBuvoDX], dx
		 call skaitykFailoBaita
		 mov dl, al
		 call skaitykFailoBaita
		 mov dh, al
		 mov [kasBuvoAX], ax
		 mov ax, dx
		 mov dx, [kasBuvoDX]
		 add ax, [saugomIP]
		 call procPutHexWord
		 mov ax, [kasBuvoAX]
		 macNewLine
		 jmp .pab
		

		 .galMOVSB
		 cmp al, 0xA4
		 jne .galMOVSW
		 macPutString "      movsb$"
		 macNewLine
		 jmp .pab

		 .galMOVSW
		 cmp al, 0xA5
		 jne .galCMPSB
		 macPutString "      movsw$"
		 macNewLine
		 jmp .pab

		 .galCMPSB
		 cmp al, 0xA6
		 jne .galCMPSW
		 macPutString "      cmpsb$"
		 macNewLine
		 jmp .pab

		 .galCMPSW
		 cmp al, 0xA7
		 jne .galSTOSB
		 macPutString "      cmpsw$"
		 macNewLine
		 jmp .pab

		 .galSTOSB
		 cmp al, 0xAA
		 jne .galSTOSW
		 macPutString "      stosb$"
		 macNewLine
		 jmp .pab

		 .galSTOSW
		 cmp al, 0xAB
		 jne .galLODSB
		 macPutString "      stosw$"
		 macNewLine
		 jmp .pab

		 .galLODSB
		 cmp al, 0xAC
		 jne .galLODSW
		 macPutString "      lodsb$"
		 macNewLine
		 jmp .pab

		 .galLODSW
		 cmp al, 0xAD
		 jne .galSCASB
		 macPutString "      lodsw$"
		 macNewLine
		 jmp .pab
		 
		 .galSCASB
		 cmp al, 0xAE
		 jne .galSCASW
		 macPutString "      scasb$"
		 macNewLine
		 jmp .pab   
		 
		 .galSCASW
		 cmp al, 0xAF
		 jne .galREPE
		 macPutString "      scasw$"
		 macNewLine
		 jmp .pab  

		 .galREPE
		 cmp al, 0xF3
		 jne .galREPNE
		 call skaitykFailoBaita
		 macPutString "      repe$"
		 jmp .galMOVSB

		 .galREPNE
		 cmp al, 0xF2
		 jne .galXORRegMemWithReg16
		 call skaitykFailoBaita
		 macPutString "      repne$"
		 jmp .galMOVSB

		 .galXORRegMemWithReg16:
		 cmp al, 0x31
		 jne .galXORRegMemWithReg8
		 macPutString "      xor $"
		 call procTvarkykModRegRM16atv
		 macNewLine
		 jmp .pab

		 .galXORRegMemWithReg8:
		 cmp al, 0x30
		 jne .galXORReg16WithRegMem
		 macPutString "      xor $"
		 call procTvarkykModRegRM8atv
		 macNewLine
		 jmp .pab
		 
		 .galXORReg16WithRegMem:
		 cmp al, 0x33
		 jne .galXORReg8WithRegMem
		 macPutString "      xor $"
		 call procTvarkykModRegRM
		 macNewLine
		 jmp .pab
		 
		 .galXORReg8WithRegMem:
		 cmp al, 0x32
		 jne .galXORImmToAx
		 macPutString "      xor $"
		 call procTvarkykModRegRM8
		 macNewLine
		 jmp .pab

		 .galXORImmToAx
		 cmp al, 0x35
		 jne .galXORImmToAl
		 macPutString "      xor ax, $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galXORImmToAl
		 cmp al, 0x34
		 jne .galORRegMemWithReg16
		 macPutString "      xor al, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galORRegMemWithReg16:
		 cmp al, 0x9
		 jne .galORRegMemWithReg8
		 macPutString "      or $"
		 call procTvarkykModRegRM16atv
		 macNewLine
		 jmp .pab

		 .galORRegMemWithReg8:
		 cmp al, 0x8
		 jne .galORReg16WithRegMem
		 macPutString "      or $"
		 call procTvarkykModRegRM8atv
		 macNewLine
		 jmp .pab
		 
		 .galORReg16WithRegMem:
		 cmp al, 0x0B
		 jne .galORReg8WithRegMem
		 macPutString "      or $"
		 call procTvarkykModRegRM
		 macNewLine
		 jmp .pab
		 
		 .galORReg8WithRegMem:
		 cmp al, 0x0A
		 jne .galORImmToAx
		 macPutString "      or $"
		 call procTvarkykModRegRM8
		 macNewLine
		 jmp .pab

		 .galORImmToAx:
		 cmp al, 0xD
		 jne .galORImmToAl
		 macPutString "      or ax, $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galORImmToAl:
		 cmp al, 0xC
		 jne .galTESTRegMemWithReg16
		 macPutString "      or al, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galTESTRegMemWithReg16:
		 cmp al, 0x85
		 jne .galTESTRegMemWithReg8
		 macPutString "      test $"
		 call procTvarkykModRegRM16atv
		 macNewLine
		 jmp .pab

		 .galTESTRegMemWithReg8:
		 cmp al, 0x84
		 jne .galTESTImmToAx
		 macPutString "      test $"
		 call procTvarkykModRegRM8atv
		 macNewLine
		 jmp .pab

		 .galTESTImmToAx
		 cmp al, 0xA9
		 jne .galTESTImmToAl
		 macPutString "      test ax, $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galTESTImmToAl
		 cmp al, 0xA8
		 jne .galANDRegMemWithReg16
		 macPutString "      test al, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galANDRegMemWithReg16:
		 cmp al, 0x21
		 jne .galANDRegMemWithReg8
		 macPutString "      and $"
		 call procTvarkykModRegRM16atv
		 macNewLine
		 jmp .pab

		 .galANDRegMemWithReg8:
		 cmp al, 0x20
		 jne .galANDReg16WithRegMem
		 macPutString "      and $"
		 call procTvarkykModRegRM8atv
		 macNewLine
		 jmp .pab
		 
		 .galANDReg16WithRegMem:
		 cmp al, 0x23
		 jne .galANDReg8WithRegMem
		 macPutString "      and $"
		 call procTvarkykModRegRM
		 macNewLine
		 jmp .pab
		 
		 .galANDReg8WithRegMem:
		 cmp al, 0x22
		 jne .galANDImmToAx
		 macPutString "      and $"
		 call procTvarkykModRegRM8
		 macNewLine
		 jmp .pab
		 
		 .galANDImmToAx:
		 cmp al, 0x25
		 jne .galANDImmToAl
		 macPutString "      and ax, $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galANDImmToAl:
		 cmp al, 0x24
		 jne .galPrasidedaD3
		 macPutString "      and al, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galPrasidedaD3:
		 cmp al, 0xD3
		 jne .galPrasidedaD2
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x4
		 je .tadaSHL11
		 cmp al, 0x5
		 je .tadaSHR11
		 cmp al, 0x7
		 je .tadaSAR11
		 cmp al, 0
		 je .tadaROL11
		 cmp al, 0x1
		 je .tadaROR11
		 cmp al, 0x2
		 je .tadaRCL11
		 jmp .tadaRCR11

		 .tadaSHL11:
		 mov al, [dabInstrukcija]
		 macPutString "      shl $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaSHR11:
		 mov al, [dabInstrukcija]
		 macPutString "      shr $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaSAR11:
		 mov al, [dabInstrukcija]
		 macPutString "      sar $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaROL11
		 mov al, [dabInstrukcija]
		 macPutString "      rol $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaROR11
		 mov al, [dabInstrukcija]
		 macPutString "      ror $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaRCL11
		 mov al, [dabInstrukcija]
		 macPutString "      rcl $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaRCR11
		 mov al, [dabInstrukcija]
		 macPutString "      rcr $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .galPrasidedaD2
		 cmp al, 0xD2
		 jne .galPrasidedaD1
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x4
		 je .tadaSHL10
		 cmp al, 0x5
		 je .tadaSHR10
		 cmp al, 0x7
		 je .tadaSAR10
		 cmp al, 0
		 je .tadaROL10
		 cmp al, 0x1
		 je .tadaROR10
		 cmp al, 0x2
		 je .tadaRCL10
		 jmp .tadaRCR10

		 .tadaSHL10
		 mov al, [dabInstrukcija]
		 macPutString "      shl $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaSHR10
		 mov al, [dabInstrukcija]
		 macPutString "      shr $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaSAR10
		 mov al, [dabInstrukcija]
		 macPutString "      sar $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaROL10
		 mov al, [dabInstrukcija]
		 macPutString "      rol $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaROR10
		 mov al, [dabInstrukcija]
		 macPutString "      ror $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaRCL10
		 mov al, [dabInstrukcija]
		 macPutString "      rcl $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .tadaRCR10
		 mov al, [dabInstrukcija]
		 macPutString "      rcr $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", cl$"
		 macNewLine
		 jmp .pab

		 .galPrasidedaD1
		 cmp al, 0xD1
		 jne .galPrasidedaD0
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x4
		 je .tadaSHL01
		 cmp al, 0x5
		 je .tadaSHR01
		 cmp al, 0x7
		 je .tadaSAR01
		 cmp al, 0
		 je .tadaROL01
		 cmp al, 0x1
		 je .tadaROR01
		 cmp al, 0x2
		 je .tadaRCL01
		 jmp .tadaRCR01

		 .tadaSHL01
		 mov al, [dabInstrukcija]
		 macPutString "      shl $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaSHR01
		 mov al, [dabInstrukcija]
		 macPutString "      shr $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaSAR01
		 mov al, [dabInstrukcija]
		 macPutString "      sar $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaROL01
		 mov al, [dabInstrukcija]
		 macPutString "      rol $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaROR01
		 mov al, [dabInstrukcija]
		 macPutString "      ror $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaRCL01
		 mov al, [dabInstrukcija]
		 macPutString "      rcl $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaRCR01
		 mov al, [dabInstrukcija]
		 macPutString "      rcr $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab


		 .galPrasidedaD0
		 cmp al, 0xd0
		 jne .galSSBRegMemWithReg8
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x4
		 je .tadaSHL00
		 cmp al, 0x5
		 je .tadaSHR00
		 cmp al, 0x7
		 je .tadaSAR00
		 cmp al, 0
		 je .tadaROL00
		 cmp al, 0x1
		 je .tadaROR00
		 cmp al, 0x2
		 je .tadaRCL00
		 jmp .tadaRCR00

		 .tadaSHL00
		 mov al, [dabInstrukcija]
		 macPutString "      shl $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaSHR00
		 mov al, [dabInstrukcija]
		 macPutString "      shr $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaSAR00
		 mov al, [dabInstrukcija]
		 macPutString "      sar $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaROL00
		 mov al, [dabInstrukcija]
		 macPutString "      rol $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaROR00
		 mov al, [dabInstrukcija]
		 macPutString "      ror $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaRCL00
		 mov al, [dabInstrukcija]
		 macPutString "      rcl $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab

		 .tadaRCR00
		 mov al, [dabInstrukcija]
		 macPutString "      rcr $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", 1$"
		 macNewLine
		 jmp .pab


		 .galSSBRegMemWithReg8:
		 cmp al, 0x18
		 jne .galSSBReg16WithRegMem
		 macPutString "      sbb $"
		 call procTvarkykModRegRM8atv
		 macNewLine
		 jmp .pab
		 
		 .galSSBReg16WithRegMem:
		 cmp al, 0x1B
		 jne .galSSBReg8WithRegMem
		 macPutString "      sbb $"
		 call procTvarkykModRegRM
		 macNewLine
		 jmp .pab
		 
		 .galSSBReg8WithRegMem:
		 cmp al, 0x1A
		 jne .galSSBRegMemWithReg16
		 macPutString "      sbb $"
		 call procTvarkykModRegRM8
		 macNewLine
		 jmp .pab
		 
		 .galSSBRegMemWithReg16:
		 cmp al, 0x19
		 jne .galSSBImmToAX
		 macPutString "      sbb $"
		 call procTvarkykModRegRM16atv
		 macNewLine
		 jmp .pab
		 
		 .galSSBImmToAX:
		 cmp al, 0x1D
		 jne .galSSBImmToAl
		 macPutString "      sbb ax, $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galSSBImmToAl:
		 cmp al, 0x1C
		 jne .galCMPRegMemWithReg8
		 macPutString "      sbb al, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galCMPRegMemWithReg8:
		 cmp al, 0x38
		 jne .galCMPReg16WithRegMem
		 macPutString "      cmp $"
		 call procTvarkykModRegRM8atv
		 macNewLine
		 jmp .pab
		 
		 .galCMPReg16WithRegMem:
		 cmp al, 0x3B
		 jne .galCMPReg8WithRegMem
		 macPutString "      cmp $"
		 call procTvarkykModRegRM
		 macNewLine
		 jmp .pab
		 
		 .galCMPReg8WithRegMem:
		 cmp al, 0x3A
		 jne .galCMPRegMemWithReg16
		 macPutString "      cmp $"
		 call procTvarkykModRegRM8
		 macNewLine
		 jmp .pab
		 
		 .galCMPRegMemWithReg16:
		 cmp al, 0x39
		 jne .galCMPImmToAX
		 macPutString "      cmp $"
		 call procTvarkykModRegRM16atv
		 macNewLine
		 jmp .pab
		 
		 .galCMPImmToAX:
		 cmp al, 0x3D
		 jne .galCMPImmToAl
		 macPutString "      cmp ax, $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galCMPImmToAl:
		 cmp al, 0x3C
		 jne .galSUBRegMemWithReg8
		 macPutString "      cmp al, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .galSUBRegMemWithReg8:
		 cmp al, 0x28
		 jne .galSUBReg16WithRegMem
		 macPutString "      sub $"
		 call procTvarkykModRegRM8atv
		 macNewLine
		 jmp .pab
		 
		 .galSUBReg16WithRegMem:
		 cmp al, 0x2B
		 jne .galSUBReg8WithRegMem
		 macPutString "      sub $"
		 call procTvarkykModRegRM
		 macNewLine
		 jmp .pab
		 
		 .galSUBReg8WithRegMem:
		 cmp al, 0x2A
		 jne .galSUBRegMemWithReg16
		 macPutString "      sub $"
		 call procTvarkykModRegRM8
		 macNewLine
		 jmp .pab
		 
		 .galSUBRegMemWithReg16:
		 cmp al, 0x29
		 jne .galSUBImmToAX
		 macPutString "      sub $"
		 call procTvarkykModRegRM16atv
		 macNewLine
		 jmp .pab
		 
		 .galSUBImmToAX:
		 cmp al, 0x2D
		 jne .galSUBImmToAl
		 macPutString "      sub ax, $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galSUBImmToAl:
		 cmp al, 0x2C
		 jne .galADCRegMemWithReg8
		 macPutString "      sub al, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galADCRegMemWithReg8:
		 cmp al, 0x10
		 jne .galADCReg16WithRegMem
		 macPutString "      adc $"
		 call procTvarkykModRegRM8atv
		 macNewLine
		 jmp .pab
		 
		 .galADCReg16WithRegMem:
		 cmp al, 0x13
		 jne .galADCReg8WithRegMem
		 macPutString "      adc $"
		 call procTvarkykModRegRM
		 macNewLine
		 jmp .pab
		 
		 .galADCReg8WithRegMem:
		 cmp al, 0x12
		 jne .galADCRegMemWithReg16
		 macPutString "      adc $"
		 call procTvarkykModRegRM8
		 macNewLine
		 jmp .pab
		 
		 .galADCRegMemWithReg16:
		 cmp al, 0x11
		 jne .galADCImmToAX
		 macPutString "      adc $"
		 call procTvarkykModRegRM16atv
		 macNewLine
		 jmp .pab
		 
		 .galADCImmToAX:
		 cmp al, 0x15
		 jne .galADCImmToAl
		 macPutString "      adc ax, $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galADCImmToAl:
		 cmp al, 0x14
		 jne .galADDReg16WithRegMem
		 macPutString "      adc al, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galADDReg16WithRegMem:
		 cmp al, 0x3
		 jne .galADDReg8WithRegMem
		 macPutString "      add $"
		 call procTvarkykModRegRM
		 macNewLine
		 jmp .pab
		 
		 .galADDReg8WithRegMem:
		 cmp al, 0x2
		 jne .galADDRegMemWithReg16
		 macPutString "      add $"
		 call procTvarkykModRegRM8
		 macNewLine
		 jmp .pab
		 
		 .galADDRegMemWithReg16:
		 cmp al, 0x1
		 jne .galADDRegMemWithReg8
		 macPutString "      add $"
		 call procTvarkykModRegRM16atv
		 macNewLine
		 jmp .pab
		 
		 .galADDRegMemWithReg8:
		 cmp al, 0x0
		 jne .galADDImmToAx
		 macPutString "      add $"
		 call procTvarkykModRegRM8atv
		 macNewLine
		 jmp .pab
		 
		 .galADDImmToAx:
		 cmp al, 0x5
		 jne .galADDImmToAl
		 macPutString "      add ax, $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galADDImmToAl:
		 cmp al, 0x4
		 jne .galPrasideda83h
		 call skaitykFailoBaita
		 mov ah, al
		 macPutString "      add al, $"
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galPrasideda83h
		 cmp al, 0x83
		 jne .galPrasideda81h
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x0
		 je .tadaADDImmToReg16MemTik1
		 cmp al, 0x2
		 je .tadaADCImmToReg16MemTik1
		 cmp al, 0x5
		 je .tadaSUBImmFromReg16MemTik1
		 cmp al, 0x3
		 je .tadaSSBImmFromReg16MemTik1
		 jmp .tadaCMPImmWithReg16MemTik1
		 
		 .tadaADDImmToReg16MemTik1:
		 macPutString "      add $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaADCImmToReg16MemTik1:
		 macPutString "      adc $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaSUBImmFromReg16MemTik1:
		 macPutString "      sub $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaSSBImmFromReg16MemTik1:
		 macPutString "      sbb $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaCMPImmWithReg16MemTik1:
		 macPutString "      cmp $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 
		 .galPrasideda81h:
		 cmp al, 0x81
		 jne .galPrasideda80h
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x0
		 je .tadaADDImmToReg16Mem
		 cmp al, 0x2
		 je .tadaADCImmToReg16Mem
		 cmp al, 0x5
		 je .tadaSUBImmFromReg16Mem
		 cmp al, 0x3
		 je .tadaSSBImmFromReg16Mem
		 cmp al, 0x7
		 je .tadaCMPImmWithReg16Mem
		 cmp al, 0x4
		 je .tadaANDImmToReg16Mem
		 cmp al, 0x1
		 je .tadaORImmToReg16Mem
		 cmp al, 0x6
		 je .tadaXORImmToReg16Mem
		 
		 .tadaADDImmToReg16Mem:
		 macPutString "      add $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaADCImmToReg16Mem:
		 macPutString "      adc $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaSUBImmFromReg16Mem:
		 macPutString "      sub $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaSSBImmFromReg16Mem:
		 macPutString "      sbb $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaCMPImmWithReg16Mem:
		 macPutString "      cmp $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab   
		 
		 .tadaANDImmToReg16Mem:
		 macPutString "      and $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab 
		 
		 .tadaORImmToReg16Mem:
		 macPutString "      or $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab 
		 
		 .tadaXORImmToReg16Mem:
		 macPutString "      xor $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab 
		 
		 .galPrasideda80h:
		 cmp al, 0x80
		 jne .galCMPImmWithAx
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x0
		 je .tadaADDImmToReg8Mem
		 cmp al, 0x2
		 je .tadaADCImmToReg8Mem
		 cmp al, 0x5
		 je .tadaSUBImmFromReg8Mem
		 cmp al, 0x3
		 je .tadaSSBImmFromReg8Mem
		 cmp al, 0x7
		 je .tadaCMPImmWithReg8Mem
		 cmp al, 0x4
		 je .tadaANDImmToReg8Mem
		 cmp al, 0x1
		 je .tadaORImmToReg8Mem
		 cmp al, 0x6
		 je .tadaXORImmToReg8Mem
		 
		 .tadaADDImmToReg8Mem:
		 macPutString "      add $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 
		 .tadaADCImmToReg8Mem:
		 macPutString "      adc $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		
		
		 .tadaSUBImmFromReg8Mem:
		 macPutString "      sub $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaSSBImmFromReg8Mem:
		 macPutString "      sbb $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaCMPImmWithReg8Mem:
		 macPutString "      cmp $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaANDImmToReg8Mem:
		 macPutString "      and $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaORImmToReg8Mem
		 macPutString "      or $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .tadaXORImmToReg8Mem
		 macPutString "      xor $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 
		 
		 .galCMPImmWithAx:
		 cmp al, 0x3D
		 jne .galCMPImmWithAl
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 macPutString "      cmp ax, $"
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 
		 
		 .galCMPImmWithAl:
		 cmp al, 0x3C
		 jne .galAAM
		 call skaitykFailoBaita
		 macPutString "      cmp al, $"
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galAAM:
		 cmp al, 0xD4
		 jne .galNEG16
		 call skaitykFailoBaita
		 macPutString "      aam$"
		 macNewLine
		 jmp .pab
		 
		 .galNEG16:
		 cmp al, 0xF7
		 jne .galNEG8
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x3
		 jne .galMUL16
		 macPutString "      neg $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galNEG8:
		 cmp al, 0xF6
		 jne .galMovMemToreg16
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x3
		 jne .galMUL8
		 macPutString "      neg $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galMUL16:
		 cmp al, 0x4
		 jne .galIMUL16
		 mov al, [dabInstrukcija]
		 macPutString "      mul $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galMUL8:
		 cmp al, 0x4
		 jne .galIMUL8
		 mov al, [dabInstrukcija]
		 macPutString "      mul $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galIMUL16:
		 cmp al, 0x5
		 jne .galDIV16
		 mov al, [dabInstrukcija]
		 macPutString "      imul $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galIMUL8:
		 cmp al, 0x5
		 jne .galDIV8
		 mov al, [dabInstrukcija]
		 macPutString "      imul $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galDIV16
		 cmp al, 0x6
		 jne .galIDIV16
		 mov al, [dabInstrukcija]
		 macPutString "      div $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galDIV8
		 cmp al, 0x6
		 jne .galIDIV8
		 mov al, [dabInstrukcija]
		 macPutString "      div $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 
		 .galIDIV8
		 cmp al, 0x7
		 jne .galNOT8
		 mov al, [dabInstrukcija]
		 macPutString "      idiv $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galIDIV16:
		 cmp al, 0x7
		 jne .galNOT16
		 mov al, [dabInstrukcija]
		 macPutString "      idiv $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab

		 .galNOT8:
		 cmp al, 0x2
		 jne .tadaTEST8
		 mov al, [dabInstrukcija]
		 macPutString "      not $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macNewLine
		 jmp .pab

		 .galNOT16:
		 cmp al, 0x2
		 jne .tadaTEST16
		 mov al, [dabInstrukcija]
		 macPutString "      not $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab

		 .tadaTEST8:
		 mov al, [dabInstrukcija]
		 macPutString "      test $"
		 call procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab

		 .tadaTEST16:
		 mov al, [dabInstrukcija]
		 macPutString "      test $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galMovMemToreg16:
		 cmp al, 0x8B
		 jne .galMOVreg16ToMem
		 macPutString "      mov $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 mov [pirmasREG], al
		 call isveskRegistra
		 macPutString ", $"
		 mov al, [dabInstrukcija]
		 call procTvarkykModRegRMbePirmoReg
		 macNewLine
		 jmp .pab
		 
		 
		 
		 .galMOVreg16ToMem:
		 cmp al, 0x89
		 jne .galMOVMemToReg16
		 macPutString "      mov $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call procTvarkykModRegRMbePirmoReg
		 macPutString ", $"
		 mov al, [dabInstrukcija]
		 shr al, 3
		 and al, 0x7
		 mov [pirmasREG], al
		 call isveskRegistra
		 macNewLine
		 jmp .pab
		 
		 .galMOVMemToReg16
		 cmp al, 0x8A
		 jne .galMOVMemToReg8
		 macPutString "      mov $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 mov [pirmasREG], al
		 call isveskRegistraMaza
		 macPutString ", $"
		 call procTvarkykModRegRMbePirmoReg
		 macNewLine
		 jmp .pab
		 
		 
		 .galMOVMemToReg8
		 cmp al, 0x88
		 jne .galMOVImmToRegMem16
		 macPutString "      mov $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 mov [pirmasREG], al
		 call procTvarkykModRegRMbePirmoReg8
		 macPutString ", $"
		 call isveskRegistraMaza
		 macNewLine
		 jmp .pab
		 
		 .galMOVImmToRegMem16
		 cmp al, 0xC7
		 jne .galMOVImmToRegMem8
		 macPutString "      mov word ptr $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call procTvarkykModRegRMbePirmoReg
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 
		 .galMOVImmToRegMem8
		 cmp al, 0xC6
		 jne .galMOVImmToReg16
		 macPutString "      mov byte ptr $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call procTvarkykModRegRMbePirmoReg
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galMOVImmToReg16
		 shr al, 3
		 cmp al, 0x17
		 jne .galMOVImmToReg8
		 macPutString "      mov $"
		 mov al, [dabInstrukcija]
		 and al, 0x7
		 mov [pirmasREG], al
		 call isveskRegistra
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galMOVImmToReg8:
		 mov al, [dabInstrukcija]
		 shr al, 3
		 cmp al, 0x16
		 jne .galMOVMemToAx
		 macPutString "      mov $"
		 mov al, [dabInstrukcija]
		 and al, 0x7
		 mov [pirmasREG], al
		 call isveskRegistraMaza
		 macPutString ", $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galMOVMemToAx
		 mov al, [dabInstrukcija]
		 cmp al, 0xA1
		 jne .galMOVMemToAl
		 macPutString "      mov ax, [$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macPutString "]$"
		 macNewLine
		 jmp .pab
		 
		 .galMOVMemToAl
		 cmp al, 0xA0
		 jne .galMOVaxToMem
		 macPutString "      mov al, [$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macPutString "]$"
		 macNewLine
		 jmp .pab
		 
		 .galMOVaxToMem
		 cmp al, 0xA3
		 jne .galMOValToMem
		 macPutString "      mov    [$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macPutString "], ax$"
		 macNewLine
		 jmp .pab
		 
		 .galMOValToMem
		 cmp al, 0xA2
		 jne .galMOVRegToSeg
		 macPutString "      mov    [$"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 mov ah, [dabInstrukcija]
		 call procPutHexByte
		 macPutString "], al$"
		 macNewLine
		 jmp .pab
		 
		 
		 .galMOVRegToSeg
		 cmp al, 0x8E
		 jne .galMOVSegToReg
		 macPutString "      mov $"
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 mov [pirmasREG], al
		 mov al, [dabInstrukcija]
		 call isveskSegmenta
		 macPutString ", word ptr $"
		 call procTvarkykModRegRMbePirmoReg
		 macNewLine
		 jmp .pab
		 
		 .galMOVSegToReg
		 cmp al, 0x8C
		 jne .galPrasidedaFFh
		 macPutString "      mov   word ptr $"
		 call procTvarkykModRegRMatv
		 macPutString ", $"
		 mov al, [dabInstrukcija]
		 shr al, 3
		 and al, 0x7
		 mov [pirmasREG], al
		 call isveskSegmenta
		 macNewLine
		 jmp .pab
		 
		 .galPrasidedaFFh:
		 cmp al, 0xFF
		 jne .galPUSHREG
		 call skaitykFailoBaita
		 mov [dabInstrukcija], al
		 shr al, 3
		 and al, 0x7
		 cmp al, 0x6
		 jne .galCALLIndIwthinSeg
		 mov al, [dabInstrukcija]
		 macPutString "      push $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine 
		 jmp .pab
		 
		 .galCALLIndIwthinSeg:
		 cmp al,0x2
		 jne .galCALLIndInter
		 macPutString "      call $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galCALLIndInter:
		 cmp al, 0x3
		 jne .galJMPIndWithSeg
		 macPutString "      call $"
		 call procTvarkykModRegBeRegRMSuFARDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galJMPIndWithSeg:
		 cmp al, 0x4
		 jne .galJMPIndInter
		 macPutString "      jmp $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galJMPIndInter:
		 cmp al, 0x5
		 jne .galINC16
		 macPutString "      jmp $"
		 call procTvarkykModRegBeRegRMSuFARDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galINC16
		 cmp al, 0x0
		 jne .tadaDEC16
		 macPutString "      inc $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .tadaDEC16
		 macPutString "      dec $"
		 call procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		 macNewLine
		 jmp .pab
		 
		 .galPUSHREG
		 cmp al, 0x50
		 jl .galPUSHSR
		 cmp al, 0x57
		 jg .galPUSHSR
		 macPutString "      push $"
		 and al, 0x7
		 mov [pirmasREG], al
		 call isveskRegistra
		 macNewLine
		 jmp .pab
		 
		 
		 .galPUSHSR
		 cmp al, 0x6
		 jl .galPOPREGMEM
		 cmp al, 0x1E
		 jg .galPOPREGMEM
		 and al, 0x7
		 cmp al, 6
		 jne .galPOPSR
		 mov al, [dabInstrukcija]
		 macPutString "      push $"
		 shr al, 3
		 and al, 0x3
		 mov [pirmasREG], al
		 call isveskSegmenta
		 macNewLine 
		 jmp .pab
		 
		 .galPOPREGMEM
		 cmp al, 0x8f
		 jne .galPOPREG
		 macPutString "      pop   word ptr $"
		 call procTvarkykModRegRMBeReg1
		 macNewLine 
		 jmp .pab
		 
		 .galPOPREG
		 mov al, [dabInstrukcija]
		 cmp al, 0x58
		 jl .galPOPSR
		 cmp al, 0x5F
		 jg .galPOPSR
		 macPutString "      pop $"
		 and al, 0x7
		 mov [pirmasREG], al
		 call isveskRegistra
		 macNewLine
		 jmp .pab
		 
		 .galPOPSR:
		 mov al, [dabInstrukcija]
		 cmp al, 0x7
		 jl .galIN16bitu
		 cmp al, 0x1F
		 jg .galIN16bitu
		 macPutString "      pop $"
		 shr al, 3
		 and al, 0x3
		 mov [pirmasREG], al
		 call isveskSegmenta
		 macNewLine
		 jmp .pab


		 ;ziurim in 16 bitu registro. sokti gali tik i dx
		 .galIN16bitu:
		 cmp al, 0xED
		 jne .galIN8bitu
		 macPutString "      in ax, dx$"
		 macNewLine
		 jmp .pab
		 
		 .galIN8bitu:
		 cmp al, 0xEC
		 jne .galIN16fixed
		 macPutString "      in al, dx$"
		 macNewLine
		 jmp .pab
		 
		 .galIN16fixed:
		 cmp al, 0xE5
		 jne .galIN8fixed
		 macPutString "      in ax, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
		 .galIN8fixed:
		 cmp al, 0xE4
		 jne .galOUT16bitu
		 macPutString "      in al, $"
		 call skaitykFailoBaita
		 mov ah, al
		 call procPutHexByte
		 macNewLine
		 jmp .pab
		 
         .galOUT16bitu:
		 cmp al, 0xEF
         jne .galOUT8bitu
         macPutString "      out dx, ax$"
         macNewLine
         jmp .pab

         .galOUT8bitu:
         cmp al, 0xEE
         jne .galOUT16fixed
         macPutString "      out dx, al$"
         macNewLine
         jmp .pab

         .galOUT16fixed:
         cmp al, 0xE7
         jne .galOUT8fixed
         call skaitykFailoBaita
         mov ah, al
         macPutString "      out $"
         call procPutHexByte
         macPutString ", ax$"
         macNewLine
         jmp .pab

         .galOUT8fixed:
         cmp al, 0xE6
         jne .galXCHGAX
         call skaitykFailoBaita
         mov ah, al
         macPutString "      out $"
         call procPutHexByte
         macPutString ", al$"
         macNewLine
         jmp .pab

         .galXCHGAX:
         shr al, 3
         cmp al, 0x12
         jne .galXCHG16
         mov al, [dabInstrukcija]
         and al, 0x7
         mov [pirmasREG], al
         macPutString "      xchg ax, $"
         call isveskRegistra
         macNewLine
         jmp .pab
         
         .galXCHG16
         mov al, [dabInstrukcija]
         cmp al, 0x87
         jne .galXCHG8
         macPutString "      xchg $"
         call procTvarkykModRegRMSuWordPtr
		 macNewLine
         jmp .pab

         .galXCHG8:
		 mov al, [dabInstrukcija]
		 cmp al, 0x86
		 jne .galINC
		 macPutString "      xchg $"
		 call procTvarkykModRegRMSuBytePtr
		 macNewLine
		 jmp .pab
		 
		 
		 
		 .galINC:
         shr al, 3                           ;INC 16 bitu
         cmp al, 0x8 
         jne .galDEC
         macPutString "      inc $"
         mov al, [dabInstrukcija]
         mov [kasBuvoBH], bh
         mov bh, [pirmasREG]
         and al, bh
         mov bh, [kasBuvoBH]
         mov [pirmasREG], al
         call isveskRegistra
		 macNewLine
         jmp .pab

         .galDEC                            ;dec 16 bitu
         mov al, [dabInstrukcija]
         shr al, 3
         cmp al, 0x9
         jne .galINCarbaDEC
         macPutString "      dec $"
         mov al, [dabInstrukcija]
         mov [kasBuvoBH], bh
         mov bh, [pirmasREG]
         and al, bh
         mov bh, [kasBuvoBH]
         mov [pirmasREG], al
         call isveskRegistra
		 macNewLine
         jmp .pab
		 
         .galINCarbaDEC:                       ;kadangi inc ir dec 8 bitu masininio kodo pirmas baitas yra lygus, reikes kazka tikrint
         mov al, [dabInstrukcija]
         cmp al, 0xFE
         jne .galLEA
         ;taigi, suradome, kad tai yra arba inc arba dec
         ;kad patikrintume, ar tai inc, ar tai dec, reikia pasiziureti vidurinius 3 bitus
         ;jeigu 000 - tai inc
         ;kitu atveju - tai dec
         ;taip pat su inc ir dec instrukcijomis mod visada bus 11, tai nereikia kreipti demesio i poslinkius, kai mod!=11
         call skaitykFailoBaita
         mov [kasBuvoBH], bh
         mov bh, [tikrinkArInc8]
         and bh, al 
         cmp bh, 0x0
		 jne .busDEC8
         call procTvarkykINC8	
		 mov bh, [kasBuvoBH]
		 macNewLine 
         jmp .pab
			
		 .busDEC8:								;DEC8
		 call procTvarkykDEC8
		 mov bh, [kasBuvoBH]
		 macNewLine 
		 jmp .pab

		 .galLEA								;LEA (load efekyvuji adresa i registra)
		 mov al, [dabInstrukcija]
		 cmp al, 0x8D
		 jne .galLDS
         macPutString "      lea $"
		 call procTvarkykModRegRM
		 macNewLine 
		 jmp .pab
		 
		 .galLDS
         mov al, [dabInstrukcija]
         cmp al, 0xC5
         jne .galLES
         macPutString "      lds $"
		 call procTvarkykModRegRM
		 macNewLine 
         jmp .pab
		 
         .galLES
         mov al, [dabInstrukcija]
         cmp al, 0xC4
         jne .galAAD
         macPutString "      les $"
         call procTvarkykModRegRM
		 macNewLine 
         jmp .pab

         .galAAD:                                ;AAD
         mov al, [dabInstrukcija]
         cmp al, 0xD5
         jne .galINT
         call skaitykFailoBaita
         writeln strAAD
         jmp .pab

		 .galINT:								; INT
		 cmp al, 0xCD
		 jne .galXLAT
		 call procTvarkykINT
		 macNewLine 
		 jmp .pab
		 
		 .galXLAT:						 		 ; XLAT
		 cmp al, 0xD7
		 jne .galPOPF
		 writeln strXLAT
		 jmp .pab
		 
		 .galPOPF:								 ; POPF
		 cmp al, 0x9D
		 jne .galPUSHF
		 writeln strPOPF
		 jmp .pab
		 
		 .galPUSHF:								 ; PUSHF
		 cmp al, 0x9C
		 jne .galSANF
		 writeln strPUSHF
		 jmp .pab
		 
		 .galSANF:								 ; SANF
		 cmp al, 0x9E
		 jne .galLANF
		 writeln strSANF
		 jmp .pab
		 
		 .galLANF:								 ; LANF
		 cmp al, 0x9F
		 jne .galCWD
		 writeln strLANF
		 jmp .pab
		 
		 .galCWD:								 ; CWD
		 cmp al, 0x99
		 jne .galCBW
		 writeln strCWD
		 jmp .pab
		 
		 .galCBW:								 ; CBW
		 cmp al, 0x98
		 jne .galDAS
		 writeln strCBW
		 jmp .pab
		 
		 .galDAS:								 ; DAS
		 cmp al, 0x2F
		 jne .galAAS
		 writeln strDAS
		 jmp .pab
		 
		 .galAAS:								 ; AAS
		 cmp al, 0x3F
		 jne .galINT3
		 writeln strAAS
		 jmp .pab
		 
		 .galINT3:								 ;INT 3
		 cmp al, 0xCC
		 jne .galINTO
		 writeln strINT3
		 jmp .pab
		
		 .galINTO:								 ;INTO
		 cmp al, 0xCE
		 jne .galIRET
		 writeln strINTO
		 jmp .pab
		 
		 .galIRET:								 ;IRET
		 cmp al, 0xCF
		 jne .galLOCK
		 writeln strIRET
		 jmp .pab
		 
		 .galLOCK:								 ; LOCK
		 cmp al, 0xF0							 
		 jne .galWAIT
		 writeln strLOCK
		 jmp .pab
		 
		 .galWAIT:								 ; WAIT
		 cmp al, 0x9B
		 jne .galHLT
		 writeln strWAIT
		 jmp .pab
		 
		 .galHLT:							 	 ; HLT
		 cmp al, 0xF4
		 jne .galSTI
		 writeln strHLT
		 jmp .pab								 
		 
		 .galSTI:
		 cmp al, 0xFB							 ; STI
		 jne .galCLI
		 writeln strSTI
		 jmp .pab
		 
		 .galCLI:
		 cmp al, 0xFA							 ; CLI
		 jne .galSTD
		 writeln strCLI
		 jmp .pab
		 
		 .galSTD:
		 cmp al, 0xFD							 ; STD
		 jne .galCLD
		 writeln strSTD
		 jmp .pab
			
		 .galCLD:
		 cmp al, 0xFC							 ; CLD
		 jne .galCLC
		 writeln strCLD
		 jmp .pab
		 
		 .galCLC:
         cmp al, 0xF8                            ; CLC
         jne .galCMC
         writeln strCLC
         jmp .pab
                 
         .galCMC:
         cmp al, 0xF5                            ; CMC
         jne .galSTC
         writeln strCMC
         jmp .pab

         .galSTC:
         cmp al, 0F9h                            ; STC
         jne .galRET
         writeln strSTC
         jmp .pab
         
         .galRET:
         cmp al, 0xC3                          ; RET
         jne .galRETF
         writeln strRET
         jmp .pab
                   
         .galRETF:
         cmp al, 0xCB                            ; RETF
         jne .tiesiogDB
         writeln strRETF
         jmp .pab
         
		 
		 cmp ax, 00
		 je .isejimas1

         .tiesiogDB:
         call konvertuokI16taine                 ; DB
         mov [nuskaitytas],  ax
         writeln strDB
         
         
         
         
         
         
         .pab:
         pop ax
         pop bx
         ret 
		 
		 .isejimas1:
		 pop cx
         pop ax
         pop si
         pop di 
         pop dx
         ret
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykINT
		call skaitykFailoBaita ;nuskaitome INT tipas
		macPutString "      int $"
		mov ah, al
        call procPutHexByte
		macPutChar 'h'
		macNewLine
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    procTvarkykJCXZ
        call skaitykFailoBaita
        macPutString "      jcxz $"
        mov ah, al
        call procPutHexByte
        macNewLine
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegBeRegRMSuFARDivIrPan
		mov al, [dabInstrukcija]
		shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "far [$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        macPutString " $"
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRM16atv
		call skaitykFailoBaita
		mov [dabInstrukcija], al
		shr al, 3
		and al, 0x7

		mov [pirmasREG], al
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "[$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		macPutString ", $"
		call isveskRegistra
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
		macPutString ", $"
		call isveskRegistra
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
		macPutString ", $"
		call isveskRegistra
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
		macPutString ", $"
		mov al, [dabInstrukcija]
		shr al, 3
		and al, 0x7
		mov [pirmasREG], al
		call isveskRegistra
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRM8atv
		call skaitykFailoBaita
		mov [dabInstrukcija], al
		shr al, 3
		and al, 0x7

		mov [pirmasREG], al
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "[$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		macPutString ", $"
		call isveskRegistraMaza
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
		macPutString ", $"
		call isveskRegistraMaza
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
		macPutString ", $"
		call isveskRegistraMaza
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistraMaza
		macPutString ", $"
		mov al, [dabInstrukcija]
		shr al, 3
		and al, 0x7
		mov [pirmasREG], al
		call isveskRegistraMaza
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegBeRegRMSuBytePtrDivIrPan
		mov al, [dabInstrukcija]
		shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "byte ptr [$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11

		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        macPutString " $"
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistraMaza
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegBeRegRMSuWordPtrDivIrPan
		mov al, [dabInstrukcija]
		shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "word ptr [$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        macPutString " $"
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegBeRegRMSuBytePtr
		call skaitykFailoBaita
		mov [dabInstrukcija], al
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "byte ptr [$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        macPutString " $"
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistraMaza
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegBeRegRMSuWordPtr
		call skaitykFailoBaita
		mov [dabInstrukcija], al
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "word ptr [$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        macPutString " $"
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRMSuBytePtr
	call skaitykFailoBaita
		mov [dabInstrukcija], al
		shl al, 2
		shr al, 5
		mov [pirmasREG], al
		call isveskRegistraMaza
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString ", byte ptr [$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        macPutString ", $"
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistraMaza
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRMSuWordPtr
		call skaitykFailoBaita
		mov [dabInstrukcija], al
		shl al, 2
		shr al, 5
		mov [pirmasREG], al
		call isveskRegistra
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString ", word ptr [$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        macPutString ", $"
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRMbePirmoReg8
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "[$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistraMaza
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRMbePirmoReg
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "[$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRMatv
		call skaitykFailoBaita
		mov [dabInstrukcija], al
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "[$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
        mov al, [dabInstrukcija]
        shl al, 2
        shr al, 5
        macPutString ", $"
        mov [pirmasREG], al
        call isveskRegistra
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRMBeReg1
		call skaitykFailoBaita
		mov [dabInstrukcija], al
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "[$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
        mov al, [dabInstrukcija]
        shl al, 2
        shr al, 5
        macPutString ", $"
        mov [pirmasREG], al
        call isveskRegistra
        macNewLine
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRMBeReg2
		mov [dabInstrukcija], al
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString "[$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
        mov al, [dabInstrukcija]
        shl al, 2
        shr al, 5
        macPutString ", $"
        mov [pirmasREG], al
        call isveskRegistra
        macNewLine
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRM
		call skaitykFailoBaita
		mov [dabInstrukcija], al
		shl al, 2
		shr al, 5
		mov [pirmasREG], al
		call isveskRegistra
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString ", [$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        macPutString ", $"
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistra
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykModRegRM8
		call skaitykFailoBaita
		mov [dabInstrukcija], al
		shr al, 3
		and al, 0x7

		mov [pirmasREG], al
		call isveskRegistraMaza
		mov al, [dabInstrukcija]
        shr al, 6
        cmp al, 0x3
        jne .galMod00
        jmp .tadaMod11
		
        .galMod00:
		macPutString ", [$"
		mov al, [dabInstrukcija]
		shr al, 6
		cmp al, 0x0
		jne .galMod01
		call registruIsvedimasKaiMod00
		ret
		
		.galMod01
		cmp al, 0x1
		jne .galMod10
		call registruIsvedimasKaiMod01
        ret
		
		.galMod10:
		cmp al, 0x2
		jne .tadaMod11
		call registruIsvedimasKaiMod10
        ret
		
		.tadaMod11:
        ;tada r/m is treated as reg
        ;traktuosime ne kaip mod reg r/m, o kaip mod r/m reg
		mov al, [dabInstrukcija]
        macPutString ", $"
		and al, 0x7
        mov [pirmasREG], al
        call isveskRegistraMaza
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    procTvarkykINC8
        ;naudosime al
        ;kaip minejau, mod visada bus 11, tai tsg reikes isvesti registra
        macPutString "      inc $"
		
        shl al, 5 ;istriname pirmus 6 bitus
		shr al, 5 ;istriname kitus bitus
        mov [pirmasREG], al
        call isveskRegistraMaza
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	procTvarkykDEC8
		macPutString "      dec $"
		shl al, 5
		shr al, 5
		mov [pirmasREG], al
		call isveskRegistraMaza
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    skaitykArgumenta:  
         ; nuskaito ir paruosia argumenta
         ; jeigu jo nerasta, tai CF <- 1, prisingu atveju - 0

         push bx
         push di
         push si 
         push ax

         xor bx, bx
         xor si, si
         xor di, di

         mov bl, [80h]
         mov [komEilIlgis], bl
         mov si, 0081h  
         mov di, komEilutesArgumentas
         push cx
         mov cx, bx
         mov ah,00
         cmp cx, 0000
         jne .pagalVisus
         stc 
         jmp .pab
   
         .pagalVisus:
         mov al, [si]     ;
         cmp al, ' '
         je .toliau
         cmp al, 0Dh
         je .toliau
         cmp al, 0Ah
         je .toliau
         mov [di],al
         ; call rasykSimboli  
         mov ah, 01                  ; ah - pozymis, kad buvo bent vienas "netarpas"
         inc di     
         jmp .kitasZingsnis
         .toliau:
         cmp ah, 01                  ; gal jau buvo "netarpu"?  
         je .isejimas 
         .kitasZingsnis:
         inc si
     
         loop .pagalVisus
         .isejimas: 
         cmp ah, 01                  ; ar buvo "netarpu"?  
         je .pridetCOM
         stc                         ; klaida!   
         jmp .pab 
         .pridetCOM:
         mov [di], byte '.'
         mov [di+1], byte 'C'
         mov [di+2], byte 'O'
         mov [di+3], byte 'M'
         clc                         ; klaidos nerasta
         .pab:
         pop cx
         pop ax
         pop si
         pop di 
         pop dx
         ret
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    skaitomeFaila:  
        ; skaitome faila po viena baita 
        ; bx - failo deskriptorius
        ; dx - buferis 
        push ax
        push dx
        push bx
        push cx
        push si
                
        mov si, dx 
        .kartok:
        mov cx, 01
        mov ah, 3Fh 
        int 21h
        jc .isejimas           ; skaitymo klaida
        cmp ax, 00
        je .isejimas           ; skaitymo pabaiga

        mov al,[si]            ; is buferio
		
		mov [kasBuvoCL], cl
		mov cl, [saugomIP]
		inc cl
		mov [saugomIP], cl
		mov cl, [kasBuvoCL]
   
        call analizuokKoda     ; bandome dekoduoti

        jmp .kartok
        
        .isejimas:
        pop si
        pop cx
        pop bx
        pop dx
        pop ax
        ret   
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	skaitykFailoBaita:
		 mov [kasBuvoCL], cl
         call procFGetChar
         mov al, cl
		 mov cl, [kasBuvoCL]
		 
		 mov [kasBuvoCL], cl
		 mov cl, [saugomIP]
		 inc cl
		 mov [saugomIP], cl
		 mov cl, [kasBuvoCL]
		
		 ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    isveskRegistra:
        mov al, 0
        cmp [pirmasREG], al
        jne .galCX
        macPutString "ax$"
        jp .isvedimoRegistroPabaiga

        .galCX:
        inc al
        cmp [pirmasREG], al
        jne .galDX
        macPutString "cx$"
        jp .isvedimoRegistroPabaiga

        .galDX
        inc al
        cmp [pirmasREG], al
        jne .galBX
        macPutString "dx$"
        jp .isvedimoRegistroPabaiga

        .galBX
        inc al
        cmp [pirmasREG], al
        jne .galSP
        macPutString "bx$"
        jp .isvedimoRegistroPabaiga

        .galSP
        inc al
        cmp [pirmasREG], al
        jne .galBP
        macPutString "sp$"
        jp .isvedimoRegistroPabaiga

        .galBP
        inc al
        cmp [pirmasREG], al
        jne .galSI
        macPutString "bp$"
        jp .isvedimoRegistroPabaiga

        .galSI
        inc al
        cmp [pirmasREG], al
        jne .busDI
        macPutString "si$"
        jp .isvedimoRegistroPabaiga

        .busDI:
        macPutString "di$"
        jp .isvedimoRegistroPabaiga

        .isvedimoRegistroPabaiga:
        mov [kasBuvoBH], bh
        mov bh, 0
        times 7 inc bh
        mov [pirmasREG], bh
        mov bh, [kasBuvoBH]
        ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    isveskRegistraMaza:
        mov al, 0
        cmp [pirmasREG], al
        jne .galCL
        macPutString "al$"
        jp .isvedimoRegistroPabaiga

        .galCL:
        inc al
        cmp [pirmasREG], al
        jne .galDL
        macPutString "cl$"
        jp .isvedimoRegistroPabaiga

        .galDL
        inc al
        cmp [pirmasREG], al
        jne .galBL
        macPutString "dl$"
        jp .isvedimoRegistroPabaiga

        .galBL
        inc al
        cmp [pirmasREG], al
        jne .galAH
        macPutString "bl$"
        jp .isvedimoRegistroPabaiga

        .galAH
        inc al
        cmp [pirmasREG], al
        jne .galCH
        macPutString "ah$"
        jp .isvedimoRegistroPabaiga

        .galCH
        inc al
        cmp [pirmasREG], al
        jne .galDH
        macPutString "ch$"
        jp .isvedimoRegistroPabaiga

        .galDH
        inc al
        cmp [pirmasREG], al
        jne .busBH
        macPutString "dh$"
        jp .isvedimoRegistroPabaiga

        .busBH:
        macPutString "bh$"
        jp .isvedimoRegistroPabaiga

        .isvedimoRegistroPabaiga:
        mov [kasBuvoBH], bh
        mov bh, 0
        times 7 inc bh
        mov [pirmasREG], bh
        mov bh, [kasBuvoBH]
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	isveskSegmenta
		mov al, 0
		cmp [pirmasREG], al
		jne .galCS
		macPutString "es$"
		jmp .segmentoIsvedimoPabaiga
		
		.galCS:
		inc al
		cmp al, [pirmasREG]
		jne .galSS
		macPutString "cs$"
		jmp .segmentoIsvedimoPabaiga
		
		.galSS:
		inc al
		cmp al, [pirmasREG]
		jne .tadaDS
		macPutString "ss$"
		jmp .segmentoIsvedimoPabaiga
		
		.tadaDS:
		macPutString "ds$"
		jmp .segmentoIsvedimoPabaiga
		
		.segmentoIsvedimoPabaiga
		mov [kasBuvoBH], bh
        mov bh, 0
        times 7 inc bh
        mov [pirmasREG], bh
        mov bh, [kasBuvoBH]
        ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	registruIsvedimasKaiMod00:
		mov al, [dabInstrukcija]
		and al, 0x7
		cmp al, 0x0
		jne .galrm001
		macPutString "bx+si$"
		jmp .IsveskPoslinki
		
		.galrm001:
		cmp al, 0x1
		jne .galrm010
		macPutString "bx+di$"
		jmp .IsveskPoslinki
		
		.galrm010
		cmp al, 0x2
		jne .galrm011
		macPutString "bp+si$"
		jmp .IsveskPoslinki
		
		.galrm011
		cmp al, 0x3
		jne .galrm100
		macPutString "bp+di$"
		jmp .IsveskPoslinki
		
		.galrm100
		cmp al, 0x4
		jne .galrm101
		macPutString "si$"
		jmp .IsveskPoslinki
		
		.galrm101
		cmp al, 0x5
		jne .galrm110
		macPutString "di$"
		jmp .IsveskPoslinki
		
		.galrm110
		cmp al, 0x6
		jne .galrm111
		call skaitykFailoBaita
		mov [dabInstrukcija], al
		call skaitykFailoBaita
		mov ah, al
		call procPutHexByte
		mov ah, [dabInstrukcija]
		call procPutHexByte
		jmp .IsveskPoslinki
		
		.galrm111
		macPutString "bx$"
		jmp .IsveskPoslinki
		
		
		.IsveskPoslinki:
		macPutString "]$"
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
registruIsvedimasKaiMod01
		mov al, [dabInstrukcija]
		and al, 0x7
		cmp al, 0x0
		jne .galrm001
		macPutString "bx+si+$"
		jmp .IsveskPoslinki
		
		.galrm001:
		cmp al, 0x1
		jne .galrm010
		macPutString "bx+di+$"
		jmp .IsveskPoslinki
		
		.galrm010
		cmp al, 0x2
		jne .galrm011
		macPutString "bp+si+$"
		jmp .IsveskPoslinki
		
		.galrm011
		cmp al, 0x3
		jne .galrm100
		macPutString "bp+di+$"
		jmp .IsveskPoslinki
		
		.galrm100
		cmp al, 0x4
		jne .galrm101
		macPutString "si+$"
		jmp .IsveskPoslinki
		
		.galrm101
		cmp al, 0x5
		jne .galrm110
		macPutString "di+$"
		jmp .IsveskPoslinki
		
		.galrm110
		cmp al, 0x6
		jne .galrm111
		macPutString "bp+$"
		jmp .IsveskPoslinki
		
		.galrm111
		macPutString "bx+$"
		jmp .IsveskPoslinki
		
		
		.IsveskPoslinki:
		call skaitykFailoBaita
		mov ah, al
		call procPutHexByte
		macPutString "]$"
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	registruIsvedimasKaiMod10
		mov al, [dabInstrukcija]
		and al, 0x7
		cmp al, 0x0
		jne .galrm001
		macPutString "bx+si+$"
		jmp .IsveskPoslinki
		
		.galrm001:
		cmp al, 0x1
		jne .galrm010
		macPutString "bx+di+$"
		jmp .IsveskPoslinki
		
		.galrm010
		cmp al, 0x2
		jne .galrm011
		macPutString "bp+si+$"
		jmp .IsveskPoslinki
		
		.galrm011
		cmp al, 0x3
		jne .galrm100
		macPutString "bp+di+$"
		jmp .IsveskPoslinki
		
		.galrm100
		cmp al, 0x4
		jne .galrm101
		macPutString "si+$"
		jmp .IsveskPoslinki
		
		.galrm101
		cmp al, 0x5
		jne .galrm110
		macPutString "di+$"
		jmp .IsveskPoslinki
		
		.galrm110
		cmp al, 0x6
		jne .galrm111
		macPutString "bp+$"
		jmp .IsveskPoslinki
		
		.galrm111
		macPutString "bx+$"
		jmp .IsveskPoslinki
		
		
		.IsveskPoslinki:
		call skaitykFailoBaita
		mov [poslinkioIsvedimuiPirmas], al
		call skaitykFailoBaita
		mov ah, al
		call procPutHexByte
		mov ah, [poslinkioIsvedimuiPirmas]
		call procPutHexByte
		macPutString "]$"
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    registruIsvedimasKaiMod11
    	mov al, [dabInstrukcija]
        shl al, 2
		shr al, 5

		cmp al, 0x0
		jne .galrm001
		macPutString "bx+si+$"
		jmp .IsveskPoslinki
		
		.galrm001:
		cmp al, 0x1
		jne .galrm010
		macPutString "bx+di+$"
		jmp .IsveskPoslinki
		
		.galrm010
		cmp al, 0x2
		jne .galrm011
		macPutString "bp+si+$"
		jmp .IsveskPoslinki
		
		.galrm011
		cmp al, 0x3
		jne .galrm100
		macPutString "bp+di+$"
		jmp .IsveskPoslinki
		
		.galrm100
		cmp al, 0x4
		jne .galrm101
		macPutString "si+$"
		jmp .IsveskPoslinki
		
		.galrm101
		cmp al, 0x5
		jne .galrm110
		macPutString "di+$"
		jmp .IsveskPoslinki
		
		.galrm110
		cmp al, 0x6
		jne .galrm111
		macPutString "bp+$"
		jmp .IsveskPoslinki
		
		.galrm111
		macPutString "bx+$"
		jmp .IsveskPoslinki
		
		
		.IsveskPoslinki:
		call skaitykFailoBaita
		mov [poslinkioIsvedimuiPirmas], al
		call skaitykFailoBaita
		mov ah, al
		call procPutHexByte
		mov ah, [poslinkioIsvedimuiPirmas]
		call procPutHexByte
		macPutString "]$"
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    writeASCIIZ:  
         ; spausdina eilute su nuline pabaiga, dx - jos adresas
         ; 

         push si
         push ax
         push dx
 
         mov  si, dx
 
         .pagalVisus:
         mov dl, [si]  ; krauname simboli
         cmp dl, 00             ; gal jau eilutes pabaiga?
         je .pab

         mov ah, 02
         int 21h
         inc si
         jmp .pagalVisus
         .pab:
         
         writeln naujaEilute
  
         pop dx
         pop ax
         pop si
         ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include 'yasmlib.asm'

section .data                   ; duomenys

	kasBuvoDX: dw 0000
	kasBuvoAX: dw 0000
	saugomIP :dw 0x100
	poslinkioIsvedimuiPirmas: db 00
	kasBuvoCL: db 00
    tikrinkArInc8: db 0x8
    kasBuvoBH: db 0000
	pirmasREG: db 0x7
	dabInstrukcija: db 00
    strAAD
       db '      aad $'
	strINT
	   db '      int $'
	strXLAT
	   db '      xlat $'
	strPOPF
	   db '      popf $'
	strPUSHF
	   db '      push $'
	strSANF
	   db '      sahf $'
	strLANF
	   db '      lahf $'
	strCWD
	   db '      cwd $'
	strCBW
	   db '      cbw $'
	strDAS
	   db '      das $'
	strAAS
	   db '      aas $'
	strINT3
	   db '      int3 $'
	strINTO
	   db '      into $'
	strIRET
	   db '      iret $'
	strLOCK
	   db '      lock $'
	strWAIT
	   db '      wait $'
	strHLT
	   db '      hlt $'
	strSTI
	   db '      sti $'
	strCLI
	   db '      cli $'
    strSTD
	   db '      std $'
	strCLD
	   db '      cld $'
    strCMC:
       db '      cmc $'  
    strSTC:
       db '      stc $'  
    strCLC:
       db '      clc $'  
    strRET:
       db '      ret $'  
    strRETF:
       db '      retf $'  
  
    
    strKablelis
	   db ',', 00
    strDB:
       db '      db ' 
    nuskaitytas:
       db 00, 00, 'h$' 
   
    klaidosPranesimas:
       db 'Klaida skaitant argumenta $'

    klaidosApieFailoAtidarymaPranesimas:
       db 'Klaida atidarant faila $'

    klaidosApieFailoSkaitymaPranesimas:
       db 'Klaida skaitant faila $'

    labas:
       db 'Labas', 0x0D, 0x0A, '$'

    naujaEilute:   
       db 0x0D, 0x0A, '$'  ; tekstas ant ekrano
 
    komEilIlgis:
       db 00
    komEilutesArgumentas:
       times 255 db 00
    skaitomasFailas:
       dw 0FFFh 
    

