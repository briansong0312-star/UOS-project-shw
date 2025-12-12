module time_base(
    input        clk,          
    input        rst,          

    input        adj_min_p,
    input        adj_hour_p,

    input        clear_time_p,  

    output reg [5:0] sec,
    output reg [5:0] min,
    output reg [4:0] hour
);

  
    reg [9:0] tick_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tick_cnt <= 10'd0;
            sec      <= 6'd0;
            min      <= 6'd0;
            hour     <= 5'd0;
        end else begin
            if (clear_time_p) begin
                tick_cnt <= 10'd0;
                sec      <= 6'd0;
                min      <= 6'd0;
                hour     <= 5'd0;
            end else begin
                if (adj_min_p) begin
                    if (min == 6'd59) min <= 6'd0;
                    else              min <= min + 6'd1;
                end

                if (adj_hour_p) begin
                    if (hour == 5'd23) hour <= 5'd0;
                    else               hour <= hour + 5'd1;
                end
                if (tick_cnt >= 10'd999) begin
                    tick_cnt <= 10'd0;
                    if (sec == 6'd59) begin
                        sec <= 6'd0;
                        if (min == 6'd59) begin
                            min <= 6'd0;
                            if (hour == 5'd23) hour <= 5'd0;
                            else               hour <= hour + 5'd1;
                        end else begin
                            min <= min + 6'd1;
                        end
                    end else begin
                        sec <= sec + 6'd1;
                    end
                end else begin
                    tick_cnt <= tick_cnt + 10'd1;
                end
            end
        end
    end

endmodule
