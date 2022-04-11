.data
        board: .space 200
        availableSpace: .space 30
        
        empty: .asciiz "."
        piece2: .asciiz "O"
        piece1: .asciiz "X"
        newLine: .asciiz "\n"
        
        userInputPrompt: .asciiz "Enter a column number (1-7): "
        invalidColumn: .asciiz "Column filled\n"

.text
        main:
        
        # =======================================
        # fill whole board with 0s using for loop
        # =======================================
        li $t1, 0
        
        populateBoard: 
        # ($t1 is counter and index of array, $t2 is for loop condition, $t3 is actual array shift based on index)
        
        sll $t3, $t1, 2
        sw $zero, board($t3) # put a zero at board[i]
        
        addi $t1, $t1, 1 # increment i
        slti  $t2, $t1, 42 # if i < 42 then loop
        bne $zero, $t2, populateBoard
        
        # ==================================================
        # fill avaiableSpace column with bottom row of board
        # ==================================================
        li $t1, 0
        
        populateAvailable: 
        
        sll $t3, $t1, 2
        addi $t5, $t1, 35
        sw $t5, availableSpace($t3) # put a 35 + i at availableSpace[i]
        
        addi $t1, $t1, 1 # increment i
        slti  $t2, $t1, 7 # if i < 7 then loop
        bne $zero, $t2, populateAvailable
        
        # ================================================================
        # get user input for column and change associated element of board
        # ================================================================
        li $t9, 1 # turn number: DO NOT USE $t9 FOR OTHER STUFF               *
        
        game:
        li $s1, 1
        li $s2, 2
        
        li $v0, 4
        la $a0, userInputPrompt
        syscall
        
        li $v0, 5
        syscall
        move $t1, $v0
        
        # VALIDATE COLUMN IN RANGE using $t3 and $t4
        slti $t3, $t1, 8
        slt $t4, $zero, $t1
        and $t3, $t3, $t4
        beq $zero, $t3, game # if invalid, restart turn
        
        addi $t1, $t1, -1
        # column - 1 = index of available space array stored in $t1
        
        # get index of board array using column and availableSpace array
        sll $t1, $t1, 2 # index to byte shift
        lw $t2, availableSpace($t1)
        # index of board array stored in $t2
        move $t8, $t2 # last move: DO NOT USE $t8 FOR OTHER STUFF            *
        
        # VALIDATE COLUMN FILLED using $t3
        slt $t3, $t2, $zero
        beq $zero, $t3, validColumn
        
        li $v0, 4
        la $a0, invalidColumn
        syscall
        j game # if invalid, restart turn
        validColumn:
        
        # available space for given column moved up 1 row using $t3
        addi $t3, $t2, -7
        sw $t3, availableSpace($t1)
        
        # change value in board array
        sll $t2, $t2, 2 # index to byte shift
        
        # turn % 2
        move $a1, $t9
        li $a2, 2
        jal mod
        
        beq $v0, $zero, p2turn
        sw $s1, board($t2)
        j hopTurn
        p2turn:
        sw $s2, board($t2)
        hopTurn:
        
        # =======================================
        # print board according to board array
        # =======================================
        
        li $t1, 0
        li $s1, 1
        li $s2, 2
        
        print:
        
        sll $t3, $t1, 2
        lw  $t2, board($t3) # branch depending on contents of board[i]
        beq $t2, $zero, printdot
        beq $t2, $s1, printX
        beq $t2, $s2, printO
        
        printdot:
        li $v0, 4
        la $a0, empty
        syscall
        j Exit1
        
        printX:
        li $v0, 4
        la $a0, piece1
        syscall
        j Exit1
        
        printO:
        li $v0, 4
        la $a0, piece2
        syscall
        j Exit1
        
        
        Exit1:
        move $a1, $t1
        li $a2, 7
        jal mod
        
        move $t4, $v0
        
        sub $t4, $t4, 6
        bne $zero, $t4, noNewLine
        
        li $v0, 4
        la $a0, newLine
        syscall
        
        noNewLine:
        
        addi $t1, $t1, 1 # increment i
        slti  $t2, $t1, 42 # if i < 42 then loop
        bne $zero, $t2, print
        
        # ===============================
        # check if last turn created win
        # ===============================
        
        
        
        addi $t9, $t9, 1 # increment turn
        j game
        
        # =======================================
        #               END OF MAIN
        # =======================================
        ExitEnd:
        li $v0, 10
        syscall
        
        # =======================================
        #               FUNCTIONS
        # =======================================
        
        # $v0 = $a1 % $a2
        mod:
        div $v0, $a1, $a2
        mulo $v0, $v0, $a2
        sub $v0, $a1, $v0
        jr $ra