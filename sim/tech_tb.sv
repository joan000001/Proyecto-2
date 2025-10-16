`timescale 1ns / 1ps

module tb_multiplex_display;

    // Parámetros del DUT
    parameter int contar = 10; // valor pequeño para simular rápido

    // Señales del testbench
    logic clk;
    logic rst_n;
    logic [3:0] digit0, digit1, digit2, digit3;
    logic [3:0] bcd_value;
    logic [3:0] segmento_activo;

    // Instancia del DUT (Device Under Test)
    multiplex_display #(
        .contar(contar)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .digit0(digit0),
        .digit1(digit1),
        .digit2(digit2),
        .digit3(digit3),
        .bcd_value(bcd_value),
        .segmento_activo(segmento_activo)
    );

    // ---- Generador de reloj ----
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // periodo = 10 ns → frecuencia 100 MHz
    end

    // ---- Estímulos ----
    initial begin
        // Inicialización
        rst_n = 0;
        digit0 = 4'd1;
        digit1 = 4'd2;
        digit2 = 4'd3;
        digit3 = 4'd4;
        #20;
        rst_n = 1;

        // Simular por un tiempo suficiente para ver varios ciclos
        #500;

        $display("Simulación completa.");
        $finish;
    end

    // ---- Monitor de señales ----
    initial begin
        $display("Tiempo | pantalla_activa | bcd_value | segmento_activo");
        $monitor("%0t ns | %b | %d | %b", $time, dut.pantalla_activa, bcd_value, segmento_activo);
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_suma;

    // Entradas
    logic [3:0] dig1_1, dig1_2, dig1_3;
    logic [3:0] dig2_1, dig2_2, dig2_3;

    // Salidas
    logic [3:0] digito1, digito2, digito3, digito4;

    // Instancia del DUT (Device Under Test)
    suma dut (
        .dig1_1(dig1_1), .dig1_2(dig1_2), .dig1_3(dig1_3),
        .dig2_1(dig2_1), .dig2_2(dig2_2), .dig2_3(dig2_3),
        .digito1(digito1), .digito2(digito2),
        .digito3(digito3), .digito4(digito4)
    );

    // --- Procedimiento de prueba ---
    initial begin
        $display("=== Simulación módulo SUMA BCD ===");
        $display("   Número1   +   Número2   =   Resultado");
        $display("------------------------------------------");

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

        $display("=== Fin de simulación ===");
        $finish;
    end

endmodule

