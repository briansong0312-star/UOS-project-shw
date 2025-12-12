module lcd_stopwatch(
    input        clk,         
    input        rst,         
    input        sw_mode,     

    input        lap_valid, 
    input  [3:0] lap_m_ten,
    input  [3:0] lap_m_one,
    input  [3:0] lap_s_ten,
    input  [3:0] lap_s_one,
    input  [3:0] lap_c_ten,
    input  [3:0] lap_c_one,

    output       LCD_E,
    output reg   LCD_RS,
    output reg   LCD_RW,
    output reg [7:0] LCD_DATA
);


    reg [3:0] div_cnt;
    reg       tick;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            div_cnt <= 4'd0;
            tick    <= 1'b0;
        end else begin
            if (div_cnt == 4'd9) begin
                div_cnt <= 4'd0;
                tick    <= 1'b1;
            end else begin
                div_cnt <= div_cnt + 4'd1;
                tick    <= 1'b0;
            end
        end
    end

    assign LCD_E = tick;


    localparam S_DELAY      = 3'd0,
               S_FUNC_SET   = 3'd1,
               S_DISP_ON    = 3'd2,
               S_ENTRY_MODE = 3'd3,
               S_LINE1_SET  = 3'd4,
               S_LINE1_DATA = 3'd5,
               S_LINE2_SET  = 3'd6,
               S_LINE2_DATA = 3'd7;

    reg [2:0] state;
    reg [5:0] step;


    wire [3:0] m_ten = (sw_mode && lap_valid) ? lap_m_ten : 4'd0;
    wire [3:0] m_one = (sw_mode && lap_valid) ? lap_m_one : 4'd0;
    wire [3:0] s_ten = (sw_mode && lap_valid) ? lap_s_ten : 4'd0;
    wire [3:0] s_one = (sw_mode && lap_valid) ? lap_s_one : 4'd0;
    wire [3:0] c_ten = (sw_mode && lap_valid) ? lap_c_ten : 4'd0;
    wire [3:0] c_one = (sw_mode && lap_valid) ? lap_c_one : 4'd0;

    function [7:0] digit_ascii(input [3:0] d);
        digit_ascii = 8'h30 + d; 
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= S_DELAY;
            step     <= 6'd0;
            LCD_RS   <= 1'b0;
            LCD_RW   <= 1'b0;
            LCD_DATA <= 8'h00;
        end else if (tick) begin
            case (state)
            
                S_DELAY: begin
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h00;
                    if (step >= 6'd19) begin
                        step  <= 6'd0;
                        state <= S_FUNC_SET;
                    end else
                        step <= step + 6'd1;
                end

          
                S_FUNC_SET: begin
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h38; 
                    state    <= S_DISP_ON;
                end

           
                S_DISP_ON: begin
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h0C; 
                    state    <= S_ENTRY_MODE;
                end

              
                S_ENTRY_MODE: begin
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h06; 
                    state    <= S_LINE1_SET;
                end

           
                S_LINE1_SET: begin
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h80;  
                    state    <= S_LINE1_DATA;
                    step     <= 6'd0;
                end

         
                S_LINE1_DATA: begin
                    LCD_RS <= 1'b1;
                    LCD_RW <= 1'b0;

                    if (!sw_mode) begin
                        LCD_DATA <= 8'h20; 
                    end else begin
                       
                        case (step)
                            6'd0:  LCD_DATA <= 8'h53; 
                            6'd1:  LCD_DATA <= 8'h54; 
                            6'd2:  LCD_DATA <= 8'h4F; 
                            6'd3:  LCD_DATA <= 8'h50; 
                            6'd4:  LCD_DATA <= 8'h57; 
                            6'd5:  LCD_DATA <= 8'h41; 
                            6'd6:  LCD_DATA <= 8'h54; 
                            6'd7:  LCD_DATA <= 8'h43; 
                            6'd8:  LCD_DATA <= 8'h48; 
                            6'd9:  LCD_DATA <= 8'h20; 
                            6'd10: LCD_DATA <= 8'h4D; 
                            6'd11: LCD_DATA <= 8'h4F; 
                            6'd12: LCD_DATA <= 8'h44; 
                            6'd13: LCD_DATA <= 8'h45; 
                            default: LCD_DATA <= 8'h20;
                        endcase
                    end

                    if (step >= 6'd15) begin
                        state <= S_LINE2_SET;
                        step  <= 6'd0;
                    end else
                        step <= step + 6'd1;
                end

           
                S_LINE2_SET: begin
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'hC0; 
                    state    <= S_LINE2_DATA;
                    step     <= 6'd0;
                end

           
                S_LINE2_DATA: begin
                    LCD_RS <= 1'b1;
                    LCD_RW <= 1'b0;

                    if (!sw_mode) begin
                        LCD_DATA <= 8'h20; 
                    end else begin
                        case (step)
                            6'd0:  LCD_DATA <= 8'h4C;              
                            6'd1:  LCD_DATA <= 8'h41;              
                            6'd2:  LCD_DATA <= 8'h50;              
                            6'd3:  LCD_DATA <= 8'h3A;              
                            6'd4:  LCD_DATA <= digit_ascii(m_ten);
                            6'd5:  LCD_DATA <= digit_ascii(m_one);
                            6'd6:  LCD_DATA <= 8'h3A;             
                            6'd7:  LCD_DATA <= digit_ascii(s_ten);
                            6'd8:  LCD_DATA <= digit_ascii(s_one);
                            6'd9:  LCD_DATA <= 8'h2E;              
                            6'd10: LCD_DATA <= digit_ascii(c_ten); 
                            6'd11: LCD_DATA <= digit_ascii(c_one);
                            default: LCD_DATA <= 8'h20;
                        endcase
                    end

                    if (step >= 6'd15) begin
                        state <= S_LINE1_SET;
                        step  <= 6'd0;
                    end else
                        step <= step + 6'd1;
                end

                default: begin
                    state    <= S_DELAY;
                    step     <= 6'd0;
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h00;
                end
            endcase
        end
    end

endmodule

