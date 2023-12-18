using OffsetArrays

@enum Direction::Int8 U=0 R=1 D=2 L=3
function part1(io=eachline("day18.txt"))
    dir_to_idx = Dict("U"=>(-1, 0), "R"=>(0, 1), "D"=>(1, 0), "L"=>(0, -1))

    instructions = map(io) do line
        dir_str, blocks_str, _ = split(line)
        dir_to_idx[dir_str], parse(Int, blocks_str)
    end

    position = (0, 0)
    signed_area = 0
    perimeter = 0

    for (dir, blocks) in instructions
        position = position .+ dir .* blocks
        signed_area += position[1] * dir[2] * blocks
        perimeter += blocks
    end

    abs(signed_area) + perimeter ÷ 2 + 1
end

using Test
@test part1("""R 6 (#70c710)
U 5 (#000000)
R 2 (#70c710)
D 10 (#000000)
L 10 (#000000)
U 3 (#000000)
R 2 (#000000)
U 2 (#000000)""" |> IOBuffer |> eachline) == 77

@test part1("""R 2 (#000000)
D 1 (#000000)
R 2 (#000000)
U 1 (#000000)
R 2 (#000000)
D 2 (#000000)
L 6 (#000000)
U 2 (#000000)""" |> IOBuffer |> eachline) == 20

@test part1("""R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)""" |> IOBuffer |> eachline) == 62

@test part1() == 47139

function part2(io=eachline("day18.txt"))
    dir_to_idx = ((-1, 0), (0, 1), (1, 0), (0, -1))


    instructions = map(io) do line
        _, _, hexcode = split(line)
        dir_to_idx[1 + hexcode[end-1] - '0'], parse(Int, view(hexcode, 3:lastindex(hexcode)-2), base=16)
    end

    position = (0, 0)
    signed_area = 0
    perimeter = 0

    for (dir, blocks) in instructions
        position = position .+ dir .* blocks
        signed_area += position[1] * dir[2] * blocks
        perimeter += blocks
    end

    abs(signed_area) + perimeter ÷ 2 + 1
end

using Test
@test part2("""R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)""" |> IOBuffer |> eachline) == 952408144115

@test part2() == 173152345887206