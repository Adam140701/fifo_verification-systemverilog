FIFO Design and Verification (SystemVerilog)

This repository contains a simple FIFO (First-In First-Out) RTL design and a self-checking SystemVerilog testbench.

The goal of this project is to demonstrate fundamental RTL design and hardware verification skills suitable for a junior or fresh graduate role.

FIFO Design:

The FIFO is a parameterized RTL module supporting configurable data width and depth.
It implements synchronous read and write operations using read and write pointers and maintains internal state to generate full and empty status flags.

Key features:

	Parameterized data width and depth

	Synchronous read and write

	Full and empty flag generation

	Circular buffer implementation

Verification Environment:

The SystemVerilog testbench is fully self-checking and verifies the following:

	Correct FIFO data ordering (first-in first-out behavior)

	Correct empty flag behavior

	Correct full flag behavior

	Reset behavior

	Directed write and read test sequences

	Random read and write stress testing

A reference model (scoreboard) is used to track expected FIFO contents and compare them against the DUT output automatically.
The simulation reports PASS or ERROR without requiring manual waveform inspection.

Running the Simulation:

The design and testbench can be simulated using Icarus Verilog.
Waveforms can optionally be viewed using GTKWave.

Typical simulation flow:

	Compile RTL and testbench

	Run directed tests

	Run random stress tests

	Report final PASS or ERROR status

Tools Used:

	SystemVerilog

	Icarus Verilog

	GTKWave

Notes:

This project focuses on verification fundamentals such as scoreboard-based checking, flag validation, and random testing.
It intentionally avoids heavy verification frameworks in order to keep the code simple, readable, and easy to understand.

Author

Adam Kassem
Electrical Engineering Graduate
