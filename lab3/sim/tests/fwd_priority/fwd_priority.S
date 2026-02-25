###############################################################################
# File         : fwd_priority.S
# Project      : EE180 Lab 3: MIPS
#
# Description:
#   Verifies forwarding priority when both EX and MEM can forward to the same
#   source register in ID. EX must win over MEM for both Rs and Rt paths.
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

    # Rs forwarding priority: EX value (2) should beat MEM value (1)
    ori     $t0, $0, 1
    ori     $t0, $0, 2
    addu    $t1, $t0, $0        # should read 2 from EX-forwarded t0

    # Rt forwarding priority: EX value (8) should beat MEM value (4)
    ori     $t2, $0, 4
    ori     $t2, $0, 8
    addu    $t3, $0, $t2        # should read 8 from EX-forwarded t2

    # Check t1 == 2
    ori     $t4, $0, 2
    subu    $t5, $t1, $t4
    sltiu   $t5, $t5, 1

    # Check t3 == 8
    ori     $t6, $0, 8
    subu    $t7, $t3, $t6
    sltiu   $t7, $t7, 1

    and     $v0, $t5, $t7       # pass if and only if both checks pass
    sw      $v0, 4($s0)
    sw      $s1, 0($s0)

$done:
    j       $done
    nop

    .end boot
