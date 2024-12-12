main:
lw s2,0x00000004(x0) #number of elements in the array
lw s3,0x00000008(x0) #address of array
addi s4,x0,1

rutina:
lw a0,0(s3)  # array[0]
jal floor_log
sw a1,0(s3)
addi s3,s3,4
sub s2,s2,s4
beq s2,x0,done
beq x0, x0, rutina

floor_log:
floor_log a1,a0
jalr x0, x1, 0

done:



