module scan_to_digit (
    input wire [7:0] scan_code,  // Scan code από το πληκτρολόγιο
    output reg [5:0] digit,      // Αποκωδικοποιημένος αριθμός (0-9) ή λάθος
    output reg valid             // Δείχνει αν ο scan code είναι έγκυρος αριθμός
);

    always @(*) begin
        case (scan_code)
            8'h45: digit = 6'd0;  // '0'
            8'h16: digit = 6'd1;  // '1'
            8'h1E: digit = 6'd2;  // '2'
            8'h26: digit = 6'd3;  // '3'
            8'h25: digit = 6'd4;  // '4'
            8'h2E: digit = 6'd5;  // '5'
            8'h36: digit = 6'd6;  // '6'
            8'h3D: digit = 6'd7;  // '7'
            8'h3E: digit = 6'd8;  // '8'
            8'h46: digit = 6'd9;  // '9'
            default: digit = 6'b111111; // Λάθος (δεν είναι αριθμός)
        endcase

        // Αν είναι αριθμός (όχι λάθος), κάνουμε valid = 1
        valid = (digit != 6'b111111) ? 1'b1 : 1'b0;
    end

endmodule