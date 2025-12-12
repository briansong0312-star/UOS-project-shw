module seg_decoder(
    input  [3:0] bcd,
    output [7:0] seg_data
);
    reg [7:0] seg_data;
    always @(bcd) begin
        case (bcd)
            4'h0: seg_data = 8'b1111_1100;  // '0
            4'h1: seg_data = 8'b0110_0000;  // '1
            4'h2: seg_data = 8'b1101_1010;  // '2
            4'h3: seg_data = 8'b1111_0010;  // '3
            4'h4: seg_data = 8'b0110_0110;  // '4
            4'h5: seg_data = 8'b1011_0110;  // '5
            4'h6: seg_data = 8'b1011_1110;  // '6
            4'h7: seg_data = 8'b1110_0000;  // '7
            4'h8: seg_data = 8'b1111_1110;  // '8
            4'h9: seg_data = 8'b1111_0110;  // '9
            4'hA: seg_data = 8'b1110_1110;  // 'A
            4'hB: seg_data = 8'b0011_1110;  // 'b
            4'hC: seg_data = 8'b1001_1100;  // 'C
            4'hD: seg_data = 8'b0111_1010;  // 'd
            4'hE: seg_data = 8'b1001_1110;  // 'E
            4'hF: seg_data = 8'b1000_1110;  // 'F
        endcase
    end
endmodule