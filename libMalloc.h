#ifndef LIB_MALLOC
#define LIB_MALLOC


struct node{
    int dirt;
    int tam;
    void* conteudo;
    struct node* prox;
};

struct Lista{
    struct node* cabeca;
    struct node* cauda;
};


//executa syscall brk para obter o edereço do topo corente da heap.
void iniciaAlocador();

//executa syscall para restaurar o valor original da heap.
void finalizaAlocador();

//libera um bloco, indica que está livre
int liberaMem(void* bloco);

//aloca a memoria
void* alocaMem(int num_bytes);



#endif