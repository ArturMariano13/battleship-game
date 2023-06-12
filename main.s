.data
a:  
	.word 1103515245  # Constante multiplicativa
m:  
	.word 12345  # Constante aditiva
c:  
	.word 10  # Módulo
line0: 
	.byte '*','*','*','*','*','*','*','*','*','*'	
line1: 
	.byte '*','*','*','*','*','*','*','*','*','*'
line2: 
	.byte '*','*','*','*','*','*','*','*','*','*'
line3: 
	.byte '*','*','*','*','*','*','*','*','*','*'
line4: 
	.byte '*','*','*','*','*','*','*','*','*','*'
line5: 
	.byte '*','*','*','*','*','*','*','*','*','*'
line6: 
	.byte '*','*','*','*','*','*','*','*','*','*'
line7: 
	.byte '*','*','*','*','*','*','*','*','*','*'
line8: 
	.byte '*','*','*','*','*','*','*','*','*','*'
line9: 
	.byte '*','*','*','*','*','*','*','*','*','*'
barco:
	.byte 'x'
	
	welcome_msg:	.asciiz "Seja bem vindo ao Batalha Naval! Boa sorte!\n"
	seed_rqst: 		.asciiz "\nInforme a seed para organizacao do tabuleiro: "
	spc: 			.asciiz " "
	linebreak:		.asciiz "\n"
	linha:			.asciiz "linha: "
	coluna: 		.asciiz "coluna: "

.text
	.globl main
main:
	PRINT_STR = 4
	PRINT_CHAR = 11
	PRINT_INT = 1
	READ_INT = 5
	END_PROGRAM = 10
	
	jal welcome				# chama função de dar boas-vindas ao usuário
	jal printMatriz			# chama função de printar a matriz
	jal posicionaHorizontal4 #chama a função para posicionar embarcações de 4 espaços
	jal posicionaHorizontal2 #chama a função para posicionar embarcações de 2 espaços
	#jal posicionaHorizontal1 #chama a função para posicionar embarcações de 1 espaços

	jal printMatriz			# chama função de printar a matriz
	
	li $v0, END_PROGRAM		# terminate program
	syscall
	

# BOAS-VINDAS
welcome:
	li $v0, PRINT_STR		# syscall 4 (print string)
	la $a0, welcome_msg		# argument (string)
	syscall					# print the string (welcome_msg)
	
	li $v0, PRINT_STR		# syscall 4 (print string)
	la $a0, seed_rqst		# argument (string)
	syscall					# print the string (seed_rqst)
	
	li $v0, READ_INT		# syscall 5 (read integer)
	syscall
	
	jr $ra
	
# GERAÇÃO DE VALORES ALEATÓRIOS	
geraAleatorio:
	move $t0, $v0			# armazena a seed em $t0
	lw $t1, a
    lw $t2, m
    lw $t3, c
	li $t4, 2  # Gera três valores aleatórios (altere conforme necessário)
    # Calcula o próximo valor aleatório
generateRandom:
	mul $t0, $t0, $t1  # t0 = t0 * a
    addu $t0, $t0, $t2  # t0 = t0 + c
    rem $t0, $t0, $t3  # t0 = t0 % m
    
	li $v0, PRINT_STR
	la $a0, linha
	syscall
	
	# Imprime o valor aleatório
    move $a0, $t0
    li $v0, PRINT_INT
    syscall
	
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	move $s0, $t0	# salva a linha em s0

	mul $t0, $t0, $t1  # t0 = t0 * a
    addu $t0, $t0, $t2  # t0 = t0 + c
    rem $t0, $t0, $t3  # t0 = t0 % m
	
	li $v0, PRINT_STR
	la $a0, coluna
	syscall
	
	# Imprime o valor aleatório
    move $a0, $t0
    li $v0, PRINT_INT
    syscall
	
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	move $s1, $t0	# salva a coluna em s1
	    
    # Pula para a próxima iteração ou termina o programa
    addiu $t4, $t4, -1
    bnez $t4, generateRandom
	
	jr $ra
	
posicionaHorizontal4:	# deve verificar para qual lado posiciona
	jal generateRandom	# chamada da função de gerar aleatório (colocar j caso não funcionar)
	li $t0, 6
	bgt $s1, $t0, posicionaHorizontal4
	li $t1, 'x'
	move $t2, $s1	# t2 = coluna
	addi $t9, $t0, 3
	
	li $t3, 0
	beq $t3, $s0, loopLinha04
	li $t3, 1
	beq $t3, $s0, loopLinha14
	li $t3, 2
	beq $t3, $s0, loopLinha24
	li $t3, 3
	beq $t3, $s0, loopLinha34
	li $t3, 4
	beq $t3, $s0, loopLinha44
	li $t3, 5
	beq $t3, $s0, loopLinha54
	li $t3, 6
	beq $t3, $s0, loopLinha64
	li $t3, 7
	beq $t3, $s0, loopLinha74
	li $t3, 8
	beq $t3, $s0, loopLinha84
	li $t3, 9
	beq $t3, $s0, loopLinha94
	loopLinha04:
		lb $t4, line0($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha04
		posicionaEmbarcacao04:
			move $t2, $s1
			sb $t1, line0($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao04
		jr $ra
	loopLinha14:
		lb $t4, line1($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha14
		posicionaEmbarcacao14:
			move $t2, $s1
			sb $t1, line1($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao14
		jr $ra
	loopLinha24:
		lb $t4, line2($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha24
		posicionaEmbarcacao24:
			move $t2, $s1
			sb $t1, line2($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao24
		jr $ra
	loopLinha34:
		lb $t4, line3($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha34
		posicionaEmbarcacao34:
			move $t2, $s1
			sb $t1, line3($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao34
		jr $ra
	loopLinha44:
		lb $t4, line4($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha44
		posicionaEmbarcacao44:
			move $t2, $s1
			sb $t1, line4($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao44
		jr $ra
	loopLinha54:
		lb $t4, line5($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha54
		posicionaEmbarcacao54:
			move $t2, $s1
			sb $t1, line5($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao54
		jr $ra
	loopLinha64:
		lb $t4, line6($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha64
		posicionaEmbarcacao64:
			move $t2, $s1
			sb $t1, line6($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao64
		jr $ra
	loopLinha74:
		lb $t4, line7($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha74
		posicionaEmbarcacao74:
			move $t2, $s1
			sb $t1, line7($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao74
		jr $ra
	loopLinha84:
		lb $t4, line8($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha84
		posicionaEmbarcacao84:
			move $t2, $s1
			sb $t1, line8($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao84
		jr $ra
	loopLinha94:
		lb $t4, line9($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4	# verifica se já há barco no local
		blt $t2, $t9, loopLinha94
		posicionaEmbarcacao94:
			move $t2, $s1
			sb $t1, line9($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao94
		jr $ra
	# s1 = coluna
	
posicionaHorizontal2:
	jal geraAleatorio	# chamada da função de gerar aleatório (colocar j caso não funcionar)
	li $t0, 8
	bgt $s1, $t0, posicionaHorizontal2
	li $t1, 'x'
	move $t2, $s1	# t2 = coluna
	addi $t9, $t2, 1
	li $t3, 0
	beq $t3, $s0, loopLinha02
	li $t3, 1
	beq $t3, $s0, loopLinha12
	li $t3, 2
	beq $t3, $s0, loopLinha22
	li $t3, 3
	beq $t3, $s0, loopLinha32
	li $t3, 4
	beq $t3, $s0, loopLinha42
	li $t3, 5
	beq $t3, $s0, loopLinha52
	li $t3, 6
	beq $t3, $s0, loopLinha62
	li $t3, 7
	beq $t3, $s0, loopLinha72
	li $t3, 8
	beq $t3, $s0, loopLinha82
	li $t3, 9
	beq $t3, $s0, loopLinha92
	loopLinha02:
		lb $t4, line0($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line0($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao02:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line0($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao02
		jr $ra
	loopLinha12:
		lb $t4, line1($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line1($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao12:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line1($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao12
		jr $ra
	loopLinha22:
		lb $t4, line2($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line2($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao22:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line2($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao22
		jr $ra
	loopLinha32:
		lb $t4, line3($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line3($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao32:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line3($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao32
		jr $ra
	loopLinha42:
		lb $t4, line4($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line4($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao42:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line4($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao42
		jr $ra
	loopLinha52:
		lb $t4, line5($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line5($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao52:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line5($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao52
		jr $ra
	loopLinha62:
		lb $t4, line6($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line6($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao62:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line6($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao62
		jr $ra
	loopLinha72:
		lb $t4, line7($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line7($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao72:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line7($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao72
		jr $ra
	loopLinha82:
		lb $t4, line8($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line8($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao82:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line8($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao82
		jr $ra
	loopLinha92:
		lb $t4, line9($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		addi $t2, $t2, 1
		lb $t4, line9($t2)
		beq $t4, $t1, posicionaHorizontal2	# verifica se já há barco no local
		posicionaEmbarcacao92:
			move $t2, $s1	# t2 recebe a coluna
			sb $t1, line3($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao92
		jr $ra
	# s1 = coluna
	
posicionaHorizontal1:
	jal geraAleatorio
	li $t0, 'x'
	move $t3, $s1
	li $t1, 0
	beq $s0, $t1, linha0
	li $t1, 1
	beq $s0, $t1, linha1
	li $t1, 2
	beq $s0, $t1, linha2
	li $t1, 3
	beq $s0, $t1, linha3
	li $t1, 4
	beq $s0, $t1, linha4
	li $t1, 5
	beq $s0, $t1, linha5
	li $t1, 6
	beq $s0, $t1, linha6
	li $t1, 7
	beq $s0, $t1, linha7
	li $t1, 8
	beq $s0, $t1, linha8
	li $t1, 9
	beq $s0, $t1, linha9
	linha0:
		la $t4, line0
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	linha1:
		la $t4, line1
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	linha2:
		la $t4, line2
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	linha3:
		la $t4, line3
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	linha4:
		la $t4, line4
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	linha5:
		la $t4, line5
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	linha6:
		la $t4, line6
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	linha7:
		la $t4, line7
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	linha8:
		la $t4, line8
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	linha9:
		la $t4, line9
		addu $t5, $t4, $t3
		sb $t2, ($t5)
		jr $ra
	# verificar se já há barco no locl sorteado
	# s1 = coluna
	jr $ra
	
printMatriz:
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)
	
PRINT_LOOP:
	lb $a0, line0($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	lb $a0, line1($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	lb $a0, line2($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	lb $a0, line3($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	lb $a0, line4($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	lb $a0, line5($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	lb $a0, line6($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	lb $a0, line7($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	lb $a0, line8($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	lb $a0, line9($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP	# verifica se i > 0 (continua o loop)

	jr $ra