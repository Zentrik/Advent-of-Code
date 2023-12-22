function part1(io=eachline("day14.txt"))
    sum_of_0idxed_rows = 0
    count = 0

    row = 0
    local next_free_slot
    for line in io
        row += 1
        if row == 1
            next_free_slot = ones(Int, length(line))
        end
        for (i, c) in pairs(line)
            if c == 'O'
                sum_of_0idxed_rows += next_free_slot[i] - 1
                count += 1
                next_free_slot[i] += 1
            elseif c == '#'
                next_free_slot[i] = row + 1
            end
        end
    end
    count * row - sum_of_0idxed_rows
end

part1("""O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....""" |> IOBuffer |> eachline)

part1()

function calculate_load(input)
    sum(pairs(IndexCartesian(), input)) do (I, c)
        c == 'O' ? size(input, 1) - (I[1] - 1) : 0
    end
end

function north_tilt!(grid)
    no_of_rows = size(grid)[1]

    @inbounds for (col, column) in pairs(eachcol(grid))
        next_free_slot = 1
        for (row, c) in pairs(column)
            if c == 'O'
                grid[row, col] = '.'
                grid[next_free_slot, col] = 'O'
                next_free_slot += 1
            elseif c == '#'
                next_free_slot = row + 1
            end
        end
    end
end

function part2(io=eachline("day14.txt"))
    matrix = stack(io; dims=1)
    seen_matrices = Dict{typeof(matrix), Int}(matrix => 0)

    num_cycles = 1000000000

    local cycles
    for outer cycles in 1:num_cycles
        for i in 1:4
            @inline north_tilt!(matrix)
            @inline matrix = rotr90(matrix)
        end

        if haskey(seen_matrices, matrix)
            break
        end

        seen_matrices[copy(matrix)] = cycles
    end

    period = cycles - seen_matrices[matrix]

    cycles_rem = (num_cycles - seen_matrices[matrix]) % period
    cycles_idx = seen_matrices[matrix] + cycles_rem
    matrix = findfirst(isequal(cycles_idx), seen_matrices)

    calculate_load(matrix)
end

part2("""O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....""" |> IOBuffer |> eachline)

part2()