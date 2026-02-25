//=============================================================================
// EE180 Lab 3
//
// Instruction fetch module. Maintains PC and updates it. Reads from the
// instruction ROM.
//=============================================================================

module instruction_fetch (
    input clk,
    input rst,
    input en,
    input jump_branch,
    input [31:0] branch_addr,
    input jump_register,
    input [31:0] jr_addr,
    input jump_target,
    input [31:0] pc_id,
    input [25:0] instr_id,

    output [31:0] pc
);
    wire [31:0] pc_id_p4 = pc_id + 3'h4;
    wire [31:0] j_addr = {pc_id_p4[31:28], instr_id[25:0], 2'b0};

    wire [31:0] pc_inc = pc + 32'd4;
    wire [31:0] pc_after_branch = jump_branch ? branch_addr : pc_inc;
    wire [31:0] pc_after_jump = jump_target ? j_addr : pc_after_branch;
    wire [31:0] pc_next = jump_register ? jr_addr : pc_after_jump;

    dffare #(32) pc_reg (.clk(clk), .r(rst), .en(en), .d(pc_next), .q(pc));

endmodule
