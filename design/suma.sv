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
