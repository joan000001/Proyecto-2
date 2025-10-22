module teclado_matricial (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [3:0]  columnas,
    output logic [3:0]  filas,
    output logic [3:0]  dig1_1,
    output logic [3:0]  dig1_2,
    output logic [3:0]  dig1_3,
    output logic [3:0]  dig2_1,
    output logic [3:0]  dig2_2,
    output logic [3:0]  dig2_3
);

    // ====== Parámetros de tiempo ======
    localparam int SCAN_DIVIDER = 13500;     // ~2ms por fila a 27MHz
    localparam int DEBOUNCE_TIME = 540000;   // ~20ms debounce

    // ====== Señales internas ======
    logic [1:0]  fila_actual;
    logic [16:0] contador_scan;
    logic [19:0] contador_debounce;
    logic [3:0]  tecla_detectada;
    logic        tecla_valida;
    logic        tecla_presionada;
    logic        tecla_anterior;
    
    // ====== Contador de dígitos capturados ======
    logic [2:0]  contador_digitos; // 0 a 6

    // ====== Registro de los 6 dígitos ======
    logic [3:0]  reg_dig1_1;
    logic [3:0]  reg_dig1_2;
    logic [3:0]  reg_dig1_3;
    logic [3:0]  reg_dig2_1;
    logic [3:0]  reg_dig2_2;
    logic [3:0]  reg_dig2_3;

    // ====== Escáner de filas ======
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fila_actual <= 2'd0;
            contador_scan <= '0;
        end else begin
            if (contador_scan >= SCAN_DIVIDER) begin
                contador_scan <= '0;
                fila_actual <= (fila_actual == 2'd3) ? 2'd0 : fila_actual + 2'd1;
            end else begin
                contador_scan <= contador_scan + 1;
            end
        end
    end

    // ====== Activación de filas (una a la vez) ======
    always_comb begin
        case (fila_actual)
            2'd0: filas = 4'b0001;
            2'd1: filas = 4'b0010;
            2'd2: filas = 4'b0100;
            2'd3: filas = 4'b1000;
            default: filas = 4'b0000;
        endcase
    end

    // ====== Decodificación de tecla ======
    always_comb begin
        tecla_valida = 1'b0;
        tecla_detectada = 4'd0;

        if (columnas != 4'b0000) begin
            tecla_valida = 1'b1;
            case ({fila_actual, columnas})
                // Fila 0
                6'b00_0001: tecla_detectada = 4'd1;  // Tecla 1
                6'b00_0010: tecla_detectada = 4'd2;  // Tecla 2
                6'b00_0100: tecla_detectada = 4'd3;  // Tecla 3
                6'b00_1000: tecla_detectada = 4'd10; // Tecla A
                // Fila 1
                6'b01_0001: tecla_detectada = 4'd4;  // Tecla 4
                6'b01_0010: tecla_detectada = 4'd5;  // Tecla 5
                6'b01_0100: tecla_detectada = 4'd6;  // Tecla 6
                6'b01_1000: tecla_detectada = 4'd11; // Tecla B
                // Fila 2
                6'b10_0001: tecla_detectada = 4'd7;  // Tecla 7
                6'b10_0010: tecla_detectada = 4'd8;  // Tecla 8
                6'b10_0100: tecla_detectada = 4'd9;  // Tecla 9
                6'b10_1000: tecla_detectada = 4'd12; // Tecla C
                // Fila 3
                6'b11_0001: tecla_detectada = 4'd15; // Tecla * (usar como borrar)
                6'b11_0010: tecla_detectada = 4'd0;  // Tecla 0
                6'b11_0100: tecla_detectada = 4'd14; // Tecla # (no usado)
                6'b11_1000: tecla_detectada = 4'd13; // Tecla D
                default: tecla_detectada = 4'd0;
            endcase
        end
    end

    

    // ====== Debouncing y detección de flanco ======
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            contador_debounce <= '0;
            tecla_presionada <= 1'b0;
            tecla_anterior <= 1'b0;
        end else begin
            tecla_anterior <= tecla_presionada;
            
            if (tecla_valida) begin
                if (contador_debounce >= DEBOUNCE_TIME) begin
                    tecla_presionada <= 1'b1;
                end else begin
                    contador_debounce <= contador_debounce + 1;
                end
            end else begin
                contador_debounce <= '0;
                tecla_presionada <= 1'b0;
            end
        end
    end



    // ====== Captura de dígitos (flanco de subida) ======
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_dig1_1 <= 4'd0;
            reg_dig1_2 <= 4'd0;
            reg_dig1_3 <= 4'd0;
            reg_dig2_1 <= 4'd0;
            reg_dig2_2 <= 4'd0;
            reg_dig2_3 <= 4'd0;
            contador_digitos <= 3'd0;
        end else begin
            // Detectar flanco de subida de tecla_presionada
            if (tecla_presionada && !tecla_anterior) begin
                // Solo aceptar números del 0-9
                if (tecla_detectada <= 4'd9) begin
                    case (contador_digitos)
                        3'd0: begin
                            reg_dig1_3 <= tecla_detectada; // Centenas número 1
                            contador_digitos <= 3'd1;
                        end
                        3'd1: begin
                            reg_dig1_2 <= tecla_detectada; // Decenas número 1
                            contador_digitos <= 3'd2;
                        end
                        3'd2: begin
                            reg_dig1_1 <= tecla_detectada; // Unidades número 1
                            contador_digitos <= 3'd3;
                        end
                        3'd3: begin
                            reg_dig2_3 <= tecla_detectada; // Centenas número 2
                            contador_digitos <= 3'd4;
                        end
                        3'd4: begin
                            reg_dig2_2 <= tecla_detectada; // Decenas número 2
                            contador_digitos <= 3'd5;
                        end
                        3'd5: begin
                            reg_dig2_1 <= tecla_detectada; // Unidades número 2
                            contador_digitos <= 3'd6;
                        end
                        default: begin
                            // Ya se capturaron los 6 dígitos, ignorar más entradas
                        end
                    endcase
                end
                // Tecla * (15) para reiniciar
                else if (tecla_detectada == 4'd15) begin
                    reg_dig1_1 <= 4'd0;
                    reg_dig1_2 <= 4'd0;
                    reg_dig1_3 <= 4'd0;
                    reg_dig2_1 <= 4'd0;
                    reg_dig2_2 <= 4'd0;
                    reg_dig2_3 <= 4'd0;
                    contador_digitos <= 3'd0;
                end
            end
        end
    end

    // ====== Asignación de salidas ======
    assign dig1_1 = reg_dig1_1;
    assign dig1_2 = reg_dig1_2;
    assign dig1_3 = reg_dig1_3;
    assign dig2_1 = reg_dig2_1;
    assign dig2_2 = reg_dig2_2;
    assign dig2_3 = reg_dig2_3;

endmodule