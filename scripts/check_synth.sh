#!/bin/sh
# Quick synthesizability check with plain Yosys (run from the project root).
yosys -q -p "read_verilog rtl/*.v; hierarchy -check -top mips32_pipeline; \
  proc; flatten; opt; check -assert; synth -top mips32_pipeline; stat" \
  && echo "SYNTH CHECK PASSED"
