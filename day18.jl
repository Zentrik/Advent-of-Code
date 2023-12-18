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
            # println(line)
            # println(displacement)
            # println(instructions[1][1])
            # println(mapreduce(*, +, displacement, Tuple(instructions[1][1])))
            normalized_displacement = displacement .÷ abs(sum(displacement))
            inner_rotation = (findfirst(isequal(normalized_displacement) ∘ Tuple, dir_to_idx)-1) - instructions[1][1]
        end
    end
    # println(inner_rotation)
    @assert !isnothing(inner_rotation) && abs(inner_rotation) == 1
    matrix_size = (max_row - min_row + 1, max_col - min_col + 1)

    matrix = OffsetArray(falses(matrix_size...), min_row:max_row, min_col:max_col)

    position = CartesianIndex(1, 1)
    matrix[position] = true
    for (dir, len) in instructions
        for _ in 1:len
            position += dir_to_idx[1+dir]
            matrix[position] = true
        end
    end

    interior_blocks = 0
    position = CartesianIndex(1, 1)
    interior_matrix = copy(matrix)
    for (dir, len) in instructions
        for _ in 1:len
            inner_direction = dir_to_idx[1+(dir+inner_rotation)%4]
            inner_position = position + inner_direction
            while !matrix[inner_position]
                interior_matrix[inner_position] = true
                inner_position += inner_direction
            end
            position += dir_to_idx[1+dir]
        end
    end
    count(interior_matrix)

    # sum = 0
    # interior_matrix = copy(matrix)
    # for col in 1:size(matrix, 2)-2
    #     in_interior = false
    #     for row in 1:size(matrix, 1)-2
    #         # println(row)
    #         if !matrix[begin+row, begin+col]
    #             if (matrix[begin+row-1, begin+col-1] | matrix[begin+row-1, begin+col+1]) && matrix[begin+row-1, begin+col]
    #                 in_interior = !in_interior
    #                 # println(in_interior)
    #             end
    #             interior_matrix[begin+row, begin+col] = in_interior
    #         end
    #     end
    # end
    # display(matrix)
    # display(interior_matrix)
    # return matrix, interior_matrix, count(interior_matrix)

    # sum(eachcol(matrix)) do col
    #     in_interior = false
    #     sum = 0
    #     for i in eachindex(col)
    #         if col[i]
    #             sum += 1
    #         elseif i != firstindex(col)
    #             if !col[i] & col[i-1] & (i-2 < firstindex(col) || !col[i-2])
    #                 in_interior = !in_interior
    #             end

    #             sum += in_interior
    #         end
    #     end
    #     sum
    # end
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

part1()