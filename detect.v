module ps2_keyboard (
    input wire clk,          // Εσωτερικό ρολόι συστήματος
    input wire reset,        // Σήμα επαναφοράς
    inout wire keyb_clk,     // Ρολόι πληκτρολογίου (PS/2)
    input wire keyb_data,    // Δεδομένα πληκτρολογίου (PS/2)
    output reg [7:0] scan_code,  // Scan code του πατημένου πλήκτρου
    output reg scan_ready   // Σημαία ότι έχει ληφθεί νέος κωδικός
);

    reg [5:0] clk_shift_reg;   // Shift register για ανίχνευση αρνητικής ακμής του keyb_clk
    reg [10:0] data_shift_reg; // Shift register για αποθήκευση των 11-bit του scan code
    reg keyb_clk_last;         // Χρησιμοποιείται για να ανιχνεύσει αλλαγές στο keyb_clk

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_shift_reg <= 6'b111111;
            data_shift_reg <= 11'b11111111111;
            scan_ready <= 0;
        end else begin
            // Μετακινούμε το shift register για την παρακολούθηση του keyb_clk
            clk_shift_reg <= {clk_shift_reg[4:0], keyb_clk};

            // Αν ανιχνεύσουμε αρνητική ακμή στο keyb_clk (000111)
            if (clk_shift_reg[5:3] == 3'b000 && clk_shift_reg[2:0] == 3'b111) begin
                data_shift_reg <= {keyb_data, data_shift_reg[10:1]}; // Shift δεξιά με νέο bit
            end

            // Όταν το τελευταίο bit του data_shift_reg γίνει 0 -> Scan code received
            if (data_shift_reg[0] == 0) begin
                scan_code <= data_shift_reg[8:1]; // Τα bit 8-1 περιέχουν τον scan code
                scan_ready <= 1; // Σηματοδοτούμε ότι υπάρχει νέος scan code
                data_shift_reg <= 11'b11111111111; // Επαναρχικοποίηση
            end else begin
                scan_ready <= 0;
            end
        end
    end

    // Διαχείριση του keyb_clk ως inout (bidirectional)
    assign keyb_clk = (!data_shift_reg[0]) ? 1'b0 : 1'bz; 

endmodule
