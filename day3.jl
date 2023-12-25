function part1(io="day3.txt")
    schematic = stack(eachline(io); dims = 1)

    part_sum = 0
    for (i, row) in pairs(eachrow(schematic))
        endidx = 0
        while endidx < lastindex(row)
            startidx = findnext(isdigit, row, endidx+1)
            isnothing(startidx) && break
            endidx = findnext(!isdigit, row, startidx)
            if isnothing(endidx)
                endidx = lastindex(row)
            else
                endidx -= 1
            end

            symbol_adjacent = false

            min_col = max(startidx-1, firstindex(row))
            max_col = min(endidx+1, lastindex(row))
            symbol_adjacent |= any(x->!isdigit(x) && x != '.', (row[min_col], row[max_col]))

            if i-1 >= firstindex(eachrow(schematic))
                @views symbol_adjacent |= any(x->!isdigit(x) && x != '.', schematic[i-1, min_col:max_col])
            end
            if i+1 <= lastindex(eachrow(schematic))
                @views symbol_adjacent |= any(x->!isdigit(x) && x != '.', schematic[i+1, min_col:max_col])
            end

            if symbol_adjacent
                part_num = 0
                for digit in @views row[startidx:endidx]
                    part_num *= 10
                    part_num += digit - '0'
                end
                part_sum += part_num
            end
        end
    end

    return part_sum
end

using Test
@test part1(raw"""
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
""" |> IOBuffer) == 4361

@test part1() == 527144

const CI = CartesianIndex
@views function part2(io="day3.txt")
    schematic = stack(eachline(io); dims = 1)

    gear_sum = 0
    for (I, c) in pairs(IndexCartesian(), schematic)
        c == '*' || continue

        num_parts_adjacent = count((CI(-1, -1), CI(-1, 0), CI(-1, 1), CI(0, -1), CI(0, 1), CI(1, -1), CI(1, 0), CI(1, 1))) do dir
            checkbounds(Bool, schematic, I + dir) || return 0
            schematic[I + dir] |> isdigit
        end

        for dirs in ((CI(-1, -1), CI(-1, 0)), (CI(-1, 0), CI(-1, 1)), (CI(1, -1), CI(1, 0)), (CI(1, 0), CI(1, 1)))
            num_parts_adjacent -= all(dirs) do dir
                checkbounds(Bool, schematic, I + dir) || return 0
                schematic[I + dir] |> isdigit
            end
        end

        if num_parts_adjacent == 2
            gear_ratio = 1
            for dir in (CI(-1, -1), CI(-1, 0), CI(-1, 1), CI(0, -1), CI(0, 1), CI(1, -1), CI(1, 0), CI(1, 1))
                schematic[I + dir] |> isdigit || continue

                if dir[2] != -1
                    if checkbounds(Bool, schematic, I + dir - CI(0, 1)) && schematic[I + dir - CI(0, 1)] |> isdigit
                        continue
                    end
                end

                startidx = findprev(!isdigit, schematic[(I+dir)[1], :], (I+dir)[2])
                startidx = isnothing(startidx) ? 1 : startidx + 1
                endidx = findnext(!isdigit, schematic[(I+dir)[1], :], (I+dir)[2])
                endidx = isnothing(endidx) ? size(schematic, 2) : endidx - 1

                part_num = 0
                for digit in schematic[(I+dir)[1], startidx:endidx]
                    part_num *= 10
                    part_num += digit - '0'
                end
                gear_ratio *= part_num
            end

            gear_sum += gear_ratio
        end
    end

    return gear_sum
end

@test part2(raw"""
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
""" |> IOBuffer) == 467835

@test part2() == 81463996