using DataStructures

const CI = CartesianIndex
const dir_to_CI = (CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1))

function part1(io="day17.txt")
    map = stack(eachline(io); dims = 1) .|> x->parse(Int, x)
    pq = PriorityQueue{Tuple{CI{2}, Int, Int}, Int}()

    pq[(CI(1, 1), 2, 0)] = 0
    visited = Dict{Tuple{CI{2}, Int}, Tuple{Int, Int}}()

    while !isempty(pq)
        key, heat_loss = popfirst!(pq)
        idx, dir, len = key

        visited_len, visited_heat_loss = get(visited, (idx, dir), (typemax(Int), typemax(Int)))
        if visited_len <= len && visited_heat_loss <= heat_loss
            continue
        end
        visited[(idx, dir)] = (len, heat_loss)

        idx == CI(size(map)...) && return heat_loss

        if len < 3
            new_idx = idx + dir_to_CI[dir]
            if checkbounds(Bool, map, new_idx)
                if get(pq, (new_idx, dir, len+1), typemax(Int)) >= heat_loss + map[new_idx]
                    pq[(new_idx, dir, len+1)] = heat_loss + map[new_idx]
                end
            end
        end
        for rot ∈ (-1, 1)
            new_dir = mod1(dir + rot, 4)
            new_idx = idx + dir_to_CI[new_dir]
            checkbounds(Bool, map, new_idx) || continue
            get(pq, (new_idx, new_dir, 1), typemax(Int)) >= heat_loss + map[new_idx] || continue
            pq[(new_idx, new_dir, 1)] = heat_loss + map[new_idx]
        end
    end

    return -1
end

using Test
@test part1("""
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
""" |> IOBuffer) == 102

@test part1() == 1195

function part2(io="day17.txt")
    map = stack(eachline(io); dims = 1) .|> x->parse(Int, x)
    pq = PriorityQueue{Tuple{CI{2}, Int, Int}, Int}()
    visited = Dict{Tuple{CI{2}, Int}, Tuple{Int, Int}}()

    for dir in 2:3
        new_idx = CI(1, 1) + dir_to_CI[dir]*4
        pq[(new_idx, dir, 4)] = sum(x->map[x], (CI(1, 1) + dir_to_CI[dir]*i for i in 1:4))
    end

    while !isempty(pq)
        key, heat_loss = popfirst!(pq)
        idx, dir, len = key

        idx == CI(size(map)...) && return heat_loss

        visited_len, visited_heat_loss = get(visited, (idx, dir), (typemax(Int), typemax(Int)))
        if visited_len <= len && visited_heat_loss <= heat_loss
            continue
        end
        visited[(idx, dir)] = (len, heat_loss)

        if len < 10
            new_idx = idx + dir_to_CI[dir]
            if checkbounds(Bool, map, new_idx)
                if get(pq, (new_idx, dir, len+1), typemax(Int)) >= heat_loss + map[new_idx]
                    pq[(new_idx, dir, len+1)] = heat_loss + map[new_idx]
                end
            end
        end
        for rot ∈ (-1, 1)
            new_dir = mod1(dir + rot, 4)
            new_idx = idx + dir_to_CI[new_dir]*4
            checkbounds(Bool, map, new_idx) || continue
            get(pq, (new_idx, new_dir, 4), typemax(Int)) >= heat_loss + sum(x->map[x], (idx + dir_to_CI[new_dir]*i for i in 1:4)) || continue
            pq[(new_idx, new_dir, 4)] = heat_loss + sum(x->map[x], (idx + dir_to_CI[new_dir]*i for i in 1:4))
        end
    end

    return -1
end

using Test
@test part2("""
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
""" |> IOBuffer) == 94

@test part2("""
111111111111
999999999991
999999999991
999999999991
999999999991
""" |> IOBuffer) == 71

@test part2() == 1347