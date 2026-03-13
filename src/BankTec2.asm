.model small
.stack 100h

.data  

MAX_CUENTAS equ 10    
MAX_NOMBRE equ 20

msgMenu db 13,10,'=============== BankTec ================', 13,10
        db '1. Crear cuenta', 13,10
        db '2. Depositar dinero',13,10
        db '3. Retirar dinero',13,10
        db '4. Consultar saldo', 13,10
        db '5. Mostrar reporte general',13,10
        db '6. Desactivar cuenta',13,10
        db '7. Salir',13,10
        db 'Seleccione una opcion:$'

msgInvalida db 13,10,'Opcion invalida. Intente de nuevo.',13,10,'$'
msgDeposito db 13,10,'[Aqui ira Depositar Dinero]',13,10,'$'
msgRetiro   db 13,10,'[Aqui ira Retirar Dinero]',13,10,'$'
msgSaldo    db 13,10,'[Aqui ira Consultar saldo]',13,10,'$'
msgReporte  db 13,10,'[Aqui ira Mostrar reporte]',13,10,'$'
msgDesact   db 13,10,'[Aqui ira Desactivar cuenta]',13,10,'$'
msgSalir    db 13,10,'Saliendo del sistema...',13,10,'$'
                                                          
                                                          
;para crear una cuenta                                                          
msgPedirCuenta db 13,10,'Ingrese el numero de cuenta: $'
msgErrorCuenta db 13,10,'Error: solo se permiten digitos.',13,10,'$'
msgErrorVacio  db 13,10,'Error: debe ingresar al menos un digito.',13,10,'$'


;para validar si el numero de cuenta ya existe 

msgCuentaExiste db 13,10, 'Error: el numero de cuenta ya existe.',13,10, '$'
msgCuentaGuardada db 13,10,'Cuenta registrada correctamente.',13,10, '$'
msgSinEspacio db 13,10,'Error: no hay espacio para mas cuentas.' ,13,10, '$'

;variables temporales 
numeroCuentaTemp dw 0
indiceEncontrado dw 0

;arreglos paralelos para manejar las cuentas
cuentasNumero dw MAX_CUENTAS dup(?)
cuentasSaldo  dw MAX_CUENTAS dup(?)
cuentasEstado db MAX_CUENTAS dup(?)
cuentasNombre db MAX_CUENTAS * MAX_NOMBRE dup(?)
contadorCuentas dw 0  

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
       call crear_cuenta
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
       int 21h
main endp

mostrar_menu proc
    lea dx, msgMenu
    call imprimir_cadena
    ret
mostrar_menu endp

leer_opcion proc
    mov ah, 01h
    int 21h
    ret
leer_opcion endp

imprimir_cadena proc
    mov ah,09h
    int 21h
    ret
imprimir_cadena endp

crear_cuenta proc
    lea dx, msgPedirCuenta
    call imprimir_cadena

    call leer_entero
    jc fin_crear_cuenta 
    

    mov numeroCuentaTemp, ax
    
    
    ;Verificamos si la cuenta ya existe
    call buscar_cuenta_por_numero
    jc cuenta_repetida
    
    ;Verificar si hay espacio para crear la cuenta
    mov ax, contadorCuentas
    cmp ax, MAX_CUENTAS
    jae sin_espacio
    
    ;Guardar cuenta nueva 
    mov si, contadorCuentas
    shl si, 1     
    
    mov ax, numeroCuentaTemp 
    mov cuentasNumero[si], ax 
    
    
    ;saldo inicial = 0 
    mov word ptr cuentasSaldo[si], 0
    
    ;Estado de la cuenta activa en 1 
    mov bx, contadorCuentas
    mov cuentasEstado[bx], 1
    
    ;limpiar nombre(20 bytes)
    
    mov ax, contadorCuentas
    mov bl, MAX_NOMBRE
    mul bl  ;AX = indice *20
    mov si, ax
    mov cx, MAX_NOMBRE
    
limpiar_nombre:
        mov cuentasNombre[si], 0 
        inc si 
        loop limpiar_nombre
        
        ;aumentar contador
        mov ax, contadorCuentas
        inc ax
        mov contadorCuentas, ax
        
        lea dx,msgCuentaGuardada
        call imprimir_cadena 
        jmp fin_crear_cuenta
    
    
cuenta_repetida:
    
        lea dx, msgCuentaExiste
        call imprimir_cadena
        jmp fin_crear_cuenta
        
sin_espacio:
       lea dx, msgSinEspacio
       call imprimir_cadena
fin_crear_cuenta:
    ret
crear_cuenta endp



   

;Para leer un entero y conversion ASCII
leer_entero proc
    push bx
    push cx
    push dx

    xor bx, bx
    xor cx, cx

leer_digito:
    mov ah, 01h
    int 21h

    cmp al, 13
    je fin_lectura

    cmp al, '0'
    jb error_no_digito

    cmp al, '9'
    ja error_no_digito

    sub al, '0'
    mov ah, 0

    push ax
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    pop ax
    add bx, ax

    inc cx
    jmp leer_digito

fin_lectura:
    cmp cx, 0
    je error_vacio

    mov ax, bx
    clc
    jmp salir_leer_entero

error_no_digito:
    lea dx, msgErrorCuenta
    call imprimir_cadena
    stc
    jmp salir_leer_entero

error_vacio:
    lea dx, msgErrorVacio
    call imprimir_cadena
    stc

salir_leer_entero:
    pop dx
    pop cx
    pop bx
    ret
leer_entero endp


;Buscar la cuenta por numero 
buscar_cuenta_por_numero proc
    push ax
    push bx
    push cx
    push si
    
    mov ax, numeroCuentaTemp
    mov cx, contadorCuentas
    xor bx, bx
    xor si, si 
    
buscar_loop:
       cmp cx, 0
       je no_encontrada
       
       cmp cuentasNumero[si], ax
       je encontrada
       
       add si, 2
       inc bx
       dec cx
       jmp buscar_loop
       
encontrada:
       mov indiceEncontrado, bx
       stc
       jmp salir_busqueda
    

no_encontrada:
    clc

salir_busqueda:
    pop si 
    pop cx
    pop bx
    pop ax
    ret

buscar_cuenta_por_numero endp








end main