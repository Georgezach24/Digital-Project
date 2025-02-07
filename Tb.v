`timescale 1ns / 1ps

module tb_calculator;

    reg clk;
    reg reset;
    reg keyb_data;
    wire keyb_clk;  // Χρησιμοποιούμε wire αντί για reg
    wire [6:0] seg1, seg2;

    // Instantiate το κύριο module
    calculator uut (
        .clk(clk),
        .reset(reset),
        .keyb_clk(keyb_clk),
        .keyb_data(keyb_data),
        .seg1(seg1),
        .seg2(seg2)
    );

    // Προσομοίωση ρολογιού 50MHz (20ns περίοδος)
    always #10 clk = ~clk;

    // Task για αποστολή scan code
    task send_scan_code(input [7:0] scan_code);
        integer i;
        begin
            force keyb_clk = 0; // Ξεκινάμε με χαμηλό clock
            keyb_data = 0; // Start bit
            #100;
            
            for (i = 0; i < 8; i = i + 1) begin
                force keyb_clk = 0; #50;
                keyb_data = scan_code[i]; #50;
                force keyb_clk = 1; #50;
            end
            
            force keyb_clk = 0; #50;
            keyb_data = 1; // Parity bit
            force keyb_clk = 1; #50;
            force keyb_clk = 0; #50;
            keyb_data = 1; // Stop bit
            force keyb_clk = 1; #50;

            release keyb_clk; // Επιστρέφουμε τον έλεγχο στο module
        end
    endtask

    initial begin
        // Αρχικοποίηση
        clk = 0;
        reset = 1;
        keyb_data = 1;
        #200;
        reset = 0;
        #200;

        // 1 + 2 =
        send_scan_code(8'h16);  // '1'
        #500;
        send_scan_code(8'h55);  // '+'
        #500;
        send_scan_code(8'h1E);  // '2'
        #500;
        send_scan_code(8'h5A);  // '='
        #1000;

        // 5 - 3 =
        send_scan_code(8'h2E);  // '5'
        #500;
        send_scan_code(8'h4E);  // '-'
        #500;
        send_scan_code(8'h26);  // '3'
        #500;
        send_scan_code(8'h5A);  // '='
        #1000;

        // Δοκιμή σφάλματος
        send_scan_code(8'h55);  // '+'
        #500;
        send_scan_code(8'h4E);  // '-'
        #500;
        send_scan_code(8'h1E);  // '2'
        #500;
        send_scan_code(8'h5A);  // '='
        #1000;

    end

endmodule
