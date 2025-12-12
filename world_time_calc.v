module world_time_calc(
    input  [4:0] hour_kst,   
    input  [1:0] tz_sel,      
    output reg [4:0] hour24 
);
    reg [4:0] utc_hour;
    reg [5:0] tmp;

    always @(*) begin
    
        if (hour_kst >= 5'd9) utc_hour = hour_kst - 5'd9;
        else                  utc_hour = hour_kst + 5'd15; 

       
        case (tz_sel)
            2'd0: begin 
                tmp = utc_hour + 5'd9;
                if (tmp >= 5'd24) tmp = tmp - 5'd24;
                hour24 = tmp;
            end
            2'd1: begin 
                tmp = utc_hour + 5'd1;
                if (tmp >= 5'd24) tmp = tmp - 5'd24;
                hour24 = tmp;
            end
            2'd2: begin  
                if (utc_hour >= 5'd5) tmp = utc_hour - 5'd5;
                else                  tmp = utc_hour + 5'd19; 
                hour24 = tmp;
            end
            2'd3: begin  
                hour24 = utc_hour;
            end
            default: hour24 = hour_kst;
        endcase
    end
endmodule