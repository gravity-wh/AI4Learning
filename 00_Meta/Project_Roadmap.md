# AI4Learning Project Roadmap & Agent Instructions

## 1. Role & Persona
*   **Role**: Expert AI Programming Assistant (Specializing in IC Design & Verification).
*   **Style**: Rigorous, physics-aware, first-principles thinking.
*   **Output**: High-quality code (SystemVerilog/Verilog), detailed mathematical derivations (LaTeX), and structured study notes.

## 2. Course 1: Advanced Digital IC (Architecture & PPA)
*   **Curriculum Source**: Berkeley EE241B / MIT 6.374.
*   **Current Status**:
    *   [x] Syllabus Design.
    *   [x] Theory: Logical Effort ($d=gh+p$), FO4 derivation, Wire delay, Timing (Skew/Jitter).
    *   [In-Progress] Lab 3: High-Speed Adder Architecture (RCA vs CLA).
*   **Pending Tasks**:
    *   **Complete Lab 3**: Implement `cla_32bit.sv` and `rca_32bit.sv`, run performance comparison.
    *   **Lab 4: SRAM Design**: 6T Cell stability simulation (SNM), Sense Amp logic.
    *   **Lab 5: Low Power**: Clock Gating & Multi-Vt implementation.
    *   **Notes**: Continue populating `Notes_C1.md` with deep dives (e.g., Elmore Delay, Velocity Saturation).

## 3. Course 2: SoC Verification (SystemVerilog & UVM)
*   **Curriculum Source**: Industry Standard Verification Methodologies.
*   **Current Status**:
    *   [x] Lab 1: FIFO Scoreboard (Data checking, Queue manipulation).
*   **Pending Tasks**:
    *   **Lab 2: Randomization**: Constraint random verification (CRV) for packet generation.
    *   **Lab 3: Functional Coverage**: Defining covergroups and bins.
    *   **Lab 4: UVM Basics**: Migrating the SV testbench to a UVM component structure (Agent, Driver, Monitor).

## 4. Course 3: Mixed-Signal IC (Modeling & System Design)
*   **Curriculum Source**: Stanford EE271 / EE315.
*   **Current Status**:
    *   [x] Syllabus Design.
    *   [x] Theory: PLL Stability (Type-II), Jitter, TI-ADC Calibration (Adaptive Filters).
*   **Pending Tasks**:
    *   **Lab 1: PLL Behavioral Modeling**: Verilog-AMS or Real-Number Modeling (RNM) in SV.
    *   **Lab 2: ADC Modeling**: SAR ADC logic and non-ideality modeling (noise, nonlinearity).
    *   **Notes**: Continue populating `Notes_C3.md` and `Tips.md` with algorithm-level solutions (e.g., LMS calibration).

## 5. Knowledge Base Maintenance (Standard of Quality)
*   **Tips.md**: Reserved for complex theoretical derivations.
    *   *Example*: PLL Stability (Bode plots, Zero insertion).
    *   *Example*: Logical Effort (NAND2 sizing, $g=4/3$).
    *   *Example*: TI ADC Calibration (Taylor series, Adaptive filters).
*   **Notes_*.md**: Structured summaries of core concepts, formulas, and interview-ready explanations.

## 6. Workflow Instructions for Future Sessions
1.  **Check Context**: Read `prompt.md` to understand the roadmap.
2.  **Update Notes**: When explaining a new concept, always summarize it back into the corresponding `Notes_*.md` or `Tips.md`.
3.  **Code Quality**: Ensure all SystemVerilog code is synthesizable (for RTL) or robust (for TB).
