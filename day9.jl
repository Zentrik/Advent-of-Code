function part1(io=eachline("day9.txt"))
    sum(io) do line
        diffed_line = parse.(Int, split(line))
        result = 0
        while any(!iszero, diffed_line)
            result += last(diffed_line)
            diffed_line = diff(diffed_line)
        end
        result
    end
end

using Test
@test part1(("0   3   6   9  12  15",)) == 18
@test part1(("1   3   6  10  15  21",)) == 28
@test part1(("10  13  16  21  30  45",)) == 68
@test part1() == 2005352194

function part2(io=eachline("day9.txt"))
    sum(io) do line
        diffed_line = parse.(Int, split(line))
        result = 0
        mul = 1
        while any(!iszero, diffed_line)
            result += mul * first(diffed_line)
            diffed_line = diff(diffed_line)
            mul = -mul
        end
        result
    end
end

@test part2(("0   3   6   9  12  15",)) == -3
@test part2(("1   3   6  10  15  21",)) == 0
@test part2(("10  13  16  21  30  45",)) == 5
@test part2() == 1077