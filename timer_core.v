
module timer_core(
    input        clk,       
    input        rst,        
    input        timer_mode, 

    input        min_set_p,  
    input        sec_set_p,   
    input        start_stop_p,
    input        reset_p,     
    input        clear_set_p, 

    output reg [6:0] tm_min,     
    output reg [5:0] tm_sec,     
    output reg [6:0] tm_centis,   

    output reg       timer_running,
    output reg       timer_done,


    output [6:0]     set_min_val,
    output [5:0]     set_sec_val
);


    reg [6:0] set_min;
    reg [5:0] set_sec;

    assign set_min_val = set_min;
    assign set_sec_val = set_sec;

    reg [3:0] tick_10ms;   

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            set_min       <= 7'd0;
            set_sec       <= 6'd0;
            tm_min        <= 7'd0;
            tm_sec        <= 6'd0;
            tm_centis     <= 7'd0;
            tick_10ms     <= 4'd0;
            timer_running <= 1'b0;
            timer_done    <= 1'b0;
        end else if (!timer_mode) begin
          
            set_min       <= 7'd0;
            set_sec       <= 6'd0;
            tm_min        <= 7'd0;
            tm_sec        <= 6'd0;
            tm_centis     <= 7'd0;
            tick_10ms     <= 4'd0;
            timer_running <= 1'b0;
            timer_done    <= 1'b0;
        end else begin
            
            if (clear_set_p) begin
                set_min       <= 7'd0;
                set_sec       <= 6'd0;
                tm_min        <= 7'd0;
                tm_sec        <= 6'd0;
                tm_centis     <= 7'd0;
                tick_10ms     <= 4'd0;
                timer_running <= 1'b0;
                timer_done    <= 1'b0;
            end else begin
              
                if (!timer_running) begin
                    if (min_set_p) begin
                        if (set_min >= 7'd99)
                            set_min <= 7'd0;
                        else
                            set_min <= set_min + 7'd1;

                        tm_min    <= (set_min >= 7'd99) ? 7'd0 : (set_min + 7'd1);
                        tm_sec    <= set_sec;
                        tm_centis <= 7'd0;
                        timer_done<= 1'b0;
                    end
                    else if (sec_set_p) begin
                        if (set_sec >= 6'd59)
                            set_sec <= 6'd0;
                        else
                            set_sec <= set_sec + 6'd1;

                        tm_min    <= set_min;
                        tm_sec    <= (set_sec >= 6'd59) ? 6'd0 : (set_sec + 6'd1);
                        tm_centis <= 7'd0;
                        timer_done<= 1'b0;
                    end
                end

         
                if (reset_p) begin
                    tm_min        <= set_min;
                    tm_sec        <= set_sec;
                    tm_centis     <= 7'd0;
                    tick_10ms     <= 4'd0;
                    timer_running <= 1'b0;
                    timer_done    <= 1'b0;
                end

            
                if (start_stop_p) begin
                
                    if ((tm_min != 0) || (tm_sec != 0) || (tm_centis != 0)) begin
                        timer_running <= ~timer_running;
                      
                        if (!timer_running)
                            timer_done <= 1'b0;
                    end
                end

           
                if (timer_running) begin
                    if (tick_10ms == 4'd9) begin
                        tick_10ms <= 4'd0;

              
                        if ((tm_min == 0) && (tm_sec == 0) && (tm_centis == 0)) begin
                            timer_running <= 1'b0;
                            timer_done    <= 1'b1;
                        end else begin
                         
                            if (tm_centis > 0) begin
                                tm_centis <= tm_centis - 7'd1;
                            end else begin
                                tm_centis <= 7'd99;
                                if (tm_sec > 0) begin
                                    tm_sec <= tm_sec - 6'd1;
                                end else begin
                                    tm_sec <= 6'd59;
                                    if (tm_min > 0)
                                        tm_min <= tm_min - 7'd1;
                                    else
                                        tm_min <= 7'd0;
                                end
                            end
                        end
                    end else begin
                        tick_10ms <= tick_10ms + 4'd1;
                    end
                end else begin
                    tick_10ms <= 4'd0;
                end
            end
        end
    end

endmodule
