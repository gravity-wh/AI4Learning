# Lab 3: High-Speed 32-bit Adder Architectures

## Lab Overview
In this lab, you will explore digital arithmetic circuits by implementing and comparing two different 32-bit adder architectures:
1.  **Ripple Carry Adder (RCA)**: The simplest architecture, but slow due to the long carry propagation chain.
2.  **Carry Lookahead Adder (CLA)**: A faster architecture that calculates carry signals in parallel using Generate (G) and Propagate (P) logic.

You will write SystemVerilog code for both adders and a self-checking testbench to verify their correctness and observe the timing differences (conceptually or via simulation delays).

## Pre-Lab Thinking

### Ripple Carry Adder (RCA)
An $N$-bit RCA is constructed by cascading $N$ Full Adders. The carry-out of bit $i$ is connected to the carry-in of bit $i+1$.
*   **Critical Path**: The carry must ripple from the Least Significant Bit (LSB) to the Most Significant Bit (MSB).
*   **Delay**: $O(N)$.

### Carry Lookahead Adder (CLA)
The CLA solves the carry propagation delay by calculating carries for each bit position simultaneously based on the inputs.
*   **Generate ($G_i$)**: A carry is generated if both inputs are 1. $G_i = A_i \cdot B_i$
*   **Propagate ($P_i$)**: A carry is propagated if at least one input is 1. $P_i = A_i \oplus B_i$ (or $A_i + B_i$)
*   **Carry Equation**: $C_{i+1} = G_i + (P_i \cdot C_i)$

By expanding this equation recursively, $C_i$ can be expressed in terms of $C_0$ and inputs $A$ and $B$, removing the dependency on the previous carry bit's calculation time.

## Step-by-Step Guide

### Step 1: Implement Ripple Carry Adder (RCA)
1.  Open `src/rca_32bit.sv`.
2.  Implement a single-bit Full Adder module.
3.  Use a `generate` loop to instantiate 32 Full Adders, connecting the carry chain.

### Step 2: Implement Carry Lookahead Adder (CLA)
1.  Open `src/cla_32bit.sv`.
2.  Implement the logic to calculate $P$ and $G$ for all bits.
3.  Implement the Carry Lookahead Logic to compute all carry bits ($C_1$ to $C_{32}$) using the $P$ and $G$ signals and $C_0$ (Cin).
4.  Compute the final Sum: $S_i = P_i \oplus C_i$.

### Step 3: Create Testbench
1.  Open `tb/tb_adder.sv`.
2.  Instantiate the `rca_32bit` and `cla_32bit` modules.
3.  Create a loop to generate random 32-bit inputs for `a` and `b`.
4.  Calculate the expected sum using behavioral SystemVerilog (`expected = a + b + cin`).
5.  Compare the outputs of your DUTs (Device Under Test) with the expected result.

## Verification Goals
*   **Functional Correctness**: Ensure both adders produce the correct sum for random inputs.
*   **Corner Cases**: Test specific cases like:
    *   Zero + Zero
    *   Max Value + 1 (Overflow)
    *   Alternating patterns (0xAAAA_AAAA + 0x5555_5555)
