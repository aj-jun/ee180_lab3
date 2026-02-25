###############################################################################
# File         : sh_mask.S
# Project      : EE180 Lab 3: MIPS
#
# Description:
#   Verifies halfword stores update only the targeted half and preserve the
#   other half. Tests both upper and lower halfword writes.
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

    ori     $t0, $0, 0x3220     

    # Seed memory word: 0x11223344
    lui     $t1, 0x1122
    ori     $t1, $t1, 0x3344
    sw      $t1, 0($t0)

    # Write upper half -> expect 0xA1B23344
    lui     $t2, 0x0000
    ori     $t2, $t2, 0xA1B2
    sh      $t2, 0($t0)
    lw      $t3, 0($t0)
    lui     $t4, 0xA1B2
    ori     $t4, $t4, 0x3344
    subu    $t5, $t3, $t4
    sltiu   $t5, $t5, 1

    # Write lower half -> expect 0xA1B2C3D4
    lui     $t6, 0x0000
    ori     $t6, $t6, 0xC3D4
    sh      $t6, 2($t0)
    lw      $t7, 0($t0)
    lui     $a0, 0xA1B2
    ori     $a0, $a0, 0xC3D4
    subu    $a1, $t7, $a0
    sltiu   $a1, $a1, 1

    and     $v0, $t5, $a1
    sw      $v0, 4($s0)
    sw      $s1, 0($s0)

$done:
    j       $done
    nop

    .end boot
