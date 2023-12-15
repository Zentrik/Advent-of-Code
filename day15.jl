function part1(io=eachsplit(readline("day15.txt"), ','))
    sum(io) do step
        hash = 0
        for c in step
            hash += UInt8(c)
            hash *= 17
            hash %= 256
        end
        hash
    end
end

function part1_fast(io="day15.txt")
    open(io) do f
        readuntil(f, UInt8('\n'))
    end |> part1_fast
end

struct Literal{T} end
Base.:(*)(x, ::Type{Literal{T}}) where {T} = T(x)
const u8 = Literal{UInt8}
function part1_fast(ascii_str::Vector{UInt8})
    result = 0
    i = 1
    while i <= length(ascii_str)
        hash = 0u8
        c = @inbounds ascii_str[i]
        while i <= length(ascii_str) && c != ','u8
            hash += c
            hash *= 17u8
            i += 1
            c = @inbounds ascii_str[i]
        end
        result += hash

        i += 1
    end

    result
end

using Test
@test part1(eachsplit("HASH", ',')) == 52
@test part1("rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7" |> (x->eachsplit(x, ','))) == 1320
part1()


@test part1_fast("HASH" |> Vector{UInt8}) == 52
@test part1_fast(",HASH" |> Vector{UInt8}) == 52
@test part1_fast("HASH,HASH" |> Vector{UInt8}) == 104
@test part1_fast("rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7" |> Vector{UInt8}) == 1320
@test part1_fast() == 510801

using BenchmarkTools
lines = eachsplit(readline("day15.txt"), ',')
@btime part1($lines)
ascii_str = readline("day15.txt") |> Vector{UInt8}
@btime part1_fast($ascii_str)

@profview for _ in 1:10^3 part1(lines) end
@profview for _ in 1:10^3 part1_fast(ascii_str) end

using OrderedCollections
function part2(io="day15.txt")
    open(io) do f
        readuntil(f, UInt8('\n'))
    end |> part2
end
function part2(ascii_str::Vector{UInt8})
    O = OrderedDict{typeof(@inbounds @views ascii_str[2:3]), UInt8}
    boxes = Vector{O}(undef, 256)

    i = 1
    while i <= length(ascii_str)
        c = @inbounds ascii_str[i]
        start_i = i
        idx0 = 0u8
        while c ∉ ('='u8, '-'u8)
            idx0 += c
            idx0 *= 17u8

            i += 1
            c = @inbounds ascii_str[i]
        end
        if @inbounds !isassigned(boxes, idx0+1)
            boxes[idx0+1] = O()
        end

        val = @inbounds ascii_str[i+1] - '0'u8

        label = @inbounds @views ascii_str[start_i:i-1]
        if c == '='u8
            boxes[idx0+1][label] = val
            i += 2
        elseif c == '-'u8
            delete!(boxes[idx0+1], label)
            i += 1
        end

        i += 1
    end

    result = 0
    for box_num in eachindex(boxes)
        !isassigned(boxes, box_num) && continue
        isempty(boxes[box_num]) && continue
        result += box_num * sum(prod, enumerate(values(boxes[box_num])))
    end
    result
end

# function part2(ascii_str::Vector{UInt8})
#     O = OrderedDict{typeof(@inbounds @views ascii_str[2:3]), UInt8}
#     boxes = [O() for _ in  1:256]

#     i = 1
#     while i <= length(ascii_str)
#         c = @inbounds ascii_str[i]
#         start_i = i
#         idx = 0u8
#         while c ∉ ('='u8, '-'u8)
#             idx += c
#             idx *= 17u8

#             i += 1
#             c = @inbounds ascii_str[i]
#         end

#         val = @inbounds ascii_str[i+1] - '0'u8
#         label = @inbounds @views ascii_str[start_i:i-1]

#         if c == '='u8
#             boxes[idx+1][label] = val
#             i += 2
#         elseif c == '-'u8
#             delete!(boxes[idx+1], label)
#             i += 1
#         end

#         i += 1
#     end

#     sum(pairs(boxes)) do (box_num, box)
#         if !isempty(box)
#             box_num * sum(prod, enumerate(values(box)))
#         else
#             0
#         end
#     end
# end

using Test
@test 145 == part2("rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7" |> Vector{UInt8})
@test part2() == 212763

ascii_str = readline("day15.txt") |> Vector{UInt8}
@btime part2($ascii_str)
@profview for _ in 1:10^3 part2(ascii_str) end
