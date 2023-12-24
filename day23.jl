function part1(io="day23.txt")
    map = stack(eachline(io); dims = 1)

    start_y = findfirst(==('.'), @views map[1, :])
    goal_y = findfirst(==('.'), @views map[end, :])

    return dfs(Set{NTuple{2, Int}}(), 1, start_y, 0, goal_y, map)
end

function dfs(path, x, y, path_length, goal_y, map)
    checkbounds(Bool, map, x, y) || return 0

    map[x, y] == '#' && return 0

    if (x, y) in path
        return 0
    end

    if x == size(map, 1) && y == goal_y
        return path_length
    end

    push!(path, (x, y))
    result = if map[x, y] == '.'
        maximum(((-1, 0), (0, 1), (1, 0), (0, -1))) do dir
            dfs(path, x + dir[1], y + dir[2], path_length+1, goal_y, map)
        end
    else
        dir = if map[x, y] == '^'
            (-1, 0)
        elseif map[x, y] == '>'
            (0, 1)
        elseif map[x, y] == 'v'
            (1, 0)
        elseif map[x, y] == '<'
            (0, -1)
        else
            throw()
        end

        dfs(path, x + dir[1], y + dir[2], path_length+1, goal_y, map)
    end
    delete!(path, (x, y))

    return result
end

using Test
@test part1("""
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#""" |> IOBuffer) == 94

@test part1() == 2366

const DIRS = ((-1, 0), (0, 1), (1, 0), (0, -1))

function part2(io="day23.txt")
    # Parse
    map = stack(eachline(io); dims = 1)

    start_node = (1, findfirst(==('.'), @views map[1, :]))
    goal_node = (size(map, 1), findfirst(==('.'), @views map[end, :]))

    replace!(map, (('^', '>', 'v', '<') .=> '.')...)

    # Create compressed graph
    idx_to_idx = Dict{NTuple{2, Int}, Int}() # to compress adjacency_list into vector
    adjacency_list = NTuple{4, NTuple{2, Int}}[]
    process_node!(adjacency_list, idx_to_idx, map, start_node, goal_node, start_node)

    # move goal node up
    goal_node_idx = idx_to_idx[goal_node]
    lost_length = adjacency_list[goal_node_idx][1][2]
    goal_node_idx = adjacency_list[goal_node_idx][1][1]

    # DFS
    path_mask = fill(false, length(adjacency_list))
    lost_length + dfs_on_compressed_graph(path_mask, idx_to_idx[start_node], 0, goal_node_idx, adjacency_list)
end

function add_child(adjacency_list, idx_to_idx, parent_node, child_node, path_len)
    for node in (parent_node, child_node)
        if !haskey(idx_to_idx, node)
            idx_to_idx[node] = length(adjacency_list)+1
            push!(adjacency_list, Tuple((1, 0) for _ in 1:4))
        end
    end
    idx = idx_to_idx[parent_node]
    next_free_idx = findfirst(==((1, 0)), adjacency_list[idx])
    new_tuple = Base.setindex(adjacency_list[idx], (idx_to_idx[child_node], path_len), next_free_idx)
    adjacency_list[idx] = new_tuple
end

function process_node!(adjacency_list, idx_to_idx, map, node, goal_node, parent_node)
    path_len = node != parent_node

    while true
        map[node...] = 'X'
        path_len += 1

        if node == goal_node
            add_child(adjacency_list, idx_to_idx, parent_node, node, path_len-1)
            add_child(adjacency_list, idx_to_idx, node, parent_node, path_len-1)
            break
        end

        possible_paths = 0
        for dir in DIRS
            next_node = node .+ dir
            checkbounds(Bool, map, next_node...) || continue
            next_node == parent_node && continue

            possible_paths += map[next_node...] == '.'

            if map[next_node...] == 'B'
                add_child(adjacency_list, idx_to_idx, parent_node, next_node, path_len)
                add_child(adjacency_list, idx_to_idx, next_node, parent_node, path_len)
            end
        end

        possible_paths == 0 && break

        if possible_paths == 1
            for dir in DIRS
                next_node = node .+ dir
                checkbounds(Bool, map, next_node...) || continue

                if map[next_node...] == '.'
                    node = next_node
                    break
                end
            end
        else
            map[node...] = 'B'

            add_child(adjacency_list, idx_to_idx, parent_node, node, path_len-1)
            add_child(adjacency_list, idx_to_idx, node, parent_node, path_len-1)

            for dir in DIRS
                next_node = node .+ dir
                checkbounds(Bool, map, next_node...) || continue

                if map[next_node...] == '.'
                    process_node!(adjacency_list, idx_to_idx, map, next_node, goal_node, node)
                end
            end

            break
        end
    end
end

function dfs_on_compressed_graph(path_mask, node, path_length, goal_node, adjacency_list)
    node == goal_node && return path_length

    @inbounds path_mask[node] = true
    max_len = 0
    for child in @inbounds adjacency_list[node]
        @inbounds child_node = child[1]
        @inbounds path_mask[child_node] && continue

        @inbounds max_len = max(max_len, dfs_on_compressed_graph(path_mask, child_node, path_length + child[2], goal_node, adjacency_list))
    end
    @inbounds path_mask[node] = false

    return max_len
end

using Test
@test part2("""
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#""" |> IOBuffer) == 154

@test part2() == 6682

@time part2()

@profview part2()