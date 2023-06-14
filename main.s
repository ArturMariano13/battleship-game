.data
a:  .word 1103515245  # Constante multiplicativa
m:  .word 12345  # Constante aditiva
c:  .word 10  # Módulo
line0:	.byte '*','*','*','*','*','*','*','*','*','*'	
line1:	.byte '*','*','*','*','*','*','*','*','*','*'
line2:	.byte '*','*','*','*','*','*','*','*','*','*'
line3:	.byte '*','*','*','*','*','*','*','*','*','*'
line4:	.byte '*','*','*','*','*','*','*','*','*','*'
line5:	.byte '*','*','*','*','*','*','*','*','*','*'
line6:	.byte '*','*','*','*','*','*','*','*','*','*'
line7:	.byte '*','*','*','*','*','*','*','*','*','*'
line8:	.byte '*','*','*','*','*','*','*','*','*','*'
line9:	.byte '*','*','*','*','*','*','*','*','*','*'
barco:	.byte 'x'
	
	welcome_msg:	.asciiz "Seja bem vindo ao Batalha Naval! Boa sorte!\n"
	seed_rqst: 		.asciiz "\nInforme a seed para organizacao do tabuleiro: "
	spc: 			.asciiz " "
	linebreak:		.asciiz "\n"
	linha:			.asciiz "linha: "
	coluna: 		.asciiz "coluna: "
	passou: 		.asciiz "passou"

.text
	.globl main
main:
	PRINT_STR = 4
	PRINT_CHAR = 11
	PRINT_INT = 1
	READ_INT = 5
	END_PROGRAM = 10
	
	jal welcome								# função de boas-vindas ao usuário
	jal inicializaGeraAleatorio				# função para inicializar valores da geração aleatória
	jal printMatriz							# matriz sem embarcações posicionadas
	li $s3, 4								# espécie de parâmetro para saber qual função será executada
	jal posicionaHorizontal4 				# função p/ posicionar embarcações de 4 espaços
	jal printMatriz							# função de printar a matriz
	li $s3, 2
	jal posicionaHorizontal2 				# função p/ posicionar embarcações de 2 espaços
	jal printMatriz							# função de printar a matriz
	li $s3, 1
	jal posiciona1							# função p/ posicionar embarcações de 1 espaço
	jal printMatriz							# função de printar a matriz
	
	li $v0, END_PROGRAM						# terminate program
	syscall

# BOAS-VINDAS
welcome:
	li $v0, PRINT_STR						# syscall 4 (print string)
	la $a0, welcome_msg						# argument (string)
	syscall									# print the string (welcome_msg)
	
	li $v0, PRINT_STR						# syscall 4 (print string)
	la $a0, seed_rqst						# argument (string)
	syscall									# print the string (seed_rqst)
	
	li $v0, READ_INT						# syscall 5 (read integer)
	syscall
	
	jr $ra
	
# GERAÇÃO DE VALORES ALEATÓRIOS	
inicializaGeraAleatorio:
	move $t0, $v0          					# armazena a seed em $t0
    lw $t1, a
    lw $t2, m
    lw $t3, c
	jr $ra
generateRandom:
    mul $t0, $t0, $t1     					# t0 = t0 * a
    addu $t0, $t0, $t2    					# t0 = t0 + c
    rem $t0, $t0, $t3     					# t0 = t0 % m

    # Verifica se o valor é negativo
    bltz $t0, convert_to_positive
	
    li $v0, PRINT_STR
    la $a0, linha
    syscall

    # Imprime o valor aleatório da linha
    move $a0, $t0
    li $v0, PRINT_INT
    syscall

    li $v0, PRINT_STR
    la $a0, linebreak
    syscall

    move $s0, $t0  							# salva a linha em $s0

    mul $t0, $t0, $t1  						# t0 = t0 * a
    addu $t0, $t0, $t2  					# t0 = t0 + c
    rem $t0, $t0, $t3  						# t0 = t0 % m

    # Verifica se o valor é negativo
    bltz $t0, convert_to_positive

    li $v0, PRINT_STR
    la $a0, coluna
    syscall

    # Imprime o valor aleatório da coluna
    move $a0, $t0
    li $v0, PRINT_INT
    syscall

    li $v0, PRINT_STR
    la $a0, linebreak
    syscall

    move $s1, $t0  							# salva a coluna em $s1
	
	li $t0, 4
	beq $s3, $t0 continue_execution4
	li $t0, 2
	beq $s3, $t0, continue_execution2
	li $t0, 1
	beq $s3, $t0, continue_execution1
continue_execution4:
    j continua4
continue_execution2:
	j continua2
continue_execution1:
	j continua1

    convert_to_positive:
    neg $t0, $t0  							# converte o valor negativo em positivo
    j generateRandom  						# pula para o código de impressão da linha
	
posicionaHorizontal4:						# corrigir loop infinito	
	j generateRandom						# chamada da função de gerar aleatório (colocar j caso não funcionar)
	continua4:
	li $t0, 6								# t0 recebe o valor máximo para a coluna em uma embarcação de 4 espaços
	bgt $s1, $t0, posicionaHorizontal4		# verifica se cabe um barco de 4 posições
	lb $t1, barco							# t1 armazena o dado do barco
	li $t2, 0								# inicializa o registrador t2
	addi $t9, $s1, 4						# t9 armazena a posição final da embarcação
	
	move $t2, $s1							# t2 recebe o valor da coluna
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
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha04				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao04:
			sb $t1, line0($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao04
			j end_loops
	loopLinha14:
		lb $t4, line1($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha14				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao14:
			sb $t1, line1($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao14
			j end_loops
	loopLinha24:
		lb $t4, line2($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha24				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao24:
			sb $t1, line2($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao24
			j end_loops
	loopLinha34:
		lb $t4, line3($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha34				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao34:
			sb $t1, line3($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao34
			j end_loops
	loopLinha44:
		lb $t4, line4($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha44				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao44:
			sb $t1, line4($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao44
			j end_loops
	loopLinha54:
		lb $t4, line5($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha54				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao54:
			sb $t1, line5($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao54
			j end_loops
	loopLinha64:
		lb $t4, line6($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha64				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao64:
			sb $t1, line6($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao64
			j end_loops
	loopLinha74:
		lb $t4, line7($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha74				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao74:
			sb $t1, line7($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao74
			j end_loops
	loopLinha84:
		lb $t4, line8($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha84				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao84:
			sb $t1, line8($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao84
			j end_loops
	loopLinha94:
		lb $t4, line9($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal4		# verifica se já há barco no local
		blt $t2, $t9, loopLinha94				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao94:
			sb $t1, line9($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao94
			j end_loops
	end_loops:
		jr $ra
	# s1 = coluna
	
posicionaHorizontal2:						# corrigir loop infinito	
	j generateRandom						# chamada da função de gerar aleatório (colocar j caso não funcionar)
	continua2:
	li $t0, 9								# t0 recebe o valor máximo para a coluna em uma embarcação de 4 espaços
	beq $s1, $t0, posicionaHorizontal2		# verifica se cabe um barco de 4 posições
	lb $t1, barco							# t1 armazena o dado do barco
	li $t2, 0								# inicializa o registrador t2
	addi $t9, $s1, 2						# t9 armazena a posição final da embarcação
	
	move $t2, $s1							# t2 recebe o valor da coluna
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
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha02				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao02:
			sb $t1, line0($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao02
			j end_loops2
	loopLinha12:
		lb $t4, line1($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha12				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao12:
			sb $t1, line1($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao12
			j end_loops2
	loopLinha22:
		lb $t4, line2($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha22				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao22:
			sb $t1, line2($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao22
			j end_loops2
	loopLinha32:
		lb $t4, line3($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha32				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao32:
			sb $t1, line3($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao32
			j end_loops2
	loopLinha42:
		lb $t4, line4($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha42				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao42:
			sb $t1, line4($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao42
			j end_loops2
	loopLinha52:
		lb $t4, line5($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha52				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao52:
			sb $t1, line5($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao52
			j end_loops2
	loopLinha62:
		lb $t4, line6($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha62				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao62:
			sb $t1, line6($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao62
			j end_loops2
	loopLinha72:
		lb $t4, line7($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha72				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao72:
			sb $t1, line7($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao72
			j end_loops2
	loopLinha82:
		lb $t4, line8($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha82				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao82:
			sb $t1, line8($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao82
			j end_loops2
	loopLinha92:
		lb $t4, line9($t2)
		addi $t2, $t2, 1
		beq $t1, $t4, posicionaHorizontal2		# verifica se já há barco no local
		blt $t2, $t9, loopLinha92				# verifica se o contador atingiu o tamanho máximo da embarcação
		move $t2, $s1							# t2 recebe o valor da coluna
		posicionaEmbarcacao92:
			sb $t1, line9($t2)
			addi $t2, $t2, 1
			blt $t2, $t9, posicionaEmbarcacao92
			j end_loops2
	end_loops2:
		jr $ra
	
posiciona1:
	j generateRandom
	continua1:
	lb $t1, barco							# t1 armazena o dado do barco
	li $t2, 0								# inicializa o registrador t2
	move $t2, $s1							# t2 recebe o valor da coluna
	li $t3, 0
	beq $s0, $t3, linha0
	li $t3, 1
	beq $s0, $t3, linha1
	li $t3, 2
	beq $s0, $t3, linha2
	li $t3, 3
	beq $s0, $t3, linha3
	li $t3, 4
	beq $s0, $t3, linha4
	li $t3, 5
	beq $s0, $t3, linha5
	li $t3, 6
	beq $s0, $t3, linha6
	li $t3, 7
	beq $s0, $t3, linha7
	li $t3, 8
	beq $s0, $t3, linha8
	li $t3, 9
	beq $s0, $t3, linha9
	linha0:
		sb $t1, line0($t2)
		j end_loops3
	linha1:
		sb $t1, line1($t2)
		j end_loops3
	linha2:
		sb $t1, line2($t2)
		j end_loops3
	linha3:
		sb $t1, line3($t2)
		j end_loops3
	linha4:
		sb $t1, line4($t2)
		j end_loops3
	linha5:
		sb $t1, line5($t2)
		j end_loops3
	linha6:
		sb $t1, line6($t2)
		j end_loops3
	linha7:
		sb $t1, line7($t2)
		j end_loops3
	linha8:
		sb $t1, line8($t2)
		j end_loops3
	linha9:
		sb $t1, line9($t2)
		j end_loops3
	# verificar se já há barco no locl sorteado
	# s1 = coluna
	end_loops3:
		jr $ra
	
printMatriz:
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)
	
PRINT_LOOP0:
	lb $a0, line0($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP0	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)

PRINT_LOOP1:
	lb $a0, line1($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP1	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)
	
PRINT_LOOP2:
	lb $a0, line2($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP2	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)
	
PRINT_LOOP3:
	lb $a0, line3($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP3	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)

PRINT_LOOP4:
	lb $a0, line4($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP4	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)
	
PRINT_LOOP5:
	lb $a0, line5($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP5	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)
	
PRINT_LOOP6:
	lb $a0, line6($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP6	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)
	
PRINT_LOOP7:
	lb $a0, line7($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP7	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)
	
PRINT_LOOP8:
	lb $a0, line8($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP8	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0				# inicializa $t9 como 0 (base do endereço)
	
PRINT_LOOP9:
	lb $a0, line9($t9)		# carrega o dado do vetor
	li $v0, PRINT_CHAR		# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR		# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1		# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_LOOP9	# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall

	jr $ra