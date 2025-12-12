
module stopwatch_core(
    input        clk,          
    input        rst,          
    input        sw_mode,      

    input        start_stop_p, 
    input        lap_p,        
    input        reset_p,      

    output reg [6:0] sw_min,       
    output reg [5:0] sw_sec,       
    output reg [6:0] sw_centis,    

    output reg [6:0] lap_min,
    output reg [5:0] lap_sec,
    output reg [6:0] lap_centis,
    output reg       lap_valid     
);

    reg running;        
    reg [3:0] tick_10ms; 


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            running    <= 1'b0;
            sw_min     <= 7'd0;
            sw_sec     <= 6'd0;
            sw_centis  <= 7'd0;
            tick_10ms  <= 4'd0;
        end else if (!sw_mode || reset_p) begin

            running    <= 1'b0;
            sw_min     <= 7'd0;
            sw_sec     <= 6'd0;
            sw_centis  <= 7'd0;
            tick_10ms  <= 4'd0;
        end else begin

            if (start_stop_p) begin
                running <= ~running;
            end


            if (running) begin
                if (tick_10ms == 4'd9) begin
                    tick_10ms <= 4'd0;

        
                    if (sw_centis == 7'd99) begin
                        sw_centis <= 7'd0;

                 
                        if (sw_sec == 6'd59) begin
                            sw_sec <= 6'd0;

                      
                            if (sw_min == 7'd99)
                                sw_min <= 7'd0;
                            else
                                sw_min <= sw_min + 7'd1;
                        end else begin
                            sw_sec <= sw_sec + 6'd1;
                        end
                    end else begin
                        sw_centis <= sw_centis + 7'd1;
                    end
                end else begin
                    tick_10ms <= tick_10ms + 4'd1;
                end
            end else begin
                tick_10ms <= 4'd0;
            end
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lap_min     <= 7'd0;
            lap_sec     <= 6'd0;
            lap_centis  <= 7'd0;
            lap_valid   <= 1'b0;
        end else if (!sw_mode || reset_p) begin
            lap_min     <= 7'd0;
            lap_sec     <= 6'd0;
            lap_centis  <= 7'd0;
            lap_valid   <= 1'b0;
        end else begin
            if (lap_p) begin
                lap_min     <= sw_min;
                lap_sec     <= sw_sec;
                lap_centis  <= sw_centis;
                lap_valid   <= 1'b1;
            end
        end
    end

endmodule

