module seg6_driver(
    input        clk,
    input        rst,
    input  [3:0] h_ten, h_one,
    input  [3:0] m_ten, m_one,
    input  [3:0] s_ten, s_one,
    output [7:0] seg_data,
    output [7:0] seg_com
);
    reg [2:0] s_cnt;
    reg [7:0] seg_data_r, seg_com_r;

    assign seg_data = seg_data_r;
    assign seg_com  = seg_com_r;


    wire [7:0] seg_h_ten, seg_h_one;
    wire [7:0] seg_m_ten, seg_m_one;
    wire [7:0] seg_s_ten, seg_s_one;

    seg_decoder U0(h_ten, seg_h_ten);  
    seg_decoder U1(h_one, seg_h_one); 
    seg_decoder U2(m_ten, seg_m_ten);  
    seg_decoder U3(m_one, seg_m_one);  
    seg_decoder U4(s_ten, seg_s_ten);  
    seg_decoder U5(s_one, seg_s_one);  


    always @(posedge clk or posedge rst)
        if (rst) s_cnt <= 3'd0;
        else     s_cnt <= s_cnt + 3'd1;


    always @(posedge clk or posedge rst) begin
        if (rst) seg_com_r <= 8'b1111_1111;
        else begin
            case (s_cnt)
                3'd0: seg_com_r <= 8'b1111_0111; 
                3'd1: seg_com_r <= 8'b1111_1011; 
                3'd2: seg_com_r <= 8'b1111_1101; 
                3'd3: seg_com_r <= 8'b1111_1110;
                3'd4: seg_com_r <= 8'b1110_1111; 
                3'd5: seg_com_r <= 8'b1101_1111; 
                default: seg_com_r <= 8'b1111_1111;
            endcase
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) seg_data_r <= 8'b0000_0000;
        else begin
            case (s_cnt)
                3'd0: seg_data_r <= seg_h_ten; // 시 십
                3'd1: seg_data_r <= seg_h_one; // 시 일
                3'd2: seg_data_r <= seg_m_ten; // 분 십
                3'd3: seg_data_r <= seg_m_one; // 분 일
                3'd4: seg_data_r <= seg_s_ten; // 초 십
                3'd5: seg_data_r <= seg_s_one; // 초 일
                default: seg_data_r <= 8'b0000_0000;
            endcase
        end
    end
endmodule
