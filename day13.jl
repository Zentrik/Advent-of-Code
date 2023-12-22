function part1(io="day13.txt")
    file_contents = readlines(io)
    patterns = []

    starti = 1
    for (i, line) in pairs(file_contents)
        if isempty(line)
            pattern = stack(file_contents[starti:i-1]; dims=1)
            push!(patterns, pattern)
            starti = i + 1
        end
    end
    push!(patterns, stack(file_contents[starti:end]; dims=1))

    sum(patterns) do pattern
        for i in 1:size(pattern, 2)-1
            if check_vertical_line_reflection(pattern, i)
                return i
            end
        end
        for i in 1:size(pattern, 1)-1
            if check_horizontal_line_reflection(pattern, i)
                return 100*i
            end
        end
    end
end

function check_vertical_line_reflection(pattern, i)
    # Columns <= i reflected into columns > i
    no_of_cols_each_side = min(size(pattern, 2) - i, i)
    start_column_idx = i - no_of_cols_each_side + 1
    end_column_idx = i + no_of_cols_each_side

    for col_idx in 0:no_of_cols_each_side-1
        left_col_idx = start_column_idx + col_idx
        right_col_idx = end_column_idx - col_idx

        if @views pattern[:, left_col_idx] != pattern[:, right_col_idx]
            return false
        end
    end

    return true
end

function check_horizontal_line_reflection(pattern, i)
    # rows <= i reflected into rows > i
    no_of_rows_each_side = min(size(pattern, 1) - i, i)
    start_row_idx = i - no_of_rows_each_side + 1
    end_row_idx = i + no_of_rows_each_side

    for row_idx in 0:no_of_rows_each_side-1
        left_row_idx = start_row_idx + row_idx
        right_row_idx = end_row_idx - row_idx

        if @views pattern[left_row_idx, :] != pattern[right_row_idx, :]
            return false
        end
    end

    return true
end

using Test
@test """#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#""" |> split |> x->stack(x; dims=1) |> x->check_horizontal_line_reflection(x, 4)

@test part1("""#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#""" |> IOBuffer) == 405

@test part1() == 37561

function part2(io="day13.txt")
    file_contents = readlines(io)
    patterns = []

    starti = 1
    for (i, line) in pairs(file_contents)
        if isempty(line)
            pattern = stack(file_contents[starti:i-1]; dims=1)
            push!(patterns, pattern)
            starti = i + 1
        end
    end
    push!(patterns, stack(file_contents[starti:end]; dims=1))

    sum(patterns) do pattern
        for i in 1:size(pattern, 2)-1
            if check_smudged_vertical_line_reflection(pattern, i)
                return i
            end
        end
        for i in 1:size(pattern, 1)-1
            if check_smudged_horizontal_line_reflection(pattern, i)
                return 100*i
            end
        end
    end
end

function check_smudged_vertical_line_reflection(pattern, i)
    # Columns <= i reflected into columns > i
    no_of_cols_each_side = min(size(pattern, 2) - i, i)
    start_column_idx = i - no_of_cols_each_side + 1
    end_column_idx = i + no_of_cols_each_side

    smudges = 0
    for col_idx in 0:no_of_cols_each_side-1
        left_col_idx = start_column_idx + col_idx
        right_col_idx = end_column_idx - col_idx

        @views smudges += count(x->!isequal(x...), zip(pattern[:, left_col_idx], pattern[:, right_col_idx]))
        if smudges > 1
            return false
        end
    end

    return smudges == 1
end

function check_smudged_horizontal_line_reflection(pattern, i)
    # rows <= i reflected into rows > i
    no_of_rows_each_side = min(size(pattern, 1) - i, i)
    start_row_idx = i - no_of_rows_each_side + 1
    end_row_idx = i + no_of_rows_each_side

    smudges = 0
    for row_idx in 0:no_of_rows_each_side-1
        left_row_idx = start_row_idx + row_idx
        right_row_idx = end_row_idx - row_idx

        @views smudges += count(x->!isequal(x...), zip(pattern[left_row_idx, :], pattern[right_row_idx, :]))
        if smudges > 1
            return false
        end
    end

    return smudges == 1
end

@test part2("""#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#""" |> IOBuffer) == 400

@test part2() == 31108