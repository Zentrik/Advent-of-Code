using DataStructures

const CI = CartesianIndex
const dir_to_CI = (CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1))
const dir_to_dirs = ((CI(0, 1), CI(0, -1)), (CI(-1, 0), CI(1, 0)))

function decrease!(pq::PriorityQueue{K, V}, value, key) where {K,V}
    i = get(pq.index, key, 0)

    if i != 0
        @inbounds oldvalue = pq.xs[i].second
        if !Base.lt(pq.o, oldvalue, value)
            pq.xs[i] = Pair{K,V}(key, value)
            DataStructures.percolate_up!(pq, i)
        end
    else
        push!(pq, key=>value)
    end
    return value
end

map_val(map) = x -> map[x] & Int8(15)
function part1(io="day17.txt", mindist=1, maxdist=3)
    map = stack(eachline(io); dims = 1) .|> x->parse(Int8, x)
    pq = PriorityQueue{Tuple{CI{2}, Bool}, Int16}()

    pq[(CI(1, 1), false)] = 0
    pq[(CI(1, 1), true)] = 0

    while !isempty(pq)
        key, heat_loss = popfirst!(pq)
        idx, dir = key

        if map[idx] & Int8(1)<<(5+dir) != 0
            continue
        else
            map[idx] |= Int8(1)<<(5+dir)
        end

        idx == CI(size(map)...) && return heat_loss

        for new_dir ∈ dir_to_dirs[1+dir]
            checkbounds(Bool, map, idx + new_dir * mindist) || continue
            new_heat_loss = heat_loss + sum(map_val(map), (idx + new_dir*j for j in 1:mindist-1); init=Int16(0))
            for i in mindist:maxdist
                new_idx = idx + new_dir * i
                checkbounds(Bool, map, new_idx) || break
                new_heat_loss += map_val(map)(new_idx)

                decrease!(pq, new_heat_loss, (new_idx, !dir))
            end
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
    part1(io, 4, 10)
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