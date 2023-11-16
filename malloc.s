.section .data

    INICIO_HEAP: .quad 0
    TOPO_HEAP: .quad 0      # o topo é o final do heap
    END_A: .quad 0          # guarda o endereço do primeiro bloco alocado
    END_B: .quad 0
    END_C: .quad 0

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

    jmp fusao

    fim_libera_memoria:
        movq 16(%rbp), %rax     # retorno o end doq foi liberado
        popq %rbp
        ret



firts_fit:
    push %rbp
    movq %rsp, %rbp
    movq 16(%rbp), %rbx     # num_bytes em rbx

    # comparar se a heap esta vazinha, se sim, aloca um novo espaço
    movq TOPO_HEAP, %r11
    cmpq INICIO_HEAP, %r11
    je alocaMem

    # se não, vereficar se existe o bloco com tamanho igual ou maior ao solicitado
        # e alocar nesse bloco

    movq INICIO_HEAP, %r8
    loop_first_fit:
        cmpq TOPO_HEAP, %r8         # condicõa de parada
        je else
	    cmpq $1, (%r8)		        # vejo se está livre
        je pula_bloco_FirstFit
        cmpq 8(%rbp), %rbx          # comparo o tamanho, pra ver se cabe
        jg pula_bloco_FirstFit
        movq $1, (%r8)              # digo que está ocupado
        addq $16, %r8               # pulo os bit de gerenciamento para devolver so o endereco bloco
        movq %r8, %rax              # guardo o endereço do bloco para retornar
        jmp fim_first_fit

        pula_bloco_FirstFit:          # se nao puloa para o proximo bloco
		    movq 8(%r8), %r9
		    addq $16, %r9
		    addq %r9, %r8
		    jmp loop_first_fit


    
    else:       # se nao exister um bloco maior ou igual, alocar no fim da heap!
        jmp alocaMem        #faço a locação padrão

    fim_first_fit:
        pop %rbp
        ret


alocaMem:
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

    
    jmp fim_first_fit

fusao:      # fazer fusao de nos livres, se a espaços consectuvos vazios, juntar os dois como um

	pushq %rbp
	movq %rsp, %rbp

	movq INICIO_HEAP, %r8	    # passo o comeco da heap
	loop_fusao:
        cmpq TOPO_HEAP, %r8     # condicõa de parada
        je fim_fusao
	    cmpq $0, (%r8)		    # comparo se o bit de dirty é zero
	je verifica_fusao

        # se nao puloa para o proximo bloco
		movq 8(%r8), %r9
		addq $16, %r9
		addq %r9, %r8
		jmp loop_fusao



	verifica_fusao:
		movq %r8, %r11		# pego o endereco de r8
		movq 8(%r11), %r9	# pego o tamanho do bloco atual para pular
		addq $16, %r9		# somo os 16 bytes de gerenciamento
		addq %r9, %r11		# teoricamente, r11 possui agora o inicio do proximo bloco
		movq 8(%r11), %r9	# o tamanho do proximo bloco e guardo em %r9 já
        	addq $16, %r9       # r9 = tamanho do bloco mais bits de gerenciamento
		cmpq $0, (%r11)		# comparo se o bit de dirty é zero tbm
		je fundir

		# se nao pulo o r8 para o proximo bloco
		movq 8(%r8), %r9
		addq $16, %r9
		addq %r9, %r8
		jmp loop_fusao


	fundir:
        	# ao fundir, ele continua no mesmo bloco que estava!
		addq %r9, 8(%r8)	# somo o tamanho do dois blocos
		jmp loop_fusao
	
    fim_fusao:
        pop %rbp 
        jmp fim_libera_memoria

_start:
    

    call iniciaAlocador 

    movq $50, %rbx           # empilha num_bytes
    pushq %rbx  
    call firts_fit
    addq $8, %rsp
    movq %rax, END_A       # guarda o endereco do primeiro bloco alocado

    movq $100, %rbx           # empilha num_bytes
    pushq %rbx  
    call firts_fit
    addq $8, %rsp
    movq %rax, END_B       # guarda o endereco do primeiro bloco alocado


    movq $75, %rbx           
    pushq %rbx  
    call firts_fit
    addq $8, %rsp
    movq %rax, END_C


    movq END_A, %rbx
    push %rbx
    call liberaMem   
    addq $8, %rsp
    movq %rax, END_A

    

    movq END_B, %rbx
    push %rbx
    call liberaMem
    addq $8, %rsp
    movq %rax, END_B

    

    call finalizaAlocador
    
    movq $60, %rax
    movq $0, %rdi
    syscall

