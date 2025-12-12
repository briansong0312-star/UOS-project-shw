module lcd_alarm_info(
    input        clk,        // 1kHz
    input        rst,        // active-high
    input  [3:0] a_h_ten,    // 알람 시각 시 10의 자리
    input  [3:0] a_h_one,    // 알람 시각 시 1의 자리
    input  [3:0] a_m_ten,    // 알람 시각 분 10의 자리
    input  [3:0] a_m_one,    // 알람 시각 분 1의 자리
    output       LCD_E,
    output reg   LCD_RS,
    output reg   LCD_RW,
    output reg [7:0] LCD_DATA
);
    // hello3 / lcd_worldclock 과 같은 상태 정의
    localparam DELAY        = 3'b000;
    localparam FUNCTION_SET = 3'b001;
    localparam ENTRY_MODE   = 3'b010;
    localparam DISP_ONOFF   = 3'b011;
    localparam LINE1        = 3'b100;
    localparam LINE2        = 3'b101;
    localparam DELAY_T      = 3'b110;
    localparam CLEAR_DISP   = 3'b111;

    reg [2:0] state;
    reg [9:0] cnt;        // 타이밍 카운터
    reg [4:0] char_cnt;   // 문자 인덱스 0~15

    // LCD_E: cnt의 LSB 사용 (기존 템플릿과 동일하게)
    assign LCD_E = cnt[1];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= DELAY;
            cnt      <= 10'd0;
            char_cnt <= 5'd0;
            LCD_RS   <= 1'b0;
            LCD_RW   <= 1'b0;
            LCD_DATA <= 8'h00;
        end else begin
            case (state)
                //--------------------------------------------------
                // 초기 딜레이
                //--------------------------------------------------
                DELAY: begin
                    if (cnt < 10'd70) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= FUNCTION_SET;
                    end
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h38;   // 8bit, 2line, 5x8
                end

                //--------------------------------------------------
                // Function Set
                //--------------------------------------------------
                FUNCTION_SET: begin
                    if (cnt < 10'd30) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= DISP_ONOFF;
                    end
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h38;
                end

                //--------------------------------------------------
                // Display On/Off
                //--------------------------------------------------
                DISP_ONOFF: begin
                    if (cnt < 10'd30) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= ENTRY_MODE;
                    end
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h0C;   // display ON, cursor OFF
                end

                //--------------------------------------------------
                // Entry Mode Set
                //--------------------------------------------------
                ENTRY_MODE: begin
                    if (cnt < 10'd30) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= CLEAR_DISP;
                    end
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h06;   // increment, no shift
                end

                //--------------------------------------------------
                // Clear Display
                //--------------------------------------------------
                CLEAR_DISP: begin
                    if (cnt < 10'd30) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt      <= 10'd0;
                        char_cnt <= 5'd0;
                        state    <= LINE1;
                    end
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h01;
                end

                //--------------------------------------------------
                // LINE1 : "alarm Time"
                //--------------------------------------------------
                LINE1: begin
                    if (cnt < 10'd30) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt      <= 10'd0;
                        char_cnt <= char_cnt + 5'd1;

                        LCD_RS <= 1'b1;  // 데이터 쓰기
                        LCD_RW <= 1'b0;

                        case (char_cnt)
                            5'd0:  LCD_DATA <= "a";
                            5'd1:  LCD_DATA <= "l";
                            5'd2:  LCD_DATA <= "a";
                            5'd3:  LCD_DATA <= "r";
                            5'd4:  LCD_DATA <= "m";
                            5'd5:  LCD_DATA <= " ";
                            5'd6:  LCD_DATA <= "T";
                            5'd7:  LCD_DATA <= "i";
                            5'd8:  LCD_DATA <= "m";
                            5'd9:  LCD_DATA <= "e";
                            default: LCD_DATA <= " ";
                        endcase

                        if (char_cnt == 5'd15) begin
                            char_cnt <= 5'd0;
                            state    <= LINE2;
                        end
                    end
                end

                //--------------------------------------------------
                // LINE2 : "HH:MM" (알람 시각)
                //   -> char_cnt==0 에서 DDRAM 주소 0xC0으로 이동
                //--------------------------------------------------
                LINE2: begin
                    if (cnt < 10'd30) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt      <= 10'd0;
                        char_cnt <= char_cnt + 5'd1;

                        // 첫 사이클은 라인2 시작 주소 설정 (명령)
                        if (char_cnt == 5'd0) begin
                            LCD_RS   <= 1'b0;    // command
                            LCD_RW   <= 1'b0;
                            LCD_DATA <= 8'hC0;   // Set DDRAM address, line2 시작
                        end else begin
                            LCD_RS <= 1'b1;      // 이후부터는 데이터
                            LCD_RW <= 1'b0;
                            case (char_cnt)
                                5'd1: LCD_DATA <= "0" + a_h_ten;  // 시 10의 자리
                                5'd2: LCD_DATA <= "0" + a_h_one;  // 시 1의 자리
                                5'd3: LCD_DATA <= ":";            // 콜론
                                5'd4: LCD_DATA <= "0" + a_m_ten;  // 분 10의 자리
                                5'd5: LCD_DATA <= "0" + a_m_one;  // 분 1의 자리
                                default: LCD_DATA <= " ";
                            endcase
                        end

                        if (char_cnt == 5'd15) begin
                            char_cnt <= 5'd0;
                            state    <= DELAY_T;
                        end
                    end
                end

                //--------------------------------------------------
                // 약간의 딜레이 후 다시 갱신
                //--------------------------------------------------
                DELAY_T: begin
                    if (cnt < 10'd200) begin
                        cnt <= cnt + 10'd1;
                    end else begin
                        cnt   <= 10'd0;
                        state <= CLEAR_DISP;
                    end
                    LCD_RS   <= 1'b0;
                    LCD_RW   <= 1'b0;
                    LCD_DATA <= 8'h02;  // Return Home 등 명령
                end

                default: begin
                    state <= DELAY;
                end
            endcase
        end
    end

endmodule
