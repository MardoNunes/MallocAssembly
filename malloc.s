.section .data

    INICIO_HEAP: .quad 0
    TOPO_HEAP: .quad 0      # o topo é o final do heap

.section .text
.globl _start

iniciaAlocador:
    push %rbp
    movq %rsp, %rbp

    # Inicializa o heap
    movq $12, %rax
    movq $0, %rdi
    syscall

    movq %rax, INICIO_HEAP  # Salva o endereço inicial do heap
    movq %rax, TOPO_HEAP    # Salva o endereço do topo do heap(final)

    pop %rbp
    ret

finalizaAlocador:
    push %rbp
    movq %rsp, %rbp

    movq $12, %rax
    movq INICIO_HEAP, %rdi  # restauro a heap
    syscall

    popq %rbp
    ret

liberaMem:
    push %rbp
    movq %rsp, %rbp
    movq 16(%rbp), %r10 # movo o parametro para %r10, o parametro passado é o comeco do bloco

    movq $0, -16(%r10)  #-16 é onde esta os bit de dirt, coloco zero para dizer q o bloco esta livre
    movq -16(%r10), %rbx # movo o dirt para %rbx

    popq %rbp
    ret


first_fit:
    push %rbp
    movq %rsp, %rbp
    movq 16(%rbp), %rbx # num_bytes, parâmetro passado
    movq INICIO_HEAP, %r10 # inicio do heap

    jmp procura_bloco_livre
    cmpq $0, %rax   # se o retorno for 0, então não tem espaço
    jne fim

    aloca_novo_bloco:
        movq 16(%rbp), %rbx     # num_bytes, parâmetro passado
        movq $12, %rax
        addq TOPO_HEAP, %rbx    # somo o topo com o num_bytes
        addq $16, %rbx      # %rbx = num_bytes + 16
        movq %rbx, %rdi     
        syscall

        # atualiza o topo
        movq TOPO_HEAP, %r10
        movq $1, (%r10)     # dirt = 1, indica que o bloco esta ocupado
        movq 16(%r10), %r9   # pega o tamanho do blo movq %r9, 8(%r10)   # guarda o tamanho do bloco nos 8 bytes seguintes
        addq $16, %r10      # pula os 16 bytes de dirt e tamanho
        movq %r10, %rax     # retorno é o endereço do bloco alocado
        movq %rbx, TOPO_HEAP    # atualiza o topo

        fim:
            popq %rbp
            ret

    procura_bloco_livre:
        movq 16(%rbp), %rbx # num_bytes, parâmetro passado
        movq INICIO_HEAP, %r10 # inicio do heap

        # loop de busca
        busca:
            cmpq TOPO_HEAP, %r10 # se o topo for igual ao inicio do heap, então não tem mais espaço ou não tem nada alocado
            je nao_tem_espaco

            cmpq $0, (%rbx)     # se dirt = 0, então o bloco esta livre (esse é o primeiro bloco do heap)
            je bloco_livre

            contiua_buscando:
                movq 8(%rbx), %r9   # pega o tamanho do bloco
                addq %r9, %rbx      # pula o bloco
                addq $16, %rbx      # pula os 16 bytes de dirt e tamanho
                jmp busca

        bloco_livre:
            movq 8(%rbx), %r9   # pega o tamanho do bloco
            cmpq %r9, %rbx      # se o tamanho do bloco for menor que o num_bytes, então não tem espaço
            jl contiua_buscando

            movq $1, (%rbx)     # ocupa bloco
            addq $16, %rbx      # pula os 16 bytes de dirt e tamanho
            movq %rbx, %rax     # retorno é o endereço do bloco alocado
            jmp fim

        nao_tem_espaco:
            movq $0, %rax
            popq %rbp
            jmp aloca_novo_bloco


    
_start:

call iniciaAlocador 

# fazer alocações e liberações da memoriaaqui
# uso push para empilhar o num_bytes
# ai usar a logica de manipulção de deslocamento usando regs





call finalocador

movq $60, %rax
movq $0, %rdi
syscall
