function part1(lines=readlines("day8.txt"))
    instructions = lines[1] |> collect .== 'R'

    nodes = Dict{String, Tuple{String, String}}()
    for line in @views lines[3:end]
        node, lnode, rnode = split(line, r"[ =(),]"; keepempty=false)
        nodes[node] = (lnode, rnode)
    end

    node = "AAA"
    counter = 0
    while node != "ZZZ"
        counter += 1
        idx = instructions[mod1(counter, length(instructions))] + 1
        node = nodes[node][idx]
    end
    counter
end

using Test
@test part1("""RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)""" |> x->split(x, '\n')) == 2

@test part1("""LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)""" |> x->split(x, '\n')) == 6

part1()

function part2(lines=readlines("day8.txt"))
    @inbounds instructions = lines[1] |> collect .== 'R'

    nodes = Dict{String, Tuple{String, String}}()
    workset = String[]
    for line in @views lines[3:end]
        node, lnode, rnode = split(line, r"[ =(),]"; keepempty=false)
        nodes[node] = (lnode, rnode)
        last(node) == 'A' && push!(workset, node)
    end

    result = 1
    counter = 0
    for node in workset
        counter = 0
        while last(node) != 'Z'
            counter += 1
            @inbounds idx = instructions[mod1(counter, length(instructions))] + 1
            node = nodes[node][idx]
        end
        result = lcm(result, counter)
    end
    result
end

using Test
@test part2("""LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)""" |> x->split(x, '\n')) == 6
part2()