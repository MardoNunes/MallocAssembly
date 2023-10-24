#include <stdlib.h>
#include <stdio.h>
#include "libMalloc.h"

//executa syscall brk para obter o edereço do topo corente da heap.
void iniciaAlocador(){
    //guarda o endereço do topo da heap em uma var global
    heap = brk(0);
}

//executa syscall para restaurar o valor original da heap.
void finalizaAlocador(){
    //restaura o valor original da heap
    brk(heap);
}


//aloca a memoria
void* alocaMem(int num_bytes){
    
}
