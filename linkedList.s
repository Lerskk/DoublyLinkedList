  .data
slist: .word 0
cclist: .word 0
wclist: .word 0
buff: .asciiz "Mamiferos"
buff2: .asciiz "Mamiferos2"
buff3: .asciiz "Mamiferos3"
# mssg: 
  .text
  .globl main
main:
  la $a0, buff($0)
  jal newCategory 
  la $a0, buff2($0)
  jal newCategory 
  la $a0, buff3($0)
  jal newCategory 


  # jal prevCategory
  jal prevCategory
  jal nextCategory
  jal nextCategory

  li $v0, 10
  syscall

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

# void newCategory($a0 = categoryNameAddress)
newCategory:
  move $a1, $a0 # input 
  lw $a0, cclist
  move $s0, $ra # save $ra
  jal addNode
  move $ra, $s0 # restore $ra
  jr $ra

# node* addNode($a0 = addressOfFirstNodeOfList, $a1 = nodeData)
addNode:
  move $s1, $ra # save $ra
  # TODO stack
  move $s2, $a0
  jal smalloc # allocate memory for the node
  move $t0, $s2
  sw $a1, 8($v0) # [][][ dataAddress ][]
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
  move $ra, $s1 # restore $ra
  jr $ra
  
# void newnode(int number)
newnode: 
  move $t0, $a0 # preserva arg 1
  li $v0, 9
  li $a0, 8
  syscall # sbrk 8 bytes long
  sw $t0, ($v0) # guarda el arg en new node
  lw $t1, slist
  beq $t1, $0, first # ? si la lista es vacia
  sw $t1, 4($v0) # inserta new node por el frente
  sw $v0, slist # actualiza la lista
  jr $ra
first: sw $0, 4($v0) # primer nodo inicializado a null
  sw $v0, slist # apunta la lista a new node
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