function part1(io=eachline("day2.txt"))
    sum(io) do line
        validgame = true
        colon_idx = findnext(!isdigit, line, 7)
        for turns in split.(split(line[colon_idx+1:end], ';'), ',')
            for cubes in turns
                end_number_idx = findnext(!isdigit, cubes, 3)
                number = parse(Int, @inbounds @view cubes[2:end_number_idx])

                start_colour_idx = findnext(isletter, cubes, end_number_idx)
                colour = @inbounds cubes[start_colour_idx]

                if colour == 'b'
                    validgame &= number <= 14
                elseif colour == 'g'
                    validgame &= number <= 13
                elseif colour == 'r'
                    validgame &= number <= 12
                end
            end
        end

        return validgame * parse(Int, @inbounds @view line[6:colon_idx-1])
    end
end

part1(split(input, '\n'))
part1()

function part2(io=eachline("day2.txt"))
    sum(io) do line
        blue_cubes = 0
        green_cubes = 0
        red_cubes = 0

        colon_idx = findnext(!isdigit, line, 7)
        for turns in split.(split(line[colon_idx+1:end], ';'), ',')
            for cubes in turns
                end_number_idx = findnext(!isdigit, cubes, 3)
                number_of_cubes = parse(Int, @inbounds @view cubes[2:end_number_idx])

                start_colour_idx = findnext(isletter, cubes, end_number_idx)
                colour = @inbounds cubes[start_colour_idx]

                if colour == 'b'
                    blue_cubes = max(blue_cubes, number_of_cubes)
                elseif colour == 'g'
                    green_cubes = max(green_cubes, number_of_cubes)
                elseif colour == 'r'
                    red_cubes = max(red_cubes, number_of_cubes)
                end
            end
        end

        return blue_cubes * green_cubes * red_cubes
    end
end

part2(split(input, '\n'))
part2()