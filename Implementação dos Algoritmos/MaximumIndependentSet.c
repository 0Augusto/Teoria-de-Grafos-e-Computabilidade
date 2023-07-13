/*
Neste código, o usuário é solicitado a inserir o número de vértices no grafo, bem como os lucros associados a cada vértice. Em seguida, o usuário é solicitado a inserir a matriz de adjacência do grafo, onde cada elemento indica se existe uma aresta entre dois vértices.

O algoritmo MIS é então chamado para encontrar o conjunto máximo independente de vértices que maximiza o lucro total. A solução é impressa na saída, mostrando quais vértices foram escolhidos e o lucro total alcançado.

Vale ressaltar que, devido à natureza exponencial do problema, o desempenho do algoritmo pode ser limitado para grafos grandes. Portanto, em casos práticos, podem ser necessárias abordagens mais eficientes, como algoritmos aproximados ou heurísticas.
*/
#include <stdio.h>
#include <stdbool.h>

#define MAX_VERTICES 100

int graph[MAX_VERTICES][MAX_VERTICES]; // Matriz de adjacência para representar o grafo
bool visited[MAX_VERTICES]; // Array para rastrear os vértices visitados

void maximumIndependentSet(int v, int n, int profit, int *maxProfit, bool *solution, bool *tempSolution) {
    if (v == n) {
        if (profit > *maxProfit) {
            *maxProfit = profit;
            for (int i = 0; i < n; i++) {
                solution[i] = tempSolution[i];
            }
        }
        return;
    }

    // Verifica se o vértice atual pode ser incluído no conjunto independente
    bool canInclude = true;
    for (int i = 0; i < v; i++) {
        if (tempSolution[i] && graph[v][i]) {
            canInclude = false;
            break;
        }
    }

    // Caso o vértice atual possa ser incluído, temos duas opções: incluí-lo ou excluí-lo
    if (canInclude) {
        // Inclui o vértice
        tempSolution[v] = true;
        maximumIndependentSet(v + 1, n, profit + graph[v][v], maxProfit, solution, tempSolution);

        // Exclui o vértice
        tempSolution[v] = false;
    }

    // Não inclui o vértice
    maximumIndependentSet(v + 1, n, profit, maxProfit, solution, tempSolution);
}

int main() {
    int n; // Número de vértices no grafo
    printf("Digite o número de vértices: ");
    scanf("%d", &n);

    int profits[MAX_VERTICES]; // Array para armazenar os lucros dos vértices
    printf("Digite os lucros dos vértices:\n");
    for (int i = 0; i < n; i++) {
        scanf("%d", &profits[i]);
    }

    printf("Digite a matriz de adjacência do grafo:\n");
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            scanf("%d", &graph[i][j]);
        }
    }

    int maxProfit = 0;
    bool solution[MAX_VERTICES] = {false}; // Array para armazenar a solução final
    bool tempSolution[MAX_VERTICES] = {false}; // Array temporário para rastrear a solução atual

    maximumIndependentSet(0, n, 0, &maxProfit, solution, tempSolution);

    printf("Conjunto de vértices escolhidos para maximizar o lucro:\n");
    for (int i = 0; i < n; i++) {
        if (solution[i]) {
            printf("Vértice %d: Lucro %d\n", i, profits[i]);
        }
    }

    printf("Lucro total: %d\n", maxProfit);

    return 0;
}

