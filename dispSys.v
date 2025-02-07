module keyboard_display_system (
    input wire clk,         // Ρολόι συστήματος
    input wire reset,       // Reset button
    inout wire keyb_clk,    // Ρολόι πληκτρολογίου PS/2
    input wire keyb_data,   // Δεδομένα πληκτρολογίου PS/2
    output wire [6:0] seg   // Έξοδοι για το 7-segment display
);

    wire [7:0] scan_code;    // Scan code από το πληκτρολόγιο
    wire scan_ready;         // Flag που δείχνει ότι λήφθηκε scan code
    wire [5:0] digit;        // Αποκωδικοποιημένος αριθμός
    wire valid;              // Έγκυρο πλήκτρο ή όχι

    // Module επικοινωνίας με το πληκτρολόγιο PS/2
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

    // Module αποκωδικοποίησης αριθμού σε 7-segment display
    seven_segment_decoder display (
        .digit(digit[3:0]),  // Χρησιμοποιούμε μόνο τα 4 LSB bits
        .segments(seg)
    );

endmodule
