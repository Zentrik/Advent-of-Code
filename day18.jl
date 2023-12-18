using OffsetArrays

@enum Direction::Int8 U=0 R=1 D=2 L=3
function part1(io=eachline("day18.txt"))
    dir_to_idx = map(CartesianIndex, ((-1, 0), (0, 1), (1, 0), (0, -1)))

    instructions = Tuple{Int8, Int}[]
    position = CartesianIndex(1, 1)
    min_row = 1
    max_row = 1
    min_col = 1
    max_col = 1
    inner_rotation = nothing
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
        position += dir_to_idx[1+direction] * parse(Int, blocks)

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

    display(matrix)
    # return matrix

    interior_matrix = copy(matrix)
    for col in 1:size(matrix, 2)-2
        in_interior = false
        last_edge = :B # :L, :R, :B : left, right, bottom
        for row in 1:size(matrix, 1)-1
            # println(row)
            # if !matrix[begin+row, begin+col]
                left = matrix[begin+row-1, begin+col-1]
                middle = matrix[begin+row-1, begin+col]
                right = matrix[begin+row-1, begin+col+1]
                if middle
                    if left & right
                        # @assert(!matrix[begin+row, begin+col])
                        in_interior = !in_interior
                        last_edge = :B
                    elseif left
                        # if last_edge == :B
                        #     @assert matrix[begin+row, begin+col]
                        # else
                        #     @assert !matrix[begin+row, begin+col]
                        # end
                        if last_edge == :R
                            in_interior = !in_interior
                        end
                        if last_edge == :B
                            last_edge = :L
                        else
                            last_edge = :B
                        end
                    elseif right
                        # if last_edge == :B
                        #     @assert matrix[begin+row, begin+col]
                        # else
                        #     @assert !matrix[begin+row, begin+col] "$row, $col"
                        # end
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
                interior_matrix[begin+row, begin+col] |= in_interior
            # end
        end
    end
    # return matrix, interior_matrix
    # display(matrix)
    # display(interior_matrix)
    return count(interior_matrix)
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