# Escuela de Ingeniería Electrónica

## EL-3307 – Diseño Lógico

### Proyecto Corto II: Diseño Digital Sincrónico en HDL

**II Semestre 2025**
**Profesor:** Dr.-Ing. Alfonso Chacón-Rodríguez
**Asistentes:** Abner López-Méndez

### 2. Referencias
- [0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

- [1] M. M. Mano and M. D. Ciletti, Digital Design: With an Introduction to the Verilog HDL, VHDL, and SystemVerilog, 5th ed. Boston, MA, USA: Pearson, 2013.

- [2] B. Razavi, Design of Analog CMOS Integrated Circuits, 2nd ed. New York, NY, USA: McGraw-Hill Education, 2016.

### 3. Desarrollo
 - Joan Franco Sandoval 

---

## . Introducción

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

**Diseño**

```systemverilog
module suma (
    input  logic [3:0]  dig1_1, 
    input  logic [3:0]  dig1_2, 
    input  logic [3:0]  dig1_3, 
    input  logic [3:0]  dig2_1,
    input  logic [3:0]  dig2_2,
    input  logic [3:0]  dig2_3,     

    output logic [3:0]  digito1, // unidades
    output logic [3:0]  digito2, // decenas
    output logic [3:0]  digito3, // centenas
    output logic [3:0]  digito4  // millares 
);

    logic [4:0] sum_u;
    logic [4:0] sum_d;
    logic [4:0] sum_m;

    logic car1;
    logic car2;

    always_comb begin
        // --- Unidades ---
        sum_u = dig1_1 + dig2_1;
        if (sum_u > 5'b01001)
            sum_u = sum_u + 5'b00110;
        digito1 = sum_u[3:0];
        car1    = sum_u[4];

        // --- Decenas ---
        sum_d = dig1_2 + dig2_2 + car1;
        if (sum_d > 5'b01001)
            sum_d = sum_d + 5'b00110;
        digito2 = sum_d[3:0];
        car2    = sum_d[4];



        // --- Centenas ---
        sum_m = dig1_3 + dig2_3 + car2;
        if (sum_m > 5'b01001)
            sum_m = sum_m + 5'b00110;
        digito3 = sum_m[3:0];
        digito4 = sum_m[4];
    end

endmodule
```

**Test**
```systemverilog

    initial begin
        $display("SUMA BCD ");
        $display("   Numero1   +   Numero2   =   Resultado");
       

        // Caso 1: 123 + 456
        dig1_3 = 4'd1; dig1_2 = 4'd2; dig1_1 = 4'd3;
        dig2_3 = 4'd4; dig2_2 = 4'd6; dig2_1 = 4'd6;
        #10;
        $display("     %0d%0d%0d   +   %0d%0d%0d   =   %0d%0d%0d%0d",
                 dig1_3, dig1_2, dig1_1,
                 dig2_3, dig2_2, dig2_1,
                 digito4, digito3, digito2, digito1);

        // Caso 2: 999 + 1
        dig1_3 = 4'd9; dig1_2 = 4'd9; dig1_1 = 4'd9;
        dig2_3 = 4'd1; dig2_2 = 4'd1; dig2_1 = 4'd1;
        #10;
        $display("     %0d%0d%0d   +   %0d%0d%0d   =   %0d%0d%0d%0d",
                 dig1_3, dig1_2, dig1_1,
                 dig2_3, dig2_2, dig2_1,
                 digito4, digito3, digito2, digito1);

        // Caso 3: 567 + 678
        dig1_3 = 4'd5; dig1_2 = 4'd6; dig1_1 = 4'd7;
        dig2_3 = 4'd6; dig2_2 = 4'd7; dig2_1 = 4'd8;
        #10;
        $display("     %0d%0d%0d   +   %0d%0d%0d   =   %0d%0d%0d%0d",
                 dig1_3, dig1_2, dig1_1,
                 dig2_3, dig2_2, dig2_1,
                 digito4, digito3, digito2, digito1);

        // Caso 4: 250 + 250
        dig1_3 = 4'd2; dig1_2 = 4'd8; dig1_1 = 4'd0;
        dig2_3 = 4'd2; dig2_2 = 4'd5; dig2_1 = 4'd0;
        #10;
        $display("     %0d%0d%0d   +   %0d%0d%0d   =   %0d%0d%0d%0d",
                 dig1_3, dig1_2, dig1_1,
                 dig2_3, dig2_2, dig2_1,
                 digito4, digito3, digito2, digito1);

        // Caso 5: 400 + 700
        dig1_3 = 4'd4; dig1_2 = 4'd0; dig1_1 = 4'd0;
        dig2_3 = 4'd7; dig2_2 = 4'd0; dig2_1 = 4'd0;
        #10;
        $display("     %0d%0d%0d   +   %0d%0d%0d   =   %0d%0d%0d%0d",
                 dig1_3, dig1_2, dig1_1,
                 dig2_3, dig2_2, dig2_1,
                 digito4, digito3, digito2, digito1);

       
        $finish;
    end

endmodule
```

**resultado de la pruba**
SUMA BCD 
   Numero1   +   Numero2   =   Resultado
     123   +   466   =   0589
     999   +   111   =   1110
     567   +   678   =   1245
     280   +   250   =   0530
     400   +   700   =   1100

---

### 5.3 Subsistema de despliegue en 7 segmentos

**Descripción:**
Recibe los dos números capturados y realiza la suma sin signo de manera sincrónica.

**Diseño**

```systemverilog
module multiplex_display #(
    parameter int contar = 1000
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [3:0]  digito1,
    input  logic [3:0]  digito2,
    input  logic [3:0]  digito3,
    input  logic [3:0]  digito4,
    output logic [3:0]  bcd_value,
    output logic [3:0]  segmento_activo
);

    logic [1:0] pantalla_activa;   // Solo 2 bits para 4 pantallas (0–3)
    logic [16:0] contador;

    // ---- CONTADOR Y SELECCIÓN DE DISPLAY ----
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            contador <= '0;
            pantalla_activa <= 2'd0;
        end else if (contador == contar) begin
            contador <= '0;
            pantalla_activa <= (pantalla_activa == 2'd3) ? 2'd0 : pantalla_activa + 1;
        end else begin
            contador <= contador + 1;
        end
    end

    // ---- MUX DE VALOR BCD ----
    always_comb begin
        unique case (pantalla_activa)
            2'd0: bcd_value = digito1;
            2'd1: bcd_value = digito2;
            2'd2: bcd_value = digito3;
            2'd3: bcd_value = digito4;
            default: bcd_value = 4'd0;
        endcase
    end

    // ---- SELECCIÓN DE DISPLAY ACTIVO ----
    always_comb begin
    unique case (pantalla_activa)
        2'd0: segmento_activo = 4'b0001;
        2'd1: segmento_activo = 4'b0010;
        2'd2: segmento_activo = 4'b0100;
        2'd3: segmento_activo = 4'b1000;
        default: segmento_activo = 4'b0000;
    endcase
end

endmodule

```

**Etapas funcionales:**

1. Conversión binario–BCD.
2. Decodificación BCD–7 segmentos.
3. Multiplexado y refresco secuencial de displays.

**Test**
```systemverilog
          always #(CLK_PERIOD/2.0) clk = ~clk;

          // Proceso inicial
          initial begin
              
              $display("Tiempo(us)\tsegmento_activo\tbcd_value\tDígito activo");
              clk = 0;
              rst_n = 0;
              digito1 = 4'd1;
              digito2 = 4'd2;
              digito3 = 4'd9;
              digito4 = 4'd4;

              #1000;    // Esperar 10 µs
              rst_n = 1;

              
              repeat (9000) begin
                  @(posedge clk);
                  if (dut.contador == 0) begin
                      string digito_activo;
                      case (segmento_activo)
                          4'b0001: digito_activo = "unidad";
                          4'b0010: digito_activo = "decena";
                          4'b0100: digito_activo = "centena";
                          4'b1000: digito_activo = "millar";
                          default: digito_activo = "N/A";
                      endcase

                      $display("%0t\t%b\t\t%d\t\t%s",
                              $time, segmento_activo, bcd_value, digito_activo);
     
```

**resultado de la pruba**
Tiempo(us)      segmento_activo bcd_value       Digito activo
1001000000000000        0001             1              unidad
3003000000000000        0010             2              decena
5005000000000000        0100             9              centena
7007000000000000        1000             4              millar
9009000000000000        0001             1              unidad
11011000000000000       0010             2              decena
13013000000000000       0100             9              centena
15015000000000000       1000             4              millar
17017000000000000       0001             1              unidad
../sim/tech_tb.sv:62: $finish called at 18999000000000000 (1ps)

---

### 5.3 Decodificaor del 7 segmentos

**Descripción:**
Convierte los datos binarios a formato decimal BCD y los muestra en cuatro displays de 7 segmentos con cátodos comunes.

**Etapas funcionales:**

1. Conversión binario–BCD.
2. Decodificación BCD–7 segmentos.
3. Multiplexado y refresco secuencial de displays.

**Test**
```systemverilog
   bcd_val = 4'hA; 
        #1;
        $display("sevseg: bcd=%h => seg=%b", bcd_val, seg_out);
        bcd_val = 4'h0; 
        #1;
        $display("sevseg: bcd=%h => seg=%b", bcd_val, seg_out);
        bcd_val = 4'h2; 
        #1;
        $display("sevseg: bcd=%h => seg=%b", bcd_val, seg_out);
        bcd_val = 4'h9; 
        #1;
        $display("sevseg: bcd=%h => seg=%b", bcd_val, seg_out);
        
```

**resultado de la pruba**
- sevseg: bcd=a => seg=0001000
- sevseg: bcd=0 => seg=1000000
- sevseg: bcd=2 => seg=0100100
- sevseg: bcd=9 => seg=0010000
---

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

### 6.3  Análisis de Consumo de Recursos y Potencia



Frecuencia de operación: 27 MHz



#### 6.3.1 Resultados de Síntesis 


- Wires	803
- Wire bits	1515
- Celdas totales	946
- Memorias	0
- Bits de memoria	0
- Procesos	0

#### 6.3.2 Distribución de celdas principales:

ALU: 134

Flip-Flops (DFFC, DFFCE, DFFP): 90

LUTs (1–4 entradas): 457

Multiplexores (LUT5–LUT8): 242

Buffers de E/S (IBUF/OBUF): 21



#### 6.3.3 Utilización del Dispositivo 



- SLICEs	683	8640	7%
- IOB	21	274	7%
- MUX2_LUT5	156	4320	3%
- MUX2_LUT6	64	2160	2%
- MUX2_LUT7	18	1080	1%
- MUX2_LUT8	4	1056	0%
- RAMW (bloques de RAM)	0	270	0%
 -rPLL / OSC / ODDR	0	—	0%

El diseño ocupa únicamente el 7% de los recursos lógicos disponibles.



---

