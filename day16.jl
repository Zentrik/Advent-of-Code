N = (-1, 0)
E = (0, 1)
S = (1, 0)
W = (0, -1)

function to_num(dir)
    if dir == N
        1
    elseif dir == E
        2
    elseif dir == S
        4
    elseif dir == W
        8
    end
end

function part1(io="day16.txt")
    grid = readlines(io) .|> collect |> x->stack(x; dims=1)

    energised_grid = zeros(UInt8, size(grid)...)
    advance_path!(energised_grid, grid, 1, 1, E)

    count(!iszero, energised_grid)
end

function advance_path!(energised_grid, grid, x, y, dir)
    checkbounds(Bool, grid, x, y) || return

    if energised_grid[x, y] & to_num(dir) != 0
        return
    end
    energised_grid[x, y] |= to_num(dir)

    if grid[x, y] == '.'
    elseif grid[x, y] == '|'
        if dir in (E, W)
            dir = N
            advance_path!(energised_grid, grid, x + S[1], y + S[2], S)
        end
    elseif grid[x, y] == '-'
        if dir in (N, S)
            dir = E
            advance_path!(energised_grid, grid, x + W[1], y + W[2], W)
        end
    elseif grid[x, y] == '/'
        dir = if dir == N
            E
        elseif dir == E
            N
        elseif dir == S
            W
        elseif dir == W
            S
        end
    elseif grid[x, y] == '\\'
        dir = if dir == N
            W
        elseif dir == E
            S
        elseif dir == S
            E
        elseif dir == W
            N
        end
    end

    advance_path!(energised_grid, grid, x + dir[1], y + dir[2], dir)
end

using Test
@test part1(raw".|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|...." |> IOBuffer) == 46

@test part1() == 7046

function part2(io="day16.txt")
    grid = readlines(io) .|> collect |> x->stack(x; dims=1)

    max_energised = 0

    for x in 1:size(grid, 1)
        energised_grid = zeros(UInt8, size(grid)...)
        advance_path!(energised_grid, grid, x, 1, E)
        max_energised = max(max_energised, count(!iszero, energised_grid))

        energised_grid = zeros(UInt8, size(grid)...)
        advance_path!(energised_grid, grid, x, size(grid, 2), W)
        max_energised = max(max_energised, count(!iszero, energised_grid))
    end

    for y in 1:size(grid, 1)
        energised_grid = zeros(UInt8, size(grid)...)
        advance_path!(energised_grid, grid, 1, y, S)
        max_energised = max(max_energised, count(!iszero, energised_grid))

        energised_grid = zeros(UInt8, size(grid)...)
        advance_path!(energised_grid, grid, size(grid, 1), y, N)
        max_energised = max(max_energised, count(!iszero, energised_grid))
    end

    return max_energised
end

@test part2(raw".|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|...." |> IOBuffer) == 51

@test part2() == 7313