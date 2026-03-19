.model small
.stack 100h

.data  

MAX_CUENTAS equ 10     ; cantidad máxima de cuentas permitidas
MAX_NOMBRE equ 20      ; tamaño máximo del nombre

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
msgSaldoActual db 13,10,'Saldo actual: $'                                                          
;para crear una cuenta                                                          
msgPedirCuenta db 13,10,'Ingrese el numero de cuenta: $'
msgErrorCuenta db 13,10,'Error: solo se permiten digitos.',13,10,'$'
msgErrorVacio  db 13,10,'Error: debe ingresar al menos un digito.',13,10,'$'


;================ para validar si el numero de cuenta ya existe ================

msgCuentaExiste db 13,10, 'Error: el numero de cuenta ya existe.',13,10, '$'
msgCuentaGuardada db 13,10,'Cuenta registrada correctamente.',13,10, '$'
msgSinEspacio db 13,10,'Error: no hay espacio para mas cuentas.' ,13,10, '$'
msgCuentaNoExiste db 13,10,'Error: la cuenta no existe.',13,10,'$'

;================ Para pedir el titular de la cuenta ================
msgPedirNombre db 13,10, 'Ingrese el nombre del titular (max 20 caracteres): $'
msgPedirSaldo  db 13,10, 'Ingrese el saldo inicial(entero con 4 decimales implicitos): $'
msgErrorNombre db 13,10, 'Error: el nombre no puede estar vacio.', 13, 10, '$'
msgErrorSaldo  db 13,10, 'Error: saldo invalido.',13,10,'$'

;================ mensajes para el reporte ================
msgRepActivas   db 'Cuentas activas   : $'
msgRepInactivas db 'Cuentas inactivas : $'
msgRepSaldoTot  db 'Saldo total       : $'
msgRepMayor     db 'Mayor saldo       : $'
msgRepMenor     db 'Menor saldo       : $'
msgSinCuentas   db 13,10,'No hay cuentas registradas.',13,10,'$'
msgSaltoLinea   db 13,10,'$'

;================ mensajes para desactivar ================
msgListaCtas    db 13,10,'Cuentas registradas:',13,10,'$'
msgNumCta       db ' Num: $'
msgSepNom       db ' - $'
msgSaldoCta     db '  Saldo: $'
msgEstActiva    db '  [ACTIVA]',13,10,'$'
msgEstInactiva  db '  [INACTIVA]',13,10,'$'
msgPedirDesact  db 13,10,'Numero a desactivar: $'
msgDesactOk     db 13,10,'Cuenta desactivada correctamente.',13,10,'$'
msgYaInactiva   db 13,10,'Error: la cuenta ya esta inactiva.',13,10,'$'
msgNoEncontr    db 13,10,'Error: cuenta no encontrada.',13,10,'$'

;================ VARIABLES TEMPORALES =================
numeroCuentaTemp dd 0  ; guarda temporalmente el número de cuenta
indiceEncontrado dd 0  ; índice donde se encontró la cuenta
saldoTemp dd 0         ; saldo temporal para operaciones
; variables del reporte
repActivas   dw 0
repInactivas dw 0
repSaldoTot  dw 0
repIdxMayor  dw 0
repIdxMenor  dw 0

;================ BUFFER PARA NOMBRE =================
bufferNombre db MAX_NOMBRE, 0, MAX_NOMBRE+1 dup(0) ; buffer para leer nombres


;========== ARREGLOS PARA MANEJO DE CUENTAS ==========
cuentasNumero dw MAX_CUENTAS dup(?)  ; números de cuenta
cuentasSaldo  dw MAX_CUENTAS dup(?)  ; saldo de cada cuenta
cuentasEstado db MAX_CUENTAS dup(?)  ; estado (activa/inactiva)
cuentasNombre db MAX_CUENTAS * MAX_NOMBRE dup(?) ; nombres de las cuentas
contadorCuentas dw 0  ; cantidad actual de cuentas creadas

.code

main proc                    ;inicia procedimiento llamado main 
        mov ax, @data        ;Se mueve la dirección @data al registro ax 
        mov ds, ax           ;Se mueve ax al registro ds

inicio_menu:                 ;empieza el ciclo de menu
        call mostrar_menu    ; llamada a mostrar_menu
        call leer_opcion     ; lee los caracteres ingresados por teclado

        cmp al, '1'          ; Compara al con 1 
        je opcion1           ; Comparación es igual salta a opcion1 

        cmp al, '2'          ; Compara al con 2 
        je opcion2           ; Si la comparación es igual salta a la opcion2 

        cmp al, '3'          ; Compara al con 3 
        je opcion3           ; Si la comparación es igual salta a la opcion3

        cmp al, '4'          ; Compara al con 4
        je opcion4           ; Si la comparación es igual salta a la opcion4

        cmp al, '5'          ; Compara al con 5
        je opcion5           ; Si la comparación es igual salta a la opcion5

        cmp al, '6'          ; Compara al con 6 
        je opcion6           ; Si la comparación es igual salta a la opcion6 

        cmp al, '7'          ; Compara al con 7
        je salir_programa    ; Si la comparación es igual finaliza el programa

        lea dx, msgInvalida  ; cargar mensaje de error
        call imprimir_cadena ; mostrar "opcion invalida"
        jmp inicio_menu      ; volver a mostrar el menu

opcion1:
       call crear_cuenta     ; llama al procedimiento crear_cuenta
       jmp inicio_menu       ; cuando termina el procedimiento, vuelve al menu

opcion2:
       call depositar_dinero ; llama al procedimiento depositar_dinero
       jmp inicio_menu       ; cuando termina el procedimiento, vuelve al menu


opcion3:
       call retirar_dinero   ; llama al procedimiento retirar_dinero
       jmp inicio_menu       ; cuando termina el procedimiento, vuelve al menu

opcion4:
       call consultar_saldo  ; llama al procedimiento consultar_saldo
       jmp inicio_menu       ; cuando termina el procedimiento, vuelve al menu

opcion5:
       call mostrar_reporte  ; llama al procedimiento mostrar_reporte
       jmp inicio_menu       ; cuando termina el procedimiento, vuelve al menu


opcion6:
       call desactivar_cuenta  ; llama al procedimiento desactivar_cuenta
       jmp inicio_menu         ; cuando termina el procedimiento, vuelve al menu

salir_programa:
       lea dx, msgSalir        ; carga el mensaje de salir en dx 
       call imprimir_cadena    ; llama a imprimir_cadena 

       mov ah,4Ch              ; termina el programa 
       int 21h
main endp

mostrar_menu proc              ; define el procedimiento mostrar_menu
    lea dx, msgMenu            ; se carga en el registro dx, la direccion de msgMenu 
    call imprimir_cadena       ; llama a imprimir_cadena 
    ret                        ; regresa al lugar donde se llamó el procedimiento 
mostrar_menu endp

leer_opcion proc               ; lee un caracter del teclado 
    mov ah, 01h                ; indica a int 21h que ejecute la funcion 
    int 21h                    ; ejecuta la interrupcion DOS
    ret
leer_opcion endp

imprimir_cadena proc           ; imprime una cadena de texto en pantalla
    mov ah,09h                 ; indica a int 21h que ejecute la función
    int 21h                    ; DOS imprime el texto hasta encontrar $.
    ret                        ; Regresa al programa.
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
    lea dx, msgPedirCuenta ; carga el mensaje msgPedirCuenta en dx
    call imprimir_cadena   ; imprime el mensaje

    call leer_entero       ;llama a procedimiento leer_entero
    jc fin_crear_cuenta    ;si el numero es invalido se sale del procedimiento
    

    mov numeroCuentaTemp, ax ; seguarda el numero en ax en una variable temporal
    
    
    ;Verificamos si la cuenta ya existe
    call buscar_cuenta_por_numero  ; busca el número en buscar_cuentas_por numero, si lo encuentra activa CF = 1 
    jc cuenta_repetida             ; Salto a cuenta_repetida
    
    ;Verificar si hay espacio para crear la cuenta
    mov ax, contadorCuentas    ; verifica con contadorCuentas si hay espacio en registro ax
    cmp ax, MAX_CUENTAS        ;compara si el maximo de cuentas se cumplio comparando con el numero guardado en ax 
    jae sin_espacio            ; si MAX_CUENTAS >= contadorCuentas, salta a procedimiento sin_espacio
    
    
    ;Pedimos el nombre de la persona
    lea dx, msgPedirNombre     ; mensaje de pedir nombre se guarda en dx 
    call imprimir_cadena       ; llama a imprimir el texto en pantalla
    
    call leer_nombre           ; llama a leer_nombre 
    jc fin_crear_cuenta        ; termina el procedimiento y salta a fin_crear_cuenta 
    
    ;pedimos el saldo inicial 
    lea dx, msgPedirSaldo      ; Carga en DX la dirección del mensaje msgPedirSaldo.
    call imprimir_cadena       ;Llama al procedimiento que imprime el texto en pantalla.
    
    call leer_entero           ; llama a leer_entero que lee un número que el usuario escribe
    jc saldo_invalido          ; Si hubo error al leer el número (Carry Flag = 1), el programa salta al procedimiento saldo_invalido
    
    mov saldoTemp, ax          ; Guarda el valor del registro ax en la variable saldoTemp
    
    ;indice actual de contadorCuentas
    mov bx, contadorCuentas    ; Copia el valor de contadorCuentas en bx.
    
    ;Guardar numero cuenta
    mov si, bx                 ; Copia el índice a si
    shl si, 1                  ; Desplaza a la izquierda y multiplica por 2 porque cada elemento ocupa 2 bytes
    mov ax, numeroCuentaTemp   ; Carga el número de cuenta que el usuario escribió
    mov cuentasNumero[si], ax  ; Guarda ese número en el arreglo cuentasNumero
    
    
    ;Guardar Saldo
    mov ax, saldoTemp          ;Carga el saldo temporal en ax 
    mov cuentasSaldo[si], ax   ;Lo guarda en el arreglo cuentasSaldo.
    
    
    ;Guardar el estado de la cuenta activa en 1 
    mov cuentasEstado[bx], 1
    
    ;Guardar el nombre del titular 
    call guardar_nombre_en_indice  ; llama al procedimiento guardar_nombre_en_indice
    
    ;aumentar contador
    mov ax, contadorCuentas  ;copia el valor actual en ax 
    inc ax                   ; le suma 1 
    mov contadorCuentas,ax   ; guarda el nuevo valor en contadorCuentas
    
    lea dx, msgCuentaGuardada  ; carga el mensaje en dx
    call imprimir_cadena       ; llama a imprimir el texto en pantalla
    jmp fin_crear_cuenta       ; Salta al final del procedimiento para terminar la operación
    
   

cuenta_repetida:
    
        lea dx, msgCuentaExiste ; Carga en DX la dirección del mensaje.
        call imprimir_cadena    ; Imprime el mensaje en pantalla.
        jmp fin_crear_cuenta    ;salto incondicional a fin de procedimiento 
        
sin_espacio:
       lea dx, msgSinEspacio ; carga direccion del mensaje en dx
       call imprimir_cadena  ;llama a imprimir el texto en pantalla
       jmp fin_crear_cuenta  ;fin del procedimiento 
       
       
saldo_invalido:
    lea dx, msgErrorSaldo ; carga la direccion del mensaje en dx
    call imprimir_cadena  ; llama a imprimir texto en pantalla  
    jmp fin_crear_cuenta  ; fin del procedimiento 
              
fin_crear_cuenta:         ; punto de salida comun
    ret                   ; regresar al lugar donde se llamó el procedimiento, en este caso regresa al menu. 
crear_cuenta endp



;Para leer un entero y conversion ASCII
leer_entero proc
    push bx  ;guardar el valor de los registros en la pila
    push cx  ; para no perder los valores que se tenia 
    push dx  ; antes de llamar al procedimiento

    xor bx, bx ; limpia el registro bx
    xor cx, cx ; limpia el registro cx

leer_digito:
    ;leer un carácter del teclado.
    mov ah, 01h
    int 21h

    cmp al, 13          ;Compara si el usuario presiono enter
    je fin_lectura      ; Si es enter, salta a la etiqueta fin_lectura.

    cmp al, '0'        ; compara si el caracter es menor que 0 
    jb error_no_digito ; Si el carácter es menor que '0', entonces no es un número.

    cmp al, '9'        ; verifica si el caracter es mayor que 9
    ja error_no_digito ; Si el carácter es mayor que '9', tampoco es número.

    sub al, '0'        ;resta para convertir el caracter ASCII  a numero real 
    mov ah, 0          ; ah contiene el numero convertido 

    push ax            ; Guarda el dígito en la pila porque se va a usar AX para multiplicar.
    mov ax, bx         ; mueve el digito a ax 
    mov dx, 10         ; mueve 10 a dx
    mul dx             ; se multiplica el digito por 10 que esta en dx
    mov bx, ax         ; guarda el resultado de ax en bx 
    pop ax             ; recupera el digito que se guardo antes
    add bx, ax         ; suma el nuevo digito

    inc cx             ; Incrementa el contador de dígitos.
    jmp leer_digito    ; lee el siguiente digito

fin_lectura:
    cmp cx, 0          ; Compara el registro CX con 0, si es 0 no se escribio ningun numero 
    je error_vacio     ; si es 0 salta a error_vacio

    mov ax, bx         ; copia lo que esta en bx en ax, en este caso el numero
    clc                ; verifica si la lectura fue exitosa con carry flag, si es 0 todo es correcto, 1 es error
    jmp salir_leer_entero  ; salta a leer entero

error_no_digito:  
    lea dx, msgErrorCuenta  ; Carga la dirección del mensaje en DX
    call imprimir_cadena    ; imprime el mensaje 
    stc                     ; Set Carry Flag, significa CF = 1, hay error
    jmp salir_leer_entero   ; Salta a la parte final del procedimiento para limpiar la pila y salir.

error_vacio:
    lea dx, msgErrorVacio   ; carga la direccion del mensaje en dx
    call imprimir_cadena    ; imprime mensaje error_vacio en pantalla
    stc                     ; CF = 1, para indicar error 

salir_leer_entero:
                            ; restaura los registros 
    pop dx
    pop cx
    pop bx
    ret                     ; regresa al lugar donde se llamo el procedimiento 
leer_entero endp


;Buscar la cuenta por numero 
buscar_cuenta_por_numero proc
    push ax                  ; numero de cuenta a buscar 
    push bx                  ; índice del arreglo
    push cx                  ; contador de cuentas 
    push si                  ; desplazamiento en memoria
    
    mov ax, numeroCuentaTemp ; se carga en AX el número de cuenta que el usuario ingresó.
    mov cx, contadorCuentas  ; cx será el contador del ciclo de búsqueda.
    xor bx, bx               ;registro bx en 0 
    xor si, si               ;registro si en 0
    
buscar_loop:
       cmp cx, 0             ; compara si cx es 0, si es asi se verificaron todas las cuentas
       je no_encontrada      ; salto condicional  a no_encontrada, sino es 0 entonces sigue
       
       cmp cuentasNumero[si], ax   ; compara cuentasNumero[indice] con numeroCuentaTemp que es ax
       jne siguiente               ; si no son iguales salta a la siguiente
        
        
       cmp cuentasEstado[bx],1     ; aunque el número coincida, se verifica que la cuenta esté activa.
       je encontrada               ; si esta activa salta a encontrada

siguiente:
        add si, 2           ; como los numeros de cuenta son Word(2 bytes) se avanza en 2 bytes
        inc bx              ; incrementa el indice logico
        dec cx              ; Reduce el contador de cuentas restantes
        jmp buscar_loop     ; Regresa al inicio del ciclo para revisar la siguiente cuenta.
encontrada:
       mov indiceEncontrado, bx  ; indica en que indice esta la cuenta
       stc                       ;  CF = 1 indica exito en la busqueda
       jmp salir_busqueda        ; salta a salir_busqueda
    

no_encontrada:
    clc                          ; si no se encontro la cuenta CF = 0  

salir_busqueda:
                                 ; Se recuperan los valores originales de los registros.
    pop si 
    pop cx
    pop bx
    pop ax
    ret                          ; regresa al programa

buscar_cuenta_por_numero endp



leer_nombre proc
       ; Se guardan los registros porque se van a modificar dentro del procedimiento
       push ax
       push dx
       
       lea dx, bufferNombre  ; se carga en DX la dirección del buffer donde se almacenará el nombre
       mov ah, 0Ah           ; Se coloca 0Ah en AH, es para leer una cadena desde el teclado.
       int 21h               ; ejecuta funcion DOS
       
       ;bufferNombre +1 = cantidad de chars escritos
       mov al, [bufferNombre+1]   ; se lee el byte 1 del buffer.
       cmp al, 0                  ; si al es igual a 0 significa que el usuario solo presiono enter y esta vacio
       je nombre_vacio            ; salta a nombre_vacio
       
       clc                        ; pone CF = 0, que indica lectura correcta.
       jmp salir_leer_nombre      ; Salta al final del procedimiento.

nombre_vacio:
    lea dx, msgErrorNombre        ; guarda la direccion del mensaje en dx 
    call imprimir_cadena          ; llama a imprimir en pantalla
    stc                           ; CF = 1, indica error de lectura 
    
salir_leer_nombre:
                                  ; se recuperan los valores de los registros originales 
    pop dx
    pop ax
    ret                           ; regresa al lugar donde se llamó el procedimiento

leer_nombre endp


guardar_nombre_en_indice proc
       ;BX = indice de cuenta a guardar
       ;Se guardan los registros porque el procedimiento los va a modificar
       push ax
       push bx
       push cx
       push dx
       push si 
       push di
       
       xor di,di  ; pone DI = 0
       mov cx, bx ; copia el índice de la cuenta a CX

;calcular el offset destino que es igual a indice * MAX_NOMBRE     
calc_offset:
    cmp cx, 0          ; compara si cx es igual a 0 
    je offset_listo    ; salta a offset_listo 
    add di, MAX_NOMBRE ; suma del digito en MAX_Nombre con di
    dec cx             ; decrementa cx
    jmp calc_offset    ; salta a calc_offset
    
offset_listo:
     ;limpia los 20 bytes del nombre destino\ 
     mov si, di         ; posición donde inicia el nombre
     mov cx, MAX_NOMBRE ; número de bytes a limpiar

     
limpiar_destino:
       lea bx,               ; cuentasNombre ;BX apunta al inicio del arreglo de nombres
       add bx, si            ; BX apunta al lugar exacto del nombre
       mov byte ptr [bx],0   ; Escribe 0 (limpia el byte)
       inc si                ; Avanza al siguiente byte
       loop limpiar_destino  ; Repite hasta limpiar 20 bytes
        
        
       ;copiar el nombre
       lea si, bufferNombre+2   ; apunta al primer carácter del nombre
       mov cl, [bufferNombre+1] ; Carga en CL la cantidad de caracteres escritos
       xor ch, ch               ; Limpia la parte alta de CX
       
copiar_nombre:
    cmp cx, 0                   ; compara si cx es igual a 0, lo que significa que ya se copiaron todos los caracteres
    je fin_guardar_nombre       ; salta a procedimiento guardar nombre
    
    mov al, [si]                ; Lee un carácter del nombre
    mov cuentasNombre[di], al   ; Guarda ese carácter en el arreglo de nombres
    inc si                      ; Avanza al siguiente carácter del buffer
    inc di                      ; Avanza al siguiente byte en el destino
    dec cx                      ; Reduce el contador de caracteres restantes
    jmp copiar_nombre           ; Regresa al inicio del ciclo para copiar el siguiente carácter
    
                
fin_guardar_nombre:             ;Recupera los valores originales de los registros
    pop di 
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret                         ; Vuelve al lugar donde se llamó el procedimiento
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

    ; calcular indice
    mov bx,indiceEncontrado
    mov si,bx
    shl si,1

    ; pedir monto
    lea dx,msgMonto
    call imprimir_cadena

    call leer_entero
    jc fin_deposito

    mov dx,ax        ; guardar monto

    call validar_monto
    cmp bx,0
    je error_monto_deposito

    ; sumar saldo
    mov bx,indiceEncontrado
    mov si,bx
    shl si,1

    mov ax,cuentasSaldo[si]
    add ax,dx
    mov cuentasSaldo[si],ax

    lea dx,msgDepositoOk
    call imprimir_cadena

    jmp fin_deposito

cuenta_no_encontrada:
    lea dx,msgCuentaNoExiste
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
    lea dx,msgCuentaNoExiste
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
    lea dx,msgSaldoActual
    call imprimir_cadena

    mov ax,cuentasSaldo[si]
    call imprimir_numero

    jmp fin_consulta

cuenta_noo_encontrada:
    lea dx,msgCuentaNoExiste
    call imprimir_cadena

fin_consulta:
    ret

consultar_saldo endp


; ==========================================================
; MOSTRAR REPORTE
;   Recorre todos los arreglos y calcula:
;     - repActivas / repInactivas
;     - repSaldoTot (suma de todos los saldos)
;     - repIdxMayor / repIdxMenor (indice byte)
;   Registros: BX=indice byte, SI=indice word, CX=contador
; ==========================================================
mostrar_reporte proc
    push ax
    push bx
    push cx
    push dx
    push si

    cmp contadorCuentas, 0
    je mr_sin_cuentas

    mov repActivas,   0
    mov repInactivas, 0
    mov repSaldoTot,  0
    mov repIdxMayor,  0
    mov repIdxMenor,  0

    xor bx, bx
    xor si, si
    mov cx, contadorCuentas

mr_loop:
    cmp cx, 0
    je mr_mostrar

    cmp cuentasEstado[bx], 1
    jne mr_inact
    inc repActivas
    jmp mr_saldo
mr_inact:
    inc repInactivas

mr_saldo:
    mov ax, cuentasSaldo[si]
    add repSaldoTot, ax

    ;comparar con mayor (JBE = menor o igual sin signo)
    mov dx, repIdxMayor
    shl dx, 1
    mov di, dx              ;DI = offset word del actual mayor
    cmp ax, cuentasSaldo[di]
    jbe mr_menor
    mov repIdxMayor, bx

mr_menor:
    ;comparar con menor (JAE = mayor o igual sin signo)
    mov dx, repIdxMenor
    shl dx, 1
    mov di, dx              ;DI = offset word del actual menor
    cmp ax, cuentasSaldo[di]
    jae mr_sig
    mov repIdxMenor, bx

mr_sig:
    inc bx
    add si, 2
    dec cx
    jmp mr_loop

mr_mostrar:
    lea dx, msgReporte
    call imprimir_cadena

    lea dx, msgRepActivas
    call imprimir_cadena
    mov ax, repActivas
    call imprimir_numero
    lea dx, msgSaltoLinea
    call imprimir_cadena

    lea dx, msgRepInactivas
    call imprimir_cadena
    mov ax, repInactivas
    call imprimir_numero
    lea dx, msgSaltoLinea
    call imprimir_cadena

    lea dx, msgRepSaldoTot
    call imprimir_cadena
    mov ax, repSaldoTot
    call imprimir_numero
    lea dx, msgSaltoLinea
    call imprimir_cadena

    lea dx, msgRepMayor
    call imprimir_cadena
    mov bx, repIdxMayor
    call mostrar_nombre_en_indice
    lea dx, msgSaltoLinea
    call imprimir_cadena

    lea dx, msgRepMenor
    call imprimir_cadena
    mov bx, repIdxMenor
    call mostrar_nombre_en_indice
    lea dx, msgSaltoLinea
    call imprimir_cadena

    jmp mr_fin

mr_sin_cuentas:
    lea dx, msgSinCuentas
    call imprimir_cadena

mr_fin:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_reporte endp


; ==========================================================
; DESACTIVAR CUENTA
;   Muestra lista con estados, pide numero de cuenta,
;   lo busca sin importar estado, y si esta activa
;   la marca como inactiva (cuentasEstado[bx] = 0).
; ==========================================================
desactivar_cuenta proc
    push ax
    push bx
    push dx

    cmp contadorCuentas, 0
    je dc_sin_cuentas

    lea dx, msgDesact
    call imprimir_cadena

    call mostrar_lista_cuentas

    lea dx, msgPedirDesact
    call imprimir_cadena

    call leer_entero
    jc fin_desactivar

    mov numeroCuentaTemp, ax
    call buscar_cuenta_todos    ;busca sin filtrar por estado
    jnc dc_no_enc

    mov bx, indiceEncontrado
    cmp cuentasEstado[bx], 0
    je dc_ya_inact

    mov byte ptr cuentasEstado[bx], 0
    lea dx, msgDesactOk
    call imprimir_cadena
    jmp fin_desactivar

dc_ya_inact:
    lea dx, msgYaInactiva
    call imprimir_cadena
    jmp fin_desactivar

dc_no_enc:
    lea dx, msgNoEncontr
    call imprimir_cadena
    jmp fin_desactivar

dc_sin_cuentas:
    lea dx, msgSinCuentas
    call imprimir_cadena

fin_desactivar:
    pop dx
    pop bx
    pop ax
    ret
desactivar_cuenta endp


; ==========================================================
; MOSTRAR LISTA CUENTAS
;   Imprime cada cuenta con: numero, nombre, saldo y estado.
;   Formato: Num: XXXX - Nombre  Saldo: XXXX  [ACTIVA/INACTIVA]
;   Registros: BX=indice byte, SI=indice word, CX=contador
; ==========================================================
mostrar_lista_cuentas proc
    push ax
    push bx
    push cx
    push dx
    push si

    lea dx, msgListaCtas
    call imprimir_cadena

    xor bx, bx
    xor si, si
    mov cx, contadorCuentas

mlc_loop:
    cmp cx, 0
    je mlc_fin

    lea dx, msgNumCta
    call imprimir_cadena
    mov ax, cuentasNumero[si]
    call imprimir_numero

    lea dx, msgSepNom
    call imprimir_cadena
    call mostrar_nombre_en_indice   ;BX = indice byte

    lea dx, msgSaldoCta
    call imprimir_cadena
    mov ax, cuentasSaldo[si]
    call imprimir_numero

    cmp cuentasEstado[bx], 1
    jne mlc_inact
    lea dx, msgEstActiva
    call imprimir_cadena
    jmp mlc_sig
mlc_inact:
    lea dx, msgEstInactiva
    call imprimir_cadena

mlc_sig:
    inc bx
    add si, 2
    dec cx
    jmp mlc_loop

mlc_fin:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_lista_cuentas endp


; ==========================================================
; BUSCAR CUENTA TODOS
;   Igual que buscar_cuenta_por_numero pero sin filtrar
;   por estado: sirve para encontrar cuentas inactivas.
;   Retorna CF=1 si encontrada, indiceEncontrado = indice byte
; ==========================================================
buscar_cuenta_todos proc
    push ax
    push bx
    push cx
    push si

    mov ax, numeroCuentaTemp
    mov cx, contadorCuentas
    xor bx, bx
    xor si, si

bct_loop:
    cmp cx, 0
    je bct_no_enc

    cmp cuentasNumero[si], ax
    je bct_enc

    add si, 2
    inc bx
    dec cx
    jmp bct_loop

bct_enc:
    mov indiceEncontrado, bx
    stc
    jmp bct_sal

bct_no_enc:
    clc

bct_sal:
    pop si
    pop cx
    pop bx
    pop ax
    ret
buscar_cuenta_todos endp


; ==========================================================
; MOSTRAR NOMBRE EN INDICE
;   Entrada: BX = indice byte de la cuenta
;   Calcula offset = BX * MAX_NOMBRE en cuentasNombre
;   e imprime caracter a caracter hasta null o CR.
; ==========================================================
mostrar_nombre_en_indice proc
    push ax
    push bx
    push cx
    push dx
    push si

    xor si, si
    mov cx, bx          ;cx = indice, para calcular offset

mnei_off:
    cmp cx, 0
    je mnei_chars
    add si, MAX_NOMBRE
    dec cx
    jmp mnei_off

mnei_chars:
    mov cx, MAX_NOMBRE  ;cx ahora es contador de chars

mnei_loop:
    cmp cx, 0
    je mnei_fin
    mov al, cuentasNombre[si]
    cmp al, 0
    je mnei_fin
    cmp al, 13
    je mnei_fin
    mov dl, al
    mov ah, 02h
    int 21h
    inc si
    dec cx
    jmp mnei_loop

mnei_fin:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_nombre_en_indice endp  

 

 

end main
