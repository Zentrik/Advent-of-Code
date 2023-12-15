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

function part2(iterator=readlines("day5.txt"))
    line, iterator = Iterators.peel(iterator)
    # parsed_seeds = parse.(Int, @view split(line)[2:end])

    print = false

    keys = UnitRange[]
    for (start_str, len_str) in Iterators.partition(split(line)[2:end], 2)
        start = parse(Int, start_str)
        len = parse(Int, len_str)
        push!(keys, start:start+len-1)
    end
    new_keys = similar(keys, 0)

    iterator = Iterators.drop(iterator, 1)
    while !(Iterators.isdone(iterator) === true || isempty(iterator))
        iterator = Iterators.drop(iterator, 1)
        line, iterator = Iterators.peel(iterator)

        resize!(new_keys, 0)
        print && println(keys)
        while !isempty(line)
            # print && println(line)
            dest_start, source_start, len = parse.(Int, split(line))

            n = length(keys)
            for _ in 1:n
                keyrange = popfirst!(keys)

                # print && println(keyrange)
                left_range = intersect(keyrange, 0:source_start-1)
                mapped_range = intersect(keyrange, source_start:source_start+len-1) .+ (dest_start - source_start)
                right_range = intersect(keyrange, source_start+len:last(keyrange))
                # print && println(left_range)
                # print && println(mapped_range)
                # print && println(right_range)
                # print && println()

                if !isempty(left_range)
                    push!(keys, left_range)
                end
                if !isempty(right_range)
                    push!(keys, right_range)
                end
                if !isempty(mapped_range)
                    push!(new_keys, mapped_range)
                end
                # print && println(keys)
            end

            if Iterators.isdone(iterator) === true || isempty(iterator)
                break
            end

            line, iterator = Iterators.peel(iterator)
        end
        # print && println(new_keys)
        append!(keys, new_keys)
    end
    print && println(keys)

    keys |> minimum |> minimum
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