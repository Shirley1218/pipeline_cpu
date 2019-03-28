module alu_16 (
    input [15:0] data_in_a,
    input [15:0] data_in_b,
    input sub,
    output logic [15:0] alu_out,
    output logic zero,
    output logic neg
);


always_comb begin
    if (sub)
        alu_out = data_in_a - data_in_b;
    else
        alu_out = data_in_a + data_in_b;
    zero = (alu_out == 0);
    neg = alu_out[15];
end


endmodule