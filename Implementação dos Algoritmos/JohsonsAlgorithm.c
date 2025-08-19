#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

#define MAX_V 100
#define INF INT_MAX

// Estrutura para representar uma aresta
typedef struct Aresta {
    int dest;           // Vértice destino
    int peso;           // Peso da aresta
    struct Aresta* prox; // Próxima aresta
} Aresta;

// Estrutura para representar um vértice
typedef struct {
    Aresta* cabeca;     // Lista de arestas
} Vertice;

// Estrutura para representar um grafo
typedef struct {
    int V;              // Número de vértices
    Vertice* array;     // Array de vértices
} Grafo;

// Criar grafo: O(V)
Grafo* criarGrafo(int V) {
    Grafo* grafo = (Grafo*)malloc(sizeof(Grafo));
    grafo->V = V;
    grafo->array = (Vertice*)malloc(V * sizeof(Vertice));
    for (int i = 0; i < V; i++)
        grafo->array[i].cabeca = NULL;
    return grafo;
}

// Adicionar aresta: O(1)
void adicionarAresta(Grafo* grafo, int src, int dest, int peso) {
    Aresta* novaAresta = (Aresta*)malloc(sizeof(Aresta));
    novaAresta->dest = dest;
    novaAresta->peso = peso;
    novaAresta->prox = grafo->array[src].cabeca;
    grafo->array[src].cabeca = novaAresta;
}

// Bellman-Ford: O(V*E)
int bellmanFord(Grafo* grafo, int src, int h[]) {
    int V = grafo->V;
    // Inicialização: O(V)
    for (int i = 0; i < V; i++)
        h[i] = INF;
    h[src] = 0;

    // Relaxamento: O(V*E)
    for (int count = 0; count < V - 1; count++) {
        for (int u = 0; u < V; u++) {
            Aresta* aresta = grafo->array[u].cabeca;
            while (aresta) {
                int v = aresta->dest;
                if (h[u] != INF && h[u] + aresta->peso < h[v])
                    h[v] = h[u] + aresta->peso;
                aresta = aresta->prox;
            }
        }
    }

    // Verificação de ciclos negativos: O(E)
    for (int u = 0; u < V; u++) {
        Aresta* aresta = grafo->array[u].cabeca;
        while (aresta) {
            int v = aresta->dest;
            if (h[u] != INF && h[u] + aresta->peso < h[v])
                return 0; // Ciclo negativo detectado
            aresta = aresta->prox;
        }
    }
    return 1;
}

// Dijkstra com array: O(V²)
void dijkstra(Grafo* grafo, int src, int dist[], int h[]) {
    int V = grafo->V;
    int visitado[MAX_V] = {0};

    // Inicialização: O(V)
    for (int i = 0; i < V; i++)
        dist[i] = INF;
    dist[src] = 0;

    // Processamento: O(V²)
    for (int count = 0; count < V - 1; count++) {
        int u = -1;
        // Encontrar vértice não visitado com menor distância: O(V)
        for (int i = 0; i < V; i++)
            if (!visitado[i] && (u == -1 || dist[i] < dist[u]))
                u = i;

        if (dist[u] == INF) break;
        visitado[u] = 1;

        // Relaxamento das arestas: O(V) no total
        Aresta* aresta = grafo->array[u].cabeca;
        while (aresta) {
            int v = aresta->dest;
            int peso = aresta->peso + h[u] - h[v]; // Peso ajustado
            if (!visitado[v] && dist[u] != INF && dist[u] + peso < dist[v])
                dist[v] = dist[u] + peso;
            aresta = aresta->prox;
        }
    }
}

// Algoritmo de Johnson: O(V² log V + V E)
void johnson(Grafo* grafo) {
    int V = grafo->V;
    int h[MAX_V];
    
    // Criar grafo temporário com vértice adicional: O(V+E)
    Grafo* grafoTemp = criarGrafo(V + 1);
    for (int u = 0; u < V; u++) {
        adicionarAresta(grafoTemp, V, u, 0);
        Aresta* aresta = grafo->array[u].cabeca;
        while (aresta) {
            adicionarAresta(grafoTemp, u, aresta->dest, aresta->peso);
            aresta = aresta->prox;
        }
    }

    // Executar Bellman-Ford: O(V*E)
    if (!bellmanFord(grafoTemp, V, h)) {
        printf("Grafo contém ciclo negativo!\n");
        free(grafoTemp);
        return;
    }

    // Reponderação das arestas: O(E)
    for (int u = 0; u < V; u++) {
        Aresta* aresta = grafo->array[u].cabeca;
        while (aresta) {
            aresta->peso += h[u] - h[aresta->dest];
            aresta = aresta->prox;
        }
    }

    // Executar Dijkstra para cada vértice: O(V * V²) = O(V³)
    printf("Matriz de distâncias:\n");
    for (int u = 0; u < V; u++) {
        int dist[MAX_V];
        dijkstra(grafo, u, dist, h);
        for (int v = 0; v < V; v++) {
            if (dist[v] == INF)
                printf("INF ");
            else
                printf("%d ", dist[v] - h[u] + h[v]); // Ajuste reverso
        }
        printf("\n");
    }
    free(grafoTemp);
}

int main() {
    int V = 4;
    Grafo* grafo = criarGrafo(V);
    adicionarAresta(grafo, 0, 1, -5);
    adicionarAresta(grafo, 0, 2, 2);
    adicionarAresta(grafo, 1, 3, 3);
    adicionarAresta(grafo, 2, 3, 1);

    johnson(grafo);
    return 0;
}

/*A complexidade do Algoritmo de Johnson é O(V² log V + V E

Algoritmo Híbrido de Bellman-Ford e Dijkstra (Johnson)
Sim, existe um algoritmo híbrido que combina características do Bellman-Ford e do Dijkstra: o Algoritmo de Johnson. Este algoritmo é usado para encontrar os caminhos mais curtos entre todos os pares de vértices em um grafo dirigido com arestas de peso negativo (mas sem ciclos negativos).

Complexidade do Algoritmo

A complexidade do Algoritmo de Johnson é O(V² log V + V E), onde:

V = número de vértices
E = número de arestas
Esta complexidade resulta da combinação:

Bellman-Ford: O(V E)
Dijkstra (com heap binário) para cada vértice: O(V E log V)

Cálculo da Complexidade Total

A complexidade do Algoritmo de Johnson é determinada pelas suas três fases principais:

Bellman-Ford: O(V·E)
Reponderação das arestas: O(E)
Execução de Dijkstra para cada vértice: O(V·(V²)) = O(V³) usando array
Complexidade total: O(V·E + E + V³) = O(V³ + V·E)

No entanto, se implementássemos Dijkstra com uma heap binária (mais eficiente), a complexidade seria:

Dijkstra com heap binário: O((E + V) log V) por execução
Para V vértices: O(V·(E + V) log V) = O(V·E log V + V² log V)
Complexidade total com heap binário: O(V·E + V·E log V + V² log V) = O(V·E log V + V² log V)

*\
