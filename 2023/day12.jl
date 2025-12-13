function part1(io="day12.txt")
    sum(eachline(io)) do line
    # line = readlines(io)[end]
        conditions, sizes_str = split(line)
        sizes = parse.(Int, split(sizes_str, ','; keepempty=false))
        # @show sizes
        # @show collect(conditions)

        backtrack(collect(conditions), sizes)
    end
end

function backtrack(conditions, sizes, conditions_i)
    # @show conditions_i
    next_conditions_i = findnext(isequal('?'), conditions, conditions_i+1)
    if isnothing(next_conditions_i)
        # @show conditions
        sizes_i = 1
        sizes = copy(sizes)
        for (i, condition) in pairs(conditions)
            if condition == '.' && i > 1 && conditions[i-1] == '#'
                sizes_i += 1
            elseif condition == '#'
                if sizes_i > length(sizes)
                    return 0
                end
                sizes[sizes_i] -= 1
            end
        end

        return all(iszero, sizes)
    end


    conditions[next_conditions_i] = '.'
    arrangements = backtrack(conditions, sizes, next_conditions_i)
    conditions[next_conditions_i] = '#'
    arrangements += backtrack(conditions, sizes, next_conditions_i)

    conditions[next_conditions_i] = '?'

    return arrangements
end

part1("""
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1""" |> IOBuffer)

using Test
@test part1("""
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1""" |> IOBuffer) == 21

@test part1() == 7753

function part2(io="day12.txt")
    # sum(eachline(io)) do line
    line = readlines(io)[2]
        conditions_str, sizes_str = split(line)

        sizes = parse.(Int, split(sizes_str, ','; keepempty=false))
        sizes = repeat(sizes, 5)
        conditions = collect(conditions_str)
        repeated_conditions = copy(conditions)
        for _ in 1:4
            push!(repeated_conditions, '?')
            append!(repeated_conditions, conditions)
        end

        backtrack(repeated_conditions, sizes, 0)
    # end
end

function backtrack(conditions, sizes, conditions_i=0, sizes_i=1)
    if sizes_i <= length(sizes) && sizes[sizes_i] < 0
        return 0
    end

    sizes = copy(sizes)
    next_conditions_i = conditions_i+1
    while next_conditions_i <= length(conditions) && conditions[next_conditions_i] != '?'
        if conditions[next_conditions_i] == '#'
            if sizes_i > length(sizes)
                return 0
            end
            sizes[sizes_i] -= 1
        elseif conditions[next_conditions_i] == '.' && next_conditions_i > 1 && conditions[next_conditions_i-1] == '#'
            sizes_i += 1
        end
        next_conditions_i += 1
    end

    if next_conditions_i > length(conditions)
        return all(iszero, sizes)
    end

    conditions[next_conditions_i] = '.'
    arrangements = if next_conditions_i > 1 && conditions[next_conditions_i-1] == '#'
        backtrack(conditions, sizes, next_conditions_i, sizes_i+1)
    else
        backtrack(conditions, sizes, next_conditions_i, sizes_i)
    end

    if sizes_i <= length(sizes)
        conditions[next_conditions_i] = '#'
        sizes[sizes_i] -= 1
        arrangements += backtrack(conditions, sizes, next_conditions_i, sizes_i)
        sizes[sizes_i] += 1
    end

    conditions[next_conditions_i] = '?'

    return arrangements
end

part2("""
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1""" |> IOBuffer)

using Test
@test part2("""
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1""" |> IOBuffer) == 525152