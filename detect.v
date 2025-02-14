module ps2_keyboard (
    input wire clk,         
    input wire reset,       
    inout wire keyb_clk,    
    input wire keyb_data,   
    output reg [7:0] scan_code,  
    output reg scan_ready   
);

    reg [10:0] data_shift_reg; 
    reg keyb_clk_last;
    reg [3:0] bit_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_shift_reg <= 11'b11111111111;
            scan_ready <= 0;
            bit_count <= 0;
        end else begin
            keyb_clk_last <= keyb_clk; 

            // ✅ Ανίχνευση αρνητικής ακμής του keyb_clk
            if (keyb_clk_last == 1 && keyb_clk == 0) begin
                data_shift_reg <= {keyb_data, data_shift_reg[10:1]}; 
                bit_count <= bit_count + 1;
                $display("🔹 [ps2_keyboard] Bit %d received: %b", bit_count, keyb_data);
            end

            // ✅ Όταν έχουμε λάβει 11 bits, αποθηκεύουμε το scan code
            if (bit_count == 11) begin
                scan_code <= data_shift_reg[8:1];  
                scan_ready <= 1;  
                $display("🟢 [ps2_keyboard] scan_ready=1! scan_code=%h", scan_code);
                bit_count <= 0;  
            end else begin
                scan_ready <= 0;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
    if (reset) begin
        scan_ready <= 0;
    end else begin
        if (scan_ready) begin
            $display("🟢 [DEBUG] scan_ready έγινε 1! scan_code = %h", scan_code);
        end
    end
end

endmodule
