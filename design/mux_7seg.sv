module multiplex_display #(
    parameter int contar = 1000
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [3:0]  digit0,
    input  logic [3:0]  digit1,
    input  logic [3:0]  digit2,
    input  logic [3:0]  digit3,
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
            2'd0: bcd_value = digit0;
            2'd1: bcd_value = digit1;
            2'd2: bcd_value = digit2;
            2'd3: bcd_value = digit3;
            default: bcd_value = 4'd0;
        endcase
    end

    // ---- SELECCIÓN DE DISPLAY ACTIVO ----
    always_comb begin
        unique case (pantalla_activa)
            2'd0: segmento_activo = 4'b1110;  // Activa display 0
            2'd1: segmento_activo = 4'b1101;  // Activa display 1
            2'd2: segmento_activo = 4'b1011;  // Activa display 2
            2'd3: segmento_activo = 4'b0111;  // Activa display 3
            default: segmento_activo = 4'b1111;
        endcase
    end

endmodule
