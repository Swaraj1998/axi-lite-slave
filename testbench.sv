`timescale 1ns / 1ps

import axi_vip_pkg::*;
import design_1_axi_vip_0_0_pkg::*;


module testbench();

bit aclk = 0;
bit aresetn = 0;
xil_axi_ulong addr1 = 32'h44A00000, addr2 = 32'h44A00004;
xil_axi_prot_t prot = 0;
bit [31:0] data_wr1 = 32'h01234567, data_wr2 = 32'h89ABCDEF;
bit [31:0] data_rd1, data_rd2;
xil_axi_resp_t resp;
always #5ns aclk = ~aclk;

design_1_wrapper DUT
(
    .aclk_0(aclk),
    .aresetn_0(aresetn)
);

// Declare agent
design_1_axi_vip_0_0_mst_t      master_agent;

initial begin    //Create an agent

master_agent = new("master vip agent",DUT.design_1_i.axi_vip_0.inst.IF);
// set tag for agents for easy debug
master_agent.set_agent_tag("Master VIP");
// set print out verbosity level.
master_agent.set_verbosity(400);
//Start the agent
master_agent.start_master();

#50ns
aresetn = 1;

#20ns
master_agent.AXI4LITE_WRITE_BURST(addr1,prot,data_wr1,resp);
#20ns
master_agent.AXI4LITE_WRITE_BURST(addr2,prot,data_wr2,resp);
#70ns
master_agent.AXI4LITE_READ_BURST(addr1,prot,data_rd1,resp);
#20ns
master_agent.AXI4LITE_READ_BURST(addr2,prot,data_rd2,resp);
#200ns

if((data_wr1 == data_rd1)&&(data_wr2 == data_rd2))
    $display("Data match, test succeeded");
else
    $display("Data do not match, test failed");
$finish;

end

endmodule
