
module tz_mode_ctrl(
    input       clk,
    input       rst,
    input       mode_toggle_p,   
    input       paris_p,
    input       ny_p,
    input       uk_p,
    input       korea_p,        
    output reg  mode_12h,        
    output reg [1:0] tz_sel
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            mode_12h <= 1'b0;        
        else if (mode_toggle_p)
            mode_12h <= ~mode_12h;
    end

 
    always @(posedge clk or posedge rst) begin
        if (rst)
            tz_sel <= 2'd0;           
        else begin
            if      (korea_p) tz_sel <= 2'd0; 
            else if (paris_p) tz_sel <= 2'd1;
            else if (ny_p)    tz_sel <= 2'd2;
            else if (uk_p)    tz_sel <= 2'd3;
        
        end
    end
endmodule
