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

