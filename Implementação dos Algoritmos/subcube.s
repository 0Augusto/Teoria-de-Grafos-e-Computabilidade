// subcube_arm64_corrigido.s
// Implementação de Grafo Subcúbico para ARM64 (Apple M1) - CORRIGIDO
// Arquitetura: AArch64

.section __DATA,__data
    // Constantes
    .set MAX_VERTICES, 100
    .set MAX_GRAU, 3
    
    // Mensagens
msg_grafo_subcubico:
    .asciz "Grafo eh subcubico\n"
msg_grafo_nao_subcubico:
    .asciz "Grafo nao eh subcubico\n"
msg_aresta_adicionada:
    .asciz "Aresta adicionada: vertice %d -> vertice %d\n"
msg_erro_grau_max:
    .asciz "Erro: Vertice %d atingiu grau maximo\n"
msg_hello:
    .asciz "Programa iniciado\n"

    // Estrutura do Grafo - Alinhada para 64 bits
    .align 3
vertices:
    .space MAX_VERTICES * 8     // Array de ponteiros (64 bits cada)
graus:
    .space MAX_VERTICES * 4     // Array de inteiros (32 bits cada)
num_vertices:
    .word 5                     // Número de vértices inicializado

.section __TEXT,__text
.globl _main
.p2align 2

//-------------------------------------------------------------
// Função: adicionar_aresta
// CORREÇÕES APLICADAS:
// 1. Corrigido uso incorreto de registradores
// 2. Corrigido salvamento de parâmetros antes de chamadas
// 3. Corrigido acesso a arrays
//-------------------------------------------------------------
_adicionar_aresta:
    stp x29, x30, [sp, #-32]!   // Aloca 32 bytes para alinhamento
    mov x29, sp
    stp x19, x20, [sp, #16]     // Salva registradores que serão usados
    
    // Salvar parâmetros originais
    mov w19, w0                 // w19 = vertice_origem
    mov w20, w1                 // w20 = vertice_destino
    
    // Verificar se vértices são válidos
    cmp w19, #MAX_VERTICES
    b.hs .erro_vertice_invalido
    
    cmp w20, #MAX_VERTICES
    b.hs .erro_vertice_invalido
    
    // Verificar grau máximo do vértice origem
    adrp x0, graus@PAGE
    add x0, x0, graus@PAGEOFF
    sxtw x1, w19                // Índice extendido para 64 bits
    ldr w2, [x0, x1, lsl #2]    // graus[origem]
    cmp w2, #MAX_GRAU
    b.hs .erro_grau_maximo
    
    // Verificar grau máximo do vértice destino
    sxtw x1, w20                // Índice extendido para 64 bits
    ldr w2, [x0, x1, lsl #2]    // graus[destino]
    cmp w2, #MAX_GRAU
    b.hs .erro_grau_maximo
    
    // Alocar novo nó para origem
    mov x0, #16                 // sizeof(Node)
    bl _malloc
    mov x21, x0                 // Salvar ponteiro do nó origem
    
    // Configurar nó da origem
    adrp x0, vertices@PAGE
    add x0, x0, vertices@PAGEOFF
    sxtw x1, w19
    ldr x2, [x0, x1, lsl #3]    // vertices[origem]
    
    str w20, [x21]              // node->vertice = destino
    str x2, [x21, #8]           // node->proximo = lista atual
    str x21, [x0, x1, lsl #3]   // vertices[origem] = novo nó
    
    // Incrementar grau do vértice origem
    adrp x0, graus@PAGE
    add x0, x0, graus@PAGEOFF
    sxtw x1, w19
    ldr w2, [x0, x1, lsl #2]
    add w2, w2, #1
    str w2, [x0, x1, lsl #2]
    
    // Alocar novo nó para destino
    mov x0, #16                 // sizeof(Node)
    bl _malloc
    mov x22, x0                 // Salvar ponteiro do nó destino
    
    // Configurar nó do destino
    adrp x0, vertices@PAGE
    add x0, x0, vertices@PAGEOFF
    sxtw x1, w20
    ldr x2, [x0, x1, lsl #3]    // vertices[destino]
    
    str w19, [x22]              // node->vertice = origem
    str x2, [x22, #8]           // node->proximo = lista atual
    str x22, [x0, x1, lsl #3]   // vertices[destino] = novo nó
    
    // Incrementar grau do vértice destino
    adrp x0, graus@PAGE
    add x0, x0, graus@PAGEOFF
    sxtw x1, w20
    ldr w2, [x0, x1, lsl #2]
    add w2, w2, #1
    str w2, [x0, x1, lsl #2]
    
    // Debug: imprimir mensagem de sucesso
    adrp x0, msg_aresta_adicionada@PAGE
    add x0, x0, msg_aresta_adicionada@PAGEOFF
    mov w1, w19
    mov w2, w20
    bl _printf
    
    b .fim_adicionar

.erro_grau_maximo:
    adrp x0, msg_erro_grau_max@PAGE
    add x0, x0, msg_erro_grau_max@PAGEOFF
    mov w1, w19
    bl _printf
    b .fim_adicionar

.erro_vertice_invalido:
    // Pode adicionar tratamento específico aqui
    b .fim_adicionar

.fim_adicionar:
    ldp x19, x20, [sp, #16]     // Restaura registradores
    ldp x29, x30, [sp], #32
    ret

//-------------------------------------------------------------
// Função: eh_subcubico (CORRIGIDA)
//-------------------------------------------------------------
_eh_subcubico:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    mov w19, #0                 // contador de vértices
    adrp x20, num_vertices@PAGE
    add x20, x20, num_vertices@PAGEOFF
    ldr w21, [x20]              // num_vertices
    
    adrp x22, graus@PAGE        // base do array graus
    add x22, x22, graus@PAGEOFF
    
.loop_vertices:
    cmp w19, w21
    b.ge .eh_subcubico_true
    
    ldr w23, [x22, w19, sxtw #2]  // graus[i]
    cmp w23, #MAX_GRAU
    b.gt .nao_eh_subcubico
    
    add w19, w19, #1
    b .loop_vertices

.eh_subcubico_true:
    adrp x0, msg_grafo_subcubico@PAGE
    add x0, x0, msg_grafo_subcubico@PAGEOFF
    bl _printf
    mov w0, #1
    b .fim_verifica

.nao_eh_subcubico:
    adrp x0, msg_grafo_nao_subcubico@PAGE
    add x0, x0, msg_grafo_nao_subcubico@PAGEOFF
    bl _printf
    mov w0, #0

.fim_verifica:
    ldp x29, x30, [sp], #16
    ret

//-------------------------------------------------------------
// Função: liberar_grafo (CORRIGIDA)
//-------------------------------------------------------------
_liberar_grafo:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    
    mov w19, #0                 // contador de vértices
    adrp x20, num_vertices@PAGE
    add x20, x20, num_vertices@PAGEOFF
    ldr w21, [x20]              // num_vertices
    
    adrp x22, vertices@PAGE     // base do array vertices
    add x22, x22, vertices@PAGEOFF
    
.loop_vertices_liberar:
    cmp w19, w21
    b.ge .fim_liberar
    
    ldr x23, [x22, w19, sxtw #3]  // vertices[i]
    
.loop_lista_liberar:
    cbz x23, .proximo_vertice
    
    ldr x24, [x23, #8]          // salva próximo nó
    mov x0, x23                 // nó atual para free
    bl _free
    
    mov x23, x24                // avança para próximo
    b .loop_lista_liberar

.proximo_vertice:
    add w19, w19, #1
    b .loop_vertices_liberar

.fim_liberar:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

//-------------------------------------------------------------
// Função principal CORRIGIDA
// Principais correções:
// 1. Alinhamento de stack correto
// 2. Uso apropriado de registradores
// 3. Chamadas de sistema macOS
//-------------------------------------------------------------
_main:
    stp x29, x30, [sp, #-16]!   // Alinha stack para 16 bytes
    mov x29, sp
    
    // Debug: mensagem de início
    adrp x0, msg_hello@PAGE
    add x0, x0, msg_hello@PAGEOFF
    bl _printf
    
    // Adicionar arestas (máximo 3 por vértice 0)
    mov w0, #0                   // origem
    mov w1, #1                   // destino
    bl _adicionar_aresta
    
    mov w0, #0
    mov w1, #2
    bl _adicionar_aresta
    
    mov w0, #0
    mov w1, #3
    bl _adicionar_aresta
    
    // Esta deve falhar (quarta aresta)
    mov w0, #0
    mov w1, #4
    bl _adicionar_aresta
    
    // Verificar se é subcúbico
    bl _eh_subcubico
    
    // Liberar memória
    bl _liberar_grafo
    
    // Sair corretamente no macOS
    mov x0, #0                   // status code 0
    ldp x29, x30, [sp], #16
    ret

//-------------------------------------------------------------
// Ponto de entrada alternativo para linker do macOS
//-------------------------------------------------------------
.globl _start
_start:
    bl _main
    mov x16, #1                  // SYS_exit
    svc #0x80
