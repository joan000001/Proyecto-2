module top (
    input  logic        clk,
    input  logic [3:0]  columnas,
    output logic [3:0]  filas,
    output logic [6:0]  segments,
    output logic [2:0]  enable_displays
);

    logic [3:0]  dig1_1; 
    logic [3:0]  dig1_2; 
    logic [3:0]  dig1_3; 
    logic [3:0]  dig2_1;
    logic [3:0]  dig2_2;
    logic [3:0]  dig2_3;

    logic        clk,
    logic        rst_n,

    logic [3:0]  digito1;
    logic [3:0]  digito2; 
    logic [3:0]  digito3; 
    logic [3:0]  digito4; 

    logic [3:0]  bcd_value,
    logic [3:0]  segmento_activo

    suma      sumador (
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

    multiplex_display      controlador_de_pantalla (
        .clk(clk),
        .rst_n(rst_n),
        .digito1(digito1),
        .digito2(digito2),
        .digito3(digito3),
        .digito4(digito4),

        .bcd_value(bcd_value),
        .segmento_activo(segmento_activo)


    );


    sevseg      segundo_decodificador (

        .bcd_value(bcd_value),
        
        .segmento_activo(segmento_activo)


    );





endmodule