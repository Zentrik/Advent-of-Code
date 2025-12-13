function part1(file="day11.txt")
    grid_char = readlines(file) .|> collect |> x->stack(x; dims=1)
    grid = grid_char .== '#'

    galaxies = Tuple{Int, Int}[]
    prefix_sum_cols = zeros(Int, size(grid, 2))
    prefix_sum_rows = zeros(Int, size(grid, 1))

    for (i, col) in enumerate(eachcol(grid))
        prefix_sum_cols[i] = all(!, col) + (i == 1 ? 0 : prefix_sum_cols[i-1])
    end
    for (i, row) in enumerate(eachrow(grid))
        prefix_sum_rows[i] = all(!, row) + (i == 1 ? 0 : prefix_sum_rows[i-1])
    end

    for I in eachindex(IndexCartesian(), grid)
        i, j = Tuple(I)
        grid[I] && push!(galaxies, (i + prefix_sum_rows[i], j + prefix_sum_cols[j]))
    end

    sum_length = 0
    for (i, galaxy) in pairs(galaxies), (j, other) in pairs(@views galaxies[i+1:end])
        sum_length += galaxy .- other .|> abs |> sum
    end
    sum_length
end

using Test
@test part1("""
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
""" |> IOBuffer) == 374

@test part1() == 10231178

function part2(file="day11.txt", k=10^6)
    grid_char = readlines(file) .|> collect |> x->stack(x; dims=1)
    grid = grid_char .== '#'

    galaxies = Tuple{Int, Int}[]
    prefix_sum_cols = zeros(Int, size(grid, 2))
    prefix_sum_rows = zeros(Int, size(grid, 1))

    for (i, col) in enumerate(eachcol(grid))
        prefix_sum_cols[i] = all(!, col) + (i == 1 ? 0 : prefix_sum_cols[i-1])
    end
    for (i, row) in enumerate(eachrow(grid))
        prefix_sum_rows[i] = all(!, row) + (i == 1 ? 0 : prefix_sum_rows[i-1])
    end

    for I in eachindex(IndexCartesian(), grid)
        i, j = Tuple(I)
        grid[I] && push!(galaxies, (i + (k-1)*prefix_sum_rows[i], j + (k-1)*prefix_sum_cols[j]))
    end

    sum_length = 0
    for (i, galaxy) in pairs(galaxies), other in @views galaxies[i+1:end]
        sum_length += sum(abs, galaxy .- other)
    end
    sum_length
end

@test part2("""
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
""" |> IOBuffer, 10) == 1030

@test part2("""
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
""" |> IOBuffer, 100) == 8410

@test part2() == 622120986954