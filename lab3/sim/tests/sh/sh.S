###############################################################################
# File         : sh.S
# Project      : EE180 Lab 2: MIPS
#
# Standards/Formatting:
#   MIPS gas, soft tab, 80 column
#
# Description:
#   Test the functionality of the 'sh' instruction.
#
###############################################################################


    .section .boot, "x"
    .balign 4
    .set    noreorder
    .global boot
    .ent    boot
boot:
    lui     $s0, 0x8002         # Load the base address of the status/test registers
    ori     $s1, $0, 1          # Prepare the 'done' status
    lui     $t0, 0              # Load some valid address 0x00003210 to register $t0
    ori     $t0, $t0, 0x3210
    lui     $t1, 0xde0f
    ori     $t1, $t1, 0xbeef	# $t1 = 0xde0fbeef
    sw      $t1, 0($t0)         
	sh      $s1, 2($t0)         #        
	lw      $t2, 0($t0)         # $t2 = 0xde0f0001
	lui     $t3, 0xde0f
    ori     $t3, $t3, 0x0001	# $t3 = 0xde0f0001
	subu    $t1, $t3, $t2       # should be 0
	sltiu   $v0, $t1, 1
    sw      $v0, 4($s0)         # Set the test result
    sw      $s1, 0($s0)         # Set 'done'

$done:
    j       $done
    nop

    .end boot
