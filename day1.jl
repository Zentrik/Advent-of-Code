function part1(io=eachline("day1.txt"))
    sum(io) do line
        x = parse(Int, line[findfirst(isdigit, line)])
        y = parse(Int, line[findlast(isdigit, line)])
        10x + y
    end
end

function match(line, i, j, string)
    # return @inbounds @view(line[i:j]) == string

    for (a, b) in enumerate(i:j)
        if line[b] != string[a]
            return false
        end
    end
    return true
end

function findfirstdigit(line, it)
    # string_to_number = Dict("one"=>1, "two"=>2, "three"=>3, "four"=>4, "five"=>5, "six"=>6, "seven"=>7, "eight"=>8, "nine"=>9)
    # sort(string_to_number; by=length)
    string_to_number = (("two", 2, 3), ("six", 6, 3), ("one", 1, 3), ("four", 4, 4), ("nine", 9, 4), ("five", 5, 4), ("eight", 8, 5), ("three", 3, 5), ("seven", 7, 5))

    line_length = length(line)

    for (i, c) in it
        if isdigit(c)
            return Int(c-'0') #parse(Int, c)
        end
        for element in string_to_number
            string, val, len = element

            if i+len-1 > line_length
                break
            end
            match(line, i, i+len-1, string) && return val
        end
    end
end

function part2(io=eachline("day1.txt"))
    return sum(io) do line
        10*findfirstdigit(line, pairs(line)) + findfirstdigit(line, Iterators.reverse(pairs(line)))
    end
end