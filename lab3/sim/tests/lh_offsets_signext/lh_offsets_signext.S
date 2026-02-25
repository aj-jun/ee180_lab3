###############################################################################
# File         : lh_offsets_signext.S
# Project      : EE180 Lab 3: MIPS
#
# Description:
#   Verifies LH on both halfword offsets and sign extension behavior.
#   Word pattern: 0x80017FFF
#   lh 0(addr) -> 0xFFFF8001 (sign-extended negative halfword)
#   lh 2(addr) -> 0x00007FFF (positive halfword)
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

    ori     $t0, $0, 0x3230     # scratch address
    lui     $t1, 0x8001
    ori     $t1, $t1, 0x7fff
    sw      $t1, 0($t0)

    lh      $t2, 0($t0)
    lh      $t3, 2($t0)

    lui     $t4, 0xffff
    ori     $t4, $t4, 0x8001
    subu    $t5, $t2, $t4
    sltiu   $t5, $t5, 1

    lui     $t6, 0x0000
    ori     $t6, $t6, 0x7fff
    subu    $t7, $t3, $t6
    sltiu   $t7, $t7, 1

    and     $v0, $t5, $t7
    sw      $v0, 4($s0)
    sw      $s1, 0($s0)

$done:
    j       $done
    nop

    .end boot
