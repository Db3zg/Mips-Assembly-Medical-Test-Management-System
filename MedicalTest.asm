# Mosa Sbeih 1211250
# Abdulghafer Qeel 1210408
.data
outputfilename: .asciiz "Tests_file.txt"
filename: .asciiz "Tests_file.txt"
bufferLength: .word 1024
buffer: .space 1024 
output_buffer: .space 1024
fp: .float 0.0
node_size: .word 36
zero_float: .float 0.0
char1: .byte 'g'        
char2: .byte 'G'
char3: .byte 'D' 
char4: .byte 'P'
hgblow: .float 13.8
hgbup: .float 17.2
bgtlow: .float 70
bgtup: .float 90
ldl: .float 100
bptlow: .float 80
bptup: .float 120
file_not_found_msg: .asciiz "FILE NOT FOUND!\n"
enter_patient_id_message: .asciiz "Enter Patient ID\n"
enter_test_type_message: .asciiz "Enter Test Type ID\n"
enter_date_year_message: .asciiz "\nWhich year has the test taken place?\n"
enter_date_month_message: .asciiz "Which month?\n"
enter_test_result_message: .asciiz "Enter Test Result\n"
enter_BPT_test_result_message: .asciiz "Enter Second Test Result\n"
year_less_than_start_msg: .asciiz "End Year cannot be less than Start Year.\n"
month_less_than_start_msg: .asciiz "End Month cannot be less than Start Month.\n"
period_1_year_prompt: .asciiz "enter the start date year:\n"
period_1_month_prompt: .asciiz "enter the start date month:\n"
period_2_year_prompt: .asciiz "enter the end date year:\n"
period_2_month_prompt: .asciiz "enter the end date month:\n"
type_test_input: .space 4
length: .space 64  # Allocate space for the input string
msg_hgb: .asciiz "Average test Hgb: "
msg_bgt: .asciiz "Average test BGT: "
msg_ldl: .asciiz "Average test LDL: "
msg_bpt: .asciiz "Average test BPT: "
newline: .asciiz "\n"
what_line_to_message: .asciiz "\nWhat line do you want to apply the operation?\n"
epsilon: .float 0.001
float100: .float 100.0
error_msg: .asciiz "\nInvalid input. Please try again.\n"
empty_msg: .asciiz "\nNo input provided. Please enter an integer.\n"
test_type_menu: .asciiz "Select a test:\n1. Hemoglobin (Hgb)\n2. Blood Glucose Test (BGT)\n3. Cholesterol Low-Density Lipoprotein (LDL)\n4. Blood Pressure Test (BPT)\n"
test_type_prompt: .asciiz "Enter the number of your choice: \n"
test_type_error_msg: .asciiz "\nInvalid choice. Please enter a number between 1 and 4.\n"
test_type_empty_msg: .asciiz "\nNo input provided. Please enter a number.\n"
year_prompt: .asciiz "Enter a year (2000-2025)\n"
year_error_msg: .asciiz "\nInvalid input. Please ensure you enter a four-digit year between 2000 and 2025.\n"
year_empty_msg: .asciiz "\nNo input provided. Please enter a four-digit year.\n"
month_prompt: .asciiz "Enter a month (1-12): "
month_error_msg: .asciiz "\nInvalid input. Please enter a valid month between 1 and 12.\n"
month_empty_msg: .asciiz "\nNo input provided. Please enter a month.\n"
test_result_prompt: .asciiz "Enter a Test Result: \n"
test_result_error_msg: .asciiz "\nInvalid input. Please enter a valid floating-point number.\n"
test_result_empty_msg: .asciiz "\nNo input provided. Please enter a number.\n"
BPT_test_result_prompt: .asciiz "Enter a Second Test Result: \n"
choice_error_msg: .asciiz "\nInvalid choice. Please enter a valid number.\n"
choice_empty_msg: .asciiz "\nNo input provided. Please enter a number.\n"
print_msg_no_tests: .asciiz "\nPatient ID Does not exits!\n"
choice_buffer: .space 3   
BPT_test_result_buffer: .space 32  
test_result_buffer: .space 32 
ten_float: .float 10.0
year_buffer: .space 6  
test_type_buffer: .space 2
month_buffer: .space 4  
patient_id_buffer: .space 16 
.text

main:
#---------------------------------------------FILE READ AND STORE TO MEMORY---------------------------------------------------------------------#
        # create linked list
  	lw $a0, node_size   # load size of the node structure
  	li $v0, 9    # syscall for memory allocation 
	syscall # the address of the new node is at $v0
   			 
   	move $t5 ,$v0 #set the address of the head in  $s0
   	move $t6 ,$v0 #set the address of the  last node (head) in  $s1
   			  
   	sw $zero, 36($t5)        # head -> next = NULL
        # read file
	la $a0 , filename  #address of null-terminated filename string
	li $a1 , 0 #read only
	li $a2 , 0 #ignored
	li $v0 , 13 #open file
	syscall
		
	blt $v0 , $zero , file_not_found
	j success
	
	
	success: #else
		move $t0 , $v0  #save file descriptor in $t0
		
	
		move $a0 , $t0  #File descriptor		
		la $a1, buffer	# address of input buffer
		li $a2, 1024	# maximum number of characters to read
		li $v0 , 14 # read from file
		syscall			
			
		 move $a0, $t0 #File descriptor      
  		 li $v0, 16   # close the file
  		 syscall
  		la $t3, buffer
  		lb $t0, 0($t3)
  		beqz $t0, menu
		loop:
    		jal parse_data 
    		jal patient_id 
    		jal test_type 
    		jal year 
    		jal month
    		jal test_result
    		jal store_data
    		beqz $t0, cont
    		j loop
    		
    		cont:
    		j menu
    		file_not_found:
    		li $v0, 4
    		la $a0, file_not_found_msg
    		syscall
    		
    		j file_not_found_2
    		
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------WRITING CONTENT OF MEMORY TO FILE AND EXITING-----------------------------------------------------#
exit_program:
    jal write_to_file
    file_not_found_2:
    li $v0, 10          
    syscall             # Terminate the program
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------INITIALIZING DATA---------------------------------------------------------------------------------#
parse_data:
        move $s0 , $zero # register to patientID
   	move $s1 , $zero #register to store year
   	move $s2 , $zero #register to store month
   	move $s3 , $zero #register to store the first char in the type
   	move $s4 , $zero #register to store the second char in the type
   	move $s5 , $zero #register to store the third char in the type
   	move $s6 , $zero #register to store the result
   	move $s7 , $zero #register to store the result
   	move $t7 , $zero #register to store the result
   	move $t8 , $zero #register to store the result
   	mtc1 $zero, $f5
   	jr $ra
#---------------------------------------------READING PATIENT ID--------------------------------------------------------------------------------#
patient_id:
    bne $t0, 10, not_line_break
    addi $t3, $t3, 1
    not_line_break:
    lb $t0, 0($t3)
    beq $t0, ':', back_patient
    sub $t0, $t0, '0'
    mul $s0, $s0, 10
    add $s0, $s0, $t0
    addi $t3, $t3, 1
    j patient_id
    back_patient:
    	jr $ra	
#---------------------------------------------READING TEST TYPE---------------------------------------------------------------------------------#
test_type:
    addi $t3, $t3, 1    # Skip the " " delimiter
    lb $s3, 1($t3)      # Load the first character of Test Type into $s1
    lb $s4, 2($t3)      # Load the second character of Test Type into $s2
    lb $s5, 3($t3)      # Load the third character of Test Type into $s3

    addi $t3, $t3, 6    
    jr $ra

    # Parse Year
#---------------------------------------------READING YEAR--------------------------------------------------------------------------------------#
year:
    lb $t0, 0($t3) 	
    beq $t0, '-', back_year
    sub $t0, $t0, '0'
    mul $s1, $s1, 10
    add $s1, $s1, $t0
    addi $t3, $t3, 1	
    j year
    back_year:
    	jr $ra
    	
#---------------------------------------------READING MONTH-------------------------------------------------------------------------------------#
month:
    addi $t3, $t3, 1
    lb $t0, 0($t3) 
    sub $t0, $t0, '0'
    mul $s2, $s2, 10
    add $s2, $s2, $t0
    addi $t3, $t3, 1
    lb $t0, 0($t3) 
    sub $t0, $t0, '0'
    mul $s2, $s2, 10
    add $s2, $s2, $t0
    addi $t3, $t3, 3
    mtc1 $zero, $f0        # Move the integer denominator to floating-point register $f2
    cvt.s.w $f0, $f0     # Convert the content of $f2 to floating-point
    jr $ra
#---------------------------------------------READING TEST RESULTS------------------------------------------------------------------------------#
# READING PART BEFORE DECIMAL POINT OR INTEGER
test_result:
    lb $t0, 0($t3) 	
    beq $t0, '\n', back
    beq $t0, ',', back
    beqz $t0, back
    beq $t0, '.', test_result_float
    sub $t0, $t0, '0'
    mul $s6,$s6, 10
    add $s6, $s6, $t0
    addi $t3, $t3, 1
    j test_result    
# READING PART AFTER DECIMAL POINT
test_result_float:
    addi $t3, $t3, 1
    lb $t0, 0($t3) 	
    beq $t0, '\n', convert_to_float
    beq $t0, 13, convert_to_float
    beqz $t0, convert_to_float
    beq $t0, ',', convert_to_float
    add $t8, $t8, 1
    sub $t0, $t0, '0'
    mul $t7,$t7, 10
    add $t7, $t7, $t0
    j test_result_float
# ADDING PART BEFORE AND AFTER DECIMAL TOGETHER AND STORING IT AS FLOAT
convert_to_float:
    li $t9, 1
    pow:
        beqz $t8, continue
        mul $t9, $t9, 10
        sub $t8, $t8, 1
        j pow
    continue:
    	mtc1 $t7, $f2        
    	cvt.s.w $f2, $f2    
    	mtc1 $t9, $f3        
    	cvt.s.w $f3, $f3     
    	div.s $f0, $f2, $f3
    	back:
    	mtc1 $s6, $f1        
    	cvt.s.w $f1, $f1     
    	add.s $f0, $f0, $f1
# CHECKING IF TEST IS BPT IF SO READ 2ND TEST
li $t7, 'B'
li $t8, 'P'
bne $s3, $t7, not_BPT
bne $s4, $t8, not_BPT
# INITLIAZING REGISTERS USED IN FIRST TEST RESULT
    addi $t3, $t3, 2
    move $s6 , $zero #register to store the result
    move $t7 , $zero #register to store the result
    move $t8 , $zero #register to store the result
    move $t9 , $zero #register to store the result
# BEFORE DECIMAL POINT
    test_result_BPT:
    lb $t0, 0($t3) 	
    beq $t0, '\n', back_BPT
    beqz $t0, back_BPT
    beq $t0, '.', test_result_float_BPT
    beq $t0, 13, back_BPT
    sub $t0, $t0, '0'
    mul $s6,$s6, 10
    add $s6, $s6, $t0
    addi $t3, $t3, 1
    j test_result_BPT 
# AFTER DECIMAL POINT
    test_result_float_BPT:
    addi $t3, $t3, 1
    lb $t0, 0($t3) 	
    beq $t0, '\n', convert_to_float_BPT
    beq $t0, 13, convert_to_float_BPT
    beqz $t0, convert_to_float_BPT
    add $t8, $t8, 1
    sub $t0, $t0, '0'
    mul $t7,$t7, 10
    add $t7, $t7, $t0
    j test_result_float_BPT
# ADDING PARTS BEFORE AND DECIMAL POINT AND STORING IT AS FLOAT
    convert_to_float_BPT:
    li $t9, 1
    pow_BPT:
        beqz $t8, continue_BPT
        mul $t9, $t9, 10
        sub $t8, $t8, 1
        j pow_BPT
    continue_BPT:
    	mtc1 $t7, $f2        
    	cvt.s.w $f2, $f2    
    	mtc1 $t9, $f3        
    	cvt.s.w $f3, $f3     
    	div.s $f5, $f2, $f3
    	back_BPT:
    	mtc1 $s6, $f1        
    	cvt.s.w $f1, $f1     
    	add.s $f5, $f5, $f1

not_BPT:
jr $ra
        
#---------------------------------------------STORING TEST DATA TO MEMORY AS A NODE IN THE LINKED LIST------------------------------------------#
store_data:
    lw $a0, node_size     # load size of the node structure
    li $v0, 9             # syscall for memory allocation
    syscall # the address of the new node is at $v0
    sw $v0, 32($t6)        # store the address of the last node in the prev
   			 
    move $t6 , $v0 #set the address of the  new last node  in  $s1
    sw $s0, 0($t6)     # Store patientID
    sw $s3, 4($t6)     # Store testType char1
    sw $s4, 8($t6)     # Store testType char2
    sw $s5, 12($t6)    # Store testType char3
    sw $s1, 16($t6)    # Store year
    sw $s2, 20($t6)    # Store month
    swc1 $f0, 24($t6)  
    swc1 $f5, 28($t6)  
    sw $zero, 32($t6)  # Next pointer set to NULL$
    addi $t3, $t3, 1
    lb $t0, 0($t3)
    
    jr $ra             # Return to caller
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------PRINTING TESTS BASED ON PATIENT ID INPUT (USED IN UPDATE AND DELETE)------------------------------#
print_list:
# READING PATIENT ID FROM USER AND VALIDATION OF INPUT 
patient_id_choice:
    li $v0, 4
    la $a0, enter_patient_id_message
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, patient_id_buffer
    li $a1, 32
    syscall
    la $t7, patient_id_buffer

    # Check if the input is empty
    lb $t0, 0($t7)  # Load the first character of the buffer
    beqz $t0, patient_id_choice_empty_input  # If it's zero, input is empty
    beq $t0, 10, patient_id_choice_empty_input  # If it's zero, input is empty

    # Check for valid integer (digits and possibly one leading '-')
    la $t1, patient_id_buffer   # Pointer to the start of the buffer
    li $t2, 1        # Flag to check validity, 1 is valid, 0 is invalid

    lb $t4, 0($t1)
    j patient_id_choice_check_first_digit

patient_id_choice_check_digits:
    lb $t4, 0($t1)
patient_id_choice_check_first_digit:
    beqz $t4, patient_id_choice_end_check  # End of string
    beq $t4, 10, patient_id_choice_end_check  # End of string
    blt $t4, '0', patient_id_choice_error # Less than '0'
    bgt $t4, '9', patient_id_choice_error # Greater than '9'
    addiu $t1, $t1, 1  # Move to the next character
    j patient_id_choice_check_digits

patient_id_choice_invalid_input:
    li $t2, 0  # Set flag to invalid

patient_id_choice_end_check:
    beqz $t2, patient_id_choice_error  # If flag is 0, input is invalid
    la $t3, patient_id_buffer
    li $s0, 0
patient_id_choice_loop:
    lb $t0, 0($t3)
    beqz $t0, patient_id_choice_done
    beq $t0, 10, patient_id_choice_done
    sub $t0, $t0, '0'
    mul $s0, $s0, 10
    add $s0, $s0, $t0
    addi $t3, $t3, 1
    j patient_id_choice_loop
    
patient_id_choice_error:
    li $v0, 4
    la $a0, error_msg
    syscall
    j patient_id_choice

patient_id_choice_empty_input:
    li $v0, 4
    la $a0, empty_msg
    syscall
    j patient_id_choice
patient_id_choice_done:
    move $t8, $s0    
    move $t9, $zero    
    
    move $t2, $t5               # Start at the head of the list
    lw $t2, 32($t2)             # Load the address of the first node
# START PRINTING AFTER VALIDATING INPUT PATIENT ID
print_list_loop:
    # Print PatientID
    lw $t0, 0($t2)              # Load PatientID
    bne $t0, $t8, skip_print    
    
    addi $t9, $t9, 1
    li $v0, 1
    move $a0, $t9
    syscall			# Print Test number 
    li $v0, 11 
    li $a0, '-' 
    syscall			# Print dash
    li $a0, ' '
    syscall			# Print space    
    
    li $v0, 1
    move $a0, $t0
    syscall                     # Print PatientID
    li $v0, 11
    li $a0, ':'
    syscall                     # Print ':'
    li $a0, ' '
    syscall                     # Print space

    lw $t0, 4($t2)              # Load TestType character 1
    move $a0, $t0
    syscall                     # Print TestType character 1
    lw $t0, 8($t2)              # Load TestType character 2
    move $a0, $t0
    syscall                     # Print TestType character 2
    lw $t0, 12($t2)             # Load TestType character 3
    move $a0, $t0
    syscall                     # Print TestType character 3

    li $v0, 11
    li $a0, ','
    syscall                     # Print ','
    li $a0, ' '
    syscall                     # Print space

    # Print Date (Year)
    lw $t0, 16($t2)             # Load Year
    li $v0, 1
    move $a0, $t0
    syscall                     # Print Year
    li $v0, 11
    li $a0, '-'
    syscall                     # Print '-'

    # Print Date (Month)
    lw $t0, 20($t2)             # Load Month
    li $v0, 1
    li $t7, 10
    ble $t7, $t0 move_on
    li $v0, 11            
    li $a0, '0'
    syscall                     # Print leading zero

move_on:
    li $v0, 1 
    move $a0, $t0
    syscall                     # Print Month

    li $v0, 11
    li $a0, ','
    syscall                     # Print ','
    li $a0, ' '
    syscall                     # Print space

    # Print Test Result
    lwc1 $f12, 24($t2)          # Load the float test result into $f12
    li $v0, 2                   # Syscall to print single precision float
    syscall

    # Additional print for specific test type "BPT"
    li $t7, 'P'
    lw $t0, 8($t2)              # Check if TestType[1] is 'P'
    bne $t0, $t7, not_BPT_print_list

    li $v0, 11
    li $a0, ',' 
    syscall                     # Print ','
    li $a0, ' ' 
    syscall                     # Print space
    lwc1 $f12, 28($t2)          # Load additional float result for "BPT"
    li $v0, 2
    syscall                     # Print additional float result

not_BPT_print_list:
    li $v0, 11
    li $a0, '\n' 
    syscall                     # Print newline
skip_print:
    lw $t2, 32($t2)             # Move to the next node
    beqz $t2, end_print_list_loop

    j print_list_loop           # Jump back to start of loop

end_print_list_loop:
    bne $t9, 0, patient_id_exits
    li $v0, 4
    la $a0, print_msg_no_tests
    syscall
    j patient_id_choice
    patient_id_exits:
    li $v0, 4
    la $a0, what_line_to_message
    syscall

# READING WHICH LINE TO DO THE OPERATION ON (UPDATE AND DELETE)
read_input:
    # Read input as a string
    li $v0, 8
    la $a0, choice_buffer
    li $a1, 3  # Reading up to 2 digits plus newline
    syscall

    # Validate input
    la $t1, choice_buffer
    lb $t0, 0($t1)
    beqz $t0, choice_invalid_choice  # Check for empty input
    lb $t3, 1($t1)
    beqz $t3, choice_check_digit          # Only one character entered

    # Check for newline if two characters were entered
    li $t4, 10
    bne $t3, $t4, choice_invalid_choice
    li $t4, 0
    lb $t4, 2($t1)
    beqz $t4, choice_check_digit  # Valid input if second character is newline

choice_check_digit:
    # Reset $t0 to first character, validate it is a digit
    lb $t0, 0($t1)
    li $t4, '0'
    blt $t0, $t4, choice_invalid_choice
    li $t4, '9'
    bgt $t0, $t4, choice_invalid_choice

    # Convert from ASCII to integer
    sub $t0, $t0, '0'

    # Check if choice is within the range [0, $t9]
    li $t7, 0       # Using $t7 as it is to store the final value
    move $t7, $t0
    blt $t7, 1, choice_invalid_choice
    bgt $t7, $t9, choice_invalid_choice

    # Continue with the operation based on the valid input
    j choice_continue

choice_invalid_choice:
    li $v0, 4
    la $a0, choice_error_msg
    syscall
    j read_input # Go back to read input again

choice_continue:

    jr $ra                    # Return from the procedure
    
    

.macro print_str (%str)
	.data
myLabel: .asciiz %str
	.text
	li $v0, 4
	la $a0, myLabel
	syscall
	.end_macro
	
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------MENU----------------------------------------------------------------------------------------------#
menu:
    print_str ("choose an operation to do:\n")
    print_str ("1) Add new medical test\n")
    print_str ("2) Search by patient ID\n")
    print_str ("3) Search for unnormal tests\n")
    print_str ("4) Average test value\n")
    print_str ("5) Update an existing test result\n")
    print_str ("6) Delete a test\n") 
    print_str ("7) Exit\n")
# VALIDATING MENU CHOICE INPUT 
menu_read_input:
    # Read input as a string
    li $v0, 8
    la $a0, choice_buffer
    li $a1, 3  # Reading up to 2 digits plus newline
    syscall

    # Validate input
    la $t1, choice_buffer
    lb $t0, 0($t1)
    beqz $t0, menu_choice_invalid_choice  # Check for empty input
    lb $t3, 1($t1)
    beqz $t3, menu_choice_check_digit     # Only one character entered

    # Check for newline if two characters were entered
    li $t4, 10
    bne $t3, $t4, menu_choice_invalid_choice
    li $t4, 0
    lb $t4, 2($t1)
    beqz $t4, menu_choice_check_digit  # Valid input if second character is newline

menu_choice_check_digit:
    # Reset $t0 to first character, validate it is a digit
    lb $t0, 0($t1)
    li $t4, '0'
    blt $t0, $t4, menu_choice_invalid_choice
    li $t4, '9'
    bgt $t0, $t4, menu_choice_invalid_choice

    # Convert from ASCII to integer
    sub $t0, $t0, '0'

    # Check if choice is within the range [1, 7]
    move $t4, $t0
    li $t9, 7        # Set upper limit to 7
    blt $t4, 1, menu_choice_invalid_choice
    bgt $t4, $t9, menu_choice_invalid_choice

    # Continue with the operation based on the valid input
    j menu_choice_continue

menu_choice_invalid_choice:
    li $v0, 4
    la $a0, choice_error_msg
    syscall
    j menu  # Go back to read input again
# NETWORKING CHOICE TO OPERATION
menu_choice_continue:
    beq $t4, 7, exit_program
    beq $t4, 2, search_by_id
    beq $t4, 1, add_new_test
    beq $t4, 3, print_up_normal_tests
    beq $t4, 4, average_test_value
    beq $t4, 5, option_5
    beq $t4, 6, option_6
    option_5:
    jal print_list
    jal update
    j menu
    option_6:
    jal print_list
    jal delete
    j menu
    

#---------------------------------------------ADDING A NEW TEST TO TESTS (MEMORY)---------------------------------------------------------------------#
add_new_test:
# READING PATIENT ID AND VALIDATING
patient_id_new_node_part:
    li $v0, 4
    la $a0, enter_patient_id_message
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, patient_id_buffer
    li $a1, 32
    syscall
    la $t7, patient_id_buffer

    # Check if the input is empty
    lb $t0, 0($t7)  # Load the first character of the buffer
    beqz $t0, patient_id_empty_input  # If it's zero, input is empty
    beq $t0, 10, patient_id_empty_input  # If it's zero, input is empty

    # Check for valid integer (digits and possibly one leading '-')
    la $t1, patient_id_buffer   # Pointer to the start of the buffer
    li $t2, 1        # Flag to check validity, 1 is valid, 0 is invalid
    li $t3, '-'      # ASCII value for '-'

    lb $t4, 0($t1)
    beq $t4, $t3, check_digits # If first character is '-', skip it in digit check
    j check_first_digit

check_digits:
    lb $t4, 0($t1)
check_first_digit:
    beqz $t4, end_check  # End of string
    beq $t4, 10, end_check  # End of string
    blt $t4, '0', patient_id_invalid_input  # Less than '0'
    bgt $t4, '9', patient_id_invalid_input # Greater than '9'
    addiu $t1, $t1, 1  # Move to the next character
    j check_digits

patient_id_invalid_input:
    li $t2, 0  # Set flag to invalid

end_check:
    beqz $t2, patient_id_error  # If flag is 0, input is invalid
    la $t3, patient_id_buffer
    li $s0, 0
new_node_patient_id:
    bne $t0, 10, new_node_not_line_break
    addi $t3, $t3, 1
    new_node_not_line_break:
    lb $t0, 0($t3)
    beqz $t0, new_node_test_type_medical
    beq $t0, 10, new_node_test_type_medical
    sub $t0, $t0, '0'
    mul $s0, $s0, 10
    add $s0, $s0, $t0
    addi $t3, $t3, 1
    j new_node_patient_id
    
patient_id_error:
    li $v0, 4
    la $a0, error_msg
    syscall
    j patient_id_new_node_part

patient_id_empty_input:
    li $v0, 4
    la $a0, empty_msg
    syscall
    j patient_id_new_node_part
    
# READING Test Type AND VALIDATING
new_node_test_type_medical:
    # Display menu
    li $v0, 4
    la $a0, test_type_menu
    syscall

    # Read one character as input
    li $v0, 8           # Syscall to read a string
    la $a0, test_type_buffer      # Pointer to buffer
    li $a1, 3          # Max characters to read (including null terminator)
    syscall
   
    la $t1, test_type_buffer
    lb $t0, 1($t1)
    bne $t0, 10, test_type_invalid_choice 
    # Check if the input is a valid choice (between '1' and '4')
    lb $t0, 0($t1)
    beqz $t0, test_type_invalid_choice 
    beq $t0, 10, test_type_invalid_choice 
    li $t1, '1'
    li $t2, '4'
    blt $t0, $t1, test_type_empty_choice   # If less than '1'
    bgt $t0, $t2, test_type_empty_choice   # If greater than '4'

    sub $t0 , $t0, '0'

test_type_store_choice:

    beq $t0, 1, store_hgb
    beq $t0, 2, store_bgt
    beq $t0, 3, store_ldl
    beq $t0, 4, store_bpt

store_hgb:
    li $s3, 'H'
    li $s4, 'g'
    li $s5, 'b'
    j new_node_year

store_bgt:
    li $s3, 'B'
    li $s4, 'G'
    li $s5, 'T'
    j new_node_year

store_ldl:
    li $s3, 'L'
    li $s4, 'D'
    li $s5, 'L'
    j new_node_year

store_bpt:
    li $s3, 'B'
    li $s4, 'P'
    li $s5, 'T'
    j new_node_year

test_type_empty_choice:
    li $v0, 4
    la $a0, test_type_empty_msg
    syscall
    j new_node_test_type_medical
    
test_type_invalid_choice:
    li $v0, 4
    la $a0, test_type_error_msg
    syscall
    j new_node_test_type_medical
# READING YEAR AND VALIDATING
new_node_year:
    # Display prompt
    li $v0, 4
    la $a0, year_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, year_buffer
    li $a1, 6  # Allow space for 4 digits, a newline, and a null terminator
    syscall

    # Check if input is empty
    la $t4, year_buffer
    lb $t0, 0($t4)
    beqz $t0, year_handle_empty

    # Ensure only 4 characters are digits and check for newline as fifth character
    la $a0, year_buffer  # Reload address of buffer
    li $t1, 0       # Counter for number of digits
    li $t2, 0       # Accumulator for converting string to integer
    li $t9, 10

year_validate_input:
    lb $t4, 0($a0)
    beqz $t4, year_handle_error   # If null character, error out if not at 4th position
    beq $t4, 10, year_check_length  # If newline, check count
    blt $t4, '0', year_handle_error  # Less than '0'
    bgt $t4, '9', year_handle_error  # Greater than '9'
    sub $t4, $t4, '0'           # Convert from ASCII to integer
    mul $t2, $t2, $t9          # Shift previous digits left
    add $t2, $t2, $t4          # Add new digit
    addi $t1, $t1, 1            # Increment digit count
    addiu $a0, $a0, 1           # Move to next character
    j year_validate_input

year_check_length:
    li $t7, 4
    bne $t1, $t7, year_handle_error  # If count is not 4, error

    # Validate year range
    li $t8, 2000
    li $t7, 2025
    blt $t2, $t8, year_handle_error  # Less than 2000
    bgt $t2, $t7, year_handle_error  # Greater than 2025

    # Store the valid year in $s1
    move $s1, $t2

    j new_node_month

year_handle_empty:
    li $v0, 4
    la $a0, year_empty_msg
    syscall
    j new_node_year

year_handle_error:
    li $v0, 4
    la $a0, year_error_msg
    syscall
    j new_node_year

new_node_month:
    # Display prompt
    li $v0, 4
    la $a0, month_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, month_buffer
    li $a1, 4  # Allow space for 2 digits, a newline, and a null terminator
    syscall

    # Check if input is empty
    la $t1, month_buffer
    lb $t0, 0($t1)
    beqz $t0, month_handle_empty  # If no input

    # Initialize variables for validation and conversion
    la $a0, month_buffer  # Pointer to start of buffer
    li $t1, 0       # Counter for number of digits
    li $t2, 0       # Accumulator for integer conversion
# READING MONTH AND VALIDATING
month_validate_input:
    lb $t4, 0($a0)  # Load the current character
    beqz $t4, month_check_length  # End of input string
    beq $t4, 10, month_check_length  # If newline, proceed to check length
    blt $t4, '0', month_handle_error  # Check if character is less than '0'
    bgt $t4, '9', month_handle_error  # Check if character is greater than '9'
    sub $t4, $t4, '0'           # Convert ASCII to integer
    li $t7, 10
    mul $t2, $t2, $t7          # Multiply current result by 10
    add $t2, $t2, $t4           # Add new digit
    addi $t1, $t1, 1            # Increment digit count
    addiu $a0, $a0, 1           # Move to next character
    j month_validate_input

month_check_length:
    li $t7, 2
    bgt $t1, $t7, month_handle_error  # If more than 2 digits, error

    # Validate month range
    li $t8, 1
    li $t7, 12
    blt $t2, $t8, month_handle_error  # If less than 1
    bgt $t2, $t7, month_handle_error  # If greater than 12

    # Store the valid month in $s1
    move $s2, $t2

    j new_node_test

month_handle_empty:
    li $v0, 4
    la $a0, month_empty_msg
    syscall
    j new_node_month

month_handle_error:
    li $v0, 4
    la $a0, month_error_msg
    syscall
    j new_node_month
# READING TEST RESULTS AND VALIDATING CAN READ INTEGER OR FLOAT
new_node_test:
    
    # Display prompt
    li $v0, 4
    la $a0, test_result_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, test_result_buffer
    li $a1, 32  # Allow space for input
    syscall

    # Check if input is empty
    la $t2, test_result_buffer
    lb $t0, 0($t2)
    beqz $t0, test_result_handle_empty  # If no input
    beq $t0, 10, test_result_handle_empty  # If newline, proceed to format check
    beq $t0, '.', test_result_handle_error  # If newline, proceed to format check
   
    li $t1, 0
    lwc1 $f0, zero_float
    lwc1 $f1, ten_float
test_result_validate_input:
    lb $t0, 0($t2)  # Load the current character
    beqz $t0, test_result_continue_program # End of input string
    beq $t0, 10, test_result_continue_program  # If newline, proceed to format check

    # Check for decimal point
    li $t7, '.'
    beq $t0, $t7, test_result_found_decimal  # Handle decimal point

    # Validate digit
    blt $t0, '0', test_result_handle_error  # Less than '0'
    bgt $t0, '9', test_result_handle_error  # Greater than '9'
    
    sub $t0, $t0, '0'
    
    mul $t1, $t1, 10
    add $t1, $t1, $t0
    
    addiu $t2, $t2, 1  # Move to next character
    j test_result_validate_input

test_result_found_decimal:
    addiu $t2, $t2, 1  # Move to next character
    lb $t0, 0($t2)
    beqz $t0, test_result_handle_error  # If no input
    beq $t0, 10, test_result_handle_error  # If newline, proceed to format check
    beq $t0, '.', test_result_handle_error  # If newline, proceed to format check
    li $t4, 1
test_result_decimal_loop:
    lb $t0, 0($t2)  # Load the current character
    beqz $t0, test_result_continue_program # End of input string
    beq $t0, 10, test_result_continue_program  # If newline, proceed to format check

    # Validate digit
    blt $t0, '0', test_result_handle_error  # Less than '0'
    bgt $t0, '9', test_result_handle_error  # Greater than '9'
    
    mul $t4, $t4, 10
    sub $t0, $t0, '0'
    mtc1 $t0, $f2
    cvt.s.w $f2, $f2
    
    mul.s $f0, $f0, $f1
    add.s $f0, $f0, $f2
    
    addiu $t2, $t2, 1  # Move to next character
    j test_result_decimal_loop

test_result_handle_empty:
    li $v0, 4
    la $a0, test_result_empty_msg
    syscall
    j new_node_test

test_result_handle_error:
    li $v0, 4
    la $a0, test_result_error_msg
    syscall
    j new_node_test

test_result_continue_program:
    # after decimal point
    mtc1 $t1, $f3
    cvt.s.w $f3, $f3
    # divisor
    mtc1 $t4, $f4
    cvt.s.w $f4, $f4
    
    div.s $f0, $f0, $f4
    add.s $f0, $f0, $f3
    
    bne $s4, 'P', not_BPT_test_result
BPT_new_node_test:
    
    # Display prompt
    li $v0, 4
    la $a0, BPT_test_result_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, BPT_test_result_buffer
    li $a1, 32  # Allow space for input
    syscall

    # Check if input is empty
    la $t2, BPT_test_result_buffer
    lb $t0, 0($t2)
    beqz $t0, BPT_test_result_handle_empty  # If no input
    beq $t0, 10, BPT_test_result_handle_empty  # If newline, proceed to format check
    beq $t0, '.', BPT_test_result_handle_error  # If newline, proceed to format check
   
    li $t1, 0
    lwc1 $f5, zero_float
    lwc1 $f1, ten_float
BPT_test_result_validate_input:
    lb $t0, 0($t2)  # Load the current character
    beqz $t0, BPT_test_result_continue_program # End of input string
    beq $t0, 10, BPT_test_result_continue_program  # If newline, proceed to format check

    # Check for decimal point
    li $t7, '.'
    beq $t0, $t7, BPT_test_result_found_decimal  # Handle decimal point

    # Validate digit
    blt $t0, '0', BPT_test_result_handle_error  # Less than '0'
    bgt $t0, '9', BPT_test_result_handle_error  # Greater than '9'
    
    sub $t0, $t0, '0'
    
    mul $t1, $t1, 10
    add $t1, $t1, $t0
    
    addiu $t2, $t2, 1  # Move to next character
    j BPT_test_result_validate_input

BPT_test_result_found_decimal:
    addiu $t2, $t2, 1  # Move to next character
    lb $t0, 0($t2)
    beqz $t0, BPT_test_result_handle_error  # If no input
    beq $t0, 10, BPT_test_result_handle_error  # If newline, proceed to format check
    beq $t0, '.', BPT_test_result_handle_error  # If newline, proceed to format check
    li $t4, 1
BPT_test_result_decimal_loop:
    lb $t0, 0($t2)  # Load the current character
    beqz $t0, BPT_test_result_continue_program # End of input string
    beq $t0, 10, BPT_test_result_continue_program  # If newline, proceed to format check

    # Validate digit
    blt $t0, '0', BPT_test_result_handle_error  # Less than '0'
    bgt $t0, '9', BPT_test_result_handle_error  # Greater than '9'
    
    mul $t4, $t4, 10
    sub $t0, $t0, '0'
    mtc1 $t0, $f2
    cvt.s.w $f2, $f2
    
    mul.s $f5, $f5, $f1
    add.s $f5, $f5, $f2
    
    addiu $t2, $t2, 1  # Move to next character
    j BPT_test_result_decimal_loop

BPT_test_result_handle_empty:
    li $v0, 4
    la $a0, test_result_empty_msg
    syscall
    j BPT_new_node_test

BPT_test_result_handle_error:
    li $v0, 4
    la $a0, test_result_error_msg
    syscall
    j BPT_new_node_test

BPT_test_result_continue_program:
    # after decimal point
    mtc1 $t1, $f3
    cvt.s.w $f3, $f3
    # divisor
    mtc1 $t4, $f4
    cvt.s.w $f4, $f4
    
    div.s $f5, $f5, $f4
    add.s $f5, $f5, $f3
    
    not_BPT_test_result:
# STORING READ DATA TO MEMORY
    jal store_data
	
    j menu
#---------------------------------------------AVERAGE VALUE FOR EACH TEST TYPE---------------------------------------------------------------------#
average_test_value:
    lwc1 $f1, zero_float    # sum for Hgb
    lwc1 $f2, zero_float      # sum for BGT
    lwc1 $f3, zero_float      # sum for LDL
    lwc1 $f4, zero_float      # sum for BPT
    lwc1 $f10 zero_float
    lwc1 $f11, zero_float
    
    li $t0, 0            # count for Hgb
    li $t1, 0            # count for BGT
    li $t2, 0            # count for LDL
    li $t3, 0            # count for BPT
    
    
    move $t4, $t5
    average_test_loop:
        lw $t4, 32($t4) 
        beqz $t4, end_average_test_loop
        
        lw $s3, 4($t4)
        lw $s4, 8($t4)
        lw $s5, 12($t4)
        lwc1 $f0, 24($t4)
        lwc1 $f10, 28($t4)
        
        li $a1, 'H'          
        li $a2, 'B'          
        li $a3, 'L'          
        
        beq $s3, $a1, Hgb # Hgb
        beq $s3, $a2, BGT_BPT # Hgb
        beq $s3, $a3, LDL # Hgb
        
        
        Hgb:
            add.s $f1, $f1, $f0
            addi $t0, $t0, 1
            j average_test_loop
        BGT_BPT:
            li $a1, 'G' 
            bne $s4, $a1, BPT
            add.s $f2, $f2, $f0
            addi $t1, $t1, 1
            j average_test_loop
            BPT:
                add.s $f4, $f4, $f0
                add.s $f11, $f11, $f10
                addi $t3, $t3, 1
                j average_test_loop
        LDL:
            add.s $f3, $f3, $f0
            addi $t2, $t2, 1
            j average_test_loop
        

    end_average_test_loop:
    beqz $t0, next_BGT
    mtc1 $t0, $f5        
    cvt.s.w $f5, $f5    
    div.s $f1, $f1, $f5
    next_BGT:
    beqz $t1, next_LDL
    mtc1 $t1, $f6        
    cvt.s.w $f6, $f6 
    div.s $f2, $f2, $f6
    next_LDL:
    beqz $t2, next_BPT
    mtc1 $t2, $f7        
    cvt.s.w $f7, $f7 
    div.s $f3, $f3, $f7
    next_BPT:
    beqz $t3, next_print_avg
    mtc1 $t3, $f8        
    cvt.s.w $f8, $f8 
    div.s $f4, $f4, $f8
    div.s $f11, $f11, $f8
    next_print_avg:
         # Print Hgb average
    li $v0, 4
    la $a0, msg_hgb
    syscall
    li $v0, 2
    mov.s $f12, $f1
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Print BGT average
    li $v0, 4
    la $a0, msg_bgt
    syscall
    li $v0, 2
    mov.s $f12, $f2
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Print LDL average
    li $v0, 4
    la $a0, msg_ldl
    syscall
    li $v0, 2
    mov.s $f12, $f3
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Print BPT average
    li $v0, 4
    la $a0, msg_bpt
    syscall
    li $v0, 2
    mov.s $f12, $f4
    syscall
    
    li $v0, 11
    li $a0, ','
    syscall
    
    li $v0, 11
    li $a0, ' '
    syscall
    
    li $v0, 2
    mov.s $f12, $f11
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    j menu
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------UPDATING TEST RESULT---------------------------------------------------------------------#
update:
    move $t9, $zero                           # Reset counter $t9 to zero

    move $t2, $t5                             # Start at the head of the list
    lw $t2, 32($t2)                           # Load the address of the first node

update_loop:
    lw $t0, 0($t2)                            # Load the PatientID from the current node

    bne $t0, $t8, not_update                  # If PatientID does not match $t8, skip updating
    addi $t9, $t9, 1                          # Increment counter
    bne $t9, $t7, not_update                  # If counter does not match $t7, skip updating

update_test:
# TAKING TEST RESULT AS INPUT AND VALIDATING     
    # Display prompt
    li $v0, 4
    la $a0, test_result_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, test_result_buffer
    li $a1, 32  # Allow space for input
    syscall

    # Check if input is empty
    la $t3, test_result_buffer
    lb $t0, 0($t3)
    beqz $t0, update_test_result_handle_empty  # If no input
    beq $t0, 10, update_test_result_handle_empty  # If newline, proceed to format check
    beq $t0, '.', update_test_result_handle_error  # If newline, proceed to format check
   
    li $t1, 0
    lwc1 $f0, zero_float
    lwc1 $f1, ten_float
update_test_result_validate_input:
    lb $t0, 0($t3)  # Load the current character
    beqz $t0, update_test_result_continue_program # End of input string
    beq $t0, 10, update_test_result_continue_program  # If newline, proceed to format check

    # Check for decimal point
    li $t7, '.'
    beq $t0, $t7, update_test_result_found_decimal  # Handle decimal point

    # Validate digit
    blt $t0, '0', update_test_result_handle_error  # Less than '0'
    bgt $t0, '9', update_test_result_handle_error  # Greater than '9'
    
    sub $t0, $t0, '0'
    
    mul $t1, $t1, 10
    add $t1, $t1, $t0
    
    addiu $t3, $t3, 1  # Move to next character
    j update_test_result_validate_input

update_test_result_found_decimal:
    addiu $t3, $t3, 1  # Move to next character
    lb $t0, 0($t3)
    beqz $t0, update_test_result_handle_error  # If no input
    beq $t0, 10, update_test_result_handle_error  # If newline, proceed to format check
    beq $t0, '.', update_test_result_handle_error  # If newline, proceed to format check
    li $t4, 1
update_test_result_decimal_loop:
    lb $t0, 0($t3)  # Load the current character
    beqz $t0, update_test_result_continue_program # End of input string
    beq $t0, 10, update_test_result_continue_program  # If newline, proceed to format check

    # Validate digit
    blt $t0, '0', update_test_result_handle_error  # Less than '0'
    bgt $t0, '9', update_test_result_handle_error  # Greater than '9'
    
    mul $t4, $t4, 10
    sub $t0, $t0, '0'
    mtc1 $t0, $f2
    cvt.s.w $f2, $f2
    
    mul.s $f0, $f0, $f1
    add.s $f0, $f0, $f2
    
    addiu $t3, $t3, 1  # Move to next character
    j update_test_result_decimal_loop

update_test_result_handle_empty:
    li $v0, 4
    la $a0, test_result_empty_msg
    syscall
    j update_test

update_test_result_handle_error:
    li $v0, 4
    la $a0, test_result_error_msg
    syscall
    j update_test

update_test_result_continue_program:
    # after decimal point
    mtc1 $t1, $f3
    cvt.s.w $f3, $f3
    # divisor
    mtc1 $t4, $f4
    cvt.s.w $f4, $f4
    
    div.s $f0, $f0, $f4
    add.s $f1, $f0, $f3

    # Check if test is BPT READ TEST RESULT AND VALIDATE                        
    lw $t0, 8($t2)                            # Load second character of TestType
    bne $t0, 'P', not_BPT_update              # If not 'P', skip second value update
    update_BPT_test:
    
    # Display prompt
    li $v0, 4
    la $a0, BPT_test_result_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, BPT_test_result_buffer
    li $a1, 32  # Allow space for input
    syscall

    # Check if input is empty
    la $t3, BPT_test_result_buffer
    lb $t0, 0($t3)
    beqz $t0, update_BPT_test_result_handle_empty  # If no input
    beq $t0, 10, update_BPT_test_result_handle_empty  # If newline, proceed to format check
    beq $t0, '.', update_BPT_test_result_handle_error  # If newline, proceed to format check
   
    li $t1, 0
    lwc1 $f5, zero_float
    lwc1 $f6, ten_float
update_BPT_test_result_validate_input:
    lb $t0, 0($t3)  # Load the current character
    beqz $t0, update_BPT_test_result_continue_program # End of input string
    beq $t0, 10, update_BPT_test_result_continue_program  # If newline, proceed to format check

    # Check for decimal point
    li $t7, '.'
    beq $t0, $t7, update_BPT_test_result_found_decimal  # Handle decimal point

    # Validate digit
    blt $t0, '0', update_BPT_test_result_handle_error  # Less than '0'
    bgt $t0, '9', update_BPT_test_result_handle_error  # Greater than '9'
    
    sub $t0, $t0, '0'
    
    mul $t1, $t1, 10
    add $t1, $t1, $t0
    
    addiu $t3, $t3, 1  # Move to next character
    j update_BPT_test_result_validate_input

update_BPT_test_result_found_decimal:
    addiu $t3, $t3, 1  # Move to next character
    lb $t0, 0($t3)
    beqz $t0, update_BPT_test_result_handle_error  # If no input
    beq $t0, 10, update_BPT_test_result_handle_error  # If newline, proceed to format check
    beq $t0, '.', update_BPT_test_result_handle_error  # If newline, proceed to format check
    li $t4, 1
update_BPT_test_result_decimal_loop:
    lb $t0, 0($t3)  # Load the current character
    beqz $t0, update_BPT_test_result_continue_program # End of input string
    beq $t0, 10, update_BPT_test_result_continue_program  # If newline, proceed to format check

    # Validate digit
    blt $t0, '0', update_BPT_test_result_handle_error  # Less than '0'
    bgt $t0, '9', update_BPT_test_result_handle_error  # Greater than '9'
    
    mul $t4, $t4, 10
    sub $t0, $t0, '0'
    mtc1 $t0, $f2
    cvt.s.w $f2, $f2
    
    mul.s $f5, $f5, $f6
    add.s $f5, $f5, $f2
    
    addiu $t3, $t3, 1  # Move to next character
    j update_BPT_test_result_decimal_loop

update_BPT_test_result_handle_empty:
    li $v0, 4
    la $a0, test_result_empty_msg
    syscall
    j update_BPT_test

update_BPT_test_result_handle_error:
    li $v0, 4
    la $a0, test_result_error_msg
    syscall
    j update_BPT_test

update_BPT_test_result_continue_program:
    # after decimal point
    mtc1 $t1, $f3
    cvt.s.w $f3, $f3
    # divisor
    mtc1 $t4, $f4
    cvt.s.w $f4, $f4
    
    div.s $f5, $f5, $f4
    add.s $f0, $f5, $f3

    swc1 $f0, 28($t2)                         # Store the second float in node at offset 28

not_BPT_update:
    swc1 $f1, 24($t2)                         # Store the first float in node at offset 24
    j end_update

not_update:
    lw $t2, 32($t2)                           # Load address of the next node
    beqz $t2, end_update                            # If end of list, go to menu
    j update_loop                             # Otherwise, continue update loop
end_update:
     jr $ra
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------DELETE A TEST FROM TESTS (MEMORY)-----------------------------------------------------------------#
# FIND THE NODE THAT HAS THE PATIENT ID FROM INPUT THEN GO THE LINE SPECIFIED BY INPUT
# GET PREVIOUS NODE AND NEXT NODE OF CURRENT NODE SET THE NEXT ADDRESS OF THE PREVIOUS NODE TO THE NEXT NODE OF CURRENT NODE
delete:
    move $t9, $zero                           # Reset counter $t9 to zero

    move $t2, $t5
    move $t1, $t2                             # Start at the head of the list
    lw $t2, 32($t2)                           # Load the address of the first node

delete_loop:
    lw $t0, 0($t2)                            # Load the PatientID from the current node

    bne $t0, $t8, not_delete                # If PatientID does not match $t8, skip updating
    addi $t9, $t9, 1                          # Increment counter
    bne $t9, $t7, not_delete                 # If counter does not match $t7, skip updating
    
    lw $t2 , 32($t2)
    sw $t2 , 32($t1)
    jr $ra

not_delete:
    lw $t2, 32($t2)
    lw $t1, 32($t1)                           # Load address of the next node
    beqz $t2, end_delete                            # If end of list, go to menu
    j delete_loop                             # Otherwise, continue update loop
end_delete:
    jr $ra
     
    
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------SEARCH FUNCTIONALITY BY ID0000--------------------------------------------------------------------#
search_by_id:
    
    print_str("choose an option:\n")
    print_str("1)Retrieve all patient tests\n")
    print_str("2)Retrieve all up normal patient tests\n")
    print_str("3)Retrieve all patient tests in a given specific period\n")
    print_str("4)Return to menu\n")
# MENU CHOICE READ AND VALIDATION
search_patient_read_input:
    # Read input as a string
    li $v0, 8
    la $a0, choice_buffer
    li $a1, 3  # Reading up to 2 digits plus newline
    syscall

    # Validate input
    la $t1, choice_buffer
    lb $t0, 0($t1)
    beqz $t0, search_patient_choice_invalid_choice  # Check for empty input
    lb $t3, 1($t1)
    beqz $t3, search_patient_choice_check_digit     # Only one character entered

    # Check for newline if two characters were entered
    li $t4, 10
    bne $t3, $t4, search_patient_choice_invalid_choice
    li $t4, 0
    lb $t4, 2($t1)
    beqz $t4, search_patient_choice_check_digit  # Valid input if second character is newline

search_patient_choice_check_digit:
    # Reset $t0 to first character, validate it is a digit
    lb $t0, 0($t1)
    li $t4, '0'
    blt $t0, $t4, search_patient_choice_invalid_choice
    li $t4, '9'
    bgt $t0, $t4, search_patient_choice_invalid_choice

    # Convert from ASCII to integer
    sub $t0, $t0, '0'

    # Check if choice is within the range [1, 7]
    move $t8, $t0
    blt $t8, 1, search_patient_choice_invalid_choice
    bgt $t8, 4, search_patient_choice_invalid_choice

    # Continue with the operation based on the valid input
    j search_patient_choice_continue

search_patient_choice_invalid_choice:
    li $v0, 4
    la $a0, choice_error_msg
    syscall
    j search_by_id  # Go back to read input again
    search_patient_choice_continue:
    beq $t8, 1, print_all_patient_test
    beq $t8, 2, print_up_normal_test
    beq $t8, 3, print_tests_in_period
    beq $t8, 4, menu
    
# FIRST PRINT ALL PATIENT TESTS
print_all_patient_test:  
# READING PATIENT ID AND VALIDATING
search_patient_id_choice:
    li $v0, 4
    la $a0, enter_patient_id_message
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, patient_id_buffer
    li $a1, 32
    syscall
    la $t7, patient_id_buffer

    # Check if the input is empty
    lb $t0, 0($t7)  # Load the first character of the buffer
    beqz $t0, search_patient_id_choice_empty_input  # If it's zero, input is empty
    beq $t0, 10, search_patient_id_choice_empty_input  # If it's zero, input is empty

    # Check for valid integer (digits and possibly one leading '-')
    la $t1, patient_id_buffer   # Pointer to the start of the buffer
    li $t2, 1        # Flag to check validity, 1 is valid, 0 is invalid

    lb $t4, 0($t1)
    j search_patient_id_choice_check_first_digit

search_patient_id_choice_check_digits:
    lb $t4, 0($t1)
search_patient_id_choice_check_first_digit:
    beqz $t4, search_patient_id_choice_end_check  # End of string
    beq $t4, 10, search_patient_id_choice_end_check  # End of string
    blt $t4, '0', search_patient_id_choice_error # Less than '0'
    bgt $t4, '9', search_patient_id_choice_error # Greater than '9'
    addiu $t1, $t1, 1  # Move to the next character
    j search_patient_id_choice_check_digits

search_patient_id_choice_invalid_input:
    li $t2, 0  # Set flag to invalid

search_patient_id_choice_end_check:
    beqz $t2, search_patient_id_choice_error  # If flag is 0, input is invalid
    la $t3, patient_id_buffer
    li $s0, 0
search_patient_id_choice_loop:
    lb $t0, 0($t3)
    beqz $t0, search_patient_id_choice_done
    beq $t0, 10, search_patient_id_choice_done
    sub $t0, $t0, '0'
    mul $s0, $s0, 10
    add $s0, $s0, $t0
    addi $t3, $t3, 1
    j search_patient_id_choice_loop
    
search_patient_id_choice_error:
    li $v0, 4
    la $a0, error_msg
    syscall
    j search_patient_id_choice

search_patient_id_choice_empty_input:
    li $v0, 4
    la $a0, empty_msg
    syscall
    j search_patient_id_choice
search_patient_id_choice_done:
    move $t7, $s0    
    move $t9, $zero    
    
    move $t2, $t5   # Start at the head of the list
    li $t4, 0
    lw $t2, 32($t2) 
print_all_patient_test_loop:
    lw $t0, 0($t2)  # Load PatientID
    bne $t0, $t7, pass
    addi $t4, $t4, 1
    # Print PatientID
    li $v0, 1
    move $a0, $t0 
    syscall
    li $v0, 11
    li $a0, ':' 
    syscall
    li $a0, ' ' 
    syscall
    
    # Print TestType
    lw $t0, 4($t2)  # Assuming TestType starts at offset 4 and is stored as ASCII codes for characters
    move $a0, $t0 
    syscall
    lw $t0, 8($t2)
    move $a0, $t0 
    syscall
    lw $t0, 12($t2)
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, ','
    syscall
    li $a0, ' '
    syscall

    # Print Date (Year)
    lw $t0, 16($t2)
    li $v0, 1
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, '-'
    syscall

    # Print Date (Month)
    lw $t0, 20($t2)
    li $v0, 1
    bgt $t0, 9, move_onn  # If month is less than 10, print leading zero
    li $a0, 0
    syscall

move_onn:
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, ','
    syscall
    li $a0, ' '
    syscall
    
    # Print Test Result
    lwc1 $f12, 24($t2)             # Load the float into $f12 (used by print float syscall)
    li $v0, 2                  # Syscall to print single precision float
    syscall
    
    
    li $t8, 'P'
    lw $t0, 8($t2)
    bne $t0, $t8, notBPT_print_list
    
    li $v0, 11
    li $a0, ',' 
    syscall
    li $v0, 11
    li $a0, ' ' 
    syscall
    lwc1 $f12, 28($t2)             # Load the float into $f12 (used by print float syscall)
    li $v0, 2                  # Syscall to print single precision float
    syscall

    
    notBPT_print_list:
    li $v0, 11
    li $a0, '\n' 
    syscall
 pass:   # Move to the next node 
    lw $t2, 32($t2)  # Move to the next node
    beqz $t2, end_print_all_patient_test_loop
    j print_all_patient_test_loop

end_print_all_patient_test_loop:
    beq $t4, 0, id_not_found
    j search_by_id

id_not_found:
    print_str("id wasn't found\n")
    j search_by_id

# PRINT UP NORMAL TESTS OF PATIENT     
print_up_normal_test:   
# READING PATIENT ID AND VALIDATING
print_str("enter patient ID to view his tests:\n")
up_normal_search_patient_id_choice:
    li $v0, 4
    la $a0, enter_patient_id_message
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, patient_id_buffer
    li $a1, 32
    syscall
    la $t7, patient_id_buffer

    # Check if the input is empty
    lb $t0, 0($t7)  # Load the first character of the buffer
    beqz $t0, up_normal_search_patient_id_choice_empty_input  # If it's zero, input is empty
    beq $t0, 10, up_normal_search_patient_id_choice_empty_input  # If it's zero, input is empty

    # Check for valid integer (digits and possibly one leading '-')
    la $t1, patient_id_buffer   # Pointer to the start of the buffer
    li $t2, 1        # Flag to check validity, 1 is valid, 0 is invalid

    lb $t4, 0($t1)
    j up_normal_search_patient_id_choice_check_first_digit

up_normal_search_patient_id_choice_check_digits:
    lb $t4, 0($t1)
up_normal_search_patient_id_choice_check_first_digit:
    beqz $t4, up_normal_search_patient_id_choice_end_check  # End of string
    beq $t4, 10, up_normal_search_patient_id_choice_end_check  # End of string
    blt $t4, '0', up_normal_search_patient_id_choice_error # Less than '0'
    bgt $t4, '9', up_normal_search_patient_id_choice_error # Greater than '9'
    addiu $t1, $t1, 1  # Move to the next character
    j up_normal_search_patient_id_choice_check_digits

up_normal_search_patient_id_choice_invalid_input:
    li $t2, 0  # Set flag to invalid

up_normal_search_patient_id_choice_end_check:
    beqz $t2, up_normal_search_patient_id_choice_error  # If flag is 0, input is invalid
    la $t3, patient_id_buffer
    li $s0, 0
up_normal_search_patient_id_choice_loop:
    lb $t0, 0($t3)
    beqz $t0, up_normal_search_patient_id_choice_done
    beq $t0, 10, up_normal_search_patient_id_choice_done
    sub $t0, $t0, '0'
    mul $s0, $s0, 10
    add $s0, $s0, $t0
    addi $t3, $t3, 1
    j up_normal_search_patient_id_choice_loop
    
up_normal_search_patient_id_choice_error:
    li $v0, 4
    la $a0, error_msg
    syscall
    j up_normal_search_patient_id_choice

up_normal_search_patient_id_choice_empty_input:
    li $v0, 4
    la $a0, empty_msg
    syscall
    j up_normal_search_patient_id_choice
up_normal_search_patient_id_choice_done:
    move $t7, $s0    
    move $t9, $zero   
    move $t2, $t5   # Start at the head of the list
    li $t4, 0
    lw $t2, 32($t2) 
print_up_normal_test_loop:
    lw $t0, 0($t2)  # Load PatientID
    bne $t0, $t7, passo
    lw $t0, 8($t2)
    lb $t8,char1
    beq $t0, $t8, n_Hgb
    lb $t8,char2
    beq $t0, $t8, n_BGT
    lb $t8,char3
    beq $t0, $t8, n_LDL
    lb $t8,char4
    beq $t0, $t8, n_BPT
    contin:
    addi $t4, $t4, 1
    # Print PatientID
    lw $t0, 0($t2)  # Load PatientID
    li $v0, 1
    move $a0, $t0 
    syscall
    li $v0, 11
    li $a0, ':' 
    syscall
    li $a0, ' ' 
    syscall
    
    # Print TestType
    lw $t0, 4($t2)  # Assuming TestType starts at offset 4 and is stored as ASCII codes for characters
    move $a0, $t0 
    syscall
    lw $t0, 8($t2)
    move $a0, $t0 
    syscall
    lw $t0, 12($t2)
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, ','
    syscall
    li $a0, ' '
    syscall

    # Print Date (Year)
    lw $t0, 16($t2)
    li $v0, 1
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, '-'
    syscall

    # Print Date (Month)
    lw $t0, 20($t2)
    li $v0, 1
    bgt $t0, 9, moveon  # If month is less than 10, print leading zero
    li $a0, 0
    syscall

moveon:
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, ','
    syscall
    li $a0, ' '
    syscall
    
    # Print Test Result
    lwc1 $f12, 24($t2)             # Load the float into $f12 (used by print float syscall)
    li $v0, 2                  # Syscall to print single precision float
    syscall
    
    
    li $t8, 'P'
    
    lw $t0, 8($t2)
    bne $t0, $t8, not_BPT_printlist
    
    li $v0, 11
    li $a0, ',' 
    syscall
    li $v0, 11
    li $a0, ' ' 
    syscall
    lwc1 $f12, 28($t2)             # Load the float into $f12 (used by print float syscall)
    li $v0, 2                  # Syscall to print single precision float
    syscall

    
    not_BPT_printlist:
    li $v0, 11
    li $a0, '\n' 
    syscall
passo:
    # Move to the next node 
    lw $t2, 32($t2)  # Move to the next node
    beqz $t2, end_print_up_normal_test_loop

    
    j print_up_normal_test_loop

end_print_up_normal_test_loop:
    beq $t4, 0, upnormal_notfound
    j search_by_id    
	
upnormal_notfound:
    print_str("id wasn't found or this id has no up normal tests\n")
    j search_by_id
    
n_Hgb:
  lwc1 $f4, hgblow
  lwc1 $f5, hgbup
  lwc1 $f6, 24($t2) #load the test result
  c.lt.s $f4, $f6    # Set condition if lower bound is less than the result
    bc1f contin  # If lower bound is not less than result

    # Check if the result is less than or equal to the upper bound
    c.le.s $f6, $f5    # Set condition if result is less than or equal to upper bound
    bc1f contin  # If result is not less than or equal to upper bound
    j passo
    
    
n_BGT:
  lwc1 $f4, bgtlow
  lwc1 $f5, bgtup
  lwc1 $f6, 24($t2)
  c.lt.s $f4, $f6    # Set condition if lower bound is less than the result
    bc1f contin  # If lower bound is not less than result

    # Check if the result is less than or equal to the upper bound
    c.le.s $f6, $f5    # Set condition if result is less than or equal to upper bound
    bc1f contin  # If result is not less than or equal to upper bound
    j passo
 
n_LDL:

  lwc1 $f5, ldl
  lwc1 $f6, 24($t2)
  c.le.s $f6, $f5    # Set condition if $f6 is less than $f5
    bc1f contin       # If $f6 is not less than $f5
    j passo
    
n_BPT:
  lwc1 $f4, bptlow
  lwc1 $f5, bptup
  #load the Systolic Blood Pressure result
  lwc1 $f6, 24($t2)
  #load the Diastolic Blood Pressure result
  lwc1 $f7, 24($t2)
  c.le.s $f6, $f5    # Set condition if $f6 is less than $f5
    bc1f contin		# If $f6 is not less than $f5
    
    c.le.s $f7, $f4    # Set condition if $f7 is less than $f4
    bc1f contin		# If $f7 is not less than $f4
    
    j passo
# PRINTING TESTS OF PATIENT WITH SPECIFIC PERIOD OF TIME
print_tests_in_period:
# READING PATIENT ID AND VALIDATING
period_search_patient_id_choice:
    li $v0, 4
    la $a0, enter_patient_id_message
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, patient_id_buffer
    li $a1, 32
    syscall
    la $t7, patient_id_buffer

    # Check if the input is empty
    lb $t0, 0($t7)  # Load the first character of the buffer
    beqz $t0, period_search_patient_id_choice_empty_input  # If it's zero, input is empty
    beq $t0, 10, period_search_patient_id_choice_empty_input  # If it's zero, input is empty

    # Check for valid integer (digits and possibly one leading '-')
    la $t1, patient_id_buffer   # Pointer to the start of the buffer
    li $t2, 1        # Flag to check validity, 1 is valid, 0 is invalid

    lb $t4, 0($t1)
    j period_search_patient_id_choice_check_first_digit

period_search_patient_id_choice_check_digits:
    lb $t4, 0($t1)
period_search_patient_id_choice_check_first_digit:
    beqz $t4, period_search_patient_id_choice_end_check  # End of string
    beq $t4, 10, period_search_patient_id_choice_end_check  # End of string
    blt $t4, '0', period_search_patient_id_choice_error # Less than '0'
    bgt $t4, '9', period_search_patient_id_choice_error # Greater than '9'
    addiu $t1, $t1, 1  # Move to the next character
    j period_search_patient_id_choice_check_digits

period_search_patient_id_choice_invalid_input:
    li $t2, 0  # Set flag to invalid

period_search_patient_id_choice_end_check:
    beqz $t2, period_search_patient_id_choice_error  # If flag is 0, input is invalid
    la $t3, patient_id_buffer
    li $s0, 0
period_search_patient_id_choice_loop:
    lb $t0, 0($t3)
    beqz $t0, period_search_patient_id_choice_done
    beq $t0, 10, period_search_patient_id_choice_done
    sub $t0, $t0, '0'
    mul $s0, $s0, 10
    add $s0, $s0, $t0
    addi $t3, $t3, 1
    j period_search_patient_id_choice_loop
    
period_search_patient_id_choice_error:
    li $v0, 4
    la $a0, error_msg
    syscall
    j period_search_patient_id_choice

period_search_patient_id_choice_empty_input:
    li $v0, 4
    la $a0, empty_msg
    syscall
    j period_search_patient_id_choice
period_search_patient_id_choice_done:
    move $t7, $s0    
    move $t9, $zero 
# READING START YEAR AND VALIDATING
period_1_year:
    # Display prompt
    li $v0, 4
    la $a0, period_1_year_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, year_buffer
    li $a1, 6  # Allow space for 4 digits, a newline, and a null terminator
    syscall

    # Check if input is empty
    la $t4, year_buffer
    lb $t0, 0($t4)
    beqz $t0, period_1_year_handle_empty

    # Ensure only 4 characters are digits and check for newline as fifth character
    la $a0, year_buffer  # Reload address of buffer
    li $t1, 0       # Counter for number of digits
    li $t2, 0       # Accumulator for converting string to integer
    li $t9, 10

period_1_year_validate_input:
    lb $t4, 0($a0)
    beqz $t4, period_1_year_handle_error   # If null character, error out if not at 4th position
    beq $t4, 10, period_1_year_check_length  # If newline, check count
    blt $t4, '0', period_1_year_handle_error  # Less than '0'
    bgt $t4, '9', period_1_year_handle_error  # Greater than '9'
    sub $t4, $t4, '0'           # Convert from ASCII to integer
    mul $t2, $t2, $t9          # Shift previous digits left
    add $t2, $t2, $t4          # Add new digit
    addi $t1, $t1, 1            # Increment digit count
    addiu $a0, $a0, 1           # Move to next character
    j period_1_year_validate_input

period_1_year_check_length:
    li $t7, 4
    bne $t1, $t7, period_1_year_handle_error  # If count is not 4, error

    # Validate year range
    li $t8, 2000
    li $t7, 2025
    blt $t2, $t8, period_1_year_handle_error  # Less than 2000
    bgt $t2, $t7, period_1_year_handle_error  # Greater than 2025

    # Store the valid year in $s1
    move $s1, $t2

    j period_1_month

period_1_year_handle_empty:
    li $v0, 4
    la $a0, year_empty_msg
    syscall
    j period_1_year

period_1_year_handle_error:
    li $v0, 4
    la $a0, year_error_msg
    syscall
    j period_1_year
# READING START MONTH AND VALIDATING
period_1_month:
    # Display prompt
    li $v0, 4
    la $a0, period_1_month_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, month_buffer
    li $a1, 4  # Allow space for 2 digits, a newline, and a null terminator
    syscall

    # Check if input is empty
    la $t1, month_buffer
    lb $t0, 0($t1)
    beqz $t0, period_1_month_handle_empty  # If no input

    # Initialize variables for validation and conversion
    la $a0, month_buffer  # Pointer to start of buffer
    li $t1, 0       # Counter for number of digits
    li $t2, 0       # Accumulator for integer conversion

period_1_month_validate_input:
    lb $t4, 0($a0)  # Load the current character
    beqz $t4, period_1_month_check_length  # End of input string
    beq $t4, 10, period_1_month_check_length  # If newline, proceed to check length
    blt $t4, '0', period_1_month_handle_error  # Check if character is less than '0'
    bgt $t4, '9', period_1_month_handle_error  # Check if character is greater than '9'
    sub $t4, $t4, '0'           # Convert ASCII to integer
    li $t7, 10
    mul $t2, $t2, $t7          # Multiply current result by 10
    add $t2, $t2, $t4           # Add new digit
    addi $t1, $t1, 1            # Increment digit count
    addiu $a0, $a0, 1           # Move to next character
    j period_1_month_validate_input

period_1_month_check_length:
    li $t7, 2
    bgt $t1, $t7, period_1_month_handle_error  # If more than 2 digits, error

    # Validate month range
    li $t8, 1
    li $t7, 12
    blt $t2, $t8, period_1_month_handle_error  # If less than 1
    bgt $t2, $t7, period_1_month_handle_error  # If greater than 12

    # Store the valid month in $s1
    move $s2, $t2

    j period_1_done

period_1_month_handle_empty:
    li $v0, 4
    la $a0, month_empty_msg
    syscall
    j period_1_month

period_1_month_handle_error:
    li $v0, 4
    la $a0, month_error_msg
    syscall
    j period_1_month
period_1_done:
move $s3, $s1
move $s6, $s2
# READING END YEAR AND VALIDATING
period_2_year:
    # Display prompt
    li $v0, 4
    la $a0, period_2_year_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, year_buffer
    li $a1, 6  # Allow space for 4 digits, a newline, and a null terminator
    syscall

    # Check if input is empty
    la $t4, year_buffer
    lb $t0, 0($t4)
    beqz $t0, period_2_year_handle_empty

    # Ensure only 4 characters are digits and check for newline as fifth character
    la $a0, year_buffer  # Reload address of buffer
    li $t1, 0       # Counter for number of digits
    li $t2, 0       # Accumulator for converting string to integer
    li $t9, 10
period_2_year_validate_input:
    lb $t4, 0($a0)
    beqz $t4, period_2_year_handle_error   # If null character, error out if not at 4th position
    beq $t4, 10, period_2_year_check_length  # If newline, check count
    blt $t4, '0', period_2_year_handle_error  # Less than '0'
    bgt $t4, '9', period_2_year_handle_error  # Greater than '9'
    sub $t4, $t4, '0'           # Convert from ASCII to integer
    mul $t2, $t2, $t9          # Shift previous digits left
    add $t2, $t2, $t4          # Add new digit
    addi $t1, $t1, 1            # Increment digit count
    addiu $a0, $a0, 1           # Move to next character
    j period_2_year_validate_input

period_2_year_check_length:
    li $t7, 4
    bne $t1, $t7, period_2_year_handle_error  # If count is not 4, error

    # Validate year range
    li $t8, 2000
    li $t7, 2025
    blt $t2, $t8, period_2_year_handle_error  # Less than 2000
    bgt $t2, $t7, period_2_year_handle_error  # Greater than 2025
    blt $t2, $s3, period_2_year_error_less_than_start  # Less than 2000
    # Store the valid year in $s1
    move $s1, $t2

    j period_2_month

period_2_year_error_less_than_start:
    li $v0, 4
    la $a0, year_less_than_start_msg
    syscall
    j period_2_year
period_2_year_handle_empty:
    li $v0, 4
    la $a0, year_empty_msg
    syscall
    j period_2_year

period_2_year_handle_error:
    li $v0, 4
    la $a0, year_error_msg
    syscall
    j period_2_year
# READING END MONTH AND VALIDATING
period_2_month:
    # Display prompt
    li $v0, 4
    la $a0, period_2_month_prompt
    syscall

    # Read input as a string
    li $v0, 8
    la $a0, month_buffer
    li $a1, 4  # Allow space for 2 digits, a newline, and a null terminator
    syscall

    # Check if input is empty
    la $t1, month_buffer
    lb $t0, 0($t1)
    beqz $t0, period_2_month_handle_empty  # If no input

    # Initialize variables for validation and conversion
    la $a0, month_buffer  # Pointer to start of buffer
    li $t1, 0       # Counter for number of digits
    li $t2, 0       # Accumulator for integer conversion

period_2_month_validate_input:
    lb $t4, 0($a0)  # Load the current character
    beqz $t4, period_2_month_check_length  # End of input string
    beq $t4, 10, period_2_month_check_length  # If newline, proceed to check length
    blt $t4, '0', period_2_month_handle_error  # Check if character is less than '0'
    bgt $t4, '9', period_2_month_handle_error  # Check if character is greater than '9'
    sub $t4, $t4, '0'           # Convert ASCII to integer
    li $t7, 10
    mul $t2, $t2, $t7          # Multiply current result by 10
    add $t2, $t2, $t4           # Add new digit
    addi $t1, $t1, 1            # Increment digit count
    addiu $a0, $a0, 1           # Move to next character
    j period_2_month_validate_input

period_2_month_check_length:
    li $t7, 2
    bgt $t1, $t7, period_2_month_handle_error  # If more than 2 digits, error

    # Validate month range
    li $t8, 1
    li $t7, 12
    blt $t2, $t8, period_2_month_handle_error  # If less than 1
    bgt $t2, $t7, period_2_month_handle_error  # If greater than 12
    bne $s1, $s3, start_not_equal_end
    blt $t2, $s6, period_2_month_error_less_than_start  # Less than 2000
    start_not_equal_end:
    # Store the valid month in $s1
    move $s2, $t2

    j period_2_done
period_2_month_error_less_than_start:
    li $v0, 4
    la $a0, month_less_than_start_msg
    syscall
    j period_2_month
period_2_month_handle_empty:
    li $v0, 4
    la $a0, month_empty_msg
    syscall
    j period_2_month

period_2_month_handle_error:
    li $v0, 4
    la $a0, month_error_msg
    syscall
    j period_2_month
period_2_done:
move $t8, $s1
move $t9, $s2
    move $t7, $s0 
    move $t2, $t5
    lw $t2, 32($t2)
    li $t4, 0  
    
print_tests_in_period_loop:
    lw $t0, 0($t2)  # Load PatientID
    bne $t0, $t7, passp
    
    lw $s4, 16($t2)	#load the year of the test
    lw $s5, 20($t2)	#load the month of the test
    # Check if the test year is between the input years
    bgt $s4, $t8, passp  # If test year is greater than second year
    blt $s4, $s3, passp  # If test year is less than first year

    # If years are equal, check the months
    beq $s4, $s3, check_month1  # If test year equals first year, check month
    beq $s4, $t8, check_month2  # If test year equals second year, check month
    j in_range                  # If test year is in range, it's in range

check_month1:
    blt $s5, $s6, passp  # If test month is less than first month
    j in_range                  # Test month is in range

check_month2:
    bgt $s5, $t9, passp  # If test month is greater than second month
    j in_range                  # Test month is in range
    in_range:
    addi $t4, $t4, 1
    # Print PatientID
    lw $t0, 0($t2)  # Load PatientID
    li $v0, 1
    move $a0, $t0 
    syscall
    li $v0, 11
    li $a0, ':' 
    syscall
    li $a0, ' ' 
    syscall
    
    # Print TestType
    lw $t0, 4($t2)  # Assuming TestType starts at offset 4 and is stored as ASCII codes for characters
    move $a0, $t0 
    syscall
    lw $t0, 8($t2)
    move $a0, $t0 
    syscall
    lw $t0, 12($t2)
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, ','
    syscall
    li $a0, ' '
    syscall

    # Print Date (Year)
    lw $t0, 16($t2)
    li $v0, 1
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, '-'
    syscall

    # Print Date (Month)
    lw $t0, 20($t2)
    li $v0, 1
    bgt $t0, 9, move_onp  # If month is less than 10, print leading zero
    li $a0, 0
    syscall

move_onp:
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, ','
    syscall
    li $a0, ' '
    syscall
    
    # Print Test Result
    lwc1 $f12, 24($t2)             # Load the float into $f12 (used by print float syscall)
    li $v0, 2                  # Syscall to print single precision float
    syscall
    
    
    li $s7, 'P'
    lw $t0, 8($t2)
    bne $t0, $s7, not_BPTprint_list
    
    li $v0, 11
    li $a0, ',' 
    syscall
    li $v0, 11
    li $a0, ' ' 
    syscall
    lwc1 $f12, 28($t2)             # Load the float into $f12 (used by print float syscall)
    li $v0, 2                  # Syscall to print single precision float
    syscall

    
    not_BPTprint_list:
    li $v0, 11
    li $a0, '\n' 
    syscall
    passp:
    # Move to the next node 
    lw $t2, 32($t2)  # Move to the next node
    beqz $t2, end_print_tests_in_period_loop
    

    
    j print_tests_in_period_loop

end_print_tests_in_period_loop:
    beq $t4, 0, not_found_in_period
    j search_by_id

not_found_in_period:
    print_str("no tests were found in this period or the id doesn't exist\n")
    j search_by_id
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------PRINT UPNORMAL TESTS OF SPECIFIED TEST TYPE-------------------------------------------------------#
print_up_normal_tests: 
# READING TEST TYPE AND VALIDATING
normal_test_type_medical:
    # Display menu
    li $v0, 4
    la $a0, test_type_menu
    syscall

    # Read one character as input
    li $v0, 8           # Syscall to read a string
    la $a0, test_type_buffer      # Pointer to buffer
    li $a1, 3          # Max characters to read (including null terminator)
    syscall
   
    la $t1, test_type_buffer
    lb $t0, 1($t1)
    bne $t0, 10, normal_test_type_invalid_choice 
    # Check if the input is a valid choice (between '1' and '4')
    lb $t0, 0($t1)
    beqz $t0, normal_test_type_invalid_choice 
    beq $t0, 10, normal_test_type_invalid_choice 
    li $t1, '1'
    li $t2, '4'
    blt $t0, $t1, normal_test_type_empty_choice   # If less than '1'
    bgt $t0, $t2, normal_test_type_empty_choice   # If greater than '4'

    sub $t0 , $t0, '0'

normal_test_type_store_choice:

    beq $t0, 1, normal_store_hgb
    beq $t0, 2, normal_store_bgt
    beq $t0, 3, normal_store_ldl
    beq $t0, 4, normal_store_bpt

normal_store_hgb:
    li $s3, 'H'
    li $s4, 'g'
    li $s5, 'b'
    j done_storing_test_type

normal_store_bgt:
    li $s3, 'B'
    li $s4, 'G'
    li $s5, 'T'
    j done_storing_test_type

normal_store_ldl:
    li $s3, 'L'
    li $s4, 'D'
    li $s5, 'L'
    j done_storing_test_type

normal_store_bpt:
    li $s3, 'B'
    li $s4, 'P'
    li $s5, 'T'
    j done_storing_test_type

normal_test_type_empty_choice:
    li $v0, 4
    la $a0, test_type_empty_msg
    syscall
    j normal_test_type_medical
    
normal_test_type_invalid_choice:
    li $v0, 4
    la $a0, test_type_error_msg
    syscall
    j normal_test_type_medical
    
    done_storing_test_type:
   move $t2, $t5   # Start at the head of the list
    lw $t2, 32($t2)
    li $t4, 0 
# LOOPING OVER MEMORY AND FINDING UPNORMAL FOR TEST TYPE CHOSEN
  print_up_normal_tests_loop:
   
    lw $t0, 8($t2)
    bne $t0, $s4, passo2
    lb $t8,char1
    beq $t0, $t8, Hgb2
    lb $t8,char2
    beq $t0, $t8, BGT2
    lb $t8,char3
    beq $t0, $t8, LDL2
    lb $t8,char4
    beq $t0, $t8, BPT2
    
    
    contin2:
    addi $t4, $t4, 1
    # Print PatientID
    lw $t0, 0($t2)  # Load PatientID
    li $v0, 1
    move $a0, $t0 
    syscall
    li $v0, 11
    li $a0, ':' 
    syscall
    li $a0, ' ' 
    syscall
    
    # Print TestType
    lw $t0, 4($t2)  # Assuming TestType starts at offset 4 and is stored as ASCII codes for characters
    move $a0, $t0 
    syscall
    lw $t0, 8($t2)
    move $a0, $t0 
    syscall
    lw $t0, 12($t2)
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, ','
    syscall
    li $a0, ' '
    syscall

    # Print Date (Year)
    lw $t0, 16($t2)
    li $v0, 1
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, '-'
    syscall

    # Print Date (Month)
    lw $t0, 20($t2)
    li $v0, 1
    bgt $t0, 9, moveon2  # If month is less than 10, print leading zero
    li $a0, 0
    syscall

moveon2:
    move $a0, $t0 
    syscall
    
    li $v0, 11
    li $a0, ','
    syscall
    li $a0, ' '
    syscall
    
    # Print Test Result
    lwc1 $f12, 24($t2)             # Load the float into $f12 (used by print float syscall)
    li $v0, 2                  # Syscall to print single precision float
    syscall
    
    
    li $t8, 'P'
    lw $t0, 8($t2)
    bne $t0, $t8, notBPT_printlist
    
    li $v0, 11
    li $a0, ',' 
    syscall
    li $v0, 11
    li $a0, ' ' 
    syscall
    lwc1 $f12, 28($t2)             # Load the float into $f12 (used by print float syscall)
    li $v0, 2                  # Syscall to print single precision float
    syscall

    
    notBPT_printlist:
    li $v0, 11
    li $a0, '\n' 
    syscall
    passo2:
    # Move to the next node 
    lw $t2, 32($t2)  # Move to the next node
    beqz $t2, end_print_up_normal_tests_loop

    
    j print_up_normal_tests_loop

end_print_up_normal_tests_loop:
    beq $t4, 0, no_unnormal
    j menu    
no_unnormal:
    print_str("no unnormal tests were found for the given tybe\n")
    j menu	
    
Hgb2:
  lwc1 $f4, hgblow
  lwc1 $f5, hgbup
  lwc1 $f6, 24($t2) #load the test result
  c.lt.s $f4, $f6    # Set condition if lower bound is less than the result
    bc1f contin2  # If lower bound is not less than result

    # Check if the result is less than or equal to the upper bound
    c.le.s $f6, $f5    # Set condition if result is less than or equal to upper bound
    bc1f contin2  # If result is not less than or equal to upper bound
    j passo2
    
    
BGT2:
  lwc1 $f4, bgtlow
  lwc1 $f5, bgtup
  lwc1 $f6, 24($t2)
  c.lt.s $f4, $f6    # Set condition if lower bound is less than the result
    bc1f contin2  # If lower bound is not less than result

    # Check if the result is less than or equal to the upper bound
    c.le.s $f6, $f5    # Set condition if result is less than or equal to upper bound
    bc1f contin2  # If result is not less than or equal to upper bound

    j passo2
 
LDL2:

  lwc1 $f5, ldl
  lwc1 $f6, 24($t2)
  c.le.s $f6, $f5    # Set condition if $f6 is less than $f5
    bc1f contin2       # If $f6 is not less than $f5
    j passo2
    
BPT2:
  lwc1 $f4, bptlow
  lwc1 $f5, bptup
  #load the Systolic Blood Pressure result
  lwc1 $f6, 24($t2)
  #load the Diastolic Blood Pressure result
  lwc1 $f7, 24($t2)
  c.le.s $f6, $f5    # Set condition if $f6 is less than $f5
    bc1f contin2		# If $f6 is not less than $f5
    
  c.le.s $f7, $f4    # Set condition if $f7 is less than $f4
    bc1f contin2		# If $f7 is not less than $f4
    
    j passo2
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------WRTING TO FILE (FROM MEMORY TO FILE)--------------------------------------------------------------------#
# WRITE CONTENT STORED IN LINKED LIST TO BUFFER THEN WRITE BUFFER TO FILE
write_to_file: 
    move $t2, $t5 # linkedlist
    lw $t2, 32($t2)
    la $t8, output_buffer # buffer
    la $s0, output_buffer
    #add $t8, $t8, $t1      # Point $a0 to where the last digit should go

storing_to_buffer:
# PATIENT ID FIND THE LENGTH OF PATIENT ID INCREMENT THE BUFFER ADDRESS BY THE LENGTH
# STORE THE PATIENT ID IN REVERSE STARTING FROM LOWEST DIGIT AND STARTING FROM THE LAST INDEX IN BUFFER
# DIVIDING THE PATIENT ID BY 10 AND GETTING THE REMINDER
    lw $t0, 0($t2)
    li $t1, 0 # number_of_digits
    li $t7, 10
    patient_id_length_loop:
       beqz $t0, end_patient_id_length_loop
       div $t0,$t0, 10
       addi $t1, $t1, 1
       j patient_id_length_loop
    end_patient_id_length_loop:
    lw $t0, 0($t2)
    add $t8, $t8, $t1
    convert:
    beqz $t0, done_patient_id        # If $t0 is zero, we are done
    div $t0, $t7          # Divide $t0 by 10; quotient in $lo, remainder in $hi
    mfhi $t9               # Move the remainder to $t2
    addi $t9, $t9, '0'     # Convert remainder to ASCII character
    addiu $t8, $t8, -1     # Move back one byte in the buffer
    sb $t9, 0($t8)         # Store the ASCII character
    mflo $t0               # Move the quotient back to $t0 for the next iteration
    j convert              # Repeat the process
    done_patient_id:
    # Seperator
    add $t8, $t8, $t1           # Move back one byte in the buffer (for ':')
    li $t9, ':'                  # Load ':' into $t9
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    li $t9, ' '                  # Load ' ' (space) into $t9
    sb $t9, 0($t8)               # Store ' ' in the buffer
    # testType
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    lw $t9, 4($t2)                  # Load ':' into $t9
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    lw $t9, 8($t2)  
    sb $t9, 0($t8)               # Store ' ' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    lw $t9, 12($t2)  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    # seperator
    li $t9, ','  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    
    li $t9, ' '  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    
# SAME ALGORITHM AS PATIENT ID
    li $t1, 4 # length of year
    add $t8, $t8, $t1
    lw $t0, 16($t2)
    convert_year:
    beqz $t0, year_done        # If $t0 is zero, we are done
    div $t0, $t7          # Divide $t0 by 10; quotient in $lo, remainder in $hi
    mfhi $t9               # Move the remainder to $t2
    addi $t9, $t9, '0'     # Convert remainder to ASCII character
    addiu $t8, $t8, -1     # Move back one byte in the buffer
    sb $t9, 0($t8)         # Store the ASCII character
    mflo $t0               # Move the quotient back to $t0 for the next iteration
    j convert_year             # Repeat the process
    year_done:
    add $t8, $t8, $t1
    # seperator
    li $t9, '-'  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    sb $zero, 0($t8)       # Null terminate the string0
    # MONTH ALGORITHM AS PATIENT ID
    li $t1, 2 # length of year
    add $t8, $t8, $t1
    lw $t0, 20($t2)
    move $s6, $t0
    convert_month:
    beqz $t0, month_done        # If $t0 is zero, we are done
    div $t0, $t7          # Divide $t0 by 10; quotient in $lo, remainder in $hi
    mfhi $t9               # Move the remainder to $t2
    addi $t9, $t9, '0'     # Convert remainder to ASCII character
    addiu $t8, $t8, -1     # Move back one byte in the buffer
    sb $t9, 0($t8)         # Store the ASCII character
    bge $s6, 10, greater_than_10
    addiu $t8, $t8, -1     # Move back one byte in the buffer
    li $t9, '0'
    sb $t9, 0($t8)         # Store the ASCII character
    greater_than_10:
    mflo $t0               # Move the quotient back to $t0 for the next iteration
    j convert_month             # Repeat the process
    month_done:
    add $t8, $t8, $t1
    # seperator
    li $t9, ','  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    
    li $t9, ' '  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
# TEST RESULT SEPERATE THE PART BEFORE DECIMAL POINT AND PART AFTER DECIMAL POINT
# BY CONVERTING THE FLOAT TO INTEGER WE GET PART BEFORE DECIMAL POINT
# TO CONVERT PART AFTER DECIMAL POINT TO INTEGER WE NEED TO
# ENTER A LOOP MULTIPLYING THE FRACTION BY 10 AND CHECKING IF THE FRACTION BECOMES 0 FOR EXAMPLE
# SAY WE HAVE 25.14
# USING CVT WE GET 25
# USING SUB 25.0, 25.14 WE GET ABOUT 0.14 (SUBTRACTING FLOATS IS NOT PRECISE WE NEED A EPSILON VALUE)
# MULTIPLY BY 10 AND REPEAT CYCLE
# 1.4 SEPERATING GET 1.0 AND 1.4 IF SUBTRACTING EQUAL ZERO WE END LOOP AND GET FRACTION PART
# 14.0 SEPERATING GET 14.0 AND 14.0 SUBTRACTING EQUALS ZERO DONE
# HOW TO STORE?
# SAME ALGORITHM FOR PATIENT ID (SAVE DECIMAL PART THEN SAVE '.' THEN SAVE FRACTION PART ) THEY ARE CONVERTED TO INTEGERS 
    lwc1 $f0, 24($t2)
    cvt.w.s $f1, $f0         # Convert to integer in floating point format
    mfc1 $t0, $f1            # Move converted integer to general register $t0
    mtc1 $t0, $f1
    cvt.s.w $f1, $f1
    sub.s $f5, $f0, $f1      # $f5 now holds the fractional part as a float
    l.s $f10, float100

    # Scale the number by 100 to shift the decimal two places to the right
    li $t4, 100
    mtc1 $t4, $f1            # Move the integer 100 into a floating-point register $f1
    cvt.s.w $f1, $f1         # Convert integer 100 to floating-point
    mul.s $f5, $f5, $f1      # Multiply $f0 by 100

    # Round to the nearest whole number
    round.w.s $f1, $f5      # Round $f0 and store the result in $f1
    cvt.s.w $f1, $f1
    div.s $f5, $f1, $f10
    li $t1, 0
    test_result_length_loop:
       beqz $t0, end_test_result_length_loop
       div $t0,$t0, 10
       addi $t1, $t1, 1
       j test_result_length_loop
    end_test_result_length_loop:
    lwc1 $f0, 24($t2)
    cvt.w.s $f1, $f0         # Convert to integer in floating point format
    mfc1 $t0, $f1            # Move converted integer to general register $t0
    #sub.s $f2, $f0, $f1      # $f2 now holds the fractional part as a float
    add $t8, $t8, $t1
    convert_test_result:
    beqz $t0, done_test_result       # If $t0 is zero, we are done
    div $t0, $t7          # Divide $t0 by 10; quotient in $lo, remainder in $hi
    mfhi $t9               # Move the remainder to $t2
    addi $t9, $t9, '0'     # Convert remainder to ASCII character
    addiu $t8, $t8, -1     # Move back one byte in the buffer
    sb $t9, 0($t8)         # Store the ASCII character
    mflo $t0               # Move the quotient back to $t0 for the next iteration
    j convert_test_result              # Repeat the process
    done_test_result:
    add $t8, $t8, $t1
    li $t1, 0
    li $t9, 0
check_fractional:
    # Multiply the fractional part by 10
    li $t7, 10
    mtc1 $t7, $f3
    cvt.s.w $f3, $f3
    mul.s $f5, $f5, $f3
    
    # Separate the integer part of the new fractional value
    cvt.w.s $f6, $f5         # Convert result to integer in floating point format
    cvt.s.w $f6, $f6

    sub.s $f7, $f5, $f6         # Set the condition flag if $f0 is equal to $f1
           # Branch to zero_true if condition flag is true
    l.s $f8, epsilon    
    c.lt.s $f7, $f8
    bc1t done_check_fractional
    b check_fractional                # Otherwise, continue looping

    done_check_fractional:
    cvt.w.s $f1, $f6         # Convert to integer in floating point format
    mfc1 $t0, $f1            # Move converted integer to general register $t0
    # store fractional part
    li $t1, 0
    beq $t0, $t1, check_BPT_write_to_file
    li $t9, '.'  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' 
    fraction_length_loop:
       beqz $t0, end_fraction_length_loop
       div $t0,$t0, 10
       addi $t1, $t1, 1
       j fraction_length_loop
    end_fraction_length_loop:
    cvt.w.s $f1, $f6         # Convert to integer in floating point format
    mfc1 $t0, $f1            # Move converted integer to general register $t0
    add $t8, $t8, $t1
    convert_fraction:
    beqz $t0, done_fraction        # If $t0 is zero, we are done
    div $t0, $t7          # Divide $t0 by 10; quotient in $lo, remainder in $hi
    mfhi $t9               # Move the remainder to $t2
    addi $t9, $t9, '0'     # Convert remainder to ASCII character
    addiu $t8, $t8, -1     # Move back one byte in the buffer
    sb $t9, 0($t8)         # Store the ASCII character
    mflo $t0               # Move the quotient back to $t0 for the next iteration
    j convert_fraction              # Repeat the process
    done_fraction:
    add $t8, $t8, $t1
    check_BPT_write_to_file:
    # Check for BPT
    li $t1, 'P'
    lw $t0, 8($t2)
    bne $t0, $t1, done_test_result_store_to_buffer
    li $t9, ','  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    
    li $t9, ' '  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    
    # test result
    lwc1 $f0, 28($t2)
    cvt.w.s $f1, $f0         # Convert to integer in floating point format
    mfc1 $t0, $f1            # Move converted integer to general register $t0
    mtc1 $t0, $f1
    cvt.s.w $f1, $f1
    sub.s $f5, $f0, $f1      # $f2 now holds the fractional part as a flo
    l.s $f10, float100

    # Scale the number by 100 to shift the decimal two places to the right
    li $t4, 100
    mtc1 $t4, $f1            # Move the integer 100 into a floating-point register $f1
    cvt.s.w $f1, $f1         # Convert integer 100 to floating-point
    mul.s $f5, $f5, $f1      # Multiply $f0 by 100

    # Round to the nearest whole number
    round.w.s $f1, $f5      # Round $f5 and store the result in $f1
    cvt.s.w $f1, $f1
    div.s $f5, $f1, $f10

    li $t1, 0
    test_result_2_length_loop:
       beqz $t0, end_test_result_2_length_loop
       div $t0,$t0, 10
       addi $t1, $t1, 1
       j test_result_2_length_loop
    end_test_result_2_length_loop:
    lwc1 $f0, 28($t2)
    cvt.w.s $f1, $f0         # Convert to integer in floating point format
    mfc1 $t0, $f1            # Move converted integer to general register $t0
    #sub.s $f2, $f0, $f1      # $f2 now holds the fractional part as a float
    add $t8, $t8, $t1
    convert_test_result_2:
    beqz $t0, done_test_result_2       # If $t0 is zero, we are done
    div $t0, $t7          # Divide $t0 by 10; quotient in $lo, remainder in $hi
    mfhi $t9               # Move the remainder to $t2
    addi $t9, $t9, '0'     # Convert remainder to ASCII character
    addiu $t8, $t8, -1     # Move back one byte in the buffer
    sb $t9, 0($t8)         # Store the ASCII character
    mflo $t0               # Move the quotient back to $t0 for the next iteration
    j convert_test_result_2              # Repeat the process
    done_test_result_2:
    add $t8, $t8, $t1
    li $t1, 0
    li $t9, 0
check_fractional_2:
    # Multiply the fractional part by 10
    li $t7, 10
    mtc1 $t7, $f3
    cvt.s.w $f3, $f3
    mul.s $f5, $f5, $f3
    
    # Separate the integer part of the new fractional value
    cvt.w.s $f6, $f5         # Convert result to integer in floating point format
    cvt.s.w $f6, $f6

    sub.s $f7, $f5, $f6         # Set the condition flag if $f0 is equal to $f1
           # Branch to zero_true if condition flag is true
    l.s $f8, epsilon    
    c.lt.s $f7, $f8
    bc1t done_check_fractional_2
    b check_fractional_2                # Otherwise, continue looping

    done_check_fractional_2:
    cvt.w.s $f1, $f6         # Convert to integer in floating point format
    mfc1 $t0, $f1            # Move converted integer to general register $t0
    # store fractional part
    li $t1, 0
    beq $t0, $t1, done_test_result_store_to_buffer
    
    li $t9, '.'  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    fraction_length_loop_2:
       beqz $t0, end_fraction_length_loop_2
       div $t0,$t0, 10
       addi $t1, $t1, 1
       j fraction_length_loop_2
    end_fraction_length_loop_2:
    cvt.w.s $f1, $f6         # Convert to integer in floating point format
    mfc1 $t0, $f1            # Move converted integer to general register $t0
    add $t8, $t8, $t1
    convert_fraction_2:
    beqz $t0, done_fraction_2        # If $t0 is zero, we are done
    div $t0, $t7          # Divide $t0 by 10; quotient in $lo, remainder in $hi
    mfhi $t9               # Move the remainder to $t2
    addi $t9, $t9, '0'     # Convert remainder to ASCII character
    addiu $t8, $t8, -1     # Move back one byte in the buffer
    sb $t9, 0($t8)         # Store the ASCII character
    mflo $t0               # Move the quotient back to $t0 for the next iteration
    j convert_fraction_2              # Repeat the process
    done_fraction_2:
    add $t8, $t8, $t1
    
    done_test_result_store_to_buffer:
    li $t9, '\n'  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    lw $t2, 32($t2)
    beqz $t2, start_write_to_file
    j storing_to_buffer
# writng buffer character by charcter to file
start_write_to_file:
    li $t9, 0  
    sb $t9, 0($t8)               # Store ':' in the buffer
    addiu $t8, $t8, 1           # Move back one byte in the buffer (for ' ')
    # Open the file
    la $a0, outputfilename    # Address of the filename
    li $a1, 0x0001            # Flags (write only, create if not exist)
    li $a2, 0x01B6            # Mode (permissions)
    li $v0, 13                # Syscall for open (file)
    syscall
    move $s6, $v0             # Save the file descriptor in $s6
    # Check if file opened correctly
    bltz $s6, error           # If $s6 is negative, an error occurred in opening the file

write_loop:
    lb $t9, 0($s0)           # Load the byte from buffer to write
    beqz $t9, done_writing   # If the byte is zero (null-terminator), we're done
    move $a0, $s6            # File descriptor
    move $a1, $s0            # Temporary register holds the byte to write
    li $a2, 1                # We're writing one byte at a time
    li $v0, 15               # Syscall for write (file)
    syscall
    addiu $s0, $s0, 1        # Move to the next byte in the buffer
    j write_loop             # Repeat the process

done_writing:
# Close the file
move $a0, $s6                # Move file descriptor to $a0 for close
li $v0, 16                   # Syscall for close (file)
syscall

    # Exit program
    li $v0, 10                # Exit syscall
    syscall

error:
    # Handle file open error
    li $v0, 10                # Exit syscall
    syscall
#---------------------------------------------DONE THANK YOU------------------------------------------------------------------------------------#
    
