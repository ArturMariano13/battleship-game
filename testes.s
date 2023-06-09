.data
    SHIP_LENGTHS: .word 2, 3, 3, 4, 5
    board: .space 100
    seed_prompt: .asciiz "Digite a semente para gerar a distribuição das embarcações: "
    coords_prompt: .asciiz "Digite as coordenadas (linha coluna): "
    hit_message: .asciiz "Acertou um navio!\n"
    water_message: .asciiz "Água...\n"
    invalid_coords_message: .asciiz "Coordenadas inválidas!\n"
    end_game_message: .asciiz "Relatório da partida:\n"
    attempts_message: .asciiz "Número de tentativas: "
    board_header: .asciiz "  0 1 2 3 4 5 6 7 8 9\n"
    new_line: .asciiz "\n"
    spc: .asciiz " "

.text
.globl main

main:
    BOARD_SIZE = 10
    NUM_SHIPS = 5
    PRINT_STR = 4
    PRINT_INT = 1
    PRINT_CHAR = 11
    READ_INT = 5
    EXIT = 10
    # $s0 => seed
    # $s1 => tentativas
    # $t0 => tabuleiro
    # $t1 => navios restantes

    # Configurar a localização do tabuleiro
    la $t0, board

    # Solicitar a seed ao usuário
    la $a0, seed_prompt
    li $v0, PRINT_STR
    syscall

    # Ler a seed
    li $v0, READ_INT        # read integer
    syscall            
    move $s0, $v0            # salvar o valor lido em $s0

    # Inicializar o gerador de números aleatórios com a seed
    move $a0, $s0
    li $v0, 42               # código para inicializar o gerador de números aleatórios
    syscall

    # Colocar os navios no tabuleiro
    la $t1, SHIP_LENGTHS
    lw $t2, NUM_SHIPS
    li $v0, PRINT_INT
place_ships_loop:
    lw $t3, 0($t1)
    li $t4, 0
place_ship_loop:
    move $a0, $t0            # salvar o tabuleiro em $a0
    move $a1, $t3            # salvar o tamanho do navio em $a1    
    move $a2, $t4 
    jal canPlaceShip
    beqz $v0, place_ship_invalid
    move $a0, $t0
    move $a1, $t3
    move $a2, $t4
    jal placeShip
    addi $t4, $t4, 1
    blt $t4, $t3, place_ship_loop
    addi $t1, $t1, 4
    addi $t2, $t2, -1
    bnez $t2, place_ships_loop

    # Exibir o tabuleiro inicial
    jal printBoard

    # Variáveis para o relatório da partida
    li $s1, 0                # tentativas

game_loop:
    # Solicitar coordenadas ao usuário
    la $a0, coords_prompt
    li $v0, PRINT_STR
    syscall

    # Ler coordenadas
    li $v0, READ_INT        # read integer (linha)
    syscall
    move $a0, $v0            # salvar a linha em $a0

    li $v0, READ_INT        # read integer (coluna)
    syscall
    move $a1, $v0            # salvar a coluna em $a1

    # Validar coordenadas
    jal validCoords
    beqz $v0, invalid_coords

    # Verificar se acertou um navio
    move $a0, $t0            # salvar o tabuleiro em $a0
    move $a1, $s1            # salvar o número de tentativas em $a1
    jal hitShip
    beqz $v0, hit

    # Exibir mensagem de água
    la $a0, water_message
    li $v0, PRINT_STR
    syscall

    b continue_game

hit:
    # Exibir mensagem de acerto
    la $a0, hit_message
    li $v0, PRINT_STR
    syscall

continue_game:
    # Incrementar o número de tentativas
    addi $s1, $s1, 1

    # Exibir tabuleiro
    jal printBoard

    # Verificar se todos os navios foram afundados
    move $a0, $t0            # salvar o tabuleiro em $a0
    jal allShipsSunk
    beqz $v0, game_loop

    # Exibir relatório da partida
    la $a0, end_game_message
    li $v0, PRINT_STR
    syscall

    # Exibir número de tentativas
    la $a0, attempts_message
    li $v0, PRINT_STR
    syscall
    move $a0, $s1            # salvar o número de tentativas em $a0
    li $v0, PRINT_INT
    syscall

    # Sair do jogo
    li $v0, EXIT
    syscall

place_ship_invalid:
    la $a0, invalid_coords_message
    li $v0, PRINT_STR
    syscall
    b place_ship_loop

invalid_coords:
    la $a0, invalid_coords_message
    li $v0, PRINT_STR
    syscall
    j game_loop

# Função para verificar se é possível posicionar um navio em determinada posição
# Argumentos:
# $a0 - ponteiro para o tabuleiro
# $a1 - tamanho do navio
# $a2 - orientação (0 - horizontal, 1 - vertical)
# Retorna:
# $v0 - 1 se é possível posicionar o navio, 0 caso contrário
canPlaceShip:
    move $v0, $zero
    move $t3, $zero

can_place_ship_loop:
    # Verificar se a posição atual está fora dos limites do tabuleiro
    bge $t3, $a1, can_place_ship_end
    add $t4, $a0, $t3
    lw $t5, BOARD_SIZE
    add $t5, $t5, $t3
    bge $t4, $t5, can_place_ship_end

    # Verificar se a posição atual já está ocupada por um navio
    lw $t6, 0($t4)
    bnez $t6, can_place_ship_end

    # Verificar se a posição abaixo (horizontal) ou à direita (vertical) está ocupada por um navio
    addi $t5, $t3, 1
    add $t5, $a0, $t5
    lw $t6, 0($t5)
    bnez $t6, can_place_ship_end

    addi $t3, $t3, 1
    j can_place_ship_loop

can_place_ship_end:
    # Verificar se todas as posições foram verificadas
    beq $t3, $a1, can_place_ship_valid

    # Se não, não é possível posicionar o navio
    j can_place_ship_invalid

can_place_ship_valid:
    # Se sim, é possível posicionar o navio
    li $v0, 1
    j can_place_ship_exit

can_place_ship_invalid:
    # Se não, não é possível posicionar o navio
    li $v0, 0

can_place_ship_exit:
    jr $ra

# Função para posicionar um navio no tabuleiro
# Argumentos:
# $a0 - ponteiro para o tabuleiro
# $a1 - tamanho do navio
# $a2 - orientação (0 - horizontal, 1 - vertical)
placeShip:
    move $t3, $zero

place_ship_loop:
    # Colocar o valor do navio na posição atual
    add $t4, $a0, $t3
    li $t5, 1
    sw $t5, 0($t4)

    # Incrementar a posição
    addi $t3, $t3, 1

    # Verificar se todas as posições do navio foram preenchidas
    beq $t3, $a1, place_ship_exit

    # Se não, continuar preenchendo as posições
    j place_ship_loop

place_ship_exit:
    jr $ra

# Função para verificar se uma posição contém um navio
# Argumentos:
# $a0 - ponteiro para o tabuleiro
# $a1 - número de tentativas
# Retorna:
# $v0 - 1 se acertou um navio, 0 caso contrário
hitShip:
    move $v0, $zero

    # Verificar se a posição contém um navio
    lw $t2, 0($a0)
    bnez $t2, hit_ship_hit

    # Se não, verificar se o número de tentativas excedeu o máximo permitido
    li $t3, 17
    blt $a1, $t3, hit_ship_exit

    # Se sim, encerrar o jogo
    li $v0, 1
    j hit_ship_exit

hit_ship_hit:
    # Se sim, acertou um navio
    li $v0, 1

    # Marcar a posição como acertada
    li $t2, -1
    sw $t2, 0($a0)

hit_ship_exit:
    jr $ra

# Função para verificar se todos os navios foram afundados
# Argumento:
# $a0 - ponteiro para o tabuleiro
# Retorna:
# $v0 - 1 se todos os navios foram afundados, 0 caso contrário
allShipsSunk:
    move $v0, $zero
    move $t1, $zero

all_ships_sunk_loop:
    # Verificar se a posição atual contém um navio
    lw $t2, 0($a0)
    bnez $t2, all_ships_sunk_not_sunk

    addi $a0, $a0, 4
    addi $t1, $t1, 1
    j all_ships_sunk_loop

all_ships_sunk_not_sunk:
    # Se sim, nem todos os navios foram afundados
    bnez $t1, all_ships_sunk_exit

    # Se não, todos os navios foram afundados
    li $v0, 1

all_ships_sunk_exit:
    jr $ra

# Função para validar as coordenadas digitadas pelo usuário
# Argumento:
# $a0 - linha
# $a1 - coluna
# Retorna:
# $v0 - 1 se as coordenadas são válidas, 0 caso contrário
validCoords:
    # Verificar se as coordenadas estão dentro dos limites do tabuleiro
    li $t2, 10
    bge $a0, $t2, valid_coords_invalid
    bge $a1, $t2, valid_coords_invalid

    # Se sim, as coordenadas são válidas
    li $v0, 1
    j valid_coords_exit

valid_coords_invalid:
    # Se não, as coordenadas são inválidas
    li $v0, 0

valid_coords_exit:
    jr $ra

# Função para exibir o tabuleiro
# Argumento:
# $a0 - ponteiro para o tabuleiro
printBoard:
    # Exibir cabeçalho do tabuleiro
    la $a0, board_header
    li $v0, PRINT_STR
    syscall

    # Exibir linhas do tabuleiro
    li $t1, 10
    li $t2, 0
print_board_loop:
    li $v0, PRINT_INT
    move $a0, $t2            # imprimir o número da linha
    syscall

    li $v0, PRINT_CHAR
    la $a0, spc              # imprimir espaço
    syscall

    move $t3, $zero
print_board_line_loop:
    add $t4, $a0, $t3
    lw $t5, 0($t4)
    beqz $t5, print_board_line_water

    li $v0, PRINT_CHAR
    la $a0, "X"              # imprimir "X" para navio acertado
    syscall

    b print_board_line_continue

print_board_line_water:
    li $v0, PRINT_CHAR
    la $a0, "."              # imprimir "." para água
    syscall

print_board_line_continue:
    addi $t3, $t3, 1
    blt $t3, 10, print_board_line_loop

    li $v0, PRINT_CHAR
    la $a0, new_line         # imprimir nova linha
    syscall

    addi $t2, $t2, 1
    blt $t2, 10, print_board_loop

    jr $ra

# Função para exibir o tabuleiro
# Argumento:
# $a0 - ponteiro para o tabuleiro
printBoard:
    # Exibir cabeçalho do tabuleiro
    la $a0, board_header
    li $v0, PRINT_STR
    syscall

    # Exibir linhas do tabuleiro
    li $t1, 10
    li $t2, 0
print_board_loop:
    li $v0, PRINT_INT
    move $a0, $t2            # imprimir o número da linha
    syscall

    li $v0, PRINT_CHAR
    la $a0, spc              # imprimir espaço
    syscall

    move $t3, $zero
print_board_line_loop:
    add $t4, $a0, $t3
    lw $t5, 0($t4)
    beqz $t5, print_board_line_water

    li $v0, PRINT_CHAR
    la $a0, "X"              # imprimir "X" para navio acertado
    syscall

    b print_board_line_continue

print_board_line_water:
    li $v0, PRINT_CHAR
    la $a0, "."              # imprimir "." para água
    syscall

    b print_board_line_continue

print_board_line_continue:
    addi $t3, $t3, 1
    blt $t3, 10, print_board_line_loop

    li $v0, PRINT_CHAR
    la $a0, new_line         # imprimir nova linha
    syscall

    addi $t2, $t2, 1
    blt $t2, 10, print_board_loop

    jr $ra

# Função para verificar se é possível posicionar um navio em determinada posição
# Argumentos:
# $a0 - ponteiro para o tabuleiro
# $a1 - tamanho do navio
# $a2 - orientação (0 - horizontal, 1 - vertical)
# Retorna:
# $v0 - 1 se é possível posicionar o navio, 0 caso contrário
canPlaceShip:
    move $v0, $zero
    move $t3, $zero

can_place_ship_loop:
    # Verificar se a posição atual está fora dos limites do tabuleiro
    bge $t3, $a1, can_place_ship_end
    add $t4, $a0, $t3
    lw $t5, 0($t4)
    bnez $t5, can_place_ship_invalid

    # Verificar se a posição abaixo (horizontal) ou à direita (vertical) está ocupada por um navio
    addi $t5, $t3, 1
    add $t5, $a0, $t5
    lw $t6, 0($t5)
    bnez $t6, can_place_ship_invalid

    addi $t3, $t3, 1
    j can_place_ship_loop

can_place_ship_end:
    # Verificar se todas as posições foram verificadas
    beq $t3, $a1, can_place_ship_valid

    # Se não, não é possível posicionar o navio
    j can_place_ship_invalid

can_place_ship_valid:
    # Se sim, é possível posicionar o navio
    li $v0, 1
    j can_place_ship_exit

can_place_ship_invalid:
    # Se não, não é possível posicionar o navio
    li $v0, 0

can_place_ship_exit:
    jr $ra

# Função para posicionar um navio no tabuleiro
# Argumentos:
# $a0 - ponteiro para o tabuleiro
# $a1 - tamanho do navio
# $a2 - orientação (0 - horizontal, 1 - vertical)
placeShip:
    move $t3, $zero

place_ship_loop:
    # Colocar o valor do navio na posição atual
    add $t4, $a0, $t3
    li $t5, 1
    sw $t5, 0($t4)

    # Incrementar a posição
    addi $t3, $t3, 1

    # Verificar se todas as posições do navio foram preenchidas
    beq $t3, $a1, place_ship_exit

    # Se não, continuar preenchendo as posições
    j place_ship_loop

place_ship_exit:
    jr $ra

# Função para verificar se uma posição contém um navio
# Argumentos:
# $a0 - ponteiro para o tabuleiro
# $a1 - número de tentativas
# Retorna:
# $v0 - 1 se acertou um navio, 0 caso contrário
hitShip:
    move $v0, $zero

    # Verificar se a posição contém um navio
    lw $t2, 0($a0)
    bnez $t2, hit_ship_hit

    # Se não, verificar se o número de tentativas excedeu o máximo permitido
    li $t3, 17
    blt $a1, $t3, hit_ship_exit

    # Se sim, encerrar o jogo
    li $v0, 1
    j hit_ship_exit

hit_ship_hit:
    # Se sim, acertou um navio
    li $v0, 1

    # Marcar a posição como acertada
    li $t2, -1
    sw $t2, 0($a0)

hit_ship_exit:
    jr $ra

# Função para verificar se todos os navios foram afundados
# Argumento:
# $a0 - ponteiro para o tabuleiro
# Retorna:
# $v0 - 1 se todos os navios foram afundados, 0 caso contrário
allShipsSunk:
    move $v0, $zero
    move $t1, $zero

all_ships_sunk_loop:
    # Verificar se a posição atual contém um navio
    lw $t2, 0($a0)
    bnez $t2, all_ships_sunk_not_sunk

    addi $a0, $a0, 4
    addi $t1, $t1, 1
    j all_ships_sunk_loop

all_ships_sunk_not_sunk:
    # Se sim, nem todos os navios foram afundados
    bnez $t1, all_ships_sunk_exit

    # Se não, todos os navios foram afundados
    li $v0, 1

all_ships_sunk_exit:
    jr $ra

# Função para validar as coordenadas digitadas pelo usuário
# Argumento:
# $a0 - linha
# $a1 - coluna
# Retorna:
# $v0 - 1 se as coordenadas são válidas, 0 caso contrário
validCoords:
    # Verificar se as coordenadas estão dentro dos limites do tabuleiro
    li $t2, 10
    bge $a0, $t2, valid_coords_invalid
    bge $a1, $t2, valid_coords_invalid

    # Se sim, as coordenadas são válidas
    li $v0, 1
    j valid_coords_exit

valid_coords_invalid:
    # Se não, as coordenadas são inválidas
    li $v0, 0

valid_coords_exit:
    jr $ra

# Função principal do jogo
main:
    # Inicializar o tabuleiro com água
    la $a0, board
    li $t1, 100
    li $t2, 0
init_board_loop:
    sw $t2, 0($a0)
    addi $a0, $a0, 4
    addi $t2, $t2, 1
    blt $t2, $t1, init_board_loop

    # Perguntar ao jogador a semente para gerar a distribuição das embarcações
    li $v0, PRINT_STR
    la $a0, seed_prompt
    syscall

    # Ler a semente
    li $v0, READ_INT
    syscall
    move $s0, $v0

    # Inicializar o gerador de números aleatórios
    li $v0, RANDOMIZE
    move $a0, $s0
    syscall

    # Posicionar as embarcações no tabuleiro
    la $a0, SHIP_LENGTHS
    li $t1, 5
    li $t2, 0
place_ships_loop:
    lw $a1, 0($a0)
    li $v0, RANDOM
    syscall
    move $a2, $v0
    andi $a2, $a2, 1

    la $a0, board
    jal canPlaceShip
    beqz $v0, place_ships_invalid

    la $a0, board
    jal placeShip

    addi $a0, $a0, 100
    addi $a0, $a0, $t2
    jal canPlaceShip
    beqz $v0, place_ships_invalid

    addi $a0, $a0, -100
    addi $a0, $a0, 10
    jal placeShip

    addi $t1, $t1, -1
    addi $a0, $a0, 40
    addi $a0, $a0, 4
    j place_ships_loop

place_ships_invalid:
    # Se a posição não for válida, reiniciar o processo
    j main

game_loop:
    # Exibir o tabuleiro
    la $a0, board
    jal printBoard

    # Perguntar ao jogador as coordenadas
    li $v0, PRINT_STR
    la $a0, coords_prompt
    syscall

    # Ler as coordenadas
    li $v0, READ_INT
    syscall
    move $s1, $v0

    # Extrair a linha e a coluna das coordenadas
    move $t0, $s1
    andi $s1, $s1, 15
    srl $t0, $t0, 4

    # Validar as coordenadas
    move $a0, $t0
    move $a1, $s1
    jal validCoords
    beqz $v0, game_loop

    # Calcular o índice da posição no tabuleiro
    move $t1, $t0
    mul $t1, $t1, 10
    add $t1, $t1, $s1
    la $a0, board
    add $a0, $a0, $t1

    # Verificar se acertou um navio
    move $a1, $t1
    jal hitShip
    beqz $v0, game_loop

    # Verificar se todos os navios foram afundados
    la $a0, board
    jal allShipsSunk
    bnez $v0, game_over

    j game_loop

game_over:
    # Exibir mensagem de vitória
    li $v0, PRINT_STR
    la $a0, win_message
    syscall

    # Encerrar o programa
    li $v0, EXIT
    li $a0, 0
    syscall


