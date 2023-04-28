	.data

buffsize: .word 20
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

#loading test value into t1
li $t1, 100

#print the test value
jal printT1Reg

#alter test value (inc by 100)
add $t1, $t1, 100

#print altered test value
jal printT1Reg

#about to call procedure that also uses caller saved $t1. Push $t1 to stack
addi $sp, $sp, -4
sw $t1, 4($sp)

#print confirmation that value pushed to stack
li $v0, 4
la $a0, push
syscall

jal testProcedure

#restore main's $t1 valuem dec stack pointer
lw $t1, 4($sp)
addi $sp, $sp, 4

#print confirmation value popped from stack
li $v0, 4
la $a0, pop
syscall

#print value of $t1 to verify value restored
jal printT1Reg

#exit program
li $v0, 10
syscall



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

#using a callee saved register that testProcedure uses to save the return address. Must push to stack
addi $sp, $sp, -4
sw $s0, 4($sp)
#save the return address before JAL links and overwrites $ra on printNewline call. Free to use $s0 since we pushed $s0 to stack
move $s0, $ra
jal printNewLine
#restore the return address into $ra
move $ra, $s0
#restore callee saved register for testProcedure to use like normal.
lw $s0, 4($sp)
addi $sp, $sp, 4
jr $ra
	
	
	
testProcedure:
li $t1, 20
#printT1Reg will test the nested procedure calls. 
#printT1Reg is using callee saved registers. Because this is going into nested calls, need to save this procedure's
#return address because $ra will be overwritten multiple times depending on the call
move $s0, $ra
jal printT1Reg
move $ra, $s0
jr $ra
