# Escuela de Ingeniería Electrónica

## EL-3307 – Diseño Lógico

### Proyecto Corto II: Diseño Digital Sincrónico en HDL

**II Semestre 2025**
**Profesor:** Dr.-Ing. Alfonso Chacón-Rodríguez
**Asistentes:** Abner López-Méndez

---

## 1. Introducción

El desarrollo de sistemas digitales modernos requiere la implementación de circuitos sincrónicos complejos que garanticen confiabilidad y precisión temporal. Las herramientas **EDA** y los lenguajes de descripción de hardware (**HDL**) permiten modelar y sintetizar dichos sistemas en plataformas reconfigurables como las **FPGAs**.

Este proyecto introduce al estudiante en la descripción y verificación de sistemas digitales sincrónicos mediante **SystemVerilog**, empleando dispositivos integrados TTL/CMOS y herramientas de laboratorio como el **osciloscopio DSO-X2002A Keysight**.

A lo largo del trabajo se realizaron tres ejercicios fundamentales:

* Análisis de **contadores sincrónicos** (74LS163).
* Construcción de un **cerrojo SR** con compuertas NAND (74HC00).
* Medición del **tiempo de establecimiento (setup time)** en un flip-flop tipo D (74LS74).

Finalmente, se planteó el diseño de un sistema digital completo que captura, procesa y despliega datos numéricos usando una FPGA.

---

## 2. Objetivo general

Desarrollar y analizar experimentalmente un sistema digital sincrónico implementado en HDL, comprendiendo la operación de los elementos secuenciales básicos y la sincronización temporal de señales digitales.

---

## 3. Objetivos específicos

1. Analizar la operación de contadores sincrónicos y la propagación del acarreo.
2. Construir un cerrojo SR sincronizado con compuertas NAND y verificar su funcionamiento.
3. Determinar experimentalmente el tiempo de establecimiento de un registro tipo D.
4. Implementar un sistema sincrónico completo en FPGA que integre lectura, procesamiento y despliegue de datos.

---

## 4. Desarrollo experimental

### 4.1 Contadores sincrónicos (74LS163)

Se conectaron dos contadores **74LS163** en cascada para formar un contador binario sincrónico de 8 bits.
Ambos segun el instructivo comparten la señal de reloj, sin embargo, usando la frecuencia de reloj base de la FPGA y tambien la indicada en el ejercicio, mediante un divisor de frecuencia, es muy rapida para poder ser persibido a simple vista
Por lo que tambien se utilizaron frecuencias mas bajas con ayuda de un generador de funciones y modificando un poco el circuito con LEDs.
La salida **RCO** del primer contador (carry out) habilita el **ENT** del segundo (carry in), asegurando que este incremente solo cuando el primero completa su ciclo (de 0000₂ a 1111₂).

**Señales principales:**

* **RCO (Ripple Carry Output):** se activa al llegar al valor máximo (1111₂).
* **ENP (P)** y **ENT (T):** habilitan la cuenta y la propagación del acarreo, respectivamente.

**Funcionamiento:**
Cuando ambas entradas de habilitación (P y T) están en alto, el contador incrementa en cada flanco positivo de reloj. Al alcanzar 1111₂, RCO se pone en alto, activando el siguiente contador.

**Tiempo de propagación:**
Los flip-flops internos cambian casi simultáneamente tras el flanco del reloj, con un retardo de **14 ns** segun la hoja de datos del integrado. El bit observado no altera significativamente este tiempo, ya que el diseño es sincrónico.

**Fallas observadas:**
En modo de captura de falla del osiloscopio se detectaron pulsos muy breves en RCO, debidos a diferencias mínimas de propagación entre flip-flops.

**Forma de onda esperada:**

```
CLK:   _|‾|_|‾|_|‾|_|‾|_
Q0:    _‾__‾__‾__‾__‾__‾_
Q1:    __‾‾____‾‾____‾‾__
Q2:    ____‾‾‾‾____‾‾‾‾__
RCO:   __________‾________
```

---

### 4.2 Construcción de un cerrojo Set-Reset con compuertas NAND (74HC00)

Se implementó un **cerrojo SR positivo** utilizando el circuito integrado **74HC00** (cuatro compuertas NAND de dos entradas).
El diseño se sincronizó mediante una señal de reloj proveniente de la FPGA y tambien frecuencias mas bajas con ayuda de un generador de funciones, de modo que el cerrojo solo responde cuando **CLK=1**.

**Principio de funcionamiento:**

* **Set (S=1, R=0):** Q=1, Q’=0
* **Reset (S=0, R=1):** Q=0, Q’=1
* **S=R=1:** mantiene el estado previo
* **S=R=0:** estado inválido (ambas salidas tienden a 1)

**Tabla de verdad:**

| CLK | S | R | Q (nuevo) | Q'     | Descripción |
| --- | - | - | --------- | ------ | ----------- |
| 1   | 1 | 0 | 1         | 0      | Set         |
| 1   | 0 | 1 | 0         | 1      | Reset       |
| 1   | 1 | 1 | Qprev     | Qprev' | Mantiene    |
| 0   | X | X | Qprev     | Qprev' | Congela     |

**Aplicación práctica:**
Este tipo de cerrojo se utiliza en etapas de almacenamiento temporal, construcción de flip-flops tipo D, y sincronización de señales. Permite mantener información estable durante la fase baja del reloj, asegurando consistencia en la transferencia de datos.

---

### 4.3 Medición del tiempo de establecimiento (Setup Time) de un registro D (74LS74)

Se analizó el **flip-flop tipo D (74LS74)**, caracterizado por capturar la señal de entrada D en el flanco positivo del reloj.

**Conceptos clave:**

* **Setup time (tₛᵤ):** tiempo mínimo antes del flanco de reloj en que D debe ser estable.
* **Hold time (tₕ):** tiempo mínimo después del flanco en que D debe mantenerse estable.
  La violación de estos tiempos puede producir **metastabilidad**, generando salidas inestables o incorrectas.

**Metodología experimental:**

1. Generar un reloj de ~1 MHz desde la FPGA, con un divisor de frecuencia.
2. Aplicar una señal D con un retardo variable respecto a CLK.
3. Observar simultáneamente D, CLK y Q en el osciloscopio.
4. Reducir el retardo hasta que Q comience a presentar errores.
5. Medir el tiempo entre el cambio en D y el flanco de CLK: ese valor es el **tₛᵤ medido**.

**Circuito empleado (ASCII):**

```
        +----------------+
CLK --->|                |
         |   74LS74      |----> Q
D  ----->| D         Q'  |
        +----------------+
             ^
             |
         Señal D con retardo variable
```

**Formas de onda observadas:**

```
CLK:  ___|‾‾‾|___|‾‾‾|___|‾‾‾|___
D:    ----‾‾‾‾----__‾‾‾‾----
Q:    ----‾‾‾‾----__‾‾‾‾----   (correcto)
         ^ tsu (D estable antes del flanco)
```

Violación del setup time:

```
CLK:  ___|‾‾‾|___|‾‾‾|___|‾‾‾|___
D:    ----‾‾‾‾----__‾‾‾‾----
Q:    ----‾‾‾‾----???----     (metastabilidad)
```

**Resultados:**

* Valor teórico (datasheet): **tₛᵤ ≈ 20 ns**, **tₕ ≈ 5 ns**.
* Valor experimental: **≈ 22 ns**.
  La ligera diferencia se atribuye a tolerancias de componentes, jitter del reloj y precisión de medición.

---

## 5. Diseño del sistema completo

El sistema sincrónico final integra tres subsistemas funcionales en una FPGA:

1. **Lectura de teclado hexadecimal**
2. **Suma aritmética**
3. **Despliegue en 7 segmentos**

La arquitectura general sigue un enfoque de **flujo de datos controlado** mediante máquinas de estados, garantizando sincronización total con el reloj maestro de **27 MHz**.

### 5.1 Subsistema de lectura del teclado

**Descripción:**
Lee datos del teclado hexadecimal 4x4, elimina rebotes y sincroniza las entradas.
El teclado se analiza columna por columna usando un contador de anillo y detección de filas activas.

**FSM principal:**

* *IDLE → DETECT → DEBOUNCE → STORE → SWITCH*
  Permite registrar los dos números consecutivos antes de activar la suma.

**Diagrama:**

```
 +--------------------+
 |  FSM de control    |
 |--------------------|
 | Barrido columnas   |
 | Lectura filas      |
 | Debounce lógico    |
 +--------+-----------+
          |
          v
 +----------------+
 | Registro datos |
 +----------------+
```

**Sincronización:**
Las señales de entrada fueron registradas doblemente para evitar metastabilidad y sincronizadas al reloj interno de 27 MHz.

---

### 5.2 Subsistema de suma aritmética

**Descripción:**
Recibe los dos números capturados y realiza la suma sin signo de manera sincrónica.

**Diseño HDL:**

```systemverilog
always_ff @(posedge clk) begin
    if (enable)
        resultado <= numA + numB;
end
```

**Diagrama:**

```
 +--------------------------+
 |   Subsistema de suma     |
 |--------------------------|
 | Entradas: numA, numB     |
 | Salida: resultado[11:0]  |
 +--------------------------+
```

El resultado se almacena en un registro temporal antes de ser enviado al subsistema de despliegue.

---

### 5.3 Subsistema de despliegue en 7 segmentos

**Descripción:**
Convierte los datos binarios a formato decimal BCD y los muestra en cuatro displays de 7 segmentos con cátodos comunes.

**Etapas funcionales:**

1. Conversión binario–BCD.
2. Decodificación BCD–7 segmentos.
3. Multiplexado y refresco secuencial de displays.

**Diagrama:**

```
          +-----------------------+
          | Decodificador BCD-7seg|
          +-----------------------+
                    |
         +----------+----------+
         |  MUX de refresco    |
         +----------+----------+
                    |
               +----+----+
               | Displays |
               | 7 segs   |
               +----------+
```

**Frecuencias típicas:**

* Lectura teclado: ~20 Hz
* Refresco display: >60 Hz
  Ambas derivadas de divisores de frecuencia del reloj principal (27 MHz).

---

## 6. Guía de diseño

### 6.1 Codificación del HDL

* Lenguaje utilizado: **SystemVerilog**.
* Se aplicó un estilo jerárquico y estructurado.
* Separación clara entre lógica combinacional (`always_comb`) y secuencial (`always_ff`).
* FSM codificadas con enumeraciones para legibilidad:

```systemverilog
typedef enum logic [2:0] {IDLE, DETECT, DEBOUNCE, STORE, SWITCH} state_t;
```

* Señales y módulos con nombres descriptivos y normalización de prefijos.

---

### 6.2 Sincronización

Todas las señales externas se sincronizaron al reloj interno de **27 MHz** mediante registros dobles para evitar metastabilidad.
Cada subsistema está registrado a la **entrada y salida**, garantizando coherencia temporal.

Se emplearon divisores de frecuencia para adaptar las tasas de operación:
[
f_{salida} = \frac{f_{reloj}}{2^N}
]
De esta forma se lograron frecuencias adecuadas para el teclado y los displays.

---

### 6.3 Verificación

**Niveles de simulación:**

1. **Pre-síntesis (RTL):** Validación funcional mediante testbenches.
2. **Post-síntesis:** Evaluación de temporización con retardos de compuerta.
3. **Post-ruteo:** Confirmación de tiempos de setup/hold y estabilidad a 27 MHz.

Se utilizó el **analizador lógico del DSO-X2002A** para verificar la respuesta temporal y detectar posibles glitches o violaciones de sincronización.
El sistema completo presentó comportamiento estable y coherente con el modelo teórico.

---

## 7. Referencias

1. Pong P. Chu, *FPGA Prototyping by SystemVerilog Examples*, Wiley, 2018.
2. William J. Dally & R. C. Harting, *Digital Design: A Systems Approach*, Cambridge University Press, 2012.
3. Keysight Technologies, *MSOX2002A Mixed Signal Oscilloscope Manual*.
4. David Medina, *Flujo abierto para TangNano 9k*, 2024.

---
