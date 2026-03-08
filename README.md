# BankTec – Sistema de Gestión de Cuentas Bancarias

Proyecto desarrollado para el curso **Paradigmas de Programación (CE1106)**
Escuela de Ingeniería en Computadores
Instituto Tecnológico de Costa Rica

## Descripción del Proyecto

BankTec es una aplicación desarrollada en **Lenguaje Ensamblador 8086** que simula la gestión básica de cuentas bancarias.
El sistema permite administrar hasta **10 cuentas**, almacenando información de cada una en estructuras de memoria y utilizando procedimientos modulares.

El programa incluye validaciones de datos, manejo de errores y operaciones bancarias básicas como depósitos, retiros y consultas de saldo.

## Objetivos del Proyecto

* Reforzar el conocimiento del lenguaje **Ensamblador 8086**.
* Implementar estructuras tipo registro en memoria.
* Utilizar procedimientos modulares mediante **CALL y RET**.
* Implementar validaciones numéricas y manejo de errores.
* Aplicar lógica condicional y estructuras de control.

## Funcionalidades del Sistema

El sistema presenta un **menú interactivo en pantalla** con las siguientes opciones:

1. Crear cuenta
2. Depositar dinero
3. Retirar dinero
4. Consultar saldo
5. Mostrar reporte general
6. Desactivar cuenta
7. Salir

### Operaciones disponibles

**Crear cuenta**

* No permite números de cuenta repetidos.
* El saldo inicial debe ser mayor o igual a 0.
* La cuenta se crea en estado **Activa**.

**Depositar dinero**

* Solo se permite en cuentas activas.
* El monto debe ser positivo.

**Retirar dinero**

* Solo se permite en cuentas activas.
* No se permite sobregiro.

**Consultar saldo**

* Permite buscar una cuenta por número.

**Mostrar reporte**
El sistema muestra:

* Total de cuentas activas
* Total de cuentas inactivas
* Saldo total del banco
* Cuenta con mayor saldo
* Cuenta con menor saldo

**Desactivar cuenta**

* Cambia el estado de la cuenta a inactiva.
* No se puede desactivar una cuenta que ya esté inactiva.

## Aspectos Técnicos Implementados

* Procedimientos separados para cada opción del menú.
* Uso de **estructuras en memoria mediante offsets**.
* Implementación de **búsqueda lineal**.
* Uso de instrucciones de control como:

  * CMP
  * JE
  * JNE
  * LOOP
* Manejo de interrupciones **INT 21h**.
* Conversión entre **ASCII y valores numéricos**.
* Validación de entradas del usuario.

## Estructura del Proyecto

Ejemplo de organización del repositorio:

```
BankTec/
│
├── README.md
├── codigo.asm
├── documentacion.pdf
├── manual_usuario.pdf
└── TareaASMI2026.pdf
```

## Documentación

La descripción completa del proyecto y los requerimientos se encuentran en:

* **TareaASMI2026.pdf**

## Integrantes del Proyecto

* Meibel Elena Mora Brenes 2021128644
* Nombre del estudiante
* Nombre del estudiante

## Fecha de Entrega

19 de marzo de 2026

## Curso

Paradigmas de Programación (CE1106)
