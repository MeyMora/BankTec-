.model small
.stack 100h

.data
msgMenu db 13,10,'=============== BankTec ================', 13,10
        db '1. Crear cuenta', 13,10
        db '2. Depositar dinero',13,10
        db '3. Retirar dinero',13,10
        db '4. Consultar saldo', 13,10
        db '5. Mostrar reporte general',13,10
        db '6. Desactivar cuenta',13,10
        db '7. Salir, 13,10'
        db 'Seleccione una opcion:$'
msgInvalida db 13,10,'Opcion invalida. Intente de nuevo.',13,10,'$'
msgCrear    db 13,10,'[Aqui ira Crear cuenta]',13,10,'$' 
msgDeposito db 13,10,'[Aqui ira Depositar Dinero]',13,10,'$'  
msgRetiro   db 13,10,'[Aqui ira Retirar Dinero]',13,10,'$'  
msgSaldo    db 13,10,'[Aqui ira Consultar saldo]',13,10,'$'
msgReporte  db 13,10,'[Aqui ira Mostrar reporte]',13,10,'$'
msgDesact   db 13,10,'[Aqui ira Desactivar cuenta]',13,10,'$'
msgSalir    db 13,10,'Saliendo del sistema...',13,10,'$'   

.code

main proc
        mov ax, @data
        mov ds, ax  
        
inicio_menu:   
        call mostrar_menu
        call leer_opcion
        
        cmp al, '1'
        je opcion1  
        
        cmp al, '2'
        je opcion2
                         
        cmp al, ''
        je opcion 3

        cmp al, '4'
        je opcion4 
        
        cmp al, '5'
        je opcion5 
        
        cmp al, '6'
        je opcion6    

        cmp al, '7'
        je salir_programa
        
        
        lea dx, msgInvalida
        call imprimir_cadena
        jmp inicio_menu
        
        
opcion1:
       lea dx, msgCrear
       call imprimir_cadena
       jmp inicio_menu
       
opcion2:
       lea dx,msgDeposito        
       call imprimir_cadena
       jmp inicio_menu  
       
opcion3:
       lea dx,msgRetiro        
       call imprimir_cadena
       jmp inicio_menu 
opcion4:
       lea dx,msgSaldo       
       call imprimir_cadena
       jmp inicio_menu    
       
opcion5:
       lea dx, msgReporte
       call imprimir_cadena
       jmp inicio_menu  
       
opcion6:
       lea dx, msgDesact
       call imprimir_cadena
       jmp inicio_menu   
       
salir_programa:
       lea dx, msgSalir
       call imprimir_cadena   
       
       mov ah,4Ch
       int21h
       
main endp


;----------------------------------
;Para mostrar el menu
;----------------------------------

mostrar_menu proc
    lea dx, msgMenu
    call imprimir_cadena
    ret
    
mostrar_menu endp


;--------------------------------------------------------------------------------------
;Para leer una opcion, leer_opcion, lee un caracter del teclado y devuelve la opcion AL
;--------------------------------------------------------------------------------------

leer_opcion proc
    mov ah, 01h
    int 21h
    ret
leer_opcion endp


;---------------------------------------------------------------------------------------  
;funcion: imprimir_cadena
;Para imprimir una cadena terminada en $, con Entrada:DX =offset del mensaje
;---------------------------------------------------------------------------------------

imprimir_cadena proc
    mov ah,09h
    int 21h
    ret
    
imprimir_cadena endp


end main
