.section .data
    INICIO_HEAP .quad 0
    TOPO_HEAP .quad 0
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




    