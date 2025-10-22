module keypad_decoder (
    input  logic [1:0] row,
    input  logic [1:0] col,
    output logic [3:0] bcd_value,
    output logic       valid
);
    always_comb begin
        valid = 1'b1;
        unique case ({row, col})
            4'b00_00: bcd_value = 4'd1;
            4'b00_01: bcd_value = 4'd2;
            4'b00_10: bcd_value = 4'd3;
            4'b00_11: bcd_value = 4'd12; // '+' asignada a fila 0, col 3 (fila 1 columna 4 en tu mención)
            4'b01_00: bcd_value = 4'd4;
            4'b01_01: bcd_value = 4'd5;
            4'b01_10: bcd_value = 4'd6;
            4'b01_11: bcd_value = 4'd12; // si quieres otra tecla + aquí, pero por defecto lo repito
            4'b10_00: bcd_value = 4'd7;
            4'b10_01: bcd_value = 4'd8;
            4'b10_10: bcd_value = 4'd9;
            4'b10_11: bcd_value = 4'd12; // opcional
            // '*' reset, '0', '#' keys (fila 3)
            4'b11_00: bcd_value = 4'd10; // '*'
            4'b11_01: bcd_value = 4'd0;  // '0'
            4'b11_10: bcd_value = 4'd11; // '#'
            4'b11_11: begin bcd_value = 4'd11; end // opcional
            default: begin
                bcd_value = 4'd0;
                valid     = 1'b0;
            end
        endcase
    end
endmodule