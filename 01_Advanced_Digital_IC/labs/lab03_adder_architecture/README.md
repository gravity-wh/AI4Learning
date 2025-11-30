# Lab 3: High-Speed 32-bit Adder Architectures

## Goals
1.  Understand the structural difference between Ripple Carry and Carry Lookahead adders.
2.  Implement a 32-bit RCA using SystemVerilog `generate` statements.
3.  Implement a 32-bit CLA (or partial CLA) using Propagate/Generate logic.
4.  Verify both designs using a self-checking testbench.

## Directory Structure
*   `src/`: Contains the source code for the adders (`rca_32bit.sv`, `cla_32bit.sv`).
*   `tb/`: Contains the testbench (`tb_adder.sv`).

## How to Run

### Prerequisites
*   Icarus Verilog (`iverilog`)
*   GTKWave (optional, for waveform viewing)

### Compilation and Simulation
To compile and run the simulation, use the following commands in your terminal:

```bash
# Compile the design and testbench
iverilog -g2012 -o adder_sim.out src/rca_32bit.sv src/cla_32bit.sv tb/tb_adder.sv

# Run the simulation
vvp adder_sim.out
```

### Viewing Waveforms
If you want to inspect the signals:
```bash
gtkwave adder_wave.vcd
```
