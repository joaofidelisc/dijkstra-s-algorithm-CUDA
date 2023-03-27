// %%writefile dijkstra_seq.c

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <limits.h>
#include <assert.h>

static unsigned long int next = 1;

struct Graph{
  int nNodes;
  int *nEdges;
  int **edges;
  int **w;
};

int my_rand(void) {
	return ((next = next * 1103515245 + 12345) % ((u_long) RAND_MAX + 1));
}

void my_srand(unsigned int seed) {
	next = seed;
}


struct Graph *createRandomGraph(int nNodes, int nEdges, int seed){
  my_srand(seed); //substituir por srand;

  struct Graph *graph = (struct Graph *) malloc(sizeof(struct Graph));
  graph->nNodes = nNodes;
  graph->nEdges = (int *) malloc(sizeof(int) * nNodes);
  graph->edges = (int **) malloc(sizeof(int *) * nNodes);
  graph->w = (int **) malloc(sizeof(int *) * nNodes);

  int k, v;
  for (v = 0; v < nNodes; v++){
    graph->edges[v] = (int *) malloc(sizeof(int) *  nNodes);
    graph->w[v] = (int *) malloc(sizeof(int) * nNodes);
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
  return graph;
}

int *dijkstra(struct Graph *graph, int source){
  double time_start, time_end;
  struct timeval tv;
  struct timezone tz;
  gettimeofday(&tv, &tz);
  time_start = (double)tv.tv_sec * 1000.00 + (double)tv.tv_usec / 1000.00;


  int nNodes = graph->nNodes;
  int *visited = (int *) malloc(sizeof(int) * nNodes);
  int *distances = (int *) malloc(sizeof(int) * nNodes);
  int k, v;
  for (v=0; v < nNodes; v++){
    distances[v] = INT_MAX;
    visited[v] = 0;
  }
  
  distances[source] = 0;
  visited[source] = 1;

  for (k=0; k < graph->nEdges[source]; k++)
    //trecho alterado
    if(distances[graph->edges[source][k]]>graph->w[source][k] )
      distances[graph->edges[source][k]] = graph->w[source][k];

  for (v=1; v < nNodes; v++){
    int min = 0;
    int minValue = INT_MAX;
    for (k=0; k < nNodes; k++)
      if (visited[k] == 0 && distances[k] < minValue){
        minValue = distances[k];
        min = k;
      }
    visited[min] = 1;
    for (k=0; k < graph->nEdges[min]; k++){
      int dest = graph->edges[min][k];
      if (distances[dest] > distances[min] + graph->w[min][k])
        distances[dest] = distances[min] + graph->w[min][k];
    }
  }
  gettimeofday(&tv, &tz);
  time_end = (double)tv.tv_sec * 1000.00 + (double)tv.tv_usec / 1000.00;
  printf("Time elapsed: %f ms\n", time_end - time_start);

  /* printf("\nThe distance vector is\n");
  for (int i = 0; i < graph->nNodes; i++) {

    printf("%d ", distances[i]);
  }
  printf(" \n"); */

  free(visited);
  return distances;
}

int main(int argc, char **argv){
  int nNodes;
  int nEdges;
  int seed;
  if (argc == 4){
    nNodes = atoi(argv[1]);
    nEdges = atoi(argv[2]);
    seed = atoi(argv[3]);
  }else{
    assert(scanf( "%d %d %d", &nNodes, &nEdges, &seed) == 3);
  }
  assert(nEdges <= nNodes/2);
  nEdges = nNodes * nEdges;

  struct Graph *graph = createRandomGraph(nNodes, nEdges, seed);
  int *dist = dijkstra(graph, 0);

  double mean = 0;
  int v;
  for (v = 0; v < graph->nNodes; v++){
    //printf("%d \n",dist[v]);
    mean += dist[v];
  }
  fprintf(stdout, "%.2f\n", mean / nNodes);

  return 0;
}