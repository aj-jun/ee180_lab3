###############################################################################
# File         : llsc.S
# Project      : EE180 Lab 2: MIPS
#
# Standards/Formatting:
#   MIPS gas, soft tab, 80 column
#
# Description:
#   Test the functionality of the 'll' and 'sc' instruction.
#
###############################################################################


    .section .boot, "x"
    .balign 4
    .set    noreorder
    .global boot
    .ent    boot
boot:
    lui     $s0, 0x8002         # 0 Load the base address of the status/test registers
    ori     $s1, $0, 1          # 1 Prepare the 'done' status
    ori     $t7, $0, 1         

    lui     $t0, 0              # 2 Load some valid address 0x00003210 to register $t0
    ori     $t0, $t0, 0x3210    # 3
    ori     $t2, $0,  0x2       # 4
    sw      $t0, 0($t0)         # 5
    ll      $t1, 0($t0)         # 7 Should load link0 from 0x00003210
    sc      $t2, 0($t0)         # 8 sc should ouput 1        
    bne     $t2, $t7, $fail     # 9
    nop
    
    ll      $t4, 0($t0)         # 5 Should load link 0 from 0x00003210
    sw      $0,  0($t0)         # 7 Will invalidate sc
    sc      $t4, 0($t0)         # 8
    bne     $t4, $0, $fail      # 9
    nop

    ori     $v0, $0, 1 
    
$finish:
    sw      $v0, 4($s0)         # 13 Set the test result
    sw      $s1, 0($s0)         # 14 Set 'done'

$done:
    j       $done
    nop

$fail:
    ori     $v0, $0, 0          
    j       $finish

    .end boot
