  .data
slist: .word 0
cclist: .word 0
wclist: .word 0
menu: .asciiz "\n1 - Crear nueva categoria vacia.\n2 - Seleccionar siguiente categoria.\n3 - Seleccionar anterior categoria.\n4 - Listar las categorias.\n5 - Borrar categoria seleccionada.\n6 - Anexar objeto a la categoria seleccionada.\n7 - Borrar un objeto de la categoria seleccionada.\n8 - Listar los objectos de la categoria seleccionada. \n9 - Salir.\n\nIngrese la opcion deseada: "
dataNodeMsg: .asciiz "\nIngrese el dato del nodo: "
objectNodeIdMsg: .asciiz "\nIngrese el id del objeto: "
objectSeparator: .asciiz ": "
emptyCategories: .asciiz "\nNo existe ninguna categoria\n"
emptyObjects: .asciiz "\nNo existe ningun objeto\n"

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
        jal nextCategory
        j endSwitch

      case3:
        bne $v0, 3, case4
        jal prevCategory
        j endSwitch

      case4:
        bne $v0, 4, case5
        jal displayCategories
        j endSwitch

      case5:
        bne $v0, 5, case6
        jal delCategory
        j endSwitch
      case6:
        bne $v0, 6, case7
        jal newObject
        j endSwitch

      case7:
        bne $v0, 7, case8
        la $a0, objectNodeIdMsg
        li $v0, 4
        syscall

        li $v0, 5
        syscall
        move $a0, $v0

        jal delObject
        j endSwitch
      case8:
        # TODO display empty list
        bne $v0, 8, case9
        jal displayObjects
        j endSwitch
      case9:
        bne $v0, 9, default
        j endfor0
      
      default:
        # TODO error message
    endSwitch:

    j for0
  endfor0:
  li $v0, 10
  syscall

# node* newCategory()
newCategory:
  addi $sp, $sp, -8 # move stack pointer
  sw $ra, 0($sp) # save $ra in the stack
  sw $a0, 4($sp) # save first parameter of addNode
  lw $a0, cclist
  la $a1, cclist
  jal addNode
  lw $t0, 4($sp) # restore first parameter of addNode in $t0

  if2:
    bnez $t0, endIf2
  thenIf2:
    sw $v0, wclist($0) # wclist = $v0
  endIf2:

  lw $ra, 0($sp) # restore $ra from the stack
  addi $sp, $sp, 8 # move stack pointer
  jr $ra

# node* addNode($a0 = addressOfFirstNodeOfList, $a1 = addressOfListPointer)
addNode:
  addi $sp, $sp, -16 # move stack pointer
  sw $ra, 0($sp) # save $ra in the stack
  sw $a1, 12($sp)

  sw $a0, 4($sp) # save first parameter
  jal smalloc # allocate memory for the node
  sw $v0, 8($sp) # save newNodeAddress
  
  li $v0, 4 
  la $a0, dataNodeMsg
  syscall

	jal smalloc # allocate memory for the dataNode
  move $a0, $v0 # addressOfDataNode as parameter for the syscall 
  li $a1, 16 # length of the dataNode
  li $v0, 8 # read string
  syscall

  lw $v0, 8($sp) # restore newNodeAddress
  sw $a0, 8($v0) # [][][ dataAddress ][]

  lw $t0, 4($sp) # restore first parameter in $t0
  lw $a1, 12($sp) # restore second parameter in $a1
  if0:
    bnez $t0, else0 # if($t0 == 0)
  then0:
    sw $v0, 0($a1) # cclist = $v0
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
  lw $ra, 0($sp) # restore $ra from the stack
  addi $sp, $sp, 16 # move stack pointer
  jr $ra

# void delNode($a0 = node*)
delNode:
  addi $sp, $sp, -8 # move stack pointer
  sw $a0, 4($sp) # save node address
  sw $ra, 0($sp) # save $ra

  lw $t0, 0($a0) # prev node address
  lw $t1, 12($a0) # next node address
  
  sw $t0, 0($t1) # prev of next = prev
  sw $t1, 12($t0) # next of prev = next


  lw $a0, 8($a0) # data node address as first parameter of sfree
  jal sfree # free third field

  lw $a0, 4($sp) # restore node address
  jal sfree # free node

  lw $ra, 0($sp) # restore $ra
  addi $sp, $sp, 8 # move stack poinetr
  jr $ra


# void delCategory()
delCategory:
  addi $sp, $sp, -8 # move stack pointer
  sw $ra, 0($sp) # store $ra in the stack

  lw $t0, wclist # working category
  sw $t0, 4($sp) # store working category in the stack
  addi $t3, $t0, 8 # address of address of first object of the category
  lw $t4, 0($t3) # address of the first object of the category
  lw $t3, 0($t3) # address of the first object of the category
  lw $t3, 0($t3) # prev of teh first object of the category
  addi $t1, $t0, 12 # next category
  lw $t1, 12($t0)
  lw $t2, cclist # first category
  if4:
		bne $t0, $t1, else4 # next == wclist then there's only one node
  then4:
    la $t8, cclist($0)
    sw $0, 0($t8) # first category = null

    j endIf4
  else4:
    if5:
      bne $t0, $t2, endIf5 # node address == cclist
    then5:
      la $t8, cclist($0)
      sw $t1, 0($t8) # cclist = next node
    endIf5:
  endIf4:

  lw $t0, 4($sp) # restore woking category
  lw $t5, 4($t0) # load address of the object 
  if6:
    beqz $t5, endIf6 # if wclist == 0 => has an object
  then6:
    for3:
      lw $t5, 12($t4)
      move $a0, $t4
      jal delNode
      
      beq $t4, $t3, endFor3
      move $t4, $t5
      j for3
    endFor3:
  endIf6:

    
  lw $t2, cclist # first category
  sw $t2, wclist # wclist = cclist

  lw $t0, 4($sp) # restore woking category
  move $a0, $t0 # node address as first parameter of delNode
  jal delNode # delete category

  lw $ra, 0($sp) # restore $ra
  addi $sp, $sp, 8 # move stack pointer
  jr $ra

# void delObject($a0 = id)
delObject: 
  addi $sp, $sp, -4
  sw $ra, 0($sp) # save $ra to the stack
  lw $t5, wclist
  lw $t0, 4($t5) # address of first object of the category
  lw $t1, 0($t0) # address of last object of the category

  # loop through objects
  # check if the id matches
  # call delNode and break the for
  lw $t2, 4($t0) # id of the first object
  if7:
    bne $a0, $t2, else7 # if id != first id => the object to delete is not the first one
  then7:
    lw $t3, 12($t0) # load nextNode of the first node
    if8:
      bne $t1, $t0, else8  # prevNode != nextNode then there's more than one object
    then8:
      sw $0, 4($t5) # remap second field of working category to null as there aren't any other objects

      move $a0, $t0 
      jal delNode

      j endIf8
    else8:
      sw $t3, 4($t5) # remap second field of working category to second object

      move $a0, $t0
      jal delNode
    endIf8:
    j endIf7
  else7:
    for4:
      lw $t2, 4($t0) # id of current object
      if9:
        bne $a0, $t2, endIf8 # if id of current object == id 
      then9:
        move $a0, $t0
        jal delNode # then delNode
        j endFor4 # break for
      endIf9:
      
      beq $t0, $t1, endFor4
      lw $t0, 12($t0)
    endFor4:
  endIf7:

  lw $ra, 0($sp) # restore $sp from the stack
  addi $sp, $sp, 4 # move stack pointer
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

# void displayCategories()
displayCategories:
  lw $t0, cclist
  if10: 
    bnez $t0, else10 # if cclist == 0 => dosn't exist any categories
  then10: 
    li $v0, 4
    la $a0, emptyCategories
    syscall
  j endIf10

  else10:
    li $v0, 11
    li $a0, '\n'
    syscall

    lw $t9, wclist
    lw $t1, cclist
    lw $t0, 0($t1) # $t1 = current and $t0 = lastNode
    for1:
      if1:
        bne $t1, $t9, endIf1 # if the current category is selected display an * before its name
      then1:
        li $v0, 11
        li $a0, '*'
        syscall
      endIf1:
      lw $a0, 8($t1)
      li $v0, 4
      syscall

      beq $t0, $t1, endfor1
      lw $t1, 12($t1)
      j for1
    endfor1:
  endIf10:
  jr $ra

# void newObject()
newObject:
  addi $sp, $sp, -8 # move stack pointer
  sw $ra, 0($sp) # save ra in the stack
  lw $a1, wclist 
  addi $a1, $a1, 4
  lw $a0, 0($a1)
  la $a1, 0($a1)

  sw $a0, 4($sp) # save $a0 in the stack
  jal addNode
  lw $t0, 4($sp) # restore $a0 from the stack in $t0

  if3:
    bnez $t0, else3 
  then3:
    li $t0, 1
    sw $t0, 4($v0) # [][0x1][][]
    j endIf3
  else3:
    lw $t0, 0($v0) # take prevNode
    lw $t0, 4($t0)
    addi $t0, $t0, 1
    sw $t0, 4($v0)
  endIf3:

  lw $ra, 0($sp)
  addi $sp, $sp, 8
  jr $ra

# void displayObjects()
displayObjects:
  li $a0, '\n'
  li $v0, 11 # print char
  syscall

  lw $t0, wclist # working category
  lw $t0, 4($t0) # firstObjectNode
  move $t1, $t0 # copy of firstObjectNode
  for2:
    lw $a0, 4($t0) # display object id
    li $v0, 1 # print int
    syscall 
    
    la $a0, objectSeparator # display ": " between the id and the object data
    li $v0, 4 # print sting
    syscall

    lw $a0, 8($t0) # display objectData
    syscall

    lw $t0, 12($t0)
    beq $t0, $t1, endfor2
    j for2 
  endfor2:

  jr $ra

# # void newnode(int number)
# newnode: move $t0, $a0 # preserva arg 1
#  li $v0, 9
#  li $a0, 8
#  syscall # sbrk 8 bytes long
#  sw $t0, ($v0) # guarda el arg en new node
#  lw $t1, slist
#  beq $t1, $0, first # ? si la lista es vacia
#  sw $t1, 4($v0) # inserta new node por el frente
#  sw $v0, slist # actualiza la lista
#  jr $ra
# first: sw $0, 4($v0) # primer nodo inicializado a null
#  sw $v0, slist # apunta la lista a new node
#  jr $ra

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
 lw $t0, slist
 sw $t0, 12($a0)
 sw $a0, slist # $a0 node address in unused list
 jr $ra