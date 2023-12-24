function part1(io="day24.txt", min_test=2*10^14, max_test=4*10^14)
    hailstones = NTuple{6, Int}[]
    for line in eachline(io)
        hailstone_str = split(line, (',', ' ', '@'); keepempty=false) |> Tuple
        hailstone = parse.(Int, hailstone_str)
        push!(hailstones, hailstone)
    end

    # sum(pairs(hailstones)) do (i, A)
    #     sum(@views hailstones[i+1:end]; init=0) do B
    #         LHS = B[1:2] .- A[1:2]
    #         @show [A[4] B[4]; A[5] B[5]]
    #         sol = [A[4] -B[4]; A[5] -B[5]] \ [LHS...]

    #         λ = sol[1]
    #         μ = sol[2]

    #         if λ < 0 || μ < 0
    #             return 0
    #         end

    #         intersection = A[1:2] .+ λ .* A[4:5]

    #         (min_test .< intersection .< max_test) |> all
    #     end
    # end

    sum(pairs(hailstones)) do (i, A)
        sum(@views hailstones[i+1:end]; init=0) do B
            # A[1:2] + λ A[4:5] = B[1:2] + μ B[4:5]
            # B[1:2] - A[1:2] = λ A[4:5] - μ B[4:5]

            LHS = B[1:2] .- A[1:2]

            @assert B[5] != 0
            mul = B[4] / B[5] # multiple for second eqn

            # LHS[1] - mul * LHS[2] = λ * (A[4] - mul * A[5])
            if A[4] - mul * A[5] == 0
                return LHS[1] - mul * LHS[2] == 0
            end
            λ = (LHS[1] - mul * LHS[2]) / (A[4] - mul * A[5])
            μ = (A[2] - B[2] + λ * A[5]) / B[5]

            if λ < 0 || μ < 0
                return 0
            end

            @assert all(A[1:2] .+ λ .* A[4:5] .≈ B[1:2] .+ μ .* B[4:5])

            intersection = A[1:2] .+ λ .* A[4:5]

            (min_test .< intersection .< max_test) |> all
        end
    end
end

using Test
@test part1("""
19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
""" |> IOBuffer, 7, 27) == 2

@test part1() == 27732