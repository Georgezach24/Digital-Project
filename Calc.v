module calculator (
    input wire clk,              // Ρολόι συστήματος
    input wire reset,            // Reset button
    inout wire keyb_clk,         // Ρολόι πληκτρολογίου PS/2
    input wire keyb_data,        // Δεδομένα πληκτρολογίου PS/2
    output wire [6:0] seg1,      // 7-segment display για 1ο νούμερο ή error
    output wire [6:0] seg2       // 7-segment display για αποτέλεσμα
);

    reg [3:0] operand1, operand2;  // Δύο αριθμοί (τελεστέοι)
    reg [3:0] result;              // Καταχωρητής για το αποτέλεσμα
    reg operation;                 // 0 = πρόσθεση, 1 = αφαίρεση
    reg [1:0] state;               // FSM κατάσταση
    reg error_flag;                 // Σημαία σφάλματος

    wire [7:0] scan_code;
    wire scan_ready;
    wire [5:0] digit;
    wire valid;

    // Module PS/2 πληκτρολογίου
    ps2_keyboard keyboard (
        .clk(clk),
        .reset(reset),
        .keyb_clk(keyb_clk),
        .keyb_data(keyb_data),
        .scan_code(scan_code),
        .scan_ready(scan_ready)
    );

    // Module αποκωδικοποίησης scan code σε αριθμό
    scan_to_digit decoder (
        .scan_code(scan_code),
        .digit(digit),
        .valid(valid)
    );

    // FSM για τον έλεγχο της ροής και διαχείριση σφαλμάτων
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 2'b00;
            operand1 <= 0;
            operand2 <= 0;
            result <= 0;
            error_flag <= 0;
        end else if (scan_ready) begin
            case (state)
                2'b00: begin // WAIT_OPERAND1
                    if (valid) begin
                        operand1 <= digit[3:0]; // Αποθήκευση πρώτου αριθμού
                        state <= 2'b01;         // Μετάβαση σε WAIT_OPERATOR
                        error_flag <= 0;        // Καθαρισμός σφάλματος
                    end else begin
                        error_flag <= 1;        // Αν δεν είναι αριθμός -> Σφάλμα
                    end
                end

                2'b01: begin // WAIT_OPERATOR
                    if (scan_code == 8'h4E) begin // Αν πατήθηκε '-'
                        operation <= 1;
                        state <= 2'b10;
                    end else if (scan_code == 8'h55) begin // Αν πατήθηκε '+'
                        operation <= 0;
                        state <= 2'b10;
                    end else begin
                        error_flag <= 1; // Αν δεν είναι έγκυρος τελεστής -> Σφάλμα
                    end
                end

                2'b10: begin // WAIT_OPERAND2
                    if (valid) begin
                        operand2 <= digit[3:0]; // Αποθήκευση δεύτερου αριθμού
                        state <= 2'b11;         // Μετάβαση σε WAIT_EQ
                        error_flag <= 0;
                    end else begin
                        error_flag <= 1; // Αν δεν είναι αριθμός -> Σφάλμα
                    end
                end

                2'b11: begin // WAIT_EQ
                    if (scan_code == 8'h5A) begin // Αν πατήθηκε '='
                        if (operand1 == 0 && operand2 == 0) begin
                            error_flag <= 1; // Αν δεν υπάρχουν αριθμοί -> Σφάλμα
                        end else begin
                            if (operation == 0)
                                result <= operand1 + operand2; // Πρόσθεση
                            else
                                result <= operand1 - operand2; // Αφαίρεση
                            error_flag <= 0;
                        end
                        state <= 2'b00; // Επιστροφή στην αρχή
                    end else begin
                        error_flag <= 1; // Αν πατήθηκε λάθος πλήκτρο στο σημείο αυτό
                    end
                end
            endcase
        end
    end

    // Module αποκωδικοποίησης αριθμού σε 7-segment display
    seven_segment_decoder display1 (
        .digit(error_flag ? 4'b1110 : operand1), // Αν υπάρχει σφάλμα, εμφανίζει 'E'
        .segments(seg1)
    );

    seven_segment_decoder display2 (
        .digit(result),
        .segments(seg2)
    );

endmodule
