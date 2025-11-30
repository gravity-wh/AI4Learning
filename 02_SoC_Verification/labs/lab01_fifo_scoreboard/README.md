# Lab 1: FIFO Scoreboard Project

## Directory Structure (目录结构)

*   **src/**: Source code for verification components.
    *   `fifo_scoreboard.sv`: The main scoreboard class definition.
*   **tb/**: Testbench files.
    *   `tb_fifo.sv`: Top-level testbench module to drive the scoreboard.

## How to Run (如何运行)

### Using Vivado / Questasim / VCS

1.  Compile the files:
    ```bash
    # Example for generic simulator
    vlog -sv src/fifo_scoreboard.sv tb/tb_fifo.sv
    ```
    *Note: Since `tb_fifo.sv` includes `fifo_scoreboard.sv`, you might only need to compile the TB depending on the tool.*

2.  Run Simulation:
    ```bash
    vsim tb_fifo
    ```

## Lab Goals (实验目标)

1.  Complete the `TODO` comments in `src/fifo_scoreboard.sv`.
2.  Complete the `TODO` comments in `tb/tb_fifo.sv`.
3.  Verify that you can detect:
    *   Successful matches.
    *   Data mismatches.
    *   Queue underflow (reading from empty).
