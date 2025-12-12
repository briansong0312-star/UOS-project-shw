module world_clock_top(
    input        clk,            
    input        rst,            
    input        mode_alarm_sw,      
    input        stopwatch_mode_sw,  
    input        timer_mode_sw,      
    input        adj_min_btn,
    input        adj_hour_btn,
    input        mode_toggle_btn,
    input        paris_btn,
    input        ny_btn,
    input        uk_btn,
    input        korea_btn,
    input        alarm_toggle_btn,
    input        alarm_stop_btn,
    input        timer_clear_btn,
    
    output [7:0] seg_data,
    output [7:0] seg_com,
    output       LCD_E,
    output       LCD_RS,
    output       LCD_RW,
    output [7:0] LCD_DATA,
    output [7:0] LED,
    output       BUZZER,
    output [3:0] RGB_R,
    output [3:0] RGB_G,
    output [3:0] RGB_B
);

    wire [9:0] btn_trig;

    oneshot_universal #(.WIDTH(10)) U_OS (
        .clk     (clk),
        .rst     (rst),
        .btn     ({adj_min_btn,    adj_hour_btn,   mode_toggle_btn,
                   paris_btn,      ny_btn,         uk_btn,       korea_btn,
                   alarm_toggle_btn, alarm_stop_btn, timer_clear_btn}),
        .btn_trig(btn_trig)
    );

    wire adj_min_p       = btn_trig[9];
    wire adj_hour_p      = btn_trig[8];
    wire mode_toggle_p   = btn_trig[7];
    wire paris_p         = btn_trig[6];
    wire ny_p            = btn_trig[5];
    wire uk_p            = btn_trig[4];
    wire korea_p         = btn_trig[3];
    wire alarm_toggle_p  = btn_trig[2];
    wire alarm_stop_p    = btn_trig[1];
    wire timer_clear_raw = btn_trig[0];

    wire in_timer_mode     = timer_mode_sw;
    wire in_stopwatch_mode = (~timer_mode_sw) && stopwatch_mode_sw;
    wire in_clock_alarm    = (~timer_mode_sw) && (~stopwatch_mode_sw);

 
    wire clk_clear_time_p =
        (in_clock_alarm && (mode_alarm_sw == 1'b0)) ? timer_clear_raw : 1'b0;


    wire timer_clear_p = in_timer_mode ? timer_clear_raw : 1'b0;


    wire clk_hour_set_p;
    wire clk_min_set_p;
    wire alarm_hour_set_p;
    wire alarm_min_set_p;

    assign clk_hour_set_p   = (in_clock_alarm && (mode_alarm_sw == 1'b0)) ? adj_hour_p : 1'b0;
    assign clk_min_set_p    = (in_clock_alarm && (mode_alarm_sw == 1'b0)) ? adj_min_p  : 1'b0;
    assign alarm_hour_set_p = (in_clock_alarm && (mode_alarm_sw == 1'b1)) ? adj_hour_p : 1'b0;
    assign alarm_min_set_p  = (in_clock_alarm && (mode_alarm_sw == 1'b1)) ? adj_min_p  : 1'b0;

  
    wire sw_start_stop_p = in_stopwatch_mode ? adj_min_p       : 1'b0;
    wire sw_lap_p        = in_stopwatch_mode ? adj_hour_p      : 1'b0;
    wire sw_reset_p      = in_stopwatch_mode ? timer_clear_raw : 1'b0;

   
    wire timer_min_set_p    = in_timer_mode ? adj_min_p      : 1'b0;
    wire timer_sec_set_p    = in_timer_mode ? adj_hour_p     : 1'b0;
    wire timer_start_stop_p = in_timer_mode ? alarm_toggle_p : 1'b0;
    wire timer_reset_p      = in_timer_mode ? alarm_stop_p   : 1'b0;
    wire alarm_toggle_eff   = in_clock_alarm ? alarm_toggle_p : 1'b0;
    wire alarm_stop_eff     = in_clock_alarm ? alarm_stop_p   : 1'b0;
    wire alarm_clear_time_p = (in_clock_alarm && (mode_alarm_sw == 1'b1)) ? timer_clear_raw : 1'b0;

    wire [5:0] sec;
    wire [5:0] min;
    wire [4:0] hour_kst;

    time_base U_TIME (
        .clk         (clk),
        .rst         (rst),
        .adj_min_p   (clk_min_set_p),
        .adj_hour_p  (clk_hour_set_p),
        .clear_time_p(clk_clear_time_p),  
        .sec         (sec),
        .min         (min),
        .hour        (hour_kst)
    );


    wire       mode_12h;
    wire [1:0] tz_sel;

    tz_mode_ctrl U_MODE (
        .clk          (clk),
        .rst          (rst),
        .mode_toggle_p(mode_toggle_p),
        .paris_p      (paris_p),
        .ny_p         (ny_p),
        .uk_p         (uk_p),
        .korea_p      (korea_p),
        .mode_12h     (mode_12h),
        .tz_sel       (tz_sel)
    );

    wire [4:0] hour24;

    world_time_calc U_WT (
        .hour_kst(hour_kst),
        .tz_sel  (tz_sel),
        .hour24  (hour24)
    );
    wire [4:0] hour_disp;
    wire       is_pm;

    hour12_24 U_HMODE (
        .hour24   (hour24),
        .mode_12h (mode_12h),
        .hour_disp(hour_disp),
        .is_pm    (is_pm)
    );

    wire [4:0] disp_hour_wc;
    wire [5:0] disp_min_wc;
    wire [5:0] disp_sec_wc;

    wire [4:0] alarm_hour;
    wire [5:0] alarm_min;

    assign disp_hour_wc = (mode_alarm_sw == 1'b1) ? alarm_hour : hour_disp;
    assign disp_min_wc  = (mode_alarm_sw == 1'b1) ? alarm_min  : min;
    assign disp_sec_wc  = (mode_alarm_sw == 1'b1) ? 6'd0       : sec;


    wire [3:0] h_ten_wc, h_one_wc;
    wire [3:0] m_ten_wc, m_one_wc;
    wire [3:0] s_ten_wc, s_one_wc;

    hms_to_bcd U_BCD_WC (
        .hour_disp(disp_hour_wc),
        .min      (disp_min_wc),
        .sec      (disp_sec_wc),
        .h_ten    (h_ten_wc),
        .h_one    (h_one_wc),
        .m_ten    (m_ten_wc),
        .m_one    (m_one_wc),
        .s_ten    (s_ten_wc),
        .s_one    (s_one_wc)
    );

    wire [6:0] sw_min;
    wire [5:0] sw_sec;
    wire [6:0] sw_centis;

    wire [6:0] lap_min;
    wire [5:0] lap_sec;
    wire [6:0] lap_centis;
    wire       lap_valid;

    stopwatch_core U_SW (
        .clk         (clk),
        .rst         (rst),
        .sw_mode     (in_stopwatch_mode),
        .start_stop_p(sw_start_stop_p),
        .lap_p       (sw_lap_p),
        .reset_p     (sw_reset_p),
        .sw_min      (sw_min),
        .sw_sec      (sw_sec),
        .sw_centis   (sw_centis),
        .lap_min     (lap_min),
        .lap_sec     (lap_sec),
        .lap_centis  (lap_centis),
        .lap_valid   (lap_valid)
    );

    wire [3:0] h_ten_sw, h_one_sw;
    wire [3:0] m_ten_sw, m_one_sw;
    wire [3:0] s_ten_sw, s_one_sw;

    stopwatch_bcd6 U_SW_BCD (
        .min    (sw_min),
        .sec    (sw_sec),
        .centis (sw_centis),
        .h_ten  (h_ten_sw),
        .h_one  (h_one_sw),
        .m_ten  (m_ten_sw),
        .m_one  (m_one_sw),
        .s_ten  (s_ten_sw),
        .s_one  (s_one_sw)
    );

    wire [3:0] lap_m_ten, lap_m_one;
    wire [3:0] lap_s_ten, lap_s_one;
    wire [3:0] lap_c_ten, lap_c_one;

    stopwatch_bcd6 U_LAP_BCD (
        .min    (lap_min),
        .sec    (lap_sec),
        .centis (lap_centis),
        .h_ten  (lap_m_ten),
        .h_one  (lap_m_one),
        .m_ten  (lap_s_ten),
        .m_one  (lap_s_one),
        .s_ten  (lap_c_ten),
        .s_one  (lap_c_one)
    );

    wire [6:0] tm_min;
    wire [5:0] tm_sec;
    wire [6:0] tm_centis;
    wire       timer_running;
    wire       timer_done;

    wire [6:0] set_min_val;
    wire [5:0] set_sec_val;

    timer_core U_TIMER (
        .clk           (clk),
        .rst           (rst),
        .timer_mode    (in_timer_mode),
        .min_set_p     (timer_min_set_p),
        .sec_set_p     (timer_sec_set_p),
        .start_stop_p  (timer_start_stop_p),
        .reset_p       (timer_reset_p),
        .clear_set_p   (timer_clear_p),
        .tm_min        (tm_min),
        .tm_sec        (tm_sec),
        .tm_centis     (tm_centis),
        .timer_running (timer_running),
        .timer_done    (timer_done),
        .set_min_val   (set_min_val),
        .set_sec_val   (set_sec_val)
    );

    wire [3:0] h_ten_tm, h_one_tm;
    wire [3:0] m_ten_tm, m_one_tm;
    wire [3:0] s_ten_tm, s_one_tm;

    stopwatch_bcd6 U_TIMER_BCD (
        .min    (tm_min),
        .sec    (tm_sec),
        .centis (tm_centis),
        .h_ten  (h_ten_tm),
        .h_one  (h_one_tm),
        .m_ten  (m_ten_tm),
        .m_one  (m_one_tm),
        .s_ten  (s_ten_tm),
        .s_one  (s_one_tm)
    );

    wire [3:0] set_h_ten, set_h_one;
    wire [3:0] set_m_ten, set_m_one;
    wire [3:0] set_s_ten, set_s_one;

    stopwatch_bcd6 U_TIMERSET_BCD (
        .min    (set_min_val),
        .sec    (set_sec_val),
        .centis (7'd0),
        .h_ten  (set_h_ten),
        .h_one  (set_h_one),
        .m_ten  (set_m_ten),
        .m_one  (set_m_one),
        .s_ten  (set_s_ten),
        .s_one  (set_s_one)
    );

    wire [3:0] h_ten, h_one, m_ten, m_one, s_ten, s_one;

    assign h_ten = in_timer_mode     ? h_ten_tm :
                   in_stopwatch_mode ? h_ten_sw :
                                       h_ten_wc;

    assign h_one = in_timer_mode     ? h_one_tm :
                   in_stopwatch_mode ? h_one_sw :
                                       h_one_wc;

    assign m_ten = in_timer_mode     ? m_ten_tm :
                   in_stopwatch_mode ? m_ten_sw :
                                       m_ten_wc;

    assign m_one = in_timer_mode     ? m_one_tm :
                   in_stopwatch_mode ? m_one_sw :
                                       m_one_wc;

    assign s_ten = in_timer_mode     ? s_ten_tm :
                   in_stopwatch_mode ? s_ten_sw :
                                       s_ten_wc;

    assign s_one = in_timer_mode     ? s_one_tm :
                   in_stopwatch_mode ? s_one_sw :
                                       s_one_wc;

    seg6_driver U_SEG (
        .clk     (clk),
        .rst     (rst),
        .h_ten   (h_ten),
        .h_one   (h_one),
        .m_ten   (m_ten),
        .m_one   (m_one),
        .s_ten   (s_ten),
        .s_one   (s_one),
        .seg_data(seg_data),
        .seg_com (seg_com)
    );

    wire alarm_en;
    wire alarm_ringing;

    alarm_ctrl U_ALARM (
        .clk          (clk),
        .rst          (rst),
        .cur_hour     (hour24),   
        .cur_min      (min),
        .cur_sec      (sec),
        .set_h_p      (alarm_hour_set_p),
        .set_m_p      (alarm_min_set_p),
        .toggle_p     (alarm_toggle_eff),
        .stop_p       (alarm_stop_eff),
        .clear_time_p (alarm_clear_time_p),
        .alarm_hour   (alarm_hour),
        .alarm_min    (alarm_min),
        .alarm_en     (alarm_en),
        .alarm_ringing(alarm_ringing)
    );

    wire [4:0] alarm_hour_disp;
    wire       alarm_is_pm;

    hour12_24 U_ALARM_HMODE (
        .hour24   (alarm_hour),
        .mode_12h (mode_12h),
        .hour_disp(alarm_hour_disp),
        .is_pm    (alarm_is_pm)
    );

    wire [3:0] a_h_ten, a_h_one, a_m_ten, a_m_one;
    wire [3:0] a_s_ten, a_s_one;

    hms_to_bcd U_BCD_ALARM (
        .hour_disp(alarm_hour_disp),
        .min      (alarm_min),
        .sec      (6'd0),
        .h_ten    (a_h_ten),
        .h_one    (a_h_one),
        .m_ten    (a_m_ten),
        .m_one    (a_m_one),
        .s_ten    (a_s_ten),
        .s_one    (a_s_one)
    );

    wire alarm_or_timer = (alarm_ringing || timer_done);

    wire buzzer_melody;
    melody_buzzer U_MELO (
        .clk   (clk),
        .rst   (rst),
        .play  (alarm_or_timer),
        .buzzer(buzzer_melody)
    );

    wire alarm_timer_blink = alarm_or_timer & ~sec[0];

    assign LED[0]   = alarm_en;
    assign LED[7:1] = {7{alarm_timer_blink}};
    assign BUZZER   = buzzer_melody & alarm_timer_blink;

    reg [15:0] blink_cnt;
    reg [9:0]  done_cnt;
    reg        done_blink;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            blink_cnt  <= 16'd0;
            done_cnt   <= 10'd0;
            done_blink <= 1'b0;
        end else begin
            if (in_timer_mode && timer_running) blink_cnt <= blink_cnt + 16'd1;
            else                                blink_cnt <= 16'd0;

            if (in_timer_mode && timer_done) begin
                if (done_cnt >= 10'd350) begin
                    done_cnt   <= 10'd0;
                    done_blink <= ~done_blink;
                end else begin
                    done_cnt <= done_cnt + 10'd1;
                end
            end else begin
                done_cnt   <= 10'd0;
                done_blink <= 1'b0;
            end
        end
    end

    wire blink_slow = blink_cnt[9];
    wire blink_mid  = blink_cnt[8];
    wire blink_fast = blink_cnt[7];

    reg base_r, base_g, base_b;

    always @(*) begin
        base_r = 1'b0; base_g = 1'b0; base_b = 1'b0;

        if (in_timer_mode) begin
            if (timer_done) begin
                base_r = done_blink;
            end else if (timer_running) begin
                if ((tm_min > 0) || (tm_sec > 6'd5)) begin
                    base_g = blink_slow;
                end else if ((tm_min == 0) && (tm_sec > 6'd1)) begin
                    base_r = blink_mid;
                    base_g = blink_mid;
                end else begin
                    base_r = blink_fast;
                end
            end
        end
    end

    assign RGB_R = {4{base_r}};
    assign RGB_G = {4{base_g}};
    assign RGB_B = {4{base_b}};

    reg [12:0] lcd_alt_cnt;
    reg        lcd_show_alarm;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lcd_alt_cnt    <= 13'd0;
            lcd_show_alarm <= 1'b0;
        end else begin
            if (!(in_clock_alarm && (mode_alarm_sw == 1'b0) && alarm_en)) begin
                lcd_alt_cnt    <= 13'd0;
                lcd_show_alarm <= 1'b0;
            end else begin
                if (lcd_alt_cnt >= 13'd4999) begin
                    lcd_alt_cnt    <= 13'd0;
                    lcd_show_alarm <= ~lcd_show_alarm;
                end else begin
                    lcd_alt_cnt <= lcd_alt_cnt + 13'd1;
                end
            end
        end
    end

    wire LCD_E_wc, LCD_RS_wc, LCD_RW_wc;
    wire [7:0] LCD_DATA_wc;

    lcd_worldclock U_LCD_WORLD (
        .clk        (clk),
        .rst        (rst),
        .mode_12h   (mode_12h),
        .tz_sel     (tz_sel),
        .is_pm      (is_pm),
        .alarm_mode (mode_alarm_sw),

        .alarm_en   (alarm_en),
        .show_alarm (lcd_show_alarm),

        .cur_h_ten  (h_ten_wc),
        .cur_h_one  (h_one_wc),
        .cur_m_ten  (m_ten_wc),
        .cur_m_one  (m_one_wc),
        .cur_s_ten  (s_ten_wc),
        .cur_s_one  (s_one_wc),

        .alarm_h_ten(a_h_ten),
        .alarm_h_one(a_h_one),
        .alarm_m_ten(a_m_ten),
        .alarm_m_one(a_m_one),
        .alarm_is_pm(alarm_is_pm),

        .LCD_E      (LCD_E_wc),
        .LCD_RS     (LCD_RS_wc),
        .LCD_RW     (LCD_RW_wc),
        .LCD_DATA   (LCD_DATA_wc)
    );

    wire LCD_E_sw, LCD_RS_sw, LCD_RW_sw;
    wire [7:0] LCD_DATA_sw;

    lcd_stopwatch U_LCD_SW (
        .clk        (clk),
        .rst        (rst),
        .sw_mode    (in_stopwatch_mode),
        .lap_valid  (lap_valid),
        .lap_m_ten  (lap_m_ten),
        .lap_m_one  (lap_m_one),
        .lap_s_ten  (lap_s_ten),
        .lap_s_one  (lap_s_one),
        .lap_c_ten  (lap_c_ten),
        .lap_c_one  (lap_c_one),
        .LCD_E      (LCD_E_sw),
        .LCD_RS     (LCD_RS_sw),
        .LCD_RW     (LCD_RW_sw),
        .LCD_DATA   (LCD_DATA_sw)
    );

    wire LCD_E_tm, LCD_RS_tm, LCD_RW_tm;
    wire [7:0] LCD_DATA_tm;

    lcd_timer U_LCD_TIMER (
        .clk        (clk),
        .rst        (rst),
        .timer_mode (in_timer_mode),
        .tm_m_ten   (set_h_ten),
        .tm_m_one   (set_h_one),
        .tm_s_ten   (set_m_ten),
        .tm_s_one   (set_m_one),
        .tm_c_ten   (set_s_ten),
        .tm_c_one   (set_s_one),
        .LCD_E      (LCD_E_tm),
        .LCD_RS     (LCD_RS_tm),
        .LCD_RW     (LCD_RW_tm),
        .LCD_DATA   (LCD_DATA_tm)
    );

    assign LCD_E    = in_timer_mode     ? LCD_E_tm    :
                      in_stopwatch_mode ? LCD_E_sw    :
                                          LCD_E_wc;

    assign LCD_RS   = in_timer_mode     ? LCD_RS_tm   :
                      in_stopwatch_mode ? LCD_RS_sw   :
                                          LCD_RS_wc;

    assign LCD_RW   = in_timer_mode     ? LCD_RW_tm   :
                      in_stopwatch_mode ? LCD_RW_sw   :
                                          LCD_RW_wc;

    assign LCD_DATA = in_timer_mode     ? LCD_DATA_tm :
                      in_stopwatch_mode ? LCD_DATA_sw :
                                          LCD_DATA_wc;

endmodule
