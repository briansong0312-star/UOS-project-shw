
module stopwatch_bcd6(
    input  [6:0] min,    
    input  [5:0] sec,     
    input  [6:0] centis,  

    output [3:0] h_ten,
    output [3:0] h_one,
    output [3:0] m_ten,
    output [3:0] m_one,
    output [3:0] s_ten,
    output [3:0] s_one
);
    assign h_ten = min / 10;
    assign h_one = min % 10;

    assign m_ten = sec / 10;
    assign m_one = sec % 10;

    assign s_ten = centis / 10;
    assign s_one = centis % 10;

endmodule

