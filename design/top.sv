module top (
    input  logic        clk,
    input  logic        rst_n,             
    input  logic [3:0]  columnas,      // Entradas de columnas del teclado
    output logic [3:0]  filas,         // Salidas de filas del teclado
    output logic [6:0]  segments,      // Segmentos a-g del display
    output logic [3:0]  enable_displays //
);

    // ====== Señales internas para los 6 dígitos ======
    logic [3:0]  dig1_1;  // Unidades del primer número
    logic [3:0]  dig1_2;  // Decenas del primer número
    logic [3:0]  dig1_3;  // Centenas del primer número
    logic [3:0]  dig2_1;  // Unidades del segundo número
    logic [3:0]  dig2_2;  // Decenas del segundo número
    logic [3:0]  dig2_3;  // Centenas del segundo número

    // ====== Señales del resultado ======
    logic [3:0]  digito1; // Unidades del resultado
    logic [3:0]  digito2; // Decenas del resultado
    logic [3:0]  digito3; // Centenas del resultado
    logic [3:0]  digito4; // Millares del resultado

    logic [3:0]  bcd_value;

    // ====== Instancia del teclado matricial ======
    teclado_matricial teclado (
        .clk(clk),
        .rst_n(rst_n),
        .columnas(columnas),
        .filas(filas),
        .dig1_1(dig1_1),
        .dig1_2(dig1_2),
        .dig1_3(dig1_3),
        .dig2_1(dig2_1),
        .dig2_2(dig2_2),
        .dig2_3(dig2_3)
    );

    // ====== Instancia del sumador BCD ======
    suma sumador (
        .dig1_1(dig1_1),
        .dig1_2(dig1_2),
        .dig1_3(dig1_3),
        .dig2_1(dig2_1),
        .dig2_2(dig2_2),
        .dig2_3(dig2_3),
        .digito1(digito1),
        .digito2(digito2),
        .digito3(digito3),
        .digito4(digito4)
    );

    // ====== Instancia del multiplexor de displays ======
    multiplex_display controlador_de_pantalla (
        .clk(clk),
        .rst_n(rst_n),
        .digito1(digito1),
        .digito2(digito2),
        .digito3(digito3),
        .digito4(digito4),
        .bcd_value(bcd_value),
        .segmento_activo(enable_displays)
    );

    // ====== Instancia del decodificador 7 segmentos ======
    sevseg decodificador (
        .bcd(bcd_value),
        .segments(segments)
    );

endmodule