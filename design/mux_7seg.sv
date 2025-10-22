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
