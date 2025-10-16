// =====================================================
// Módulo principal de antirrebote (debounce) // ia
// =====================================================
module debounce (
    input  logic pb_1,      // entrada del botón
    input  logic clk,       // reloj principal
    output logic pb_out     // salida sin rebote
);
    logic slow_clk;         // reloj lento
    logic Q0, Q1, Q2, Q2_bar;

    // Instanciación de módulos
    clock_div u1 (.Clk_100M(clk), .slow_clk(slow_clk));
    my_dff d0 (.DFF_CLOCK(slow_clk), .D(pb_1), .Q(Q0));
    my_dff d1 (.DFF_CLOCK(slow_clk), .D(Q0),   .Q(Q1));
    my_dff d2 (.DFF_CLOCK(slow_clk), .D(Q1),   .Q(Q2));

    // Lógica combinacional
    assign Q2_bar = ~Q2;
    assign pb_out = Q1 & Q2_bar;
endmodule


// =====================================================
// Módulo divisor de reloj
// =====================================================
module clock_div (
    input  logic Clk_100M,   // reloj de entrada (100 MHz)
    output logic slow_clk    // reloj dividido (lento)
);
    logic [26:0] counter = 0;

    always_ff @(posedge Clk_100M) begin
        if (counter >= 249999)
            counter <= 0;
        else
            counter <= counter + 1;

        slow_clk <= (counter < 125000) ? 1'b0 : 1'b1;
    end
endmodule


// =====================================================
// Flip-Flop tipo D (para sincronizar señales)
// =====================================================
module my_dff (
    input  logic DFF_CLOCK,  // reloj
    input  logic D,          // entrada de datos
    output logic Q           // salida
);
    always_ff @(posedge DFF_CLOCK) begin
        Q <= D;
    end
endmodule
