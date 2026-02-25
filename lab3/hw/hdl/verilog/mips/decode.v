//=============================================================================
// EE180 Lab 3
//
// Decode module. Determines what to do with an instruction.
//=============================================================================

`include "mips_defines.v"

module decode (
    input [31:0] pc,
    input [31:0] instr,
    input [31:0] rs_data_in,
    input [31:0] rt_data_in,

    output wire [4:0] reg_write_addr,
    output wire jump_branch,
    output wire jump_target,
    output wire jump_reg,
    output wire [31:0] jr_pc,
    output reg [3:0] alu_opcode,
    output wire [31:0] alu_op_x,
    output wire [31:0] alu_op_y,
    output wire mem_we,
    output wire [31:0] mem_write_data,
    output wire mem_read,
    output wire mem_byte,
    output wire mem_signextend,
    output wire reg_we,
    output wire movn,
    output wire movz,
    output wire [4:0] rs_addr,
    output wire [4:0] rt_addr,
    output wire atomic_id,
    input  atomic_ex,
    output wire mem_sc_mask_id,
    output wire mem_sc_id,
    output wire [31:0] branch_addr,
    output wire is_link,
    
    output wire stall,
    output wire [31:0] ra,
    output wire mem_half,

    input reg_we_ex,
    input [4:0] reg_write_addr_ex,
    input [31:0] alu_result_ex,
    input mem_read_ex,

    input reg_we_mem,
    input [4:0] reg_write_addr_mem,
    input [31:0] reg_write_data_mem,
    
    input sc_complete,
    input mem_sc_ex
);

//******************************************************************************
// instruction field
//******************************************************************************

    wire [5:0] op = instr[31:26];
    assign rs_addr = instr[25:21];
    assign rt_addr = instr[20:16];
    wire [4:0] rd_addr = instr[15:11];
    wire [4:0] shamt = instr[10:6];
    wire [5:0] funct = instr[5:0];
    wire [15:0] immediate = instr[15:0];

    wire [31:0] rs_data, rt_data;

//******************************************************************************
// branch instructions decode
//******************************************************************************

    wire isBEQ    = (op == `BEQ);
    wire isBGEZNL = (op == `BLTZ_GEZ) & (rt_addr == `BGEZ);
    wire isBGEZAL = (op == `BLTZ_GEZ) & (rt_addr == `BGEZAL);
    wire isBGTZ   = (op == `BGTZ) & (rt_addr == 5'b00000);
    wire isBLEZ   = (op == `BLEZ) & (rt_addr == 5'b00000);
    wire isBLTZNL = (op == `BLTZ_GEZ) & (rt_addr == `BLTZ);
    wire isBLTZAL = (op == `BLTZ_GEZ) & (rt_addr == `BLTZAL);
    wire isBNE    = (op == `BNE);
    wire isBranchLink = (isBGEZAL | isBLTZAL);


//******************************************************************************
// jump instructions decode
//******************************************************************************

    wire isJ    = (op == `J);
    wire isJR   = (op == `SPECIAL) & (funct == `JR);
    wire isJAL  = (op == `JAL);
    wire isJALR = (op == `SPECIAL) & (funct == `JALR);
    assign is_link = isJAL | isJALR;

//******************************************************************************
// shift instruction decode
//******************************************************************************

    wire isSLL = (op == `SPECIAL) & (funct == `SLL);
    wire isSRL = (op == `SPECIAL) & (funct == `SRL);
    wire isSLLV = (op == `SPECIAL) & (funct == `SLLV);
    wire isSRLV = (op == `SPECIAL) & (funct == `SRLV);

    wire isSRA = (op == `SPECIAL) & (funct == `SRA);
    wire isSRAV = (op == `SPECIAL) & (funct == `SRAV);

    wire isShiftImm = isSLL | isSRL | isSRA;
    wire isShift = isShiftImm | isSLLV | isSRLV | isSRAV;

//******************************************************************************
// ALU instructions decode / control signal for ALU datapath
//******************************************************************************

    always @* begin
        casex({op, funct})
            {`ADDI, `DC6}:      alu_opcode = `ALU_ADD;
            {`ADDIU, `DC6}:     alu_opcode = `ALU_ADDU;
            {`XORI, `DC6}:      alu_opcode = `ALU_XOR;
            {`SLTI, `DC6}:      alu_opcode = `ALU_SLT;
            {`SLTIU, `DC6}:     alu_opcode = `ALU_SLTU;
            {`ANDI, `DC6}:      alu_opcode = `ALU_AND;
            {`ORI, `DC6}:       alu_opcode = `ALU_OR;
            {`LB, `DC6}:        alu_opcode = `ALU_ADD;
            {`LL, `DC6}:        alu_opcode = `ALU_ADD;
            {`LW, `DC6}:        alu_opcode = `ALU_ADD;
            {`LBU, `DC6}:       alu_opcode = `ALU_ADD;
            {`LH, `DC6}:        alu_opcode = `ALU_ADD;
            {`SB, `DC6}:        alu_opcode = `ALU_ADD;
            {`SH, `DC6}:        alu_opcode = `ALU_ADD;
            {`SC, `DC6}:        alu_opcode = `ALU_ADD;
            {`SW, `DC6}:        alu_opcode = `ALU_ADD;
            {`BEQ, `DC6}:       alu_opcode = `ALU_SUBU;
            {`BNE, `DC6}:       alu_opcode = `ALU_SUBU;
            {`SPECIAL, `ADD}:   alu_opcode = `ALU_ADD;
            {`SPECIAL, `ADDU}:  alu_opcode = `ALU_ADDU;
            {`SPECIAL, `SUB}:   alu_opcode = `ALU_SUB;
            {`SPECIAL, `SUBU}:  alu_opcode = `ALU_SUBU;
            {`SPECIAL, `AND}:   alu_opcode = `ALU_AND;
            {`SPECIAL, `OR}:    alu_opcode = `ALU_OR;
            {`SPECIAL, `NOR}:   alu_opcode = `ALU_NOR;
            {`SPECIAL, `XOR}:   alu_opcode = `ALU_XOR;
            {`SPECIAL2, `MUL}:  alu_opcode = `ALU_MUL;
            {`SPECIAL, `MOVN}:  alu_opcode = `ALU_PASSX;
            {`SPECIAL, `MOVZ}:  alu_opcode = `ALU_PASSX;
            {`SPECIAL, `SLT}:   alu_opcode = `ALU_SLT;
            {`SPECIAL, `SLTU}:  alu_opcode = `ALU_SLTU;
            {`SPECIAL, `SLL}:   alu_opcode = `ALU_SLL;
            {`SPECIAL, `SRL}:   alu_opcode = `ALU_SRL;
            {`SPECIAL, `SLLV}:  alu_opcode = `ALU_SLL;
            {`SPECIAL, `SRLV}:  alu_opcode = `ALU_SRL;
            {`SPECIAL, `SRA}:   alu_opcode = `ALU_SRA;
            {`SPECIAL, `SRAV}:  alu_opcode = `ALU_SRA;
            // compare rs data to 0, only care about 1 operand
            {`BGTZ, `DC6}:      alu_opcode = `ALU_PASSX;
            {`BLEZ, `DC6}:      alu_opcode = `ALU_PASSX;
            {`BLTZ_GEZ, `DC6}: begin
                if (isBranchLink)
                    alu_opcode = `ALU_PASSY; // pass link address for mem stage
                else
                    alu_opcode = `ALU_PASSX;
            end
            // pass link address to be stored in $ra
            {`JAL, `DC6}:       alu_opcode = `ALU_PASSY;
            {`SPECIAL, `JALR}:  alu_opcode = `ALU_PASSY;
            {`SPECIAL, `JR}:    alu_opcode = `ALU_PASSY;
            // or immediate with 0
            {`LUI, `DC6}:       alu_opcode = `ALU_PASSY;
            default:            alu_opcode = `ALU_PASSX;
    	endcase
    end

//******************************************************************************
// Compute value for 32 bit immediate data
//******************************************************************************

    wire use_imm = &{op != `SPECIAL, op != `SPECIAL2, op != `BNE, op != `BEQ};

    wire [31:0] imm_sign_extend = {{16{immediate[15]}}, immediate};
    wire [31:0] imm_upper = {immediate, 16'b0};

    wire [31:0] imm_first = (op == `LUI) ? imm_upper : imm_sign_extend;
    
    // for logical immediate operations, don't sign extend (0 extend instead)
    wire [31:0] imm = (|{op == `ORI, op == `XORI, op == `ANDI}) ? {16'b0, immediate} : imm_first;
    
//******************************************************************************
// forwarding and stalling logic
//******************************************************************************

    wire hit_rs_ex = &{rs_addr == reg_write_addr_ex, rs_addr != `ZERO, reg_we_ex};
    wire hit_rt_ex = &{rt_addr == reg_write_addr_ex, rt_addr != `ZERO, reg_we_ex};
    wire hit_rs_mem = &{rs_addr == reg_write_addr_mem, rs_addr != `ZERO, reg_we_mem};
    wire hit_rt_mem = &{rt_addr == reg_write_addr_mem, rt_addr != `ZERO, reg_we_mem};

    wire [1:0] fwd_rs_sel = hit_rs_ex ? 2'd2 : (hit_rs_mem ? 2'd1 : 2'd0);
    wire [1:0] fwd_rt_sel = hit_rt_ex ? 2'd2 : (hit_rt_mem ? 2'd1 : 2'd0);

    assign rs_data = (fwd_rs_sel == 2'd2) ? alu_result_ex :
                     (fwd_rs_sel == 2'd1) ? reg_write_data_mem : rs_data_in;
    assign rt_data = (fwd_rt_sel == 2'd2) ? alu_result_ex :
                     (fwd_rt_sel == 2'd1) ? reg_write_data_mem : rt_data_in;

    wire rs_mem_dependency = &{rs_addr == reg_write_addr_ex, mem_read_ex, rs_addr != `ZERO};
    wire rt_mem_dependency = &{rt_addr == reg_write_addr_ex, mem_read_ex, rt_addr != `ZERO};

    wire isLUI = op == `LUI;
    wire isALUImm = |{op == `ADDI, op == `ADDIU, op == `SLTI, op == `SLTIU, op == `ANDI, op == `ORI, op == `XORI};
    wire uses_rs = ~|{isLUI, jump_target, isShiftImm};
    wire uses_rt = ~|{isLUI, jump_target, isALUImm, mem_read, mem_sc_id};
    wire load_use_stall = (rs_mem_dependency & uses_rs) | (rt_mem_dependency & uses_rt);
    wire sc_wait_stall = mem_sc_ex && uses_rt;

    assign stall = load_use_stall | sc_wait_stall;

    assign jr_pc = rs_data;
    assign mem_write_data = rt_data;

//******************************************************************************
// Determine ALU inputs and register writeback address
//******************************************************************************

    // for shift operations, use either shamt field or lower 5 bits of rs
    // otherwise use rs

    wire [31:0] shift_amount = isShiftImm ? shamt : rs_data[4:0];
    assign alu_op_x = isShift ? shift_amount : rs_data;

    // for link operations, use next pc (current pc + 8)
    // for immediate operations, use Imm
    // otherwise use rt
    assign alu_op_y = (use_imm) ? imm : rt_data;

    // Write register destination is rt_addr, rd_addr, or 31 for JAL
    assign reg_write_addr = (isJAL | isJALR) ? 5'd31 : (use_imm ? rt_addr : rd_addr);
    assign ra = pc + 4'h8;

    // determine when to write back to a register (any operation that isn't an
    // unconditional store, non-linking branch, or non-linking jump)
    assign reg_we = ~|{(mem_we & (op != `SC)), isJ, isBGEZNL, isBGTZ, isBLEZ, isBLTZNL, isBNE, isBEQ};

    // determine whether a register write is conditional
    assign movn = &{op == `SPECIAL, funct == `MOVN};
    assign movz = &{op == `SPECIAL, funct == `MOVZ};

//******************************************************************************
// Memory control
//******************************************************************************
    assign mem_we   = |{op == `SW, op == `SB, op == `SH, op == `SC};
    assign mem_read = |{op == `LB, op == `LBU, op == `LW, op == `LH, op == `LL};
    assign mem_byte = |{op == `SB, op == `LB, op == `LBU};
    assign mem_signextend = ~|{op == `LBU};
    assign mem_half = |{op == `LH, op == `SH};
//******************************************************************************
// Load linked / Store conditional
//******************************************************************************
    assign mem_sc_id = (op == `SC);
    wire mem_ll_id, mem_is_store_id;

    assign mem_ll_id = (op == `LL);
    assign mem_is_store_id = |{op == `SB, op == `SH, op == `SW};

    // if the current operation is a ll, or it's not a write and ll was previously set, or the sc hasn't completed yet the ll was previously set
    assign atomic_id = |{mem_ll_id, (~mem_is_store_id & ~sc_complete & atomic_ex)};

    // 'mem_sc_mask_id' is high when a store conditional should not store
    assign mem_sc_mask_id = &{mem_sc_id, ~atomic_id};

//******************************************************************************
// Branch resolution
//******************************************************************************

    wire isEqual = rs_data == rt_data;
    wire signed [31:0] signed_rs_data = rs_data;

    assign jump_branch = |{isBEQ & isEqual,
                           isBNE & ~isEqual,
                           isBGEZNL & signed_rs_data >= 32'sh0,
                           isBGTZ & signed_rs_data > 32'sh0,
                           isBLEZ & signed_rs_data <= 32'sh0,
                           isBLTZNL & signed_rs_data < 32'sh0};

    assign jump_target = |{isJ, isJAL};
    assign jump_reg = |{isJR, isJALR};

//******************************************************************************
// BEQ
//******************************************************************************
    assign branch_addr = pc + 3'h4 + (imm_sign_extend << 2);
    
endmodule
