###############################################################################
# File         : xor.S
# Project      : EE180 Lab 2: MIPS
#
# Standards/Formatting:
#   MIPS gas, soft tab, 80 column
#
# Description:
#   Test the functionality of the 'xor' instruction.
#
###############################################################################

    .section .boot, "x"
    .balign 4
    .set    noreorder
    .global boot
    .ent    boot
boot:
    lui     $s0, 0x8002         # Load in address of the status and test registers
    ori     $s1, $0, 1          # Initialize 'done' (status)
    ori     $t0, $0,  0b1000
    xori    $t4, $t0, 0b1001
    sw      $t4, 4($s0)         # Set test result
    sw      $s1, 0($s0)         # Set 'done'

$done:
    j       $done
    nop

    .end boot
