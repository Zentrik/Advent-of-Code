function part1(io="day21.txt", steps=64)
    grid = readlines(io) .|> collect |> x->stack(x; dims=1)
    x, y = findfirst(isequal('S'), grid) |> Tuple
    bfs(grid, steps)
end

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

            grid[x, y] == '3' && continue
            if (steps - steps_taken) % 2 == 0
                if grid[x, y] == 'O'
                    continue
                elseif grid[x, y] == '1'
                    grid[x, y] = '3'
                else
                    grid[x, y] = 'O'
                    num_garden_plots += 1
                end
            else
                if grid[x, y] == '1'
                    continue
                elseif grid[x, y] == 'O'
                    grid[x, y] = '3'
                else
                    grid[x, y] = '1'
                end
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

@test part1() == 3591

function part2(io="day21.txt", steps=26501365)
    grid = readlines(io) .|> collect |> x->stack(x; dims=1)
    x, y = findfirst(isequal('S'), grid) |> Tuple
    bfs(grid, steps)
end

function bfs(grid, steps)
    x, y = findfirst(isequal('S'), grid) |> Tuple

    visited_grid = Dict{Tuple{Int, Int, Int, Int}, Int8}()

    queue = Set(((x, y, 0, 0),))
    next_queue = typeof(queue)()

    num_garden_plots = 0

    for steps_taken in 0:steps
        while !isempty(queue)
            x, y, a, b = pop!(queue)

            if x == size(grid, 1) + 1
                x = 1
                a += 1
            elseif x == 0
                x = size(grid, 1)
                a -= 1
            end

            if y == size(grid, 2) + 1
                y = 1
                b += 1
            elseif y == 0
                y = size(grid, 2)
                b -= 1
            end

            grid[x, y] == '#' && continue

            key = (x, y, a, b)
            visited_val = get(visited_grid, key, 0)
            if steps_taken == steps
                num_garden_plots += visited_val <= 1
                visited_grid[key] = 2
                continue
            end

            visited_val == 3 && continue
            if (steps - steps_taken) % 2 == 0
                if visited_val == 2
                    continue
                elseif visited_val == 1
                    visited_grid[key] = 3
                    num_garden_plots += 1
                else
                    visited_grid[key] = 2
                    num_garden_plots += 1
                end
            else
                if visited_val == 1
                    continue
                elseif visited_val == 2
                    visited_grid[key] = 3
                else
                    visited_grid[key] = 1
                end
            end

            for dir in ((0, 1), (0, -1), (1, 0), (-1, 0))
                new_x, new_y = x+dir[1], y+dir[2]
                push!(next_queue, (new_x, new_y, a, b))
            end
        end
        queue, next_queue = next_queue, queue
    end

    return num_garden_plots
end

@test part2("""...........
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

@test part2("""...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........""" |> IOBuffer, 10) == 50

@test part2("""...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........""" |> IOBuffer, 50) == 1594

@test part2("""...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........""" |> IOBuffer, 100) == 6536

@test part2("""...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........""" |> IOBuffer, 500) == 167004

@test part2("""...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........""" |> IOBuffer, 1000) == 668697

# @test part2("""...........
# .....###.#.
# .###.##..#.
# ..#.#...#..
# ....#.#....
# .##..S####.
# .##..#...#.
# .......##..
# .##.#.####.
# .##..##.##.
# ...........""" |> IOBuffer, 5000) == 16733044

@test part2("day21.txt", 64) == 3591

part2("day21.txt", 1000)

function part2(io="day21.txt", steps=26501365)
    grid = readlines(io) .|> collect |> x->stack(x; dims=1)
    @assert any(isodd, size(grid))
    x, y = findfirst(isequal('S'), grid) |> Tuple
    bfs(grid, steps)
end

function shortest_cycle_paths(a, b, grid)
    queue = Set(((a, b, false),))
    next_queue = Set{Tuple{Int, Int, Bool}}()

    odd_shortest_path = 0
    even_shortest_path = 0
    path_len = 0
    while odd_shortest_path == 0 || even_shortest_path == 0
        while !isempty(queue)
            x, y, cycled = pop!(queue)
            cycled |= x == 0 || x == size(grid, 1) + 1 || y == 0 || y == size(grid, 2) + 1
            x, y = mod1(x, size(grid, 1)), mod1(y, size(grid, 2))
            checkbounds(Bool, grid, x, y) || continue
            grid[x, y] == '#' && continue

            if cycled && x == a && y == b
                if path_len % 2 == 0
                    even_shortest_path = path_len
                else
                    odd_shortest_path = path_len
                end
                continue
            end

            for dir in ((0, 1), (0, -1), (1, 0), (-1, 0))
                new_x, new_y = x+dir[1], y+dir[2]
                push!(next_queue, (new_x, new_y))
            end
        end
        path_len += 1
        queue, next_queue = next_queue, queue
    end

    return odd_shortest_path, even_shortest_path
end

shortest_cycle_paths

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