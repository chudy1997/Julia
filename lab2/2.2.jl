module NewGraphs

using StatsBase

export GraphVertex, NodeType, Person, Address,
       generate_random_graph, get_random_person, get_random_address, generate_random_nodes,
       convert_to_graph,
       bfs, check_euler, partition,
       graph_to_str, node_to_str,
       test_graph

# Types of valid graph node's values.
abstract NodeType

type Person <: NodeType
  name::String
end

type Address <: NodeType
  streetNumber::Int64
end

#= Single graph vertex type.
Holds node value and information about adjacent vertices =#

type GraphVertex
  value ::NodeType
  neighbors ::Vector
end

# Number of graph nodes.
const N = 800::Int64

# Number of graph edges.
const K = 10000::Int64

#= Generates random directed graph of size N with K edges
and returns its adjacency matrix.=#

function generate_random_graph()
    opt=1
    amo=K
    if K < N*N/2
      A = zeros(Int64,N,N)
    else
      A = ones(Int64,N,N)
      opt=0
      amo=N*N-K
    end

    for i in sample(1:N*N, amo, replace=false)
      A[i] = opt
    end
    A
end

# Generates random person object (with random name).
function get_random_person()
  Person(randstring())
end

# Generates random person object (with random name).
function get_random_address()
  Address(rand(1:100))
end

# Generates N random nodes (of random NodeType).
function generate_random_nodes()
  nodes = Vector()
  for i= 1:N
    push!(nodes, rand() > 0.5 ? get_random_person() : get_random_address())
  end
  nodes
end

#= Converts given adjacency matrix (NxN)
  into list of graph vertices (of type GraphVertex and length N). =#
function convert_to_graph(A::Array{Int64,2}, nodes)
  N = length(nodes)::Int64
  push!(graph, map(n -> GraphVertex(n, GraphVertex[]), nodes)...)

  for i = 1:N, j = 1:N
      if A[i,j] == 1
        push!(graph[i].neighbors, graph[j])
      end
  end
end

#= Groups graph nodes into connected parts. E.g. if entire graph is connected,
  result list will contain only one part with all nodes. =#
function partition()
  parts = []
  remaining = Set{GraphVertex}(graph)
  visited = bfs(remaining=remaining)
  push!(parts, Set{GraphVertex}(visited))

  while !isempty(remaining)
    new_visited = bfs(visited=visited, remaining=remaining)
    push!(parts, new_visited)
  end
  parts
end

#= Performs BFS traversal on the graph and returns list of visited nodes.
  Optionally, BFS can initialized with set of skipped and remaining nodes.
  Start nodes is taken from the set of remaining elements. =#
function bfs(;visited=Set{GraphVertex}(), remaining=Set{GraphVertex}(graph))
  first = next(remaining, start(remaining))[1]
  q = [first] :: Array{GraphVertex,1}
  push!(visited, first)
  delete!(remaining, first)
  local_visited = Set{GraphVertex}([first])

  while !isempty(q)
    v = pop!(q)

    for n in v.neighbors
      if !(n in visited)
        push!(q, n)
        push!(visited, n)
        push!(local_visited, n)
        delete!(remaining, n)
      end
    end
  end
  local_visited
end

#= Checks if there's Euler cycle in the graph by investigating
   connectivity condition and evaluating if every vertex has even degree =#
function check_euler()
  if length(partition()) == 1
    return all(map(v -> iseven(length(v.neighbors)), graph))
  end
    "Graph is not connected"
end

#= Returns text representation of the graph consisiting of each node's value
   text and number of its neighbors. =#

function vertex_to_str(n::Person)
  "Person: $(n.name)\n"
end

function vertex_to_str(n::Address)
  "Street nr: $(n.streetNumber)\n"
end


function graph_to_str()
  graph_str = ""
  for v in graph :: Vector{GraphVertex}
    graph_str *= "****\n"*vertex_to_str(v.value)*"Neighbors: $(length(v.neighbors))\n"
  end
  graph_str
end

#= Tests graph functions by creating 100 graphs, checking Euler cycle
  and creating text representation. =#
function test_graph()
  println("MY VERSION:\n")
  for i=1:5
    global graph = GraphVertex[]

    print("1. generate_random_graph: ")
    @time A = generate_random_graph()
    print("2. generate_random_nodes: ")
    @time nodes = generate_random_nodes()
    print("3. convert_to_graph: ")
    @time convert_to_graph(A, nodes)
    print("4. graph_to_str: ")
    @time str = graph_to_str()
    print("5. check_euler: ")
    @time check_euler()
  end
end

end
