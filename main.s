.data
a:  .word 1103515245  # Constante multiplicativa
m:  .word 12345  # Constante aditiva
c:  .word 10  # Módulo
acertos:  .word 0
erros:  .word 0
tentativas: .word 0
porcentagem: .word 0

# MATRIZ PARA ARMAZENAR AS EMBARCAÇÕES
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
agua: 	.byte '~'
vazio:  .byte '*'

# MATRIZ PARA ARMAZENAR BARCOS, ESPAÇOS NÃO TESTADOS E ÁGUA
jogo0:	.byte '*','*','*','*','*','*','*','*','*','*'	
jogo1:	.byte '*','*','*','*','*','*','*','*','*','*'
jogo2:	.byte '*','*','*','*','*','*','*','*','*','*'
jogo3:	.byte '*','*','*','*','*','*','*','*','*','*'
jogo4:	.byte '*','*','*','*','*','*','*','*','*','*'
jogo5:	.byte '*','*','*','*','*','*','*','*','*','*'
jogo6:	.byte '*','*','*','*','*','*','*','*','*','*'
jogo7:	.byte '*','*','*','*','*','*','*','*','*','*'
jogo8:	.byte '*','*','*','*','*','*','*','*','*','*'
jogo9:	.byte '*','*','*','*','*','*','*','*','*','*'
	
	welcome_msg:	.asciiz "Seja bem vindo ao Batalha Naval! Boa sorte!\n"
	seed_rqst: 		.asciiz "\nInforme a seed para organizacao do tabuleiro: "
	spc: 			.asciiz " "
	linebreak:		.asciiz "\n"
	msg_acerto:         .asciiz "Acertou!!"
	msg_erro:           .asciiz "Errou! Caiu na agua"
	msg_jaFoi: 		.asciiz "Erro! Coordenadas ja testadas!"
	game:           .asciiz "\nO Jogo iniciou!!\n"
	msg_linha:      .asciiz "Informe a linha: "
	msg_coluna:     .asciiz "Informe a coluna " 
	msg_parada:     .asciiz "O jogo acaba apos 10 rodadas."
	msg_fim:        .asciiz "GAME OVER"
	msg_tentativasfinal: .asciiz "Total de tentativas:"
	msg_acertofinal:  .asciiz "Total de acertos: "
	msg_errosfinal: .asciiz "Total de erros: "
	msg_porcentagem: .asciiz "Seu percentual de acertos foi de: "
	porcentagemfinal: .asciiz "%"
	msg_maior: .asciiz  "Erro! Valor maior que 9!!"
	msg_menor0: .asciiz "Erro! Valor menor que 0!!"
	msg_regramaior: .asciiz "Insira apenas valores entre 0 e 9."

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
	li $s3, 2
	jal posicionaHorizontal2 				# função p/ posicionar embarcações de 2 espaços
	li $s3, 1
	jal posiciona1							# função p/ posicionar embarcações de 1 espaço
	li $s3, 2
	jal posicionaHorizontal2 				# função p/ posicionar embarcações de 2 espaços
	li $s7, -1	# contador jogo
	jal printGame                           # função p/ começar o game

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
	
    move $s0, $t0  							# salva a linha em $s0

    mul $t0, $t0, $t1  						# t0 = t0 * a
    addu $t0, $t0, $t2  					# t0 = t0 + c
    rem $t0, $t0, $t3  						# t0 = t0 % m

    # Verifica se o valor é negativo
    bltz $t0, convert_to_positive

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
	
	
printGame: 
    li $s3, 0  # t9 armazena as tentativas
    li $s4, 0  # t8 armazena os erros
	li $s5, 0 # t7 armazena os acertos
	
	li $v0, PRINT_STR		# mostra "\n"
    la $a0, linebreak
    syscall 
	
    li $v0, PRINT_STR			       # syscall 4 (print string)
	la $a0, msg_parada						# argument (string)
	syscall	
	li $v0, PRINT_STR			       # syscall 4 (print string)
	la $a0, linebreak						# argument (string)
	syscall	
	li $v0, PRINT_STR			       # syscall 4 (print string)
	la $a0, msg_regramaior						# argument (string)
	syscall	
	li $v0, PRINT_STR			       # syscall 4 (print string)
	la $a0, linebreak						# argument (string)
	syscall	
    li $v0, PRINT_STR			       # syscall 4 (print string)
	la $a0, game						# argument (string)
	syscall	
    j comecou	
comecou:
	addi $s7, $s7, 1
	beq $s7, 15, fim_jogo	# jogo limitado em 15 rodadas
    li $v0, PRINT_STR
	la $a0, linebreak
	syscall

    li $v0, PRINT_STR						# syscall 4 (print string)
	la $a0, msg_linha						# argument (string)
	syscall		

  	li $v0, READ_INT						# syscall 5 (read integer)
	syscall
	
	move $t0, $v0 # t0 é a linha
	
	li $t4, 10
	bge $t0, $t4, maior
	bltz $t0, menor0
   
    li $v0, PRINT_STR				# solicita ao usuário uma coluna
    la $a0, msg_coluna
    syscall 
	
	li $v0, READ_INT				# syscall 5 (read integer)
	syscall		
   
    move $t1, $v0 					# t1 é a coluna
	bge $t1, $t4, maior
	bltz $t1, menor0
 
	lb $t6, barco	# t6 armazena o dado do barco
	lb $t7, vazio	# t7 armazena o dado do vazio
	lb $t8, agua    # t8 armazena o dado da agua
	
	li $t5, 0 # dado temporario para fazer o teste beq
	beq $t0, $t5, linhaJogo0
	li $t5, 1
	beq $t0, $t5, linhaJogo1
	li $t5, 2
	beq $t0, $t5, linhaJogo2
	li $t5, 3
	beq $t0, $t5, linhaJogo3
	li $t5, 4
	beq $t0, $t5, linhaJogo4
	li $t5, 5
	beq $t0, $t5, linhaJogo5
	li $t5, 6
	beq $t0, $t5, linhaJogo6
	li $t5, 7
	beq $t0, $t5, linhaJogo7
	li $t5, 8
	beq $t0, $t5, linhaJogo8
	li $t5, 9
	beq $t0, $t5, linhaJogo9
	
	linhaJogo0:
	    lb $t3, line0($t1)		# carrega o dado do vetor
		lb $t9, jogo0($t1)
		#beq $t9, $t6, jaFoi		# se for um 'x' (barco), verifica que aquela posicao já foi
		bne $t7, $t9, jaFoi			# se for diferente de um '*' (vazio), verifica que aquela posicao já foi
		bne $t6, $t3, errou0
		sb $t6, jogo0($t1)
		j acerto
		errou0:
			sb $t8, jogo0($t1)
			j erro
	linhaJogo1:
		lb $t3, line1($t1)		# carrega o dado do vetor
		lb $t9, jogo1($t1)
		#beq $t9, $t6, jaFoi
		bne $t7, $t9, jaFoi
		bne $t6, $t3 , errou1
		sb $t6, jogo1($t1)
		j acerto
		errou1:
			sb $t8, jogo1($t1)
		j erro
	linhaJogo2:
		lb $t3, line2($t1)		# carrega o dado do vetor
		lb $t9, jogo2($t1)
		#beq $t9, $t6, jaFoi
		bne $t7, $t9, jaFoi
		bne $t6, $t3 , errou2
		sb $t6, jogo2($t1)
		j acerto
		errou2:
			sb $t8, jogo2($t1)
		j erro
	linhaJogo3:
		lb $t3, line3($t1)		# carrega o dado do vetor
		lb $t9, jogo3($t1)
		#beq $t9, $t7, jaFoi
		bne $t7, $t9, jaFoi
		bne $t6, $t3 , errou3
		sb $t6, jogo3($t1)
		j acerto
		errou3:
			sb $t8, jogo3($t1)
		j erro
	linhaJogo4:
		lb $t3, line4($t1)		# carrega o dado do vetor
		lb $t9, jogo4($t1)
		#beq $t9, $t6, jaFoi
		bne $t7, $t9, jaFoi
		bne $t6, $t3 , errou4
		sb $t6, jogo4($t1)
		j acerto
		errou4:
			sb $t8, jogo4($t1)
		j erro
	linhaJogo5:
		lb $t3, line5($t1)		# carrega o dado do vetor
		lb $t9, jogo5($t1)
		#beq $t9, $t6, jaFoi
		bne $t7, $t9, jaFoi
		bne $t6, $t3 , errou5
		sb $t6, jogo5($t1)
		j acerto
		errou5:
			sb $t8, jogo5($t1)
		j erro
	linhaJogo6:
		lb $t3, line6($t1)		# carrega o dado do vetor
		lb $t9, jogo6($t1)
		#beq $t9, $t6, jaFoi
		bne $t7, $t9, jaFoi
		bne $t6, $t3 , errou6
		sb $t6, jogo6($t1)
		j acerto
		errou6:
			sb $t8, jogo6($t1)
		j erro
	linhaJogo7:
	    lb $t3, line7($t1)		# carrega o dado do vetor
		lb $t9, jogo7($t1)
		#beq $t9, $t6, jaFoi
		bne $t7, $t9, jaFoi
		bne $t6, $t3 , errou7
		sb $t6, jogo7($t1)
		j acerto
		errou7:
			sb $t8, jogo7($t1)
		j erro
	linhaJogo8:
	    lb $t3, line8($t1)		# carrega o dado do vetor
		lb $t9, jogo8($t1)
		#beq $t9, $t6, jaFoi
		bne $t7, $t9, jaFoi
		bne $t6, $t3 , errou8
		sb $t6, jogo8($t1)
		j acerto
		errou8:
			sb $t8, jogo8($t1)
		j erro
	linhaJogo9:
		lb $t3, line9($t1)		# carrega o dado do vetor
		lb $t9, jogo9($t1)
		#beq $t9, $t6, jaFoi
		bne $t7, $t9, jaFoi
		bne $t6, $t3 , errou9
		sb $t6, jogo9($t1)
		j acerto
		errou9:
			sb $t8, jogo9($t1)
		j erro
		
acerto:
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $v0, PRINT_STR						# syscall 4 (print string)
	la $a0, msg_acerto						# argument (string)
	syscall
	addi $s5, $s5, 1
	addi $s3, $s3, 1 						# aumentar o contador de tentativas
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	j printJogo

erro:
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $v0, PRINT_STR						# syscall 4 (print string)
	la $a0, msg_erro						# argument (string)
	syscall
	addi $s4, $s4, 1						# incrementa o contador de erros
	addi $s3, $s3, 1 						# incrementa o contador de tentativas
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	j printJogo
	 

jaFoi:
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $v0, PRINT_STR						# syscall 4 (print string)
	la $a0, msg_jaFoi						# argument (string)
	syscall
	addi $s3, $s3, 1						# incrementa o contador de tentativas
	addi $s4, $s4, 1						# incrementa o contador de erros
	
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	j printJogo
	 
maior: 
	li $v0, PRINT_STR						# mostra "\n"
    la $a0, linebreak
    syscall 
	 
	li $v0, PRINT_STR						# mostra a mensagem de valor maior que 9
    la $a0, msg_maior
    syscall

    li $v0, PRINT_STR						# mostra "\n"
    la $a0, linebreak
    syscall
											# decrementa o contador de tentativas
	j printJogo
	
menor0:
	li $v0, PRINT_STR						# mostra "\n"
    la $a0, linebreak
    syscall 
	 
	li $v0, PRINT_STR						# mostra a mensagem de valor menor que 0
    la $a0, msg_menor0
    syscall

    li $v0, PRINT_STR						# mostra "\n"
    la $a0, linebreak
    syscall
	addi $s7, $s7, -1						# decrementa o contador de tentativas
	j printJogo
	   
   	
parada:
	li $v0, PRINT_STR						# mostra "\n"
    la $a0, linebreak
    syscall 
	
	sw $s3, tentativas
	sw $s4, erros
	sw $s5, acertos
		
	mul $s5, $s5, 100     					# multiplica o número de acertos por 100
    div $s5, $s3          					# divide o resultado pelo número de tentativas

    mflo $t2     
	
	sw $t2, porcentagem
	
	li $v0, PRINT_STR						# syscall 4 (print string)
	la $a0, msg_fim							# argument (string)
	syscall
	
	li $v0, PRINT_STR						# mostra "\n"
    la $a0, linebreak
    syscall 
	 
	li $v0, PRINT_STR					
    la $a0, msg_tentativasfinal
    syscall 
	 
	li $v0, PRINT_INT
    lw $a0, tentativas
    syscall
	
	li $v0, PRINT_STR		
    la $a0, linebreak
    syscall 
	 
	li $v0, PRINT_STR		
    la $a0, msg_acertofinal
    syscall 
	 
	li $v0, PRINT_INT
    lw $a0, acertos
    syscall
	
	li $v0, PRINT_STR		
    la $a0, linebreak
    syscall 
	 
	li $v0, PRINT_STR		
    la $a0, msg_errosfinal
    syscall 
	 
	li $v0, PRINT_INT
    lw $a0, erros
    syscall
	
	li $v0, PRINT_STR		
    la $a0, linebreak
    syscall 
	 
	li $v0, PRINT_STR		
    la $a0, msg_porcentagem
    syscall 
	 
	li $v0, PRINT_INT
    lw $a0, porcentagem
    syscall
	
	li $v0, PRINT_STR		
    la $a0, porcentagemfinal
    syscall 
	
	jr $ra
	
printJogo:
	li $t0, 10
	li $t9, 0				
	
PRINT_JOGO0:
	lb $a0, jogo0($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO0						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0									# inicializa $t9 como 0 (base do endereço)

PRINT_JOGO1:
	lb $a0, jogo1($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO1						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0									# inicializa $t9 como 0 (base do endereço)
	
PRINT_JOGO2:
	lb $a0, jogo2($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO2						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0									# inicializa $t9 como 0 (base do endereço)
	
PRINT_JOGO3:
	lb $a0, jogo3($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO3						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0									# inicializa $t9 como 0 (base do endereço)

PRINT_JOGO4:
	lb $a0, jogo4($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO4						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0									# inicializa $t9 como 0 (base do endereço)
	
PRINT_JOGO5:
	lb $a0, jogo5($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO5						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0									# inicializa $t9 como 0 (base do endereço)
	
PRINT_JOGO6:
	lb $a0, jogo6($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO6						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0									# inicializa $t9 como 0 (base do endereço)
	
PRINT_JOGO7:
	lb $a0, jogo7($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO7						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0									# inicializa $t9 como 0 (base do endereço)
	
PRINT_JOGO8:
	lb $a0, jogo8($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO8						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	li $t0, 10
	li $t9, 0									# inicializa $t9 como 0 (base do endereço)
	
PRINT_JOGO9:
	lb $a0, jogo9($t9)							# carrega o dado do vetor
	li $v0, PRINT_CHAR							# mostra o valor lido
	syscall
	
	li $v0, PRINT_STR							# mostra " "
	la $a0, spc
	syscall
	
	addi $t0, $t0, -1							# decrementa o contador (i)
	addi $t9, $t9, 1
	bgtz $t0, PRINT_JOGO9						# verifica se i > 0 (continua o loop)
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
	j comecou
	
fim_jogo:
	jal parada
	li $v0, END_PROGRAM							# terminate program
	syscall