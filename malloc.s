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
    movq INICIO_HEAP, %rdi
    syscall

    popq %rbp
    ret
    