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

            # @assert all(A[1:2] .+ λ .* A[4:5] .≈ B[1:2] .+ μ .* B[4:5])

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

using NonlinearSolve, StaticArrays

# each hailstone is x_i + t_i * y_i and the one we throw is denoted a + t_i * b
function f(u, hailstones)
    a, b, t = u[SVector{3}(1:3)], u[SVector{3}(4:6)], u[SVector{3}(7:9)]

    x₁, y₁ = hailstones[1][SVector{3}(1:3)], hailstones[1][SVector{3}(4:6)]
    Δ₁ = a - x₁ + ((b - y₁) * t[1])

    x₂, y₂ = hailstones[2][SVector{3}(1:3)], hailstones[2][SVector{3}(4:6)]
    Δ₂ = a - x₂ + ((b - y₂) * t[2])

    x₃, y₃ = hailstones[3][SVector{3}(1:3)], hailstones[3][SVector{3}(4:6)]
    Δ₃ = a - x₃ + ((b - y₃) * t[3])

    vcat(Δ₁, Δ₂, Δ₃)
end

# function f(u, hailstones)
#     @views a, b, t = u[1:3], u[4:6], u[7:end]
#     # a, b, t = u[SVector{3}(1:3)], u[SVector{3}(4:6)], u[SVector{3}(7:9)]

#     mapreduce(vcat, zip(t, hailstones)) do (tᵢ, stone)
#         xᵢ, yᵢ = stone[1:3], stone[4:6]
#         (a - xᵢ + ((b - yᵢ) * tᵢ))
#     end
# end

function part2(io="day24.txt")
    hailstones = SVector{6, Int}[] # for some reason seems to be better to be SVec{6} instead of SVec{2, SVec{3}}
    for line in eachline(io)
        hailstone_str = split(line, (',', ' ', '@'); keepempty=false) |> Tuple
        hailstone = map(x->parse(Int, x), hailstone_str)
        push!(hailstones, hailstone)
    end

    # u0 = zeros(SVector{9}) # for some reason gives NaN with SVector
    u0 = [hailstones[1]..., 0, 0, 0]
    # u0 = zeros(9)
    prob = NonlinearProblem(f, u0, hailstones[1:3])

    sol = solve(prob)
end

# function part2(io="day24.txt")
#     hailstones = NTuple{6, Int}[]
#     for line in eachline(io)
#         hailstone_str = split(line, (',', ' ', '@'); keepempty=false) |> Tuple
#         hailstone = parse.(Int, hailstone_str)
#         push!(hailstones, hailstone)
#     end

#     for (i, A) in pairs(hailstones), B in @views hailstones[i+1:end]
#         if A[4:6] == (B[4:6] .* A[4] .÷ B[4]) && (B[4:6] .* A[4] .% B[4] .== 0) |> all
#             @show A, B
#         end
#     end
# end

@time part2("""
19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
""" |> IOBuffer)

part2()

using StaticArrays, LinearAlgebra

parse_line(line) = parse_triplet.(split(line, " @ ")) |> Tuple
parse_triplet(str) = parse.(Int64, split(str, ", ")) |> Tuple
parse_input(path="day24.txt") = parse_line.(eachline(path))

# ... part 1 stuff omitted ...

# ------ Part 2 ------

using NonlinearSolve

function expand_decision_vector(dv)
    tt = @SVector [dv[1], dv[2], dv[3]]
    x_star = @SVector [dv[4], dv[5], dv[6]]
    v_star = @SVector [dv[7], dv[8], dv[9]]
    tt, x_star, v_star
end

function get_intersection_times(a, b, c)
    x_a, v_a = SVector.(a)
    x_b, v_b = SVector.(b)
    x_c, v_c = SVector.(c)
    scaling = 1
    function f(u, _)
        tt, x_star, v_star = expand_decision_vector(u)
        Δa = (x_star - scaling * x_a + tt[1] * (v_star - v_a))
        Δb = (x_star - scaling * x_b + tt[2] * (v_star - v_b))
        Δc = (x_star - scaling * x_c + tt[3] * (v_star - v_c))
        vcat(Δa, Δb, Δc)
    end
    u0 = [x_a..., v_a..., 0, 0, 0]
    @show sol = solve(NonlinearProblem(f, u0))
    display(sol)
    tt, x_star, v_star = expand_decision_vector(sol.u)
    # v_star has the best relative precision since it has the lowest magnitude
    # We believe in v⋆
    v_star = round.(Int64, v_star)
    refine_solution(a, b, c, tt ./ scaling, x_star ./ scaling, v_star)
end

L¹(x) = sum(abs.(x))

function int_error(xv, t, x_star, v_star)
    x, v = SVector.(xv)
    x - x_star + (v - v_star) * t
end

function adjust_t(xv, t0, x_star, v_star)
    t = t0
    err = int_error(xv, t, x_star, v_star) |> L¹
    while true
        err_next = int_error(xv, t + 1, x_star, v_star) |> L¹
        err_next >= err && return t
        err = err_next
        t += 1
    end
    while true
        err_prev = int_error(xv, t - 1, x_star, v_star) |> L¹
        err_prev >= err && return t
        err = err_prev
        t -= 1
    end
end

function refine_solution(a, b, c, t_abc, x_star_0, v_star)
    tt = round.(Int64, t_abc)
    x_star = round.(Int64, x_star_0)
    abc = (a, b, c)
    err = sum(L¹, int_error(xv, t, x_star, v_star) for (xv, t) ∈ zip(abc, tt))
    while err > 0
        tt = map(((xv, t),) -> adjust_t(xv, t, x_star, v_star), zip(abc, tt))
        new_err = sum(L¹, int_error(xv, t, x_star, v_star) for (xv, t) ∈ zip(abc, tt))
        new_err <= err || error("")
        err = new_err
        avg_error = sum(((xv, t),) -> int_error(xv, t, x_star, v_star), zip(abc, tt)) / 3
        x_star += round.(Int64, avg_error)
    end
    @show x_star
    sum(x_star)
end

function solve_p2(particles)
    get_intersection_times(particles[1:3]...)
end

parse_input() |> solve_p2 |> println

using LinearAlgebra

function skew(x)
    [0 -x[3] x[2]; x[3] 0 -x[1]; -x[2] x[1] 0]
end

function part2(io="day24.txt")
    hailstones = NTuple{2, SVector{3, Int}}[]
    for line in eachline(io)
        hailstone_str = split(line, (',', ' ', '@'); keepempty=false) |> Tuple
        hailstone = map(x->parse(Int, x), hailstone_str)
        push!(hailstones, (hailstone[1:3], hailstone[4:6]))
    end

    x₁, y₁ = hailstones[1]
    x₂, y₂ = hailstones[2]
    x₃, y₃ = hailstones[3]

    A₁ = hcat(skew(y₁ - y₂), skew(x₂ - x₁))
    RHS₁ = x₂ × y₂ - x₁ × y₁

    A₂ = hcat(skew(y₁ - y₃), skew(x₃ - x₁))
    RHS₂ = x₃ × y₃ - x₁ × y₁

    A = vcat(A₁, A₂)
    RHS = vcat(RHS₁, RHS₂)

    sol = A \ RHS
    mapreduce(x->round(Int, x), +, sol[1:3])
end

using Test
@test part2("""
19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
""" |> IOBuffer) == 47

@test part2() == 641619849766168