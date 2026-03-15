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
        db '7. Salir', 13,10
        db 'Seleccione una opcion:$'
msgInvalida db 13,10,'Opcion invalida. Intente de nuevo.',13,10,'$'
msgCrear    db 13,10,'[Aqui ira Crear cuenta]',13,10,'$' 
msgDeposito db 13,10,'[Aqui ira Depositar Dinero]',13,10,'$'  
msgRetiro   db 13,10,'[Aqui ira Retirar Dinero]',13,10,'$'  
msgSaldo    db 13,10,'[Aqui ira Consultar saldo]',13,10,'$'
msgReporte  db 13,10,'[Aqui ira Mostrar reporte]',13,10,'$'
msgDesact   db 13,10,'[Aqui ira Desactivar cuenta]',13,10,'$'
msgSalir    db 13,10,'Saliendo del sistema...',13,10,'$' 

msgMonto db 13,10,'Ingrese el monto:$'
msgCuenta db 13,10,'Ingrese numero de cuenta:$'

msgErrorCuenta db 13,10,'Cuenta no encontrada$',13,10
msgErrorMonto db 13,10,'Monto invalido$',13,10
msgErrorFondos db 13,10,'Fondos insuficientes$',13,10

msgDepositoOk db 13,10,'Deposito realizado$',13,10
msgRetiroOk db 13,10,'Retiro realizado$',13,10  

; variables del sistema bancario

numero_cuenta dw ?
indice_cuenta dw ?
monto dw ?

; arreglo de saldos para 10 cuentas
saldos dw 10 dup(0)

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
                         
        cmp al, '3'
        je opcion3

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
    call depositar_dinero
    jmp inicio_menu
    
opcion3:
    call retirar_dinero
    jmp inicio_menu  
    
opcion4:
    call consultar_saldo
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
       int 21h
       
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

;Validar
validar_monto proc

    cmp ax,0
    jle monto_invalido

    mov bx,1
    ret

monto_invalido:
    mov bx,0
    ret

validar_monto endp 


mostrar_mensaje_error proc

    mov ah,09h
    int 21h

    ret

mostrar_mensaje_error endp   

;Depositar
depositar_dinero proc

    lea dx,msgCuenta
    call imprimir_cadena

    ; leer numero cuenta
    call leer_opcion
    sub al,'0'
    mov ah,0
    mov numero_cuenta,ax

    ; buscar cuenta 
    call buscar_cuenta

    cmp ax,-1
    je error_cuenta

    mov indice_cuenta,ax

    lea dx,msgMonto
    call imprimir_cadena

    call leer_opcion
    sub al,'0'
    mov ah,0
    mov monto,ax

    mov ax,monto
    call validar_monto

    cmp bx,0
    je error_monto

    ; actualizar saldo
    mov si,indice_cuenta
    add si,si
    mov ax,saldos[si]
    add ax,monto
    mov saldos[si],ax

    lea dx,msgDepositoOk
    call imprimir_cadena

    ret

error_cuenta:
    lea dx,msgErrorCuenta
    call mostrar_mensaje_error
    ret

error_monto:
    lea dx,msgErrorMonto
    call mostrar_mensaje_error
    ret

depositar_dinero endp 

;REtirar
retirar_dinero proc

    lea dx,msgCuenta
    call imprimir_cadena

   
    
    call leer_opcion
    sub al,'0'
    mov ah,0
    mov monto,ax
  
    call buscar_cuenta

    cmp ax,-1
    je error_cuenta_r

    mov indice_cuenta,ax

    lea dx,msgMonto
    call imprimir_cadena

    call leer_opcion
    sub al,'0'
    mov monto,ax

    mov ax,monto
    call validar_monto

    cmp bx,0
    je error_monto_r

    mov si,indice_cuenta
    add si,si
    mov ax,saldos[si]

    cmp ax,monto
    jl fondos_insuficientes

    sub ax,monto
    mov saldos[si],ax

    lea dx,msgRetiroOk
    call imprimir_cadena

    ret

error_cuenta_r:
    lea dx,msgErrorCuenta
    call mostrar_mensaje_error
    ret

error_monto_r:
    lea dx,msgErrorMonto
    call mostrar_mensaje_error
    ret

fondos_insuficientes:
    lea dx,msgErrorFondos
    call mostrar_mensaje_error
    ret

retirar_dinero endp

consultar_saldo proc

    lea dx,msgCuenta
    call imprimir_cadena

    call leer_opcion
    sub al,'0'
    mov ah,0
    mov monto,ax

    call buscar_cuenta

    cmp ax,-1
    je error_cuenta_s

    mov si,indice_cuenta
    add si,si
    mov ax,saldos[si]

    add al,'0'
    mov dl,al
    mov ah,02h
    int 21h

    ret

error_cuenta_s:
    lea dx,msgErrorCuenta
    call mostrar_mensaje_error
    ret

consultar_saldo endp


buscar_cuenta proc

    ; version temporal
    ; siempre retorna indice 0

    mov ax,0
    ret

buscar_cuenta endp

end main
