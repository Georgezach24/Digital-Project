module calculator (
    input wire clk,
    input wire reset,
    inout wire keyb_clk,
    input wire keyb_data,
    output wire [6:0] seg1,
    output wire [6:0] seg2
);

    reg [3:0] operand1, operand2;
    reg [3:0] result;
    reg operation;
    reg [1:0] state;
    reg error_flag;

    wire [7:0] scan_code;
    wire scan_ready;
    wire [5:0] digit;
    wire valid;

    ps2_keyboard keyboard (
        .clk(clk),
        .reset(reset),
        .keyb_clk(keyb_clk),
        .keyb_data(keyb_data),
        .scan_code(scan_code),
        .scan_ready(scan_ready)
    );

    scan_to_digit decoder (
        .scan_code(scan_code),
        .digit(digit),
        .valid(valid)
    );

    always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= 2'b00;
        operand1 <= 0;
        operand2 <= 0;
        result <= 0;
        error_flag <= 0;
    end else if (scan_ready) begin  
        $display("🟢 FSM ΛΑΜΒΑΝΕΙ scan_ready=1! scan_code=%h | state=%b", scan_code, state);
        case (state)
            2'b00: begin 
                if (valid) begin
                    operand1 <= digit[3:0];  
                    state <= 2'b01;       
                    error_flag <= 0;       
                    $display("✅ STATE 00 -> operand1 = %d", operand1);
                end else begin
                    error_flag <= 1;       
                end
            end

            2'b01: begin 
                if (scan_code == 8'h4E) begin 
                    operation <= 1;
                    state <= 2'b10;
                    $display("✅ STATE 01 -> Operation = '-'");
                end else if (scan_code == 8'h55) begin 
                    operation <= 0;
                    state <= 2'b10;
                    $display("✅ STATE 01 -> Operation = '+'");
                end else begin
                    error_flag <= 1; 
                end
            end

            2'b10: begin 
                if (valid) begin
                    operand2 <= digit[3:0];  
                    state <= 2'b11;       
                    error_flag <= 0;
                    $display("✅ STATE 10 -> operand2 = %d", operand2);
                end else begin
                    error_flag <= 1; 
                end
            end

            2'b11: begin 
                if (scan_code == 8'h5A) begin 
                    if (operand1 == 0 && operand2 == 0) begin
                        error_flag <= 1; 
                    end else begin
                        if (operation == 0)
                            result <= operand1 + operand2;
                        else
                            result <= operand1 - operand2;
                        error_flag <= 0;
                        $display("✅ STATE 11 -> Υπολογισμός ΟΚ: result = %d", result);
                    end
                    state <= 2'b00; 
                end else begin
                    error_flag <= 1; 
                end
            end
        endcase
    end
end



    seven_segment_decoder display1 (
        .digit(error_flag ? 4'b1110 : operand1), 
        .segments(seg1)
    );

    seven_segment_decoder display2 (
        .digit(result),
        .segments(seg2)
    );

endmodule
