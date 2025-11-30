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
└── 03_Mixed_Signal_IC/     # Course 3: Modeling, PLLs, ADCs, and Calibration
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
