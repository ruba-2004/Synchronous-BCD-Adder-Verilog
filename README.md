<div align="center">
  
# Synchronous 3-Digit BCD Adder: RCA vs. CLA Architecture
**Advanced Digital Systems Design (Verilog)**

[![Language](https://img.shields.io/badge/Language-Verilog-00599C.svg?style=flat-square)](#)
[![Simulation](https://img.shields.io/badge/EDA-Active__HDL-F7931E.svg?style=flat-square)](#)
[![Domain](https://img.shields.io/badge/Domain-Digital_Logic_Design-5C3EE8.svg?style=flat-square)](#)

*A structural hardware implementation comparing the performance, latency, and logic of Ripple Carry and Carry Lookahead architectures in synchronous BCD arithmetic.*

</div>

---

## Abstract
This repository contains the Verilog RTL and verification testbenches for a fully synchronous, parameterized multi-digit Binary Coded Decimal (BCD) adder. The project investigates the trade-offs in digital arithmetic by implementing the adder in two distinct stages: a baseline Ripple Carry Adder (RCA) and a high-performance Carry Lookahead Adder (CLA). 

The design is strictly structural, utilizing `generate` loops for module instantiation, and operates within a clocked environment using D-flip-flops for input/output synchronization.

**Developed at Birzeit University, Department of Electrical and Computer Engineering.** **Author:** Ruba Aldaghamin

## Architecture & Implementation

### Core BCD Logic
Unlike binary addition, BCD arithmetic requires post-addition correction. The base module evaluates if the intermediate `binary_sum` exceeds 9 or produces a carry-out. If true, an active-high correction signal triggers a secondary adder to add `6` (0110) to the result, ensuring valid decimal encoding. 

### Stage 1: Ripple Carry Adder (RCA)
The baseline implementation utilizes a cascaded sequence of Full Adders. 
* **Mechanism:** Carry bits propagate sequentially through each bit and digit, creating a critical path dependent on the data width.
* **Structure:** Requires two 4-bit RCAs per digit (one for initial summation, one for BCD correction).
* **Clock Period:** 1600 ns (calculating for worst-case ripple latency + flip-flop setup/hold).

### Stage 2: Carry Lookahead Adder (CLA)
The optimized implementation replaces the RCA modules with structural CLA logic.
* **Mechanism:** Eliminates sequential carry propagation by computing Generate (`G = A & B`) and Propagate (`P = A ^ B`) signals in parallel.
* **Performance Gain:** Drastically flattens the gate-level depth, calculating all carry bits simultaneously.
* **Clock Period:** 100 ns (accommodating CLA gate delay, BCD correction, and register timing).

---

## Performance Comparison
Latency and frequency analysis based on predefined gate delays (e.g., XOR = 15ns, AND/OR = 11ns). 

| Adder Architecture | Total Gate Delay (Approx.) | Safe Clock Period | Max Safe Frequency | Performance Gain |
| :--- | :--- | :--- | :--- | :--- |
| **Ripple Carry (Stage 1)** | ~800 ns | 1600 ns | 1.25 MHz | Baseline |
| **Carry Lookahead (Stage 2)** | ~70 - 80 ns | 100 ns | 10.0 MHz | **8.0x Faster** |

---

## Verification Methodology
Robust verification was a primary focus of this project, utilizing automated, file-based testbenches.

1. **Automated Decimal Checking:** A custom Verilog `task` extracts the 4-bit BCD slices, applies their decimal weights (100, 10, 1), and compares the computed decimal value against the expected output.
2. **File I/O Logging:** Simulation results are dynamically written to `simulation_output.txt` for record-keeping.
3. **Intentional Fault Injection:** To validate the robustness of the testbench, erroneous expected values were intentionally injected into the simulation. The testbench successfully caught these discrepancies and documented them in a separate `error_log.txt`.

## Repository Structure
* `/src/`: Contains all Verilog (`.v`) source files, including the RCA, CLA, Flip-Flops, and BCD correction modules.
* `/sim/`: Contains the testbench files (`tb_bcd_adder_ndigit_with_ff.v`) and output logs (`simulation_output.txt`, `error_log.txt`).
* `/docs/`: Contains the comprehensive technical report detailing gate-level diagrams, timing waveforms, and delay calculations.

## Future Works
* **Pipelining:** Introduction of intermediate registers between digit modules to break the carry chain and increase throughput.
* **Global Lookahead:** Implementation of a secondary level of carry-lookahead logic across the macroscopic digit blocks to eliminate the final inter-digit ripple.
* **FPGA Synthesis:** Deploying the RTL to a physical FPGA to extract real-world resource utilization (LUTs/Registers) and dynamic power consumption metrics.
