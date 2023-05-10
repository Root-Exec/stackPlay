	.data

buffsize: .word 20
pi: .float 3.1459
testString: .asciiz "This is a test\n"
push: .asciiz "Value pushed to stack\n"
pop: .asciiz "Value popped from stack\n"
t1reg: .asciiz "Current value in $t1: "
newLine: .asciiz "\n"


.globl main
	
	.text
		
main:
#print this is a test
li $v0, 4
la $a0, testString
syscall

#loading test value into t1 (100)
li $t1, 100

#print the test value
jal printT1Reg

#alter test value (inc by 100)
add $t1, $t1, 100

#print altered test value (200)
jal printT1Reg

#push $t1 to stack because $t registers are caller saved
addi $sp, $sp, -4
sw $t1, 4($sp)

#print confirmation that value pushed to stack
li $v0, 4
la $a0, push
syscall

jal testProcedure

#restore main's $t1 value (200, subprocedures changed it to 20) && dec stack pointer
lw $t1, 4($sp)
addi $sp, $sp, 4

#print confirmation value popped from stack
li $v0, 4
la $a0, pop
syscall

#print value of $t1 to verify value restored
jal printT1Reg

#test loading full 32 bit numbers into a register, test number is 2000000 (0x001e8480)
lui $s2, 0x001e
ori $s2, $s2, 0x8480


#print out full 32 bit number
li $v0, 1
la $a0, ($s2)
syscall

lwc1 $f12, pi
li $v0, 2
syscall

#exit program
li $v0, 10
syscall


#########procedure listing###########

printNewLine:
li $v0, 4
la $a0, newLine
syscall
jr $ra


printT1Reg:
#print current value of $t1
li $v0, 4
la $a0, t1reg
syscall
li $v0, 1
la $a0, ($t1)
syscall

#push current $ra onto stack and call procedure
add $sp, $sp, -8
sw $ra, 8($sp)

jal printNewLine

#restore $ra
lw $ra, 8($sp)
add $sp, $sp, 8
jr $ra
	
	
testProcedure:
li $t1, 20
#printT1Reg will test the nested procedure calls order of events. 

#save return address to stack
add $sp, $sp, -8
sw $ra, 8($sp)

#intentionally not pushing $t1 to stack to call printT1Reg which will verify the new $t1 value (20, previously 200)
#$t1 is a caller saved register and will normally push $t1 to stack before calling another procedure
jal printT1Reg

#restore $ra and return
lw $ra, 8($sp)
add $sp, $sp, 8
jr $ra
