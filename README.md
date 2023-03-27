# dijkstra-s-algorithm-CUDA

## Problem F
## Dijkstra

Dijkstra’s algorithm, conceived by computer scientist Edsger Dijkstra in 1956 and published in 1959, is a graph search algorithm that solves the single-source shortest path problem for a graph with non-negative edge path costs.
For a give node in a graph, the algorithm finds the path with lowest cost (i.e. the shortest path) between that node and the destination node. 

An adjacency list representation for a graph associates each node in the graph with the collection of its neighboring nodes.

This list also can store the weight of each edge or other information that helps the algorithm finding the shortest path.
Write a parallel version of the Dijkstra’s algorithm.

## Input
The input contains 3 integers. The first integer represents the total number of nodes in
the graph (2 ≤ V ≤ 50). The second integer represents the average number of outgoing
edges per node (1 ≤ E ≤ V/2). The last integer represents the seed for a random number
generator (0 ≤ S < 2³²).
The input must be read from the standard input.

## Output
The output has only one number. It represents the mean distance from node 0 to all
nodes.
The output must be written to the standard output.

Within the parameters of the parallel programming marathon and using the serial version of Dijkstra's algorithm, the Dijkstra algorithm was implemented with CUDA.
