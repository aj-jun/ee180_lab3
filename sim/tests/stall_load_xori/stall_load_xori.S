###############################################################################
# File         : stall_load_xori.S
# Project      : EE180 Lab 3: MIPS
#
# Description:
#   Checks load-use stalling for an immediate ALU op (xori) that consumes Rs.
#   If stall is missing, xori may use stale Rs data.
#
###############################################################################

    .section .boot, "x"
    .balign 4
    .set    noreorder
    .global boot
    .ent    boot
boot:
    lui     $s0, 0x8002         # status/test register base
    ori     $s1, $0, 1          # done = 1

    ori     $t0, $0, 0x3210
    lui     $t1, 0x0000
    ori     $t1, $t1, 0x00f0    # value to load
    sw      $t1, 0($t0)

    ori     $t2, $0, 0x0f0f     # stale value that should NOT be used
    lw      $t2, 0($t0)         # t2 should become 0x000000f0
    xori    $t3, $t2, 0x00ff    # expected 0x0000000f

    ori     $t4, $0, 0x000f
    subu    $t5, $t3, $t4
    sltiu   $v0, $t5, 1

    sw      $v0, 4($s0)
    sw      $s1, 0($s0)

$done:
    j       $done
    nop

    .end boot
