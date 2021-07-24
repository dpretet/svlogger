#!/usr/bin/env bash

iverilog -g2012 -Wall -o icarus.out -f files.f  fsm_example_testbench.sv ; vvp icarus.out
