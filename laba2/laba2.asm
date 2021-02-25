    .model tiny
    org 100h 
.data
    input_msg db "Input string: $"
    output_msg db "Your string: $"
    end_line db 0Ah, 0Dh, '$'
    string db 100 dup('$')                                       
    buffer db 50 dup('$')
    new_string db 100 dup('$')
    pos0 dw 0  ; start pos of del word
    pos1 dw 0  ; end pos of del word
    pos2 dw 0  ; buffer
    pos3 dw 0  ; for current position of new_string
    
    
.code        
    output macro string      
        mov ah, 09h    
        mov dx, offset string
        int 21h
    endm
    
    input macro string
        mov ah, 0Ah
        mov dx, offset string
        int 21h
    endm
    
    op_ch macro chr
        mov ah, 02h
        mov dl, chr
        int 21h
    endm
                                  
start:
    
    
                                                                                     
    output input_msg                          
    input string                              
    
    mov si, 2
    
first:      

    cmp string[si], 0Dh
    je second 
    inc si   
    jmp first

second:
    
    mov string[si], 024h                                 
    
    mov pos3, 0                                           

for0:
    
    mov si, 2
    xor bx, bx
       
     
for1:   ; read space / tab      
        ; this cycle need to skip space / tab
    cmp string[si], 20h
    jne for12
    inc si
    jmp for1
    
for12:
    
    mov pos0, si
     
           
for2:   ; read letters    
    
    mov pos1, si
    cmp string[si], 20h
    je for3   
    cmp string[si], 24h
    je for3
    
    mov dl, string[si]     ; write key_word in buffer
    mov buffer[bx], dl
    
    inc si
    inc bx
    
    jmp for2    
                
    
for3:   ; read space / tab    
        ; this cycle need to skip space / tab    
    cmp string[si], 024h
    je for56
    cmp string[si], 20h
    jne for34    
    inc si    
    jmp for3    

for34:
    
    
    mov pos2, si     ; remember start position of compared word
    xor bx, bx
    
     
for4:    ; cycle for compare buffer with compared word
                                            
    mov dl, string[si]
    cmp dl, buffer[bx]
    jb for45    ; if not equal ,then jmp to save
    ja skip_word
    inc si
    inc bx
    cmp string[si], 020h
    je for3
    cmp string[si], 024h
    je for56    
    jmp for4
    
skip_word:
    
    cmp string[si], 020h
    je for3
    cmp string[si], 024h
    je for56
    inc si
    jmp skip_word    
    
    
for45:   ; save in buffer
    
    xor bx, bx
    mov si, pos2
    mov pos0, si   ; start pos of del word 
    
for5:               ; push in buffer
                           
    mov dl, string[si]      
    mov buffer[bx], dl    
    inc bx
    inc si
    mov pos1, si    ; end pos of del word    
    cmp string[si], 020h
    je push_$_in_buffer_sp
    cmp string[si], 024h
    je push_$_in_buffer_end
    jmp for5        

push_$_in_buffer_sp:
    
    mov buffer[bx], 024h 
    jmp for3     
    
push_$_in_buffer_end:
    
    mov buffer[bx], 024h 
     

for56:
    
    mov si, pos3
    xor bx, bx

for6:        ; copy from buffer to new_string
    
    mov dl, buffer[bx]
    mov new_string[si], dl
    inc si
    inc bx
    cmp buffer[bx], 024h
    je for67
    jmp for6
    

for67:
    
    mov new_string[si], 020h
    inc si
    mov pos3, si
    xor bx, bx
    mov cx, 10
      
  
for7:       ; fill buffer by '$' 
    
    mov buffer[bx], 024h
    inc bx
    loop for7


for78:     
    
    mov si, pos1
    mov bx, pos0
    

for8:
        
    mov dl, string[si]
    mov string[bx], dl    ; delete min word from string 
    cmp string[si], 024h
    je for89
    inc bx
    inc si
    jmp for8

for89:
    
    mov string[bx], 024h       ; add '$' in and 'string'
    mov si, 2

for9:                          ; check end of sorting
    
    cmp string[si], ' '         ; if left only space...
    jne  for10
    inc si
    jmp for9


for10:
                              ; ...and '$', then to finish
    cmp string[si], 024h
    je finish
    jmp for0   
   
    
finish:
    
    mov si, pos3
    mov new_string[si], 024h
     
    output end_line 
    output output_msg
    output new_string
    
    
    
    mov ah, 4Ch
    int 21h

    end start  