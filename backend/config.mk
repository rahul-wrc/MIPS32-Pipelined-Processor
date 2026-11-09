# OpenROAD-flow-scripts: copy to flow/designs/sky130hd/mips32/config.mk
# RTL goes to flow/designs/src/mips32/, constraint.sdc next to this file.
export DESIGN_NICKNAME = mips32
export DESIGN_NAME     = mips32_pipeline
export PLATFORM        = sky130hd

export VERILOG_FILES = $(sort $(wildcard ./designs/src/$(DESIGN_NICKNAME)/*.v))
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

# Flop-based 256-word dmem is large; keep utilisation modest so routing converges.
export CORE_UTILIZATION       = 35
export PLACE_DENSITY_LB_ADDON = 0.20
