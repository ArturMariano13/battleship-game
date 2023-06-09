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
	
	welcome_msg:	.asciiz "Seja bem vindo ao Batalha Naval! Boa sorte!\n"
	seed_rqst: 		.asciiz "\nInforme a seed para organizacao do tabuleiro: "
	spc: 			.asciiz " "
	linebreak:		.asciiz "\n"

.text
	.globl main
main:
	PRINT_STR = 4
	PRINT_CHAR = 11
	PRINT_INT = 1
	READ_INT = 5
	END_PROGRAM = 10
	
	jal welcome				# chama função de dar boas-vindas ao usuário
	jal geraAleatorio		# chama função de gerar valores pseudo-aleatórios
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
	li $t4, 8  # Gera 5 valores aleatórios (altere conforme necessário)
    # Calcula o próximo valor aleatório
generateRandom:
	mul $t0, $t0, $t1  # t0 = t0 * a
    addu $t0, $t0, $t2  # t0 = t0 + c
    rem $t0, $t0, $t3  # t0 = t0 % m
    
	# Imprime o valor aleatório
    move $a0, $t0
    li $v0, PRINT_INT
    syscall
	
	li $v0, PRINT_STR
	la $a0, spc
	syscall
    
    # Pula para a próxima iteração ou termina o programa
    addiu $t4, $t4, -1
    bnez $t4, generateRandom
	
	# quebra de linha
	li $v0, PRINT_STR
	la $a0, linebreak
	syscall
	
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
	
END_PRINT:	
	jr $ra