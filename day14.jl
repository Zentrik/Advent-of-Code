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
    no_of_rows = size(input)[1]
    total_load = 0

    for column in eachcol(input)
        next_free_slot = 1
        for (row, c) in pairs(column)
            if c == 'O'
                total_load += no_of_rows - (next_free_slot - 1)
                next_free_slot += 1
            elseif c == '#'
                next_free_slot = row + 1
            end
        end
    end
    total_load
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
    # for _ in 1:1000000000-1
        for i in 1:4
            @inline north_tilt!(matrix)
            # display(rotl90(matrix, i-1))
            @inline matrix = rotr90(matrix)
        end
    # end
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