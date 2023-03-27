// %%writefile dijkstra_cuda_v1.cu

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <limits.h>
#include <assert.h>

//#define DEBUG

static unsigned long int next = 1;

int my_rand(void) {
	return ((next = next * 1103515245 + 12345) % ((u_long) RAND_MAX + 1));
}

void my_srand(unsigned int seed) {
	next = seed;
}

typedef struct {
  int nNodes;   //nro nós
  int *nEdges;  //nro arestas de cada nó.         0 <= i <= nNode
  int **edges;  //arestas
  int **w;      //pesos
} Graph;

void createRandomGraphCUDA(int nNodes, int nEdges, int seed, Graph *graph){
  my_srand(seed); 

  graph->nNodes = nNodes;
  
  cudaMallocManaged(&(graph->nEdges), sizeof(int) * nNodes);
  cudaMallocManaged(&(graph->edges), sizeof(int*) * nNodes);
  cudaMallocManaged(&(graph->w), sizeof(int*) * nNodes);
  
  int k, v;
  for (v = 0; v < nNodes; v++){
    cudaMallocManaged(&(graph->edges[v]), sizeof(int) * nNodes);
    cudaMallocManaged(&(graph->w[v]), sizeof(int) * nNodes);
    graph->nEdges[v] = 0;
  }

  int source = 0;

  for (source = 0; source < nNodes; source++){
    int nArestasVertice = (double) nEdges / nNodes * (0.5 + my_rand() / (double) RAND_MAX);
    for (k = nArestasVertice; k >= 0; k--){
      int dest = my_rand() % nNodes;
      int w = 1 + (my_rand() % 10);
      graph->edges[source][graph->nEdges[source]] = dest;
      graph->w[source][graph->nEdges[source]++] = w;
    }
  }
}

__global__ void dijkstra_kernel(Graph *d_graph, int min, int *distances){
  int idx = threadIdx.x;
  if (idx < d_graph->nEdges[min]){
    int dest = d_graph->edges[min][idx];
    if (distances[dest] > distances[min] + d_graph->w[min][idx]){
      distances[dest] = distances[min] + d_graph->w[min][idx];
    }
  }
}

void printaMatriz( int** mat, int tam){
  for( int i = 0; i < tam; i++){
    for( int j = 0; j < tam; j++)
      printf("%d ", mat[i][j]);
    printf("\n");
  }
  return;
}

void printaVetor( int* vet, int tam){
  for( int i = 0; i < tam; i++){
    if( i % 80 == 0)
      printf("\n");
    printf("%d ", vet[i]);
  }
  printf("\n");
}


int main(int argc, char **argv){
  int nNodes;
  int nEdges;
  int seed;

  if (argc == 4){
    nNodes = atoi(argv[1]);   //NRO NÓS
    nEdges = atoi(argv[2]);   //MÉDIA DO NRO DE ARESTAS por nó
    seed = atoi(argv[3]);     //SEED PARA GERAÇÃO DO GRAFO
  }else{
    fscanf(stdin, "%d %d %d", &nNodes, &nEdges, &seed);
  }

  nEdges = nNodes * nEdges;
  
  int* visited;
  int* distances;

  cudaMallocManaged(&visited, nNodes * sizeof(int));
  cudaMallocManaged(&distances, nNodes * sizeof(int));

  Graph *d_graph;
  cudaMallocManaged(&d_graph, sizeof(Graph));  
 
  if (visited == NULL || distances == NULL || d_graph == NULL){
    printf("ERRO!!!");
    return 1;
  }

  createRandomGraphCUDA(nNodes, nEdges, seed, d_graph);

  int k = 0, v = 0, source = 0;

  for (v=0; v < nNodes; v++){
    distances[v] = INT_MAX;
    visited[v] = 0;
  }
  
  distances[source] = 0;
  visited[source] = 1;

  for (k=0; k < d_graph->nEdges[source]; k++)
    if(distances[d_graph->edges[source][k]] > d_graph->w[source][k] )
      distances[d_graph->edges[source][k]] = d_graph->w[source][k];


  for (v=1; v < nNodes; v++){
    int min = 0;
    int minValue = INT_MAX;
    for (k=0; k < nNodes; k++)
      if (visited[k] == 0 && distances[k] < minValue){
        minValue = distances[k];
        min = k;
      }
    visited[min] = 1;
    
    dijkstra_kernel<<<1, d_graph->nEdges[min]>>>(d_graph, min, distances);
    cudaDeviceSynchronize();
  }

  double mean = 0;
  for (v=0; v < d_graph->nNodes; v++)
    mean += distances[v];
  
  printf("%.2f\n", mean / nNodes);

#ifdef DEBUG
  printf("\nnEdges: ");
  printaVetor(d_graph->nEdges, nNodes);
  printf("\n");

  printf("\nWeights: ");
  printaMatriz(d_graph->w, nNodes);
  printf("\n");

  printf("\nMatriz: \n");
  printaMatriz(d_graph->edges, nNodes);
  printf("\n");

  printf("\nDistancias: ");
  printaVetor(distances, nNodes);
  printf("\n");
#endif

  cudaFree(distances);
  cudaFree(visited);
  cudaFree(d_graph);
  return 0;
}