
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name hdmi_verify -dir "C:/Users/liuzh_000/Documents/GE/B Project/hdmi_verify/planAhead_run_2" -part xc6slx45fgg484-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "hdmi_verify.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {hdmi_verify.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top hdmi_verify $srcset
add_files [list {hdmi_verify.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx45fgg484-2
