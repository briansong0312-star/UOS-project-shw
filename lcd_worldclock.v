module lcd_worldclock(
    input        clk,     
    input        rst,     
    input        mode_12h,
    input  [1:0] tz_sel,
    input        is_pm,         
    input        alarm_mode,    

    input        alarm_en,      
    input        show_alarm,    


    input  [3:0] cur_h_ten,
    input  [3:0] cur_h_one,
    input  [3:0] cur_m_ten,
    input  [3:0] cur_m_one,
    input  [3:0] cur_s_ten,
    input  [3:0] cur_s_one,


    input  [3:0] alarm_h_ten,
    input  [3:0] alarm_h_one,
    input  [3:0] alarm_m_ten,
    input  [3:0] alarm_m_one,
    input        alarm_is_pm,   


    output       LCD_E,
    output reg   LCD_RS,
    output reg   LCD_RW,
    output reg [7:0] LCD_DATA
);

    localparam DELAY        = 3'b000;
    localparam FUNCTION_SET = 3'b001;
    localparam ENTRY_MODE   = 3'b010;
    localparam DISP_ONOFF   = 3'b011;
    localparam LINE1        = 3'b100;
    localparam LINE2        = 3'b101;
    localparam DELAY_T      = 3'b110;
    localparam CLEAR_DISP   = 3'b111;

    reg [2:0] state;
    reg [9:0] cnt;          
    reg [4:0] char_cnt;     


    reg init_cleared;


    reg LCD_E_r;
    assign LCD_E = LCD_E_r;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= DELAY;
            cnt          <= 10'd0;
            char_cnt     <= 5'd0;
            LCD_RS       <= 1'b0;
            LCD_RW       <= 1'b0;
            LCD_DATA     <= 8'h00;
            LCD_E_r      <= 1'b0;
            init_cleared <= 1'b0;
        end else begin
  
            LCD_E_r <= 1'b0;

            case (state)

                DELAY: begin
                    if (cnt == 10'd0) begin
                        LCD_RS   <= 1'b0;
                        LCD_RW   <= 1'b0;
                        LCD_DATA <= 8'h38;  
                        LCD_E_r  <= 1'b1;
                    end
                    if (cnt < 10'd70) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= FUNCTION_SET;
                    end
                end

                FUNCTION_SET: begin
                    if (cnt == 10'd0) begin
                        LCD_RS   <= 1'b0;
                        LCD_RW   <= 1'b0;
                        LCD_DATA <= 8'h38;
                        LCD_E_r  <= 1'b1;
                    end
                    if (cnt < 10'd30) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= DISP_ONOFF;
                    end
                end

                DISP_ONOFF: begin
                    if (cnt == 10'd0) begin
                        LCD_RS   <= 1'b0;
                        LCD_RW   <= 1'b0;
                        LCD_DATA <= 8'h0C;  
                        LCD_E_r  <= 1'b1;
                    end
                    if (cnt < 10'd30) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= ENTRY_MODE;
                    end
                end

                ENTRY_MODE: begin
                    if (cnt == 10'd0) begin
                        LCD_RS   <= 1'b0;
                        LCD_RW   <= 1'b0;
                        LCD_DATA <= 8'h06;  
                        LCD_E_r  <= 1'b1;
                    end
                    if (cnt < 10'd30) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= CLEAR_DISP;
                    end
                end

                CLEAR_DISP: begin
                    if (!init_cleared) begin
                        if (cnt == 10'd0) begin
                            LCD_RS   <= 1'b0;
                            LCD_RW   <= 1'b0;
                            LCD_DATA <= 8'h01;  
                            LCD_E_r  <= 1'b1;
                        end
                        if (cnt < 10'd30) begin
                            cnt <= cnt + 10'd1;
                        end else begin
                            cnt          <= 10'd0;
                            char_cnt     <= 5'd0;
                            init_cleared <= 1'b1;
                            state        <= LINE1;
                        end
                    end else begin
                        cnt      <= 10'd0;
                        char_cnt <= 5'd0;
                        state    <= LINE1;
                    end
                end

                LINE1: begin
                    if (cnt == 10'd0) begin
                        if (char_cnt == 5'd0) begin
                            LCD_RS   <= 1'b0;
                            LCD_RW   <= 1'b0;
                            LCD_DATA <= 8'h80;
                        end else begin
                            LCD_RS <= 1'b1;
                            LCD_RW <= 1'b0;

                            if (alarm_mode) begin
                       
                                case (char_cnt)
                                    5'd1:  LCD_DATA <= "A";
                                    5'd2:  LCD_DATA <= "L";
                                    5'd3:  LCD_DATA <= "A";
                                    5'd4:  LCD_DATA <= "R";
                                    5'd5:  LCD_DATA <= "M";
                                    5'd6:  LCD_DATA <= " ";
                                    5'd7:  LCD_DATA <= "S";
                                    5'd8:  LCD_DATA <= "E";
                                    5'd9:  LCD_DATA <= "T";
                                    5'd10: LCD_DATA <= " ";
                                    5'd11: LCD_DATA <= "M";
                                    5'd12: LCD_DATA <= "O";
                                    5'd13: LCD_DATA <= "D";
                                    5'd14: LCD_DATA <= "E";
                                    default: LCD_DATA <= " ";
                                endcase
                            end else if (show_alarm && alarm_en) begin
                            
                                case (char_cnt)
                                    5'd1:  LCD_DATA <= "a";
                                    5'd2:  LCD_DATA <= "l";
                                    5'd3:  LCD_DATA <= "a";
                                    5'd4:  LCD_DATA <= "r";
                                    5'd5:  LCD_DATA <= "m";
                                    5'd6:  LCD_DATA <= " ";
                                    5'd7:  LCD_DATA <= "T";
                                    5'd8:  LCD_DATA <= "i";
                                    5'd9:  LCD_DATA <= "m";
                                    5'd10: LCD_DATA <= "e";
                                    default: LCD_DATA <= " ";
                                endcase
                            end else begin
                                case (char_cnt)
                                    5'd1:  LCD_DATA <= mode_12h ? "1" : "2";
                                    5'd2:  LCD_DATA <= mode_12h ? "2" : "4";
                                    5'd3:  LCD_DATA <= "h";
                                    5'd4:  LCD_DATA <= "o";
                                    5'd5:  LCD_DATA <= "u";
                                    5'd6:  LCD_DATA <= "r";
                                    5'd7:  LCD_DATA <= " ";
                                    5'd8:  LCD_DATA <= "m";
                                    5'd9:  LCD_DATA <= "o";
                                    5'd10: LCD_DATA <= "d";
                                    5'd11: LCD_DATA <= "e";
                                    5'd12: LCD_DATA <= " ";
                                    5'd13: LCD_DATA <= (mode_12h ? (is_pm ? "P" : "A") : " ");
                                    5'd14: LCD_DATA <= (mode_12h ? "M" : " ");
                                    default: LCD_DATA <= " ";
                                endcase
                            end
                        end

                        LCD_E_r <= 1'b1; 
                    end
          
                    if (cnt < 10'd3) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt <= 10'd0;
                        if (char_cnt == 5'd15) begin
                            char_cnt <= 5'd0;
                            state    <= LINE2;
                        end else begin
                            char_cnt <= char_cnt + 5'd1;
                        end
                    end
                end
                
                LINE2: begin
                    if (cnt == 10'd0) begin
                        
                        if (char_cnt == 5'd0) begin
                            LCD_RS   <= 1'b0;
                            LCD_RW   <= 1'b0;
                            LCD_DATA <= 8'hC0;
                        end else begin
                            LCD_RS <= 1'b1;
                            LCD_RW <= 1'b0;

                            if (alarm_mode) begin
                        
                                if (alarm_en) begin
                                   
                                    case (char_cnt)
                                        5'd1:  LCD_DATA <= "A";
                                        5'd2:  LCD_DATA <= "L";
                                        5'd3:  LCD_DATA <= "A";
                                        5'd4:  LCD_DATA <= "R";
                                        5'd5:  LCD_DATA <= "M";
                                        5'd6:  LCD_DATA <= " ";
                                        5'd7:  LCD_DATA <= "O";
                                        5'd8:  LCD_DATA <= "N";
                                        default: LCD_DATA <= " ";
                                    endcase
                                end else begin
                                  
                                    case (char_cnt)
                                        5'd1:  LCD_DATA <= "A";
                                        5'd2:  LCD_DATA <= "L";
                                        5'd3:  LCD_DATA <= "A";
                                        5'd4:  LCD_DATA <= "R";
                                        5'd5:  LCD_DATA <= "M";
                                        5'd6:  LCD_DATA <= " ";
                                        5'd7:  LCD_DATA <= "O";
                                        5'd8:  LCD_DATA <= "F";
                                        5'd9:  LCD_DATA <= "F";
                                        default: LCD_DATA <= " ";
                                    endcase
                                end
                            end else if (show_alarm && alarm_en) begin
                               
                                case (char_cnt)
                                    5'd1:  LCD_DATA <= "0" + alarm_h_ten;
                                    5'd2:  LCD_DATA <= "0" + alarm_h_one;
                                    5'd3:  LCD_DATA <= ":";
                                    5'd4:  LCD_DATA <= "0" + alarm_m_ten;
                                    5'd5:  LCD_DATA <= "0" + alarm_m_one;
                                    5'd6:  LCD_DATA <= " ";
                                    5'd7:  LCD_DATA <= (mode_12h ? (alarm_is_pm ? "P" : "A") : " ");
                                    5'd8:  LCD_DATA <= (mode_12h ? "M" : " ");
                                    default: LCD_DATA <= " ";
                                endcase
                            end else begin
                              
                                case (tz_sel)
                                    2'd0: begin
                                       
                                        case (char_cnt)
                                            5'd1:  LCD_DATA <= "K";
                                            5'd2:  LCD_DATA <= "o";
                                            5'd3:  LCD_DATA <= "r";
                                            5'd4:  LCD_DATA <= "e";
                                            5'd5:  LCD_DATA <= "a";
                                            5'd6:  LCD_DATA <= " ";
                                            5'd7:  LCD_DATA <= "t";
                                            5'd8:  LCD_DATA <= "i";
                                            5'd9:  LCD_DATA <= "m";
                                            5'd10: LCD_DATA <= "e";
                                            default: LCD_DATA <= " ";
                                        endcase
                                    end
                                    2'd1: begin
                                     
                                        case (char_cnt)
                                            5'd1:  LCD_DATA <= "P";
                                            5'd2:  LCD_DATA <= "a";
                                            5'd3:  LCD_DATA <= "r";
                                            5'd4:  LCD_DATA <= "i";
                                            5'd5:  LCD_DATA <= "s";
                                            5'd6:  LCD_DATA <= " ";
                                            5'd7:  LCD_DATA <= "t";
                                            5'd8:  LCD_DATA <= "i";
                                            5'd9:  LCD_DATA <= "m";
                                            5'd10: LCD_DATA <= "e";
                                            default: LCD_DATA <= " ";
                                        endcase
                                    end
                                    2'd2: begin
                                    
                                        case (char_cnt)
                                            5'd1:  LCD_DATA <= "N";
                                            5'd2:  LCD_DATA <= "e";
                                            5'd3:  LCD_DATA <= "w";
                                            5'd4:  LCD_DATA <= "Y";
                                            5'd5:  LCD_DATA <= "o";
                                            5'd6:  LCD_DATA <= "r";
                                            5'd7:  LCD_DATA <= "k";
                                            5'd8:  LCD_DATA <= " ";
                                            5'd9:  LCD_DATA <= "t";
                                            5'd10: LCD_DATA <= "i";
                                            5'd11: LCD_DATA <= "m";
                                            5'd12: LCD_DATA <= "e";
                                            default: LCD_DATA <= " ";
                                        endcase
                                    end
                                    2'd3: begin
                                
                                        case (char_cnt)
                                            5'd1:  LCD_DATA <= "U";
                                            5'd2:  LCD_DATA <= "K";
                                            5'd3:  LCD_DATA <= " ";
                                            5'd4:  LCD_DATA <= "t";
                                            5'd5:  LCD_DATA <= "i";
                                            5'd6:  LCD_DATA <= "m";
                                            5'd7:  LCD_DATA <= "e";
                                            default: LCD_DATA <= " ";
                                        endcase
                                    end
                                    default: begin
                                        LCD_DATA <= " ";
                                    end
                                endcase
                            end
                        end

                        LCD_E_r <= 1'b1;  
                    end

        
                    if (cnt < 10'd3) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt <= 10'd0;
                        if (char_cnt == 5'd15) begin
                            char_cnt <= 5'd0;
                            state    <= DELAY_T;
                        end else begin
                            char_cnt <= char_cnt + 5'd1;
                        end
                    end
                end

       
                DELAY_T: begin
                    LCD_RS  <= 1'b0;
                    LCD_RW  <= 1'b0;
                    LCD_E_r <= 1'b0;

                    if (cnt < 10'd10) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= LINE1;
                    end
                end

                default: begin
                    state <= DELAY;
                end
            endcase
        end
    end

endmodule