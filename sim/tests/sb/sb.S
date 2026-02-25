###############################################################################
# File         : sb.S
# Project      : EE180 Lab 2: MIPS
#
# Standards/Formatting:
#   MIPS gas, soft tab, 80 column
#
# Description:
#   Test the functionality of the 'sb' instruction.
#
###############################################################################

    .section .boot, "x"
    .balign 4
    .set    noreorder
    .global boot
    .ent    boot
boot:
    lui     $s0, 0x8002         # Load the base address of the status/test registers

    lui     $t1, 0x0321         
    ori     $t0, $0, 1
    sb		$t0, 0($t1)	# TODO: WAW dependency stall?
    ori     $t0, $0, 2
    sb		$t0, 1($t1)	
    ori     $t0, $0, 3
    sb		$t0, 2($t1)	
    ori     $t0, $0, 4
    sb		$t0, 3($t1)	
    
    lw      $t3, 0($t1)
    lui     $t4, 0x0102
    ori     $t4, 0x0304
    bne     $t3, $t4, $fail

    ori     $t7, $0, 1

$finish:    
    sw      $t7, 4($s0)         # Set the test result
    sw      $s1, 0($s0)         # Set 'done'

$done:
    j       $done
    nop

$fail:
    ori     $v0, $0, 0          
    j       $finish

    .end boot
