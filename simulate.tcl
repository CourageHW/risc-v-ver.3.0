# ===================================================================

# ===================================================================
# This version creates a temporary project on disk to ensure
# compatibility with all Vivado simulation commands.
# --- 1. Project Setup ---
# Define the temporary project directory and name.
set PROJ_DIR "./vivado_sim_project"
set PROJ_NAME "riscv_simulation"

# The -force flag will overwrite the project if it already exists.
create_project ${PROJ_NAME} ${PROJ_DIR} -part xc7z020clg400-1 -force


# --- 2. Add Source Files ---
# Add all necessary source files using relative paths from the project root.
add_files -fileset sim_1 [list \
  ./core_pkg.sv \
  ./interface/IF2ID_if.sv \
  ./interface/ID2EX_if.sv \
  ./rtl/0.Pipeline/IF_to_ID_Reg.sv \
  ./rtl/0.Pipeline/ID_to_EX_Reg.sv \
  ./rtl/1.IF_Stage/program_counter.sv \
  ./rtl/1.IF_Stage/instruction_memory.sv \
  ./rtl/1.IF_Stage/IF_stage.sv \
  ./rtl/2.ID_Stage/register_file.sv \
  ./rtl/2.ID_Stage/immediate_generator.sv \
  ./rtl/2.ID_Stage/ID_stage.sv \
  ./rtl/6.Control_Unit/main_control_unit.sv \
  ./rtl/riscv_core.sv \
  ./tb/1.IF_Stage/tb_IF_stage.sv \
  ./tb/2.ID_Stage/tb_ID_stage.sv \
  ./tb/tb_riscv_core_if_id.sv \
]

#add_files -fileset sim_1 -norecurse [list \
]

# --- 3. Set Compile Order ---
# Explicitly set the defines package to be compiled first.
set_property top tb_riscv_core_if_id [get_filesets sim_1]
update_compile_order -fileset sim_1


# --- 4. Launch Simulation ---
puts "INFO: Launching simulation..."
launch_simulation

# --- 5. Run Simulation ---
puts "INFO: Running simulation until \$finish..."
run -all

if { $argc > 0 && [lindex $argv 0] == "gui" } {
    # '-gui' 옵션이 있으면, 파형 분석을 위해 GUI를 실행합니다.
    puts "INFO: Simulation stopped. Opening waveform GUI..."
    start_gui
    # GUI 모드에서는 사용자가 직접 닫을 것이므로, 자동으로 종료하지 않습니다.
} else {
    # '-gui' 옵션이 없으면 (기본 동작), 프로젝트를 닫고 종료합니다.
    puts "INFO: Simulation finished. Closing project."
    close_project
    exit
}
