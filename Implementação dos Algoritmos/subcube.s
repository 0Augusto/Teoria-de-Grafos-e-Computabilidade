section .data
    ; Constantes
    MAX_VERTICES equ 100
    MAX_GRAU equ 3
    
    ; Mensagens
    msg_grafo_subcubico db "Grafo eh subcubico", 0xA, 0
    msg_grafo_nao_subcubico db "Grafo nao eh subcubico", 0xA, 0
    msg_aresta_adicionada db "Aresta adicionada: vertice %d -> vertice %d", 0xA, 0
    msg_erro_grau_max db "Erro: Vertice %d atingiu grau maximo", 0xA, 0
    
    ; Estrutura do Grafo
    vertices times MAX_VERTICES * 4 dd 0  ; Array de ponteiros para listas de adjacência
    graus times MAX_VERTICES dd 0         ; Grau de cada vértice
    num_vertices dd 0

section .bss
    ; Buffer para manipulação de strings
    buffer resb 64

section .text
    global _start
    extern printf, malloc, free

;-------------------------------------------------------------
; Estrutura de um nó da lista de adjacência
; struct Node {
;     int vertice;
;     struct Node* proximo;
; }
;-------------------------------------------------------------

;-------------------------------------------------------------
; Função: adicionar_aresta
; Complexidade: O(1) - tempo constante
; Descrição: Adiciona uma aresta entre dois vértices
;-------------------------------------------------------------
adicionar_aresta:
    push ebp
    mov ebp, esp
    ; [ebp+8] = vertice_origem, [ebp+12] = vertice_destino
    
    ; Verificar se vertices são válidos
    mov eax, [ebp+8]
    cmp eax, MAX_VERTICES
    jge .erro_vertice_invalido
    
    mov ebx, [ebp+12]
    cmp ebx, MAX_VERTICES
    jge .erro_vertice_invalido
    
    ; Verificar grau máximo (CONDIÇÃO SUBCÚBICA)
    ; Complexidade: O(1) - acesso direto a array
    mov ecx, [graus + eax*4]    ; O(1) - acesso indexado
    cmp ecx, MAX_GRAU           ; O(1) - comparação
    jge .erro_grau_maximo       ; O(1) - salto condicional
    
    mov edx, [graus + ebx*4]    ; O(1)
    cmp edx, MAX_GRAU           ; O(1)
    jge .erro_grau_maximo       ; O(1)
    
    ; Alocar novo nó para origem
    push 8                      ; O(1) - sizeof(Node)
    call malloc                 ; O(1) - alocação de memória
    add esp, 4
    
    mov ecx, [ebp+8]
    mov [eax], ecx              ; node->vertice = origem
    mov edx, [vertices + ecx*4]
    mov [eax+4], edx            ; node->proximo = lista atual
    mov [vertices + ecx*4], eax ; atualiza cabeça da lista
    
    ; Incrementar grau do vértice origem
    mov eax, [graus + ecx*4]
    inc eax
    mov [graus + ecx*4], eax
    
    ; Alocar novo nó para destino (grafo não direcionado)
    push 8
    call malloc
    add esp, 4
    
    mov ecx, [ebp+12]
    mov [eax], ecx              ; node->vertice = destino
    mov edx, [vertices + ecx*4]
    mov [eax+4], edx            ; node->proximo = lista atual
    mov [vertices + ecx*4], eax ; atualiza cabeça da lista
    
    ; Incrementar grau do vértice destino
    mov eax, [graus + ecx*4]
    inc eax
    mov [graus + ecx*4], eax
    
    jmp .fim
    
.erro_grau_maximo:
    ; Implementar tratamento de erro
    push dword [ebp+8]
    push msg_erro_grau_max
    call printf
    add esp, 8
    jmp .fim
    
.erro_vertice_invalido:
    ; Tratamento de erro para vértice inválido
    jmp .fim
    
.fim:
    pop ebp
    ret

;-------------------------------------------------------------
; Função: eh_subcubico
; Complexidade: O(V) - linear no número de vértices
; Descrição: Verifica se o grafo é subcúbico
;-------------------------------------------------------------
eh_subcubico:
    push ebp
    mov ebp, esp
    
    mov ecx, 0                  ; contador de vértices
    mov esi, [num_vertices]     ; O(1) - acesso a variável global
    
.loop_vertices:
    cmp ecx, esi                ; O(1) - comparação
    jge .eh_subcubico           ; O(1) - se todos vértices verificados
    
    ; Verificar grau de cada vértice
    ; Complexidade: O(1) por vértice, total O(V)
    mov eax, [graus + ecx*4]    ; O(1) - acesso indexado
    cmp eax, MAX_GRAU           ; O(1) - comparação
    jg .nao_eh_subcubico        ; O(1) - salto condicional
    
    inc ecx                     ; O(1)
    jmp .loop_vertices          ; O(V) - loop executa V vezes

.eh_subcubico:
    push msg_grafo_subcubico
    call printf
    add esp, 4
    mov eax, 1                  ; retorna true
    jmp .fim

.nao_eh_subcubico:
    push msg_grafo_nao_subcubico
    call printf
    add esp, 4
    mov eax, 0                  ; retorna false

.fim:
    pop ebp
    ret

;-------------------------------------------------------------
; Função: liberar_grafo
; Complexidade: O(V + E) - vértices + arestas
; Descrição: Libera toda a memória alocada
;-------------------------------------------------------------
liberar_grafo:
    push ebp
    mov ebp, esp
    
    mov ecx, 0                  ; contador de vértices
    mov esi, [num_vertices]     ; O(1)
    
.loop_vertices:
    cmp ecx, esi                ; O(1)
    jge .fim                    ; O(1)
    
    mov edi, [vertices + ecx*4] ; O(1) - cabeça da lista
    
.loop_lista:
    test edi, edi               ; O(1) - verifica se é NULL
    jz .proximo_vertice         ; O(1)
    
    ; Liberar nó atual
    mov ebx, [edi+4]            ; O(1) - salva próximo
    push edi                    ; O(1)
    call free                   ; O(1) - libera memória
    add esp, 4
    
    mov edi, ebx                ; O(1) - avança para próximo
    jmp .loop_lista             ; O(E) - loop por todas arestas

.proximo_vertice:
    inc ecx                     ; O(1)
    jmp .loop_vertices          ; O(V) - loop por todos vértices

.fim:
    pop ebp
    ret

;-------------------------------------------------------------
; Função: imprimir_grafo
; Complexidade: O(V + E) - vértices + arestas
; Descrição: Imprime a estrutura do grafo
;-------------------------------------------------------------
imprimir_grafo:
    push ebp
    mov ebp, esp
    
    mov ecx, 0                  ; contador de vértices
    mov esi, [num_vertices]     ; O(1)
    
.vertice_loop:
    cmp ecx, esi                ; O(1)
    jge .fim                    ; O(1)
    
    ; Imprimir vértice e seu grau
    mov eax, [graus + ecx*4]    ; O(1)
    ; Aqui iria código para imprimir
    
    mov edi, [vertices + ecx*4] ; O(1) - cabeça da lista
    
.aresta_loop:
    test edi, edi               ; O(1)
    jz .proximo_vertice         ; O(1)
    
    mov eax, [edi]              ; O(1) - vértice adjacente
    ; Aqui iria código para imprimir aresta
    
    mov edi, [edi+4]            ; O(1) - próximo nó
    jmp .aresta_loop            ; O(E) - loop por arestas

.proximo_vertice:
    inc ecx                     ; O(1)
    jmp .vertice_loop           ; O(V) - loop por vértices

.fim:
    pop ebp
    ret

;-------------------------------------------------------------
; Exemplo de uso
;-------------------------------------------------------------
_start:
    ; Inicializar grafo com 5 vértices
    mov dword [num_vertices], 5
    
    ; Adicionar arestas (exemplo)
    push 1                      ; destino
    push 0                      ; origem
    call adicionar_aresta       ; O(1)
    add esp, 8
    
    push 2
    push 0
    call adicionar_aresta       ; O(1)
    add esp, 8
    
    push 3
    push 0
    call adicionar_aresta       ; O(1)
    add esp, 8
    
    ; Tentar adicionar quarta aresta - deve falhar
    push 4
    push 0
    call adicionar_aresta       ; O(1)
    add esp, 8
    
    ; Verificar se é subcúbico
    call eh_subcubico           ; O(V)
    
    ; Liberar memória
    call liberar_grafo          ; O(V + E)
    
    ; Sair
    mov eax, 1
    xor ebx, ebx
    int 0x80