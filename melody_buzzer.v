
module melody_buzzer(
    input  clk,      
    input  rst,     
    input  play,    
    output reg buzzer
);


    localparam STEP_LEN = 8;

    reg [2:0]  step_idx;   
    reg [15:0] ms_cnt;    
    reg [9:0]  tone_cnt;  

 
    reg [15:0] cur_dur;   
    reg        cur_beep;  

    always @(*) begin
        case (step_idx)
    
            3'd0, 3'd2, 3'd4, 3'd6: begin
                cur_dur  = 16'd80;  
                cur_beep = 1'b1;
            end
           
            3'd1, 3'd3, 3'd5: begin
                cur_dur  = 16'd40;  
                cur_beep = 1'b0;
            end
            default: begin 
                cur_dur  = 16'd220;  
                cur_beep = 1'b0;
            end
        endcase
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            step_idx <= 3'd0;
            ms_cnt   <= 16'd0;
            tone_cnt <= 10'd0;
            buzzer   <= 1'b0;
        end else if (!play) begin

            step_idx <= 3'd0;
            ms_cnt   <= 16'd0;
            tone_cnt <= 10'd0;
            buzzer   <= 1'b0;
        end else begin

            if (ms_cnt >= cur_dur) begin
                ms_cnt <= 16'd0;

                if (step_idx == (STEP_LEN-1))
                    step_idx <= 3'd0;
                else
                    step_idx <= step_idx + 3'd1;
            end else begin
                ms_cnt <= ms_cnt + 16'd1;
            end


            if (!cur_beep) begin
   
                buzzer   <= 1'b0;
                tone_cnt <= 10'd0;
            end else begin

                if (tone_cnt >= 10'd0) begin
                    tone_cnt <= 10'd0;
                    buzzer   <= ~buzzer;
                end else begin
                    tone_cnt <= tone_cnt + 10'd1;
                end
            end
        end
    end

endmodule
