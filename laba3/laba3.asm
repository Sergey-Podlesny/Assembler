name "laba3"   
.model tiny
org  100h
                      
.data      
   _errorOF db 'Overflow!','$'
   _errorDBZ db 'Divide by zero error!','$'
   _errorInput   db 'Input error','$'      
   _inputOperand db 'Operand: ','$'
   _inputOperation db 'Operation: ','$'
   _INFO    db 'Types of operations:',10,13,'1. + -> sum',10,13,'2. - -> sub',10,13, '3. * -> mul',10,13,'4. / -> div',10,13,'5. n -> new operands',10,13,'6. q -> exit','$'           
   _nl      db 10,13,'$'
   first    dw 4    
   second   dw 2
   min      dw 0
   max      dw 32767
   string   dw 255, 255 dup(?)
   
.code  
jmp start 

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

;------------------------------------------------
start:         
        xor bp, bp     
        
startConvert:
        output _inputOperand          
        input string
        output _nl
        mov bx, 10
        xor di, di    
        xor ax, ax
        xor cx, cx
        lea si, string + 2
        cmp byte ptr [si], "-"
        jne convert
        mov di, 1
        inc si
        
convert:
        mov cl, [si]
        cmp cl, 0Dh
        je endConvert
        cmp cl, '0'
        jb inputException
        cmp cl, '9'
        ja inputException       
        sub cl, '0'
        mul bx
        jo inputException
        add ax, cx
        jo inputException
        inc si
        jmp convert        
        
inputException:
        output _errorInput
        output _nl
        jmp startConvert                     
        
endConvert:
        cmp ax, min
        jb inputException
        cmp ax, max
        ja inputException
        cmp di, 1
        jne exitFromConvert
        neg ax
        
exitFromConvert:       
        push ax
        inc bp
        cmp bp, 2
        jb startConvert
        pop ax
        mov second, ax        
        pop bx
        mov first, bx      
        xor ax, bx
        jns operations
        mov si, 1                          
        
operations:        
        output _INFO

enter_type_operation:
        output _nl
        output _inputOperation
        mov ah,01h          
        int 21h
        mov bl, al
        output _nl             
        cmp bl,'+'          
        je summ             
        cmp bl,'-'          
        je subt
        cmp bl, '*'
        je mult
        cmp bl, '/'
        je divis
        cmp bl, 'n'
        je start
        cmp bl, 'q'
        je exit
        output _errorInput           
        jmp enter_type_operation

summ:
        mov ax,first
        mov bx,second
        add ax,bx            
        jo errorOF          
        jmp write_res           

subt:             
        mov ax,first       
        mov bx,second
        sub ax,bx          
        jo errorOF       
        jmp write_res         

mult:         
        mov ax,first
        mov bx,second
        mov cx, ax
        xor cx, bx
        xor di, di
        jns notSignedAnswMul
        mov di, 1
notSignedAnswMul:
        test ax, ax
        jns notSignedAxMul
        neg ax
notSignedAxMul:
        test bx, bx
        jns notSignedBxMul
        neg bx
notSignedBxMul:                
        mul bx             
        jo errorOF
        cmp di, 1
        jne write_res
        neg ax         
        jmp write_res

divis:           
        mov ax,first
        mov bx,second
        cmp bx, 0
        je errorDivByZero
        xor dx, dx
        xor di, di
        mov cx, ax
        xor cx, bx
        jns notSignedAnswDiv
        mov di, 1
notSignedAnswDiv:
        test ax, ax
        jns notSignedAxDiv
        neg ax
notSignedAxDiv:
        test bx, bx
        jns notSignedBxDiv
        neg bx
notSignedBxDiv:
        div bx    
        jo errorOF         
        cmp di, 1
        jne write_res
        neg ax         
        jmp write_res

write_res:
        test ax,ax          
        jns init            
        mov cx,ax           
        mov ah,02h          
        mov dl,'-'          
        int 21h             
        mov ax,cx           
        neg ax              

init:           
        xor cx,cx            
        xor dx,dx             
        push -1           
        mov cx,10         

repeat: 
        xor dx,dx     
        div cx            
        push dx           
        cmp ax,0          
        jne repeat        
        mov ah,02h         
        
digit:  
        pop dx        
        cmp dx,-1         
        je enter_type_operation           
        add dl,'0'        
        int 21h           
        jmp digit         

errorOF:
        output _errorOF               
        jmp enter_type_operation              

errorDivByZero:
        output _errorDBZ
        jmp enter_type_operation              

exit:
        mov ax,4c00h       
        int 21h
end begin                                            