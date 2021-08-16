  .data
slist: .word 0
cclist: .word 0
wclist: .word 0
menu: .asciiz "1 - Crear nueva categoria vacia.\n2 - Seleccionar siguiente categoria.\n3 - Seleccionar anterior categoria.\n4 - Listar las categorias.\n9 - Salir.\n\nIngrese la opcion deseada: "

  .text
  .globl main
main:
  for0:
    la $a0, menu
    li $v0, 4
    syscall
    
    li $v0, 5
    syscall

    beq $v0, 9, endfor0
    
		switch:
      case1:
        bne $v0, 1, case2
        lw $a0, cclist
        jal newCategory
        j endSwitch

      case2:
        bne $v0, 2, case3
        jal nextCatagory
        j endSwitch

      case3:
        bne $v0, 3, case4
        jal prevCatagory
        j endSwitch

      case4:
        bne $v0, 4, case5
        j endSwitch

      case9:
        bne $v0, 9, default
        j endfor0
      
      default:

    endSwitch:

    j for0
  endfor0:
  li $v0, 10
  syscall

# void newCategory($a0 = categoryNameAddress)
newCategory:
  move $a1, $a0 # input 
  lw $a0, cclist
  addi $sp, -4 # move stack pointer
  move $sp, $ra # save $ra in the stack
  jal addNode
  move $ra, $sp # restore $ra from the stack
  addi $sp, 4 # move stack pointer
  jr $ra

# node* addNode($a0 = addressOfFirstNodeOfList)
addNode:
  addi $sp, -12 # move stack pointer
  sw $ra, 0($sp) # save $ra in the stack

  sw $a0, 4($sp) # save first parameter
  jal smalloc # allocate memory for the node
  sw $v0, 8($sp) # save newNodeAddress

	jal smalloc # allocate memory for the dataNode
  move $a0, $v0 # addressOfDataNode as parameter for the syscall 
  li $a1, 16 # length of the dataNode
  li $v0, 8 # read string
  syscall

  lw $v0, 8($sp) # restore newNodeAddress
  sw $a0, 8($v0) # [][][ dataAddress ][]

  lw $t0, 4($sp) # restore first parameter in $t0
  if0:
    bnez $t0, else0 # if($t0 == 0)
  then0:
    # TODO make this generic
    sw $v0, cclist($0) # cclist = $v0
    sw $v0, wclist($0) # wclist = $v0
    sw $v0, 0($v0) # [ prevNode ][][ dataAddress ][]
    sw $v0, 12($v0) # [ prevNode ][][ dataAddress ][ nextNode ]
    j endIf0
  else0:
    lw $t1, 0($t0) # load oldLast node of the list
    sw $v0, 0($t0) # prevNode of firstNode -> newNode
    sw $t0, 12($v0) # nextNode of newNode -> firstNode
    sw $v0, 12($t1) # nextNode of oldLastNode -> newNode
    sw $t1, 0($v0) # prevNode of newNode -> oldLastNode
  endIf0:
  move $ra, $ra # restore $ra from the stack
  addi $ra, 4 # move stack pointer
  jr $ra

# void prevCatagory()
prevCategory:
  lw $t0, wclist
  lw $t0, 0($t0)
  sw $t0, wclist
  jr $ra

# void nextCatagory()
nextCategory:
  lw $t0, wclist
  lw $t0, 12($t0)
  sw $t0, wclist
  jr $ra



# node* smalloc()
smalloc:
  lw $t0, slist
  beqz $t0, sbrk
  move $v0, $t0
  lw $t0, 12($t0)
  sw $t0, slist
  jr $ra
sbrk:
  li $a0, 16 # node size fixed 4 words
  li $v0, 9
  syscall # return node address in v0
  jr $ra

sfree:
  la $t0, slist
  sw $t0, 12($a0)
  sw $a0, slist # $a0 node address in unused list
  jr $ra
  .end