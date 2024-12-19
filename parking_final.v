/********
CSE 30342 - Digital Integrated Circuits - University of Notre Dame

Christian Farls: cfarls@nd.edu

Matt Zagrocki: mzagrock@nd.edu

Danny Mikolay: dmikolay@nd.edu

This Verilog module simulates a parking lot with functionalities
for entering and exiting the lot. The system uses a finite state machine (FSM)
to control the entry and exit gates, validate passcodes, and maintain 
the car count in the lot. The parking lot has a user-set maximum capacity, 
and only valid passcodes can allow cars to enter. The system also ensures 
that a car can exit the lot if there is at least one car present.
*******/

module user_proj_parking (
    input wire clk,
    input wire reset,
    input wire [7:0] passcode_in,
    input wire enter_req,
    input wire exit_req,
    input wire [4:0] max_capacity, //  maximum capacity (can be set by user)
    output reg [4:0] car_count,    // how many cars are in the lot
    output reg entry_gate_open,
    output reg exit_gate_open,
    output reg lot_full            // status flag indicating if lot is full
);

    // parameters
    localparam PASSCODE  = 8'b11111111;  // set passcode (this can be whatever)

    // FSM States
    localparam IDLE        = 3'b000,
               CHECK_ENTRY = 3'b001,
               ENTRY_OPEN  = 3'b010,
               ENTRY_CLOSE = 3'b011,
               CHECK_EXIT  = 3'b100,
               EXIT_OPEN   = 3'b101,
               EXIT_CLOSE  = 3'b110;

    reg [2:0] current_state, next_state;

    // state register
    always @(posedge clk or posedge reset) begin
        if (reset) 
            current_state <= IDLE;
        else 
            current_state <= next_state;
    end

    // next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                // idle - wait for enter_req or exit_req
                if (enter_req) 
                    next_state = CHECK_ENTRY;
                else if (exit_req)
                    next_state = CHECK_EXIT;
                else
                    next_state = IDLE;
            end

            CHECK_ENTRY: begin
                // check if passcode matches and lot not full then you can open the gate
                if ((passcode_in == PASSCODE) && (car_count < max_capacity))
                    next_state = ENTRY_OPEN;
                else
                // if passcode fails or lot is full, go to idle
                    next_state = IDLE;
            end

            ENTRY_OPEN: begin
                // gate open for one cycle
                next_state = ENTRY_CLOSE;
            end

            ENTRY_CLOSE: begin
                // close gate, return to idle
                //can add delay or sensor input for real-world usage
                next_state = IDLE;
            end

            CHECK_EXIT: begin
                // no passcode needed for exit but open the gate if count > 0
                if (car_count > 0)
                    next_state = EXIT_OPEN;
                else
                    next_state = IDLE;
            end

            EXIT_OPEN: begin
                // gate open for one cycle then closes
                next_state = EXIT_CLOSE;
            end

            EXIT_CLOSE: begin
                // close gate, return to idle and wait for entry or exit request
                //can add delay or sensor input for real-world usage
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // output, datapath logic

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            car_count       <= 0;
            entry_gate_open <= 0;
            exit_gate_open  <= 0;
            lot_full        <= 0;
        end else begin
            // default outputs unless otherwise set by fsm. Need them to be zero because we want the gate closed by default
            entry_gate_open <= 0;
            exit_gate_open  <= 0;

            // update the lot_full flag based on current car_count and max_capacity
            if (car_count >= max_capacity)
                lot_full <= 1; // set flag high
            else
                lot_full <= 0;

            case (next_state)
                ENTRY_OPEN: begin
                    entry_gate_open <= 1;
                    // increment the car count when gate opens if not full
                    if (car_count < max_capacity)
                        car_count <= car_count + 1;
                end

                EXIT_OPEN: begin
                    exit_gate_open <= 1;
                    // decrement the car count when gate opens if there are cars present
                    if (car_count > 0)
                        car_count <= car_count - 1;
                end

                default: begin
                    // no action other than defaults : gates closed
                end
            endcase
        end
    end

endmodule
