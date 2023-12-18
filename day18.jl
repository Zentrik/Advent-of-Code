using OffsetArrays

@enum Direction::Int8 U=0 R=1 D=2 L=3
function part1(io=eachline("day18.txt"))
    dir_to_idx = map(CartesianIndex, ((-1, 0), (0, 1), (1, 0), (0, -1)))

    instructions = Tuple{Int8, Int}[]
    position = CartesianIndex(1, 1)
    positions_set = Set{CartesianIndex{2}}()
    push!(positions_set, position)
    min_row = 1
    max_row = 1
    min_col = 1
    max_col = 1
    for line in io
        dir, blocks, _ = split(line)
        enum_direction = if dir == "D"
            D
        elseif dir == "U"
            U
        elseif dir == "R"
            R
        elseif dir == "L"
            L
        end
        direction = Integer(enum_direction)
        push!(instructions, (direction, parse(Int, blocks)))
        for _ in 1:parse(Int, blocks)
            position += dir_to_idx[1+direction]
            push!(positions_set, position)
        end

        min_row = min(min_row, position[1])
        max_row = max(max_row, position[1])
        min_col = min(min_col, position[2])
        max_col = max(max_col, position[2])
    end

    interior_blocks = 0
    for col in min_col+1:max_col-1
        in_interior = false
        last_edge = :B # :L, :R, :B : partial left, partial right, both
        for row in min_row+1:max_row-1
            left = CartesianIndex(row-1, col-1) in positions_set
            middle = CartesianIndex(row-1, col) in positions_set
            right = CartesianIndex(row-1, col+1) in positions_set
            if middle
                if left & right
                    in_interior = !in_interior
                    last_edge = :B
                elseif left
                    if last_edge == :R
                        in_interior = !in_interior
                    end
                    if last_edge == :B
                        last_edge = :L
                    else
                        last_edge = :B
                    end
                elseif right
                    if last_edge == :L
                        in_interior = !in_interior
                    end
                    if last_edge == :B
                        last_edge = :R
                    else
                        last_edge = :B
                    end
                end
            end
            if CartesianIndex(row, col) ∉ positions_set
                interior_blocks += in_interior
            end
        end
    end
    return length(positions_set) + interior_blocks
end

part1("""R 6 (#70c710)
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
U 2 (#7a21e3)""" |> IOBuffer |> eachline)

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


@enum Direction::Int8 U=0 R=1 D=2 L=3
function part2(io=eachline("day18.txt"))
    dir_to_idx = map(CartesianIndex, ((-1, 0), (0, 1), (1, 0), (0, -1)))

    instructions = Tuple{Int8, Int}[]
    position = CartesianIndex(1, 1)
    min_row = 1
    max_row = 1
    min_col = 1
    max_col = 1
    inner_rotation = nothing
    for line in io
        _, _, hexcode = split(line)
        blocks = parse(Int, hexcode[3:end-2], base=16)
        direction = parse(Int, hexcode[end-1])
        push!(instructions, (direction, blocks))
        position += dir_to_idx[1+direction] * blocks

        min_row = min(min_row, position[1])
        max_row = max(max_row, position[1])
        min_col = min(min_col, position[2])
        max_col = max(max_col, position[2])

        displacement = Tuple(position - CartesianIndex(1, 1))
        if isnothing(inner_rotation) && any(!iszero, displacement) && mapreduce(*, +, displacement, Tuple(dir_to_idx[1+instructions[1][1]])) == 0
            normalized_displacement = displacement .÷ abs(sum(displacement))
            inner_rotation = (findfirst(isequal(normalized_displacement) ∘ Tuple, dir_to_idx)-1) - instructions[1][1]
        end
    end
    println(instructions)
    @assert !isnothing(inner_rotation) && abs(inner_rotation) == 1
    matrix_size = (max_row - min_row + 1, max_col - min_col + 1)

    matrix = OffsetArray(falses(matrix_size...), min_row:max_row, min_col:max_col)

    edge_blocks = 1
    position = CartesianIndex(1, 1)
    matrix[position] = true
    for (dir, len) in instructions
        for _ in 1:len
            position += dir_to_idx[1+dir]
            edge_blocks += !matrix[position]
            matrix[position] = true
        end
    end

    interior_matrix = copy(matrix)
    for col in 1:size(matrix, 2)-2
        in_interior = false
        for row in 1:size(matrix, 1)-2
            # println(row)
            if !matrix[begin+row, begin+col]
                left = matrix[begin+row-1, begin+col-1]
                middle = matrix[begin+row-1, begin+col]
                right = matrix[begin+row-1, begin+col+1]
                if middle
                    if left & right
                        in_interior = !in_interior
                    elseif left
                        if inner_rotation == 1 # rotate clockwise for inner direction, i.e. up
                            in_interior = false # so just left interior
                        else
                            in_interior = true
                        end
                    elseif right
                        if inner_rotation == 1 # rotate clockwise for inner direction, i.e. down
                            in_interior = true # so just entered interior
                        else
                            in_interior = false
                        end
                    end
                end
                interior_matrix[begin+row, begin+col] = in_interior
            end
        end
    end
    display(matrix)
    display(interior_matrix)
    return matrix, interior_matrix, count(interior_matrix)

    # interior_blocks = 0
    # position = CartesianIndex(1, 1)
    # interior_matrix = similar(matrix)
    # fill!(interior_matrix, false)
    # for (dir, len) in instructions
    #     for _ in 1:len
    #         inner_direction = dir_to_idx[1+(dir+inner_rotation)%4]
    #         inner_position = position + inner_direction
    #         while !matrix[inner_position]
    #             interior_blocks += !interior_matrix[inner_position]
    #             interior_matrix[inner_position] = true
    #             inner_position += inner_direction
    #         end
    #         position += dir_to_idx[1+dir]
    #     end
    # end
    interior_blocks + edge_blocks
end

part2("""R 6 (#70c710)
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
U 2 (#7a21e3)""" |> IOBuffer |> eachline)

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