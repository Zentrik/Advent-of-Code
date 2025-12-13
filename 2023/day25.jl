function part1(io="day25.txt")
    adjacency_list = Dict{String, Vector{String}}()
    for line in eachline(io)
        parent, children... = split(line, (':', ' '); keepempty=false)
        append!(get!(adjacency_list, string(parent), []), children)
        for child in children
            push!(get!(adjacency_list, string(child), []), parent)
        end
    end

    component = adjacency_list |> keys |> first # random component

    for (i, second_component) in adjacency_list |> keys |> enumerate
        i == 1 && continue

        max_flow, used_edges = ford_fulkerson(component, second_component, adjacency_list)

        if max_flow <= 3
            S = Set{String}()
            addtoS(S, component, used_edges, adjacency_list)
            return length(S) * (length(adjacency_list) - length(S))
        end
    end
end

function addtoS(S, vertex, used_edges, adjacency_list)
    vertex in S && return

    push!(S, vertex)
    for neighbour in adjacency_list[vertex]
        if (vertex, neighbour) ∉ used_edges || (neighbour, vertex) ∈ used_edges
            addtoS(S, neighbour, used_edges, adjacency_list)
        end
    end
end

function ford_fulkerson(start_vertex, end_vertex, adjacency_list)
    flow = 0
    used_edges = Set{Tuple{String, String}}()
    path = Set{String}()
    while true
        increased_by = increase_flow!(used_edges, path, start_vertex, end_vertex, adjacency_list)
        flow += increased_by

        if increased_by == 0
            return flow, used_edges
        end
        if flow >= 4
            return flow, used_edges
        end
        empty!(path)
    end
end

function increase_flow!(used_edges, path, current_vertex, end_vertex, adjacency_matrix)
    current_vertex == end_vertex && return true

    for neighbour in adjacency_matrix[current_vertex]
        neighbour in path && continue
        (current_vertex, neighbour) in used_edges && continue

        push!(path, neighbour)
        flow_increased = increase_flow!(used_edges, path, neighbour, end_vertex, adjacency_matrix)
        # delete!(path, neighbour) # perf optimization, exponential to linear? hopefully correct to not do

        if flow_increased
            if (neighbour, current_vertex) in used_edges
                delete!(used_edges, (neighbour, current_vertex))
            else
                push!(used_edges, (current_vertex, neighbour))
            end
            return true
        end
    end

    return false
end

using Test
@test part1("""
a: b c
b: e d
c: e
e: f
d: f
""" |> IOBuffer) == 5

@test part1("""
jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr""" |> IOBuffer) == 54

@test part1() == 543036

# @time part1("day25/size-8192.txt")