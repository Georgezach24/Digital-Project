module ps2_keyboard_display (
    input clk, reset,
    inout keyb_clk,
    input keyb_data,
    output reg [6:0] hex_display,
    output reg [7:0] scan_code  // Προσθήκη scan_code ως έξοδος
);

    reg [5:0] clk_shift_reg;
    reg [10:0] keyb_data_reg;
    reg [7:0] scan_code;
    reg [3:0] number;

    assign keyb_clk = (keyb_data_reg[0] == 1'b0) ? 1'b0 : 1'b1;


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_shift_reg <= 6'b000000;
            keyb_data_reg <= 11'b11111111111;
        end else begin
            clk_shift_reg <= {clk_shift_reg[4:0], keyb_clk};
            
            if (clk_shift_reg[5:3] == 3'b000 && clk_shift_reg[2:0] == 3'b111) begin
                keyb_data_reg <= {keyb_data, keyb_data_reg[10:1]};
            end
        end
    end
    
always @(negedge keyb_data_reg[0]) begin
    scan_code <= keyb_data_reg[8:1]; // Αποθήκευση scan code
    $display("Time: %0t | Stored Scan Code: %h", $time, scan_code); // DEBUG
    keyb_data_reg <= 11'b11111111111;
end


    always @(*) begin
    case (scan_code)
        8'h45: number = 4'd0;
        8'h16: number = 4'd1;
        8'h1E: number = 4'd2;
        8'h26: number = 4'd3;
        8'h25: number = 4'd4;
        8'h2E: number = 4'd5;
        8'h36: number = 4'd6;
        8'h3D: number = 4'd7;
        8'h3E: number = 4'd8;
        8'h46: number = 4'd9;
        default: number = 4'd15;
    endcase
    $display("Time: %0t | Scan Code: %h -> Decoded Number: %d", $time, scan_code, number);
end

    
    always @(*) begin
        case (number)
            4'd0: hex_display = 7'b1000000;
            4'd1: hex_display = 7'b1111001;
            4'd2: hex_display = 7'b0100100;
            4'd3: hex_display = 7'b0110000;
            4'd4: hex_display = 7'b0011001;
            4'd5: hex_display = 7'b0010010;
            4'd6: hex_display = 7'b0000010;
            4'd7: hex_display = 7'b1111000;
            4'd8: hex_display = 7'b0000000;
            4'd9: hex_display = 7'b0010000;
            default: hex_display = 7'b1111111;
        endcase
    end
endmodule
