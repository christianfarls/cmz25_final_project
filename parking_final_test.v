module user_proj_parking_tb();

    reg clk;
    reg reset;
    reg [7:0] passcode_in;
    reg enter_req;
    reg exit_req;
    wire [4:0] car_count;
    wire entry_gate_open;
    wire exit_gate_open;

    // Instantiate the unit under test
    user_proj_parking dut (
        .clk(clk),
        .reset(reset),
        .passcode_in(passcode_in),
        .enter_req(enter_req),
        .exit_req(exit_req),
        .car_count(car_count),
        .entry_gate_open(entry_gate_open),
        .exit_gate_open(exit_gate_open)
    );

    // clock generation for testing circuit logic
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock equivalent
    end

    initial begin
        // Initialize signals
        reset        = 1;
        passcode_in  = 8'b00000000;
        enter_req    = 0;
        exit_req     = 0;

        // Release reset
        #20 reset = 0;

        // case 1 entering with right passcode
        passcode_in = 8'b11111111;
        enter_req = 1;
        #10 enter_req = 0;
        #50;
        $display("Test case - car tries entering with right password - car count: %d", car_count);
        $display("expecting 1, received %d", car_count);

        // case 2 entering with wrong passcode
        passcode_in = 8'b00000000;
        enter_req = 1;
        #10 enter_req = 0;
        #50;
        $display("Car count: %d", car_count);
        $display("Test case - car tries entering with wrong password - car count: %d", car_count);
        $display("expecting 1, received %d", car_count);

        // case 3 multiple entries repetitively
        repeat(5) begin
            passcode_in = 8'b11111111;
            enter_req = 1;
            #10 enter_req = 0;
            #50;
        end
        $display("Test case - 5 cars repeatedly enter with right password - car count: %d", car_count);
        $display("expecting 6, received %d", car_count);

        // case 4 car leaves the parking lot
        exit_req = 1;
        #10 exit_req = 0;
        #50;
        $display("Test case - 1 car leaves the parking lot");
        $display("Car count: %d", car_count);
        $display("expecting 5, received %d", car_count);

        // fill up to 20 cars
        // case 5 - filling up lot until 20 cars
        while (car_count < 20) begin
            passcode_in = 8'b11111111;
            enter_req = 1;
            #10 enter_req = 0;
            #50;
            //$display("Car count: %d", car_count);
        end
        $display("Test case - 20 cars in lot (filled capacity)");
        $display("expecting 20, received %d", car_count);

        // case 6attempt another entry at full capacity (should fail)
        passcode_in = 8'b11111111;
        enter_req = 1;
        #10 enter_req = 0;
        #50;
        $display("Test case - another car tries to enter when lot is full");
        $display("Car count: %d", car_count);
        $display("expecting 20, received %d", car_count);


        // case 7 cars until lot is empty
        while (car_count > 0) begin
            exit_req = 1;
            #10 exit_req = 0;
            #50;
        end
        $display("Test case - cars exit until the lot is empty");
        $display("expecting 0, received %d", car_count);

        //case 8 - lot is currently empty, then a random amount of cars enter and exit, some with correct passcodes, some fail, this is suppsoed to test it big time.
        
        //first car correct
        $display("car one success");
        passcode_in = 8'b11111111;
        enter_req = 1;
        #10 enter_req = 0;
        #50;
        $display("expecting 1, received %d", car_count);

        // fail
        $display("car 2 fail");
        passcode_in = 8'b11111110;
        enter_req = 1;
        #10 enter_req = 0;
        #50;
        $display("expecting 1, received %d", car_count);

        //fail
        $display("car 3 fail");
        passcode_in = 8'b11101111;
        enter_req = 1;
        #10 enter_req = 0;
        #50;
        $display("expecting 1, received %d", car_count);

        // car enter success
        $display("car 4 success");
        passcode_in = 8'b11111111;
        enter_req = 1;
        #10 enter_req = 0;
        #50;
        $display("status check");
        $display("expecting 2, received %d", car_count);

        //1 car leaves
        $display("one car leaves");
        exit_req = 1;
        #10 exit_req = 0;
        #50;
        $display("expecting 1, received %d", car_count);

        // 4 cars enter then 1 car leaves
        $display("4 enter, 1 car leaves");
        repeat(4) begin
            passcode_in = 8'b11111111;
            enter_req = 1;
            #10 enter_req = 0;
            #50;
        end
        exit_req = 1;
        #10 exit_req = 0;
        #50;
        $display("expecting 4, received %d", car_count);

        // End simulation
        #100 $finish;
    end

endmodule
