module user_proj_parking (
    input wire clk,
    input wire reset,
    input wire [7:0] passcode_in,
    input wire enter_req,
    input wire exit_req,
    output reg [4:0] car_count, // how many cars are in the lot
    output reg entry_gate_open,
    output reg exit_gate_open
);

    // parameters
    localparam PASSCODE  = 8'b11111111;  // set passcode (this theoretically can be whatever)
    localparam MAX_COUNT = 5'd20;  // Max 20 cars in the lot

    // FSM States
    localparam IDLE        = 3'b000,
            CHECK_ENTRY    = 3'b001,
            ENTRY_OPEN     = 3'b010,
            ENTRY_CLOSE    = 3'b011,
            CHECK_EXIT     = 3'b100,
            EXIT_OPEN      = 3'b101,
            EXIT_CLOSE     = 3'b110;

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
                if ((passcode_in == PASSCODE) && (car_count < MAX_COUNT))
                    next_state = ENTRY_OPEN;
                else
                // if passcode fails, go to idle
                    next_state = IDLE;
            end

            ENTRY_OPEN: begin
                // gate open for one cycle
                next_state = ENTRY_CLOSE;
            end

            ENTRY_CLOSE: begin
                // close gate, return to idle
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
        end else begin
            // default outputs unless otherwise set by fsm. Need them to be zero because we want the gate closed by default
            entry_gate_open <= 0;
            exit_gate_open  <= 0;

            case (next_state)
                ENTRY_OPEN: begin
                    entry_gate_open <= 1;
                    // increment the car count when gate opens
                    if (car_count < MAX_COUNT)
                        car_count <= car_count + 1;
                end

                EXIT_OPEN: begin
                    exit_gate_open <= 1;
                    // decrement the car count when gate opens
                    if (car_count > 0)
                        car_count <= car_count - 1;
                end

                default: begin
                    // no  action other than defaults : gates closed
                end
            endcase
        end
    end

endmodule
