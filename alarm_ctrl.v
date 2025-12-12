
module alarm_ctrl(
    input        clk,
    input        rst,

    input  [4:0] cur_hour,
    input  [5:0] cur_min,
    input  [5:0] cur_sec,

    input        set_h_p,
    input        set_m_p,
    input        toggle_p,
    input        stop_p,
    input        clear_time_p,

    output reg [4:0] alarm_hour,
    output reg [5:0] alarm_min,
    output reg       alarm_en,
    output reg       alarm_ringing
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alarm_hour    <= 5'd0;
            alarm_min     <= 6'd0;
            alarm_en      <= 1'b0;
            alarm_ringing <= 1'b0;
        end else begin

            if (clear_time_p) begin
                alarm_hour    <= 5'd0;
                alarm_min     <= 6'd0;
                alarm_en      <= 1'b0;  
                alarm_ringing <= 1'b0;  
            end else begin
            
                if (set_h_p) begin
                    if (alarm_hour >= 5'd23)
                        alarm_hour <= 5'd0;
                    else
                        alarm_hour <= alarm_hour + 5'd1;
                end

                if (set_m_p) begin
                    if (alarm_min >= 6'd59)
                        alarm_min <= 6'd0;
                    else
                        alarm_min <= alarm_min + 6'd1;
                end

             
                if (toggle_p) begin
                    alarm_en <= ~alarm_en;
                end

            
                if (alarm_en && !alarm_ringing &&
                    (cur_hour == alarm_hour) &&
                    (cur_min  == alarm_min ) &&
                    (cur_sec  == 6'd0)) begin
                    alarm_ringing <= 1'b1;
                end

      
                if (stop_p) begin
                    alarm_ringing <= 1'b0;
                end
            end
        end
    end

endmodule
