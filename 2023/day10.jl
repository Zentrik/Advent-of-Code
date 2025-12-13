using MLStyle

N, E, S, W = (-1, 0), (0, 1), (1, 0), (0, -1)
function pipe_to_direction(pipe)
    @match pipe begin
        '|' => (N, S)
        '-' => (E, W)
        'L' => (N, E)
        'J' => (N, W)
        '7' => (S, W)
        'F' => (S, E)
    end
end

function part1(io = "day10.txt")
    file = readlines(io)
    grid = file .|> collect |> x->stack(x; dims=1)

    x, y = Tuple(findfirst(isequal('S'), grid))
    # @show x, y

    last_move_dir = nothing
    for dir in (N, E, S, W)
        newx, newy = x + dir[1], y + dir[2]
        # @show newx, newy
        if grid[newx, newy] != '.' && any(nextdir->(x, y) == (newx, newy) .+ nextdir, pipe_to_direction(grid[newx, newy]))
            last_move_dir = dir
            x, y = newx, newy
            break
        end
    end
    # @assert(!isnothing(last_move_dir))
    path_len = 1
    while grid[x, y] != 'S'
        # @show grid[x, y] == 'S'
        diridx = findfirst(!isequal((-1).*last_move_dir), pipe_to_direction(grid[x, y]))
        dir = pipe_to_direction(grid[x, y])[diridx]
        x, y = x + dir[1], y + dir[2]

        last_move_dir = dir
        path_len += 1
    end

    ceil(Integer, (path_len - 1) / 2)
end

using Test
@test part1("""
.....
.S-7.
.|.|.
.L-J.
.....
""" |> IOBuffer) == 4

@test part1("""
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
""" |> IOBuffer) == 8

@test part1() == 7145

function part2(io = "day10.txt")
    file = readlines(io)
    grid = file .|> collect |> x->stack(x; dims=1)

    x, y = Tuple(findfirst(isequal('S'), grid))

    last_move_dir = nothing
    for dir in (N, E, S, W)
        newx, newy = x + dir[1], y + dir[2]
        checkbounds(Bool, grid, newx, newy) || continue
        if grid[newx, newy] != '.' && any(nextdir->(x, y) == (newx, newy) .+ nextdir, pipe_to_direction(grid[newx, newy]))
            last_move_dir = dir
            x, y = newx, newy
            break
        end
    end

    signed_area = x * last_move_dir[2]
    perimeter = 1
    while grid[x, y] != 'S'
        diridx = findfirst(!isequal((-1).*last_move_dir), pipe_to_direction(grid[x, y]))
        dx, dy = pipe_to_direction(grid[x, y])[diridx]

        x, y = x + dx, y + dy
        signed_area += x * dy
        perimeter += 1
        last_move_dir = dx, dy
    end
    abs(signed_area) - perimeter ÷ 2 + 1
end

@test part2("""
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
""" |> IOBuffer) == 4

@test part2("""
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
""" |> IOBuffer) == 8

@test part2("""
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
""" |> IOBuffer) == 10

part2()