module pipeline_reg #( parameter DATA_WIDTH = 16 )
(
    input clk,
    input reset,
    input enable,
    input [DATA_WIDTH-1:0] reg_in,
    output logic [DATA_WIDTH-1:0] reg_out
);

always_ff @(posedge clk) begin
    if (reset) begin
        reg_out <= 0; 
    end else if (enable) begin
        reg_out <= reg_in;
    end  
end
    
endmodule