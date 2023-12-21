function part1(io="day21.txt", steps=64)
    grid = readlines(io) .|> collect |> x->stack(x; dims=1)
    x, y = findfirst(isequal('S'), grid) |> Tuple
    # dfs(x, y, grid, steps)
    bfs(grid, steps)
end

# function dfs(x, y, grid, steps)
#     checkbounds(Bool, grid, x, y) || return 0
#     grid[x, y] == '#' && return 0
#     if steps == 0
#         new_endpoint = grid[x, y] != 'O'
#         grid[x, y] = 'O'
#         return new_endpoint
#     end

#     sum(((0, 1), (0, -1), (1, 0), (-1, 0))) do dir
#         new_x, new_y = x+dir[1], y+dir[2]
#         dfs(new_x, new_y, grid, steps-1)
#     end
# end

function bfs(grid, steps)
    x, y = findfirst(isequal('S'), grid) |> Tuple

    queue = Set(((x, y),))
    next_queue = Set()

    num_garden_plots = 0

    for steps_taken in 0:steps
        while !isempty(queue)
            x, y = pop!(queue)
            checkbounds(Bool, grid, x, y) || continue
            grid[x, y] == '#' && continue
            if steps_taken == steps
                num_garden_plots += grid[x, y] != 'O'
                grid[x, y] = 'O'
                continue
            end

            for dir in ((0, 1), (0, -1), (1, 0), (-1, 0))
                new_x, new_y = x+dir[1], y+dir[2]
                push!(next_queue, (new_x, new_y))
            end
        end
        queue, next_queue = next_queue, queue
    end

    return num_garden_plots
end

using Test
@test part1("""...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........""" |> IOBuffer, 6) == 16

part1()