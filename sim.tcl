create_project -in_memory -part xc7z020clg400-1 -force axi_lite_slave_test
set_property BOARD_PART em.avnet.com:microzed_7020:part0:1.1 [current_project]
set_property default_lib work [current_project]

create_bd_design "design_1"

set_property ip_repo_paths /media/hdd1/Xilinx/Projects/ip_repo [current_project]
update_ip_catalog

create_bd_cell -type ip -vlnv user.org:user:axi_lite:1.0 axi_lite_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 axi_vip_0

make_bd_pins_external [get_bd_pins axi_vip_0/aclk]
make_bd_pins_external [get_bd_pins axi_vip_0/aresetn]

set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} \
	CONFIG.INTERFACE_MODE {MASTER}] [get_bd_cells axi_vip_0]

connect_bd_intf_net [get_bd_intf_pins axi_vip_0/M_AXI] \
	[get_bd_intf_pins axi_lite_0/s_axi]

apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config \
	{ Clk {/aclk_0 (100 MHz)} Freq {100} Ref_Clk0 {} \
	Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_lite_0/s_axi_aclk]

connect_bd_net [get_bd_ports aresetn_0] [get_bd_pins axi_lite_0/s_axi_areset_n]
assign_bd_address -target_address_space \
	/axi_vip_0/Master_AXI [get_bd_addr_segs axi_lite_0/s_axi/reg0] -force

make_wrapper -files [get_files design_1.bd] -top
generate_target all [get_files design_1.bd]

export_ip_user_files
set XSIM_SCRIPTS_DIR .ip_user_files/sim_scripts/design_1/xsim 

#exec $XSIM_SCRIPTS_DIR/design_1.sh

# Compile

exec xvlog .gen/sources_1/bd/design_1/hdl/design_1_wrapper.v
exec xvlog -L axi_vip_v1_1_8 -L xilinx_vip -prj $XSIM_SCRIPTS_DIR/vlog.prj
exec xvhdl -prj $XSIM_SCRIPTS_DIR/vhdl.prj
#exec xvlog -L axi_vip_v1_1_8 -L xilinx_vip -prj testbench_vlog.prj
#exec xvhdl -prj testbench_vhdl.prj

# Elaborate

exec xelab --debug typical -L xilinx_vip -L work -L axi_infrastructure_v1_1_0 \
	-L axi_vip_v1_1_8 -L xilinx_vip -L unisims_ver -L unimacro_ver \
	-L secureip --snapshot testbench_behav work.testbench work.glbl

# Simulate

exec xsim testbench_behav -t testbench.tcl -protoinst \
	"$XSIM_SCRIPTS_DIR/protoinst_files/design_1.protoinst" -gui
