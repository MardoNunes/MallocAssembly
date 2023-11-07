.section .data

    INICIO_HEAP: .quad 0
    TOPO_HEAP: .quad 0      # o topo é o final do heap
    END_A: .quad 0          # guarda o endereço do primeiro bloco alocado
    END_B: .quad 0
    TESTE: .quad 0
    str1: .string "Tamanho da heap: % s \n"

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

    movq $12, %rax
    movq $0, %rdi
    syscall

    movq %rax, TOPO_HEAP    # reseta a heap

    popq %rbp
    ret

liberaMem:
    push %rbp
    movq %rsp, %rbp
    movq 16(%rbp), %r10     # guardo o endereço passado como parametro

    # não vai liberar todo o bloco, vai apenas indicar que posso usa-lo para outro fim
    movq $0, -16(%r10)      # indico que o bloco está livre apenas
    movq -16(%r10), %rbx

    popq %rbp
    ret



alocaMem:
    push %rbp
    movq %rsp, %rbp
    movq 16(%rbp), %rbx     # jogo o num_bytes passado como parametr em rbx

    movq $12, %rax
    addq TOPO_HEAP, %rbx    # somo o topo do heap com o num_bytes + 16
    addq $16, %rbx          # somo os 16 de gerenciamente em rbx (rbx = num_bytes + 16)
    movq %rbx, %rdi
    syscall                 # realizo a alocação

    movq TOPO_HEAP, %r10
    movq $1, (%r10)         # coloco 1 nos 8 primeiro bytes para indicar q está ocupado (dirty)
    movq 16(%rbp), %r9      # guardo valor de num_bytes em r9
    movq %r9, 8(%r10)       # guardo o tamanho do bloco nos 8 bytes seguintes do dirty

    # atualizo o topo
    addq $16, %r10
    movq %r10, %rax
    movq %rbx, TOPO_HEAP

    popq %rbp
    ret



_start:
    movq $1, TESTE

    call iniciaAlocador 

    movq $50, %rbx           # empilha num_bytes
    pushq %rbx  
    call alocaMem
    addq $8, %rsp
    movq %rax, END_A       # guarda o endereco do primeiro bloco alocado

    movq $50, %rbx           # empilha num_bytes
    pushq %rbx  
    call alocaMem
    addq $8, %rsp
    movq %rax, END_B       # guarda o endereco do primeiro bloco alocado


    movq END_B, %rbx
    push %rbx
    call liberaMem
    addq $8, %rsp
    movq %rax, END_B


    call finalizaAlocador
    
    movq $60, %rax
    movq $0, %rdi
    syscall

