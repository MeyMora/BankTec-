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
msgMonto db 13,10,'Ingrese el monto:$'
msgDepositoOk db 13,10,'Deposito realizado$',13,10,'$'
msgRetiroOk db 13,10,'Retiro realizado$',13,10,'$'
msgErrorFondos db 13,10,'Fondos insuficientes$',13,10,'$'

saltoLinea db 13,10,'$'                                                          
                                                          
;para crear una cuenta                                                          
msgPedirCuenta db 13,10,'Ingrese el numero de cuenta: $'
msgErrorCuenta db 13,10,'Error: solo se permiten digitos.',13,10,'$'
msgErrorVacio  db 13,10,'Error: debe ingresar al menos un digito.',13,10,'$'


;para validar si el numero de cuenta ya existe 

msgCuentaExiste db 13,10, 'Error: el numero de cuenta ya existe.',13,10, '$'
msgCuentaGuardada db 13,10,'Cuenta registrada correctamente.',13,10, '$'
msgSinEspacio db 13,10,'Error: no hay espacio para mas cuentas.' ,13,10, '$'


;Para pedir el titular de la cuenta
msgPedirNombre db 13,10, 'Ingrese el nombre del titular (max 20 caracteres): $'
msgPedirSaldo  db 13,10, 'Ingrese el saldo inicial(entero con 4 decimales implicitos)$'
msgErrorNombre db 13,10, 'Error: el nombre no puede estar vacio.', 13, 10, '$'
msgErrorSaldo  db 13,10, 'Error: saldo invalido.',13,10,'$'

;variables temporales 
numeroCuentaTemp dw 0
indiceEncontrado dw 0  
saldoTemp dw 0 

bufferNombre db MAX_NOMBRE, 0, MAX_NOMBRE+1 dup(0)


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


imprimir_numero proc
    push ax
    push bx
    push cx
    push dx

    cmp ax,0
    jne convertir

    mov dl,'0'
    mov ah,02h
    int 21h
    jmp fin_impresion

convertir:
    mov bx,10
    xor cx,cx

dividir:
    xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jne dividir

imprimir_digito:
    pop dx
    add dl,'0'
    mov ah,02h
    int 21h
    loop imprimir_digito

fin_impresion:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
imprimir_numero endp




crear_cuenta proc 
    ;Pedir el numero de cuenta
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
    
    
    ;Pedimos el nombre de la persona
    lea dx, msgPedirNombre
    call imprimir_cadena
    
    call leer_nombre
    jc fin_crear_cuenta
    
    ;pedimos el saldo inicial
    lea dx, msgPedirSaldo
    call imprimir_cadena
    
    call leer_entero
    jc saldo_invalido
    
    mov saldoTemp, ax
    
    ;indice actual de contadorCuentas
    mov bx, contadorCuentas
    
    ;Guardar numero cuenta
    mov si, bx
    shl si, 1
    mov ax, numeroCuentaTemp
    mov cuentasNumero[si], ax
    
    
    ;Guardar Saldo
    mov ax, saldoTemp
    mov cuentasSaldo[si], ax
    
    
    ;Guardar el estado de la cuenta activa en 1 
    mov cuentasEstado[bx], 1
    
    ;Guardar el nombre del titular 
    call guardar_nombre_en_indice
    
    ;aumentar contador
    mov ax, contadorCuentas
    inc ax
    mov contadorCuentas,ax
    
    lea dx, msgCuentaGuardada
    call imprimir_cadena
    jmp fin_crear_cuenta
    
   
    
    
    
cuenta_repetida:
    
        lea dx, msgCuentaExiste
        call imprimir_cadena
        jmp fin_crear_cuenta
        
sin_espacio:
       lea dx, msgSinEspacio
       call imprimir_cadena  
       jmp fin_crear_cuenta
       
       
saldo_invalido:
    lea dx, msgErrorSaldo
    call imprimir_cadena       
    jmp fin_crear_cuenta
              
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
       jne siguiente
        
        
       cmp cuentasEstado[bx],1    
       je encontrada

siguiente:
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



leer_nombre proc
       push ax
       push dx
       
       lea dx, bufferNombre
       mov ah, 0Ah
       int 21h
       
       ;bufferNombre +1 = cantidad de chars escritos
       mov al, [bufferNombre+1]
       cmp al, 0
       je nombre_vacio
       
       clc
       jmp salir_leer_nombre

nombre_vacio:
    lea dx, msgErrorNombre
    call imprimir_cadena
    stc
    
salir_leer_nombre:
    pop dx
    pop ax
    ret

leer_nombre endp


guardar_nombre_en_indice proc
       ;Entrada
       ;BX = indice de cuenta a guardar
       
       push ax
       push bx
       push cx
       push dx
       push si 
       push di
       
       ;calcular el offset destino que es igual a indice * MAX_NOMBRE
       xor di,di
       mov cx, bx
       
calc_offset:
    cmp cx, 0
    je offset_listo
    add di, MAX_NOMBRE
    dec cx
    jmp calc_offset   
    
offset_listo:
     ;limpia los 20 bytes del nombre destino\ 
     mov si, di 
     mov cx, MAX_NOMBRE

     
limpiar_destino:
       lea bx, cuentasNombre
       add bx, si
       mov byte ptr [bx],0
       inc si 
       loop limpiar_destino
        
        
       ;copiar el nombre
       lea si, bufferNombre+2 
       mov cl, [bufferNombre+1]
       xor ch, ch
       
copiar_nombre:
    cmp cx, 0
    je fin_guardar_nombre
    
    mov al, [si]
    mov cuentasNombre[di], al
    inc si 
    inc di
    dec cx
    jmp copiar_nombre
    
                
fin_guardar_nombre:
    pop di 
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
guardar_nombre_en_indice endp




validar_monto proc

    cmp ax,0
    jle monto_invalido

    mov bx,1
    ret

monto_invalido:
    mov bx,0
    ret

validar_monto endp



depositar_dinero proc

    lea dx,msgPedirCuenta
    call imprimir_cadena

    call leer_entero
    jc fin_deposito

    mov numeroCuentaTemp,ax

    call buscar_cuenta_por_numero
    jnc cuenta_no_encontrada

    mov bx,indiceEncontrado
    mov si,bx
    shl si,1

    lea dx,msgMonto
    call imprimir_cadena

    call leer_entero
    jc fin_deposito

    mov ax,ax
    call validar_monto

    cmp bx,0
    je error_monto_deposito

    mov bx,indiceEncontrado
    mov si,bx
    shl si,1

    mov ax,cuentasSaldo[si]
    add ax,ax
    mov cuentasSaldo[si],ax

    lea dx,msgDepositoOk
    call imprimir_cadena

    jmp fin_deposito

cuenta_no_encontrada:
    lea dx,msgErrorCuenta
    call imprimir_cadena
    jmp fin_deposito

error_monto_deposito:
    lea dx,msgErrorSaldo
    call imprimir_cadena


fin_deposito:
    ret

depositar_dinero endp

retirar_dinero proc

    lea dx,msgPedirCuenta
    call imprimir_cadena

    call leer_entero
    jc fin_retiro

    mov numeroCuentaTemp,ax

    call buscar_cuenta_por_numero
    jnc cuenta_no_encontrada_r

    mov bx,indiceEncontrado
    mov si,bx
    shl si,1

    lea dx,msgMonto
    call imprimir_cadena

    call leer_entero
    jc fin_retiro

    mov dx,ax

    mov ax,cuentasSaldo[si]
    cmp ax,dx
    jl fondos_insuficientes

    sub ax,dx
    mov cuentasSaldo[si],ax

    lea dx,msgRetiroOk
    call imprimir_cadena

    jmp fin_retiro

cuenta_no_encontrada_r:
    lea dx,msgErrorCuenta
    call imprimir_cadena
    jmp fin_retiro

fondos_insuficientes:
    lea dx,msgErrorFondos
    call imprimir_cadena

fin_retiro:
    ret

retirar_dinero endp


consultar_saldo proc

    lea dx,msgPedirCuenta
    call imprimir_cadena

    call leer_entero
    jc fin_consulta

    mov numeroCuentaTemp,ax

    call buscar_cuenta_por_numero
    jnc cuenta_noo_encontrada

    mov bx,indiceEncontrado
    mov si,bx
    shl si,1

    ; SALTO DE LINEA
    lea dx,saltoLinea
    call imprimir_cadena

    mov ax,cuentasSaldo[si]
    call imprimir_numero

    jmp fin_consulta

cuenta_noo_encontrada:
    lea dx,msgErrorCuenta
    call imprimir_cadena

fin_consulta:
    ret

consultar_saldo endp







end main
