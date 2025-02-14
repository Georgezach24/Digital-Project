`timescale 1ns / 1ps

module tb_calculator;

    reg clk;
    reg reset;
    reg keyb_data;
    wire keyb_clk;  
    wire [6:0] seg1, seg2;

    calculator uut (
        .clk(clk),
        .reset(reset),
        .keyb_clk(keyb_clk),
        .keyb_data(keyb_data),
        .seg1(seg1),
        .seg2(seg2)
    );

    initial clk = 0;
    always #10 clk = ~clk;  // 50MHz clock

    always #2000 force uut.keyboard.scan_ready = 1;
    always #2100 force uut.keyboard.scan_ready = 0;


    // ✅ **Tracking για όλα τα σήματα**
    initial begin
        $monitor("Time: %0t | clk=%b | reset=%b | keyb_clk=%b | keyb_data=%b | seg1=%b | seg2=%b",
                 $time, clk, reset, keyb_clk, keyb_data, seg1, seg2);
    end

    // ✅ **Γεννήτρια PS/2 Clock με `force/release` για να μην είναι `Z`**
    initial begin
        keyb_clk = 1;
        forever #50  keyb_clk = ~keyb_clk;
    end

    task send_scan_code(input [7:0] scan_code);
    integer i;
    begin
        force keyb_clk = 1; 
        keyb_data = 0; // Start bit
        #100;
        $display("🟢 [Testbench] Sending START bit για scan_code=%h", scan_code);

        for (i = 0; i < 8; i = i + 1) begin
            keyb_clk = 0; #50;
            keyb_data = scan_code[i]; #100;
            keyb_clk = 1; #50;
            $display("🔹 [Testbench] Sent bit %d: %b", i, scan_code[i]);  
        end

        keyb_clk = 0; #50;
        keyb_data = 1; // Parity bit
        keyb_clk = 1; #100;
        $display("🟢 [Testbench] Sent parity bit");

        force keyb_clk = 0; #50;
        keyb_data = 1; // Stop bit
        force keyb_clk = 1; #100;
        $display("🟢 [Testbench] Sent stop bit");

        release keyb_clk;  // ✅ ΣΩΣΤΗ ΑΠΕΛΕΥΘΕΡΩΣΗ ΤΟΥ `inout`
        #1000;  
    end
endtask


    // ✅ **Τεστ Εισαγωγής Αριθμών**
    initial begin
        reset = 1;
        keyb_data = 1;
        #1000;
        reset = 0;
        #1000; 

        send_scan_code(8'h16);  // '1'
        #2000;
        send_scan_code(8'h55);  // '+'
        #2000;
        send_scan_code(8'h1E);  // '2'
        #2000;
        send_scan_code(8'h5A);  // '='
        #4000; 

        $stop;
    end

endmodule
