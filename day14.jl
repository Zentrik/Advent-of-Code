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