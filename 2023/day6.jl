function number_of_ways_to_win(time, distance_to_beat)
    discriminant = time^2 - 4*distance_to_beat
    discriminant <= 0 && return 0
    sqrt_val = sqrt(discriminant)
    small_root = 1+floor(Int, (time - sqrt_val) / 2)
    larger_root = ceil(Int, (time + sqrt_val) / 2)-1
    return larger_root - small_root + 1
end

function part1(io=readlines("day6.txt"))
    timeline = @inbounds io[1]
    distanceline = @inbounds io[2]

    time_end = 6
    distance_end = 9

    prod = 1

    while true
        time_start = findnext(isdigit, timeline, time_end+1)
        isnothing(time_start) && break
        time_end = findnext(!isdigit, timeline, time_start+1)
        if isnothing(time_end)
            time_end = lastindex(timeline)
        else
            time_end -= 1
        end
        distance_start = findnext(isdigit, distanceline, distance_end+1)
        distance_end = findnext(!isdigit, distanceline, distance_start+1)
        if isnothing(distance_end)
            distance_end = lastindex(distanceline)
        else
            distance_end -= 1
        end

        time = parse(Int, @inbounds @view timeline[time_start:time_end])
        distance_to_beat = parse(Int, @inbounds @view distanceline[distance_start:distance_end])

        # @show time, distance_to_beat
        # println(number_of_ways_to_win(time, distance_to_beat))
        prod *= number_of_ways_to_win(time, distance_to_beat)
    end

    prod
end

part1()

function parseInt(line, start)
    parsed_value = 0
    idx = start
    while true
        idx = findnext(isdigit, line, idx+1)
        isnothing(idx) && break

        parsed_value *= 10
        parsed_value += parse(Int, line[idx])
    end
    parsed_value
end

function part2(io=readlines("day6.txt"))
    timeline = @inbounds io[1]
    distanceline = @inbounds io[2]

    number_of_ways_to_win(parseInt(timeline, 6), parseInt(distanceline, 9))
end

part2(input)
part2()

function part2_simple(io=readlines("day6.txt"))
    time_line, distance_line = io
    time_digits = split(time_line)[2:end]
    dist_digits = split(distance_line)[2:end]

    total_times = parse.(Int, time_digits)
    to_beat = parse.(Int, dist_digits)

    number_of_ways_to_win(parse(Int, join(time_digits)), parse(Int, join(dist_digits)))
end

part2_simple(input)
part2_simple()