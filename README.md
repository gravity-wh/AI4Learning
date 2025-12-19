# AI4ICLearning: AI-Assisted IC Design & Verification Journey

Welcome to **AI4ICLearning** (AI for Integrated Circuit Learning). This repository documents my comprehensive learning journey into Advanced Digital IC Design, SoC Verification, and Mixed-Signal System Design, guided by an expert AI programming assistant.

## 🚀 Project Overview

This project adopts a "First-Principles" approach to mastering complex IC design concepts. By leveraging AI to generate rigorous mathematical derivations, industry-standard code templates, and structured study notes, I am building a knowledge base comparable to top-tier university curricula (Berkeley EE241B, MIT 6.374, Stanford EE271).

## 📂 Repository Structure

The repository is organized into modular courses and global knowledge bases:

```text
AI4ICLearning/
├── 00_Meta/                # Project roadmap and AI agent instructions
├── 00_Global_Knowledge/    # Deep theoretical derivations (PLL, Logical Effort, etc.)
├── 01_Advanced_Digital_IC/ # Course 1: Architecture, PPA, and Physics
├── 02_SoC_Verification/    # Course 2: SystemVerilog, UVM, and Testbenches
├── 03_Mixed_Signal_IC/     # Course 3: Modeling, PLLs, ADCs, and Calibration
├── 04_UCLA_EE215A/         # Course 4: Introduction to Digital ICs (UCLA)
├── 06_Embedded_C_Rust/     # Course 6: C & Rust Embedded Programming
├── 07_Data_Structures/     # Course 7: Data Structures and Algorithms
├── 08_C_RISC_V_Assembly/   # Course 8: C Language and RISC-V Assembly
├── 09_Compilers/           # Course 9: Compiler Principles and RISC-V Backend
└── 10_Bootloader_Development/ # Course 10: Bootloader Development and System Boot
```

## 📚 Curriculum Highlights

### [01_Advanced_Digital_IC](./01_Advanced_Digital_IC/)
Focuses on the physics and architecture of high-speed digital circuits.
*   **Key Topics**: Logical Effort ($d=gh+p$), Wire Delay models, SRAM Design (6T Cell), Adder Architectures (CLA, Kogge-Stone).
*   **Labs**: High-speed adder implementation, SRAM stability simulation.

### [02_SoC_Verification](./02_SoC_Verification/)
Focuses on modern verification methodologies using SystemVerilog.
*   **Key Topics**: OOP in SV, Randomization (CRV), Functional Coverage, Scoreboarding.
*   **Labs**: FIFO Scoreboard, Random Packet Generation.

### [03_Mixed_Signal_IC](./03_Mixed_Signal_IC/)
Focuses on system-level modeling and digitally-assisted analog design.
*   **Key Topics**: PLL Stability Analysis (Type-II), Jitter & Phase Noise, TI-ADC Calibration (LMS Algorithms).
*   **Labs**: PLL Behavioral Modeling, ADC Non-ideality Modeling.

### [04_UCLA_EE215A](./04_UCLA_EE215A/)
Introduction to Digital Integrated Circuits based on UCLA curriculum.
*   **Key Topics**: CMOS Fundamentals, Logic Gate Design, Sequential Circuits, Interconnect Modeling, Power Analysis.
*   **Labs**: CMOS Inverter Characterization, Logic Gate Implementation, D Flip-Flop Design.

### [06_Embedded_C_Rust](./06_Embedded_C_Rust/)
C & Rust Embedded Programming: RISC-V and STM32 Bare-Metal Development.
*   **Key Topics**: Toolchain Setup, Register Programming, Interrupt Handling, Embedded HAL, FFI, Mixed Compilation.
*   **Labs**: LED Control, UART Communication, Sensor Reading, PWM Generation, ADC Data Acquisition.

### [07_Data_Structures](./07_Data_Structures/)
Data Structures and Algorithms: Foundations of Efficient Programming.
*   **Key Topics**: Complexity Analysis, Arrays, Linked Lists, Trees, Hash Tables, Graph Algorithms, Advanced Data Structures.
*   **Labs**: Dynamic Array Implementation, Binary Search Tree, Hash Table, Graph Traversal, Advanced Data Structures.

### [08_C_RISC_V_Assembly](./08_C_RISC_V_Assembly/)
C Language and RISC-V Assembly: Bridging High-Level and Low-Level Programming.
*   **Key Topics**: C Language Core, RISC-V Instruction Set, Assembly Basics, C-Assembly Correspondence, Function Calling Conventions, Mixed Programming, System Calls, Optimization Techniques.
*   **Labs**: Toolchain Setup, Assembly Programming, C-Assembly Analysis, Optimization Practice, Mixed Programming, System Calls, RISC-V Emulator Implementation.

### [09_Compilers](./09_Compilers/)
Compiler Principles and RISC-V Backend: Understanding and Extending Compilers.
*   **Key Topics**: Compiler Architecture, GCC Backend Structure, Intermediate Representations (GIMPLE/RTL), Instruction Selection, Code Generation, Custom Instruction Extension, ELF File Format, Linker Operation.
*   **Labs**: GCC/RISC-V Toolchain Setup, GCC Backend Architecture Analysis, Custom Instruction Set Extension, Instruction Selection Optimization, Linker and ELF File Analysis, Complete Custom Instruction Support.

### [10_Bootloader_Development](./10_Bootloader_Development/)
Bootloader Development and System Boot: From Hardware Initialization to Kernel Launch.
*   **Key Topics**: Bootloader Workflow, RISC-V Privilege Mode Switching (M→S), Device Tree (DT) Basics, UART/DDR/GPIO Initialization, Kernel Image Loading, OpenSBI Integration.
*   **Labs**: RISC-V Bootloader Environment Setup, Hardware Initialization and Privilege Switching, Kernel Loading and Device Tree Processing, Complete Bootloader Implementation for Custom RISC Softcore.

## 🤖 AI-Assisted Methodology

This project is built in collaboration with an AI assistant acting as a senior IC engineer. The workflow involves:
1.  **Syllabus Design**: Aligning with top university standards.
2.  **Theory Derivation**: Using AI to derive complex formulas (e.g., Optimal FO4, PLL Transfer Functions) from scratch.
3.  **Code Implementation**: Generating and refining synthesizable RTL and robust Testbenches.
4.  **Documentation**: Maintaining structured notes and "Tips" for complex topics.

## 📅 Roadmap

*   [ ] Complete Lab 3 for Advanced Digital IC (Adders).
*   [ ] Implement UVM Testbench for SoC Verification.
*   [ ] Model SAR ADC with non-linearities in Verilog-AMS/SystemVerilog.

---
*Created and maintained with the assistance of AI.*
