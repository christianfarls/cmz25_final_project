# Parking Lot Gate Simulator

CSE 30342 - Digital Integrated Circuits - University of Notre Dame

Christian Farls: cfarls@nd.edu

Matt Zagrocki: mzagrock@nd.edu

Danny Mikolay: dmikolay@nd.edu

## Overview

This Verilog module simulates a parking lot with basic functionalities for entering and exiting the lot. The system uses a finite state machine (FSM) to control the entry and exit gates, validate passcodes, and maintain the car count in the lot. The parking lot has a fixed maximum capacity, and only valid passcodes can allow cars to enter. The system also ensures that a car can exit the lot if there is at least one car present.

### Key Features

- **Passcode-based entry**: A valid passcode is required to open the entry gate and allow a car to enter the lot.
- **Automatic exit**: No passcode is required to exit, but the gate will only open if there are cars in the lot.
- **Car count management**: The car count is maintained, and the system ensures that the number of cars doesn't exceed the lot's capacity.
- **Gate operation**: The entry and exit gates operate for a single cycle when requested.

## Module Description

### Inputs

| Signal        | Width   | Description                                              |
|---------------|---------|----------------------------------------------------------|
| `clk`         | 1 bit   | Clock signal for timing and state transitions.           |
| `reset`       | 1 bit   | Asynchronous reset to initialize the FSM and car count. |
| `passcode_in` | 8 bits  | Input passcode for validating entry requests.           |
| `enter_req`   | 1 bit   | Signal requesting the entry gate to open.               |
| `exit_req`    | 1 bit   | Signal requesting the exit gate to open.                |

### Outputs

| Signal           | Width   | Description                                                      |
|------------------|---------|------------------------------------------------------------------|
| `car_count`      | 5 bits  | The current number of cars in the parking lot.                  |
| `entry_gate_open`| 1 bit   | Indicates if the entry gate is open (1) or closed (0).          |
| `exit_gate_open` | 1 bit   | Indicates if the exit gate is open (1) or closed (0).           |

### Parameters

| Parameter      | Value      | Description                                      |
|----------------|------------|--------------------------------------------------|
| `PASSCODE`     | `8'b11111111` | Predefined passcode for validating entry.      |
| `MAX_COUNT`    | `5'd20`      | Maximum number of cars allowed in the parking lot. |

### States

The FSM is designed with 7 states:

| State          | Binary Value | Description                                                      |
|----------------|--------------|------------------------------------------------------------------|
| `IDLE`         | `3'b000`     | Initial and idle state, waiting for entry or exit requests.      |
| `CHECK_ENTRY`  | `3'b001`     | Verifying entry request: checks passcode and lot capacity.      |
| `ENTRY_OPEN`   | `3'b010`     | Entry gate opens for one cycle.                                 |
| `ENTRY_CLOSE`  | `3'b011`     | Entry gate closes after opening.                                 |
| `CHECK_EXIT`   | `3'b100`     | Verifying exit request: checks if any cars are in the lot.      |
| `EXIT_OPEN`    | `3'b101`     | Exit gate opens for one cycle.                                  |
| `EXIT_CLOSE`   | `3'b110`     | Exit gate closes after opening.                                  |

### State Transitions

| Current State   | Input Condition                    | Next State          | Action                                        |
|-----------------|-------------------------------------|---------------------|-----------------------------------------------|
| `IDLE`          | `enter_req`                         | `CHECK_ENTRY`       | Transition to check entry request.           |
| `IDLE`          | `exit_req`                          | `CHECK_EXIT`        | Transition to check exit request.            |
| `CHECK_ENTRY`   | `passcode_in == PASSCODE` and `car_count < MAX_COUNT` | `ENTRY_OPEN`       | Open entry gate and increment car count.     |
| `CHECK_ENTRY`   | Else                                | `IDLE`              | Invalid passcode or full lot, return to idle.|
| `ENTRY_OPEN`    | Always                              | `ENTRY_CLOSE`       | Open entry gate for one cycle.               |
| `ENTRY_CLOSE`   | Always                              | `IDLE`              | Close entry gate and return to idle.         |
| `CHECK_EXIT`    | `car_count > 0`                     | `EXIT_OPEN`         | Open exit gate and decrement car count.     |
| `CHECK_EXIT`    | Else                                | `IDLE`              | No cars to exit, return to idle.             |
| `EXIT_OPEN`     | Always                              | `EXIT_CLOSE`        | Open exit gate for one cycle.                |
| `EXIT_CLOSE`    | Always                              | `IDLE`              | Close exit gate and return to idle.          |

### Actions

| Action        | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `entry_gate_open <= 1`  | Open the entry gate when entry request is valid and conditions met.    |
| `exit_gate_open <= 1`   | Open the exit gate when there are cars in the lot and exit is requested.|
| `car_count <= car_count + 1` | Increment car count when a car enters and the entry gate is opened.|
| `car_count <= car_count - 1` | Decrement car count when a car exits and the exit gate is opened.  |
| `entry_gate_open <= 0`   | Close the entry gate after one cycle.                                 |
| `exit_gate_open <= 0`    | Close the exit gate after one cycle.                                  |

## Functional Description

The parking lot system operates as follows:

1. **Idle State**:
   - The system starts in the `IDLE` state and waits for either an entry request (`enter_req`) or an exit request (`exit_req`).
   
2. **Entry Request Handling** (`CHECK_ENTRY`):
   - If an entry request is received, the system checks whether the passcode matches the predefined `PASSCODE` and whether the parking lot is not full (`car_count < MAX_COUNT`).
   - If the passcode is correct and space is available, the system transitions to the `ENTRY_OPEN` state, where the entry gate is opened, and a car is allowed to enter. The car count is incremented.
   - If the passcode is incorrect or the lot is full, the system transitions back to the `IDLE` state.

3. **Exit Request Handling** (`CHECK_EXIT`):
   - If an exit request is received, the system checks whether there are any cars in the parking lot (`car_count > 0`).
   - If cars are present, the system transitions to the `EXIT_OPEN` state, where the exit gate is opened, and a car is allowed to exit. The car count is decremented.
   - If there are no cars, the system transitions back to the `IDLE` state.

4. **Gate Operations**:
   - Both the entry and exit gates open for exactly one cycle in their respective states (`ENTRY_OPEN` and `EXIT_OPEN`), after which they are closed in `ENTRY_CLOSE` and `EXIT_CLOSE`.

## Design Considerations

- **Max Car Capacity**: The system ensures that the number of cars in the lot does not exceed `MAX_COUNT` (20 cars).
- **Passcode Validation**: The system requires a correct passcode to open the entry gate, providing basic security.
- **State-based Operation**: The finite state machine ensures that the system operates in a predictable manner, with clear states for handling different requests.

## Conclusion

This Verilog module simulates a simple yet effective parking lot control system. It manages car entry and exit, validates passcodes, and ensures that the parking lot capacity is never exceeded. The system uses an FSM for state management and provides clear and predictable behavior based on the input signals.

