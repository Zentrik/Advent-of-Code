function part1(iterator=readlines("day5.txt"))
    line, iterator = Iterators.peel(iterator)
    keys = parse.(Int, @view split(line)[2:end])

    new_keys = similar(keys)

    iterator = Iterators.drop(iterator, 1)
    while !(Iterators.isdone(iterator) === true || isempty(iterator))
        iterator = Iterators.drop(iterator, 1)
        line, iterator = Iterators.peel(iterator)

        # println(keys)
        copyto!(new_keys, keys)
        while !isempty(line)
            # println(line)
            dest_start, source_start, len = parse.(Int, split(line))
            for (i, key) in pairs(keys)
                if source_start <= key < source_start + len
                    new_keys[i] = dest_start + key - source_start
                end
            end

            if Iterators.isdone(iterator) === true || isempty(iterator)
                break
            end

            line, iterator = Iterators.peel(iterator)
        end
        keys, new_keys = new_keys, keys
    end

    minimum(keys)
end

part1(split("""seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4""", '\n'))

part1()

function parseline(line)
    dest_start = 0
    i = 1
    while !isspace(line[i])
        dest_start *= 10
        dest_start += line[i] - '0'
        i += 1
    end

    source_start = 0
    i += 1
    while !isspace(line[i])
        source_start *= 10
        source_start += line[i] - '0'
        i += 1
    end

    len = 0
    i += 1
    while i <= ncodeunits(line)
        len *= 10
        len += line[i] - '0'
        i += 1
    end

    dest_start, source_start, len
end

function part2(lines=readlines("day5.txt"))
    keys = Vector{Tuple{Int, Int}}(undef, 500)
    resize!(keys, 0)
    it = lines[1] |> eachsplit |> Iterators.peel |> last
    for (start_str, len_str) in Iterators.partition(it, 2)
        start = parse(Int, start_str)
        len = parse(Int, len_str)
        push!(keys, (start, start+len-1))
    end
    new_keys = similar(keys)

    lineidx = 2
    while lineidx <= length(lines)
        lineidx += 2
        resize!(new_keys, 0)

        while lineidx <= length(lines) && !isempty(lines[lineidx])
            line = lines[lineidx]
            dest_start, source_start, len = parseline(line)
            source_end = source_start+len-1

            n = length(keys)
            for _ in 1:n
                x, y = popfirst!(keys)

                if x < source_start
                    push!(keys, (x, min(y, source_start-1)))
                end
                if source_end < y
                    push!(keys, (max(x, source_end+1), y))
                end
                if source_start <= y && x <= source_end
                    Δ = dest_start - source_start
                    push!(new_keys, (max(x, source_start)+Δ, min(y, source_end)+Δ))
                end
            end
            lineidx += 1
        end
        append!(keys, new_keys)
    end

    minimum(first, keys)
end

part2(split("""seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4""", '\n'))

part2()