module tb_ps2_keyboard_display();
    reg clk, reset;
    reg keyb_data;
    wire keyb_clk;  // Χρήση wire αντί για reg
    wire [6:0] hex_display;
    
    reg keyb_clk_drive; // Χρησιμοποιείται για να οδηγήσουμε το keyb_clk

    ps2_keyboard_display uut (
        .clk(clk),
        .reset(reset),
        .keyb_clk(keyb_clk),
        .keyb_data(keyb_data),
        .hex_display(hex_display)
    );

    initial begin
    $monitor("Time: %0t | Scan Code: %h | Number: %d | HEX Display: %b", 
             $time, uut.scan_code, uut.number, uut.hex_display);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock

        keyb_clk_drive = 1;  // Ξεκινάμε με default τιμή 1
        keyb_data = 1;
    end

    task send_scan_code(input [7:0] scan_code);
    integer i;
    reg [10:0] packet;
    begin
        packet = {1'b0, scan_code, 2'b11}; // Start bit, scan code, parity και stop bit
        $display("Sending Scan Code: %h", scan_code);
        
        for (i = 0; i < 11; i = i + 1) begin
            keyb_data = packet[i];
            keyb_clk_drive = 0; // Καθαρό ρολόι
            #10;
            keyb_clk_drive = 1;
            #10;
                end
        end
    endtask



    initial begin
        reset = 1;
        keyb_clk_drive = 1; // Default κατάσταση του keyb_clk
        keyb_data = 1;
        #20;
        reset = 0;
        
        send_scan_code(8'h16); // Send scan code for '1'
        #100;
        send_scan_code(8'h1E); // Send scan code for '2'
        #100;
        send_scan_code(8'h26); // Send scan code for '3'
        #100;
        send_scan_code(8'h25); // Send scan code for '4'
        #100;
        send_scan_code(8'h2E); // Send scan code for '5'
        #100;
        
        $stop;
    end

    always @(posedge clk) begin
    $display("Time: %0t | keyb_clk: %b | keyb_data: %b", 
             $time, keyb_clk, keyb_data);
    end


always @(posedge clk) begin
    if (uut.scan_code !== 8'h00) begin
        $display("Time: %0t | Received scan code: %h | Decoded Number: %d | HEX Display: %b", 
                 $time, uut.scan_code, uut.number, uut.hex_display);
    end
end


endmodule
