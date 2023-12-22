function part1(io="day22.txt")
    bricks = NTuple{6, Int}[]

    maxx = 0
    maxy = 0
    maxz = 0
    for line in eachline(io)
        bx, by, bz, ex, ey, ez = parse.(Int, split(line, r"[,~]"; keepempty=false))
        if ex < bx
            bx, ex = ex, bx
        end
        if ey < by
            by, ey = ey, by
        end
        if ez < bz
            bz, ez = ez, bz
        end
        bx += 1
        by += 1
        ex += 1
        ey += 1
        push!(bricks, (bx, by, bz, ex, ey, ez))

        maxx = max(maxx, bx, ex)
        maxy = max(maxy, by, ey)
        maxz = max(maxz, bz, ez)
    end

    sort!(bricks; by=brick->brick[3])

    world = zeros(Int, (maxx, maxy, maxz))

    for (i, brick) in pairs(bricks)
        bx, by, bz, ex, ey, ez = brick

        local fell_by
        for outer fell_by in 0:bz-1
            if any(!iszero, world[bx:ex, by:ey, (bz:ez) .- fell_by])
                fell_by -= 1
                break
            end
        end

        world[bx:ex, by:ey, (bz:ez) .- fell_by] .= i
        bricks[i] = (bx, by, bz-fell_by, ex, ey, ez-fell_by)
    end

    disintegrable = 0
    for (i, brick) in pairs(bricks)
        bx, by, bz, ex, ey, ez = brick

        if ez == size(world, 3)
            disintegrable += 1
            continue
        end

        visited = falses(length(bricks))

        can_disintegrate_block = true
        for x in bx:ex, y in by:ey
            block_above = world[x, y, ez+1]
            if block_above != 0 && !visited[block_above]
                visited[block_above] = true
                resting_brick = bricks[block_above]

                is_resting_solely_on = true
                for ix in resting_brick[1]:resting_brick[4], iy in resting_brick[2]:resting_brick[5]
                    if world[ix, iy, ez] ∉ (0, i)
                        is_resting_solely_on = false
                        break
                    end
                end

                can_disintegrate_block &= !is_resting_solely_on
            end
        end

        disintegrable += can_disintegrate_block
    end

    return disintegrable
end

using Test
@test part1("""
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9""" |> IOBuffer) == 5

@test part1() == 497

function part2(io="day22.txt")
    bricks = NTuple{6, Int}[]

    maxx = 0
    maxy = 0
    maxz = 0
    for line in eachline(io)
        bx, by, bz, ex, ey, ez = parse.(Int, split(line, r"[,~]"; keepempty=false))
        if ex < bx
            bx, ex = ex, bx
        end
        if ey < by
            by, ey = ey, by
        end
        if ez < bz
            bz, ez = ez, bz
        end
        bx += 1
        by += 1
        ex += 1
        ey += 1
        push!(bricks, (bx, by, bz, ex, ey, ez))

        maxx = max(maxx, bx, ex)
        maxy = max(maxy, by, ey)
        maxz = max(maxz, bz, ez)
    end

    sort!(bricks; by=brick->brick[3])

    world = zeros(Int, (maxx, maxy, maxz))

    for (i, brick) in pairs(bricks)
        bx, by, bz, ex, ey, ez = brick

        local fell_by
        for outer fell_by in 0:bz-1
            if any(!iszero, world[bx:ex, by:ey, (bz:ez) .- fell_by])
                fell_by -= 1
                break
            end
        end

        world[bx:ex, by:ey, (bz:ez) .- fell_by] .= i
        bricks[i] = (bx, by, bz-fell_by, ex, ey, ez-fell_by)
    end

    sum = 0
    for j in eachindex(bricks)
        world = zeros(Int, (maxx, maxy, maxz))

        for (i, brick) in pairs(bricks)
            if i == j
                continue
            end

            bx, by, bz, ex, ey, ez = brick

            local fell_by
            for outer fell_by in 0:bz-1
                if any(!iszero, world[bx:ex, by:ey, (bz:ez) .- fell_by])
                    fell_by -= 1
                    break
                end
            end

            world[bx:ex, by:ey, (bz:ez) .- fell_by] .= i
            sum += fell_by > 0
        end
    end

    return sum
end

using Test
@test part2("""
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9""" |> IOBuffer) == 7

@test part2() == 67468