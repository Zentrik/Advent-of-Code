# struct Literal{T} end
# Base.:(*)(x, ::Type{Literal{T}}) where {T} = T(x)
# const u8 = Literal{UInt8}

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

function part1_fast(ascii_str::Vector{UInt8})
    result = 0
    i = 1
    while i <= length(ascii_str)
        hash = 0
        while i <= length(ascii_str) && @inbounds ascii_str[i] != UInt8(',')
            @inbounds hash += ascii_str[i]
            hash *= 17
            hash &= 255

            i += 1
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
part1_fast()

using BenchmarkTools
lines = eachsplit(readline("day15.txt"), ',')
@btime part1($lines)
ascii_str = readline("day15.txt") |> Vector{UInt8}
@btime part1_fast($ascii_str)

@profview for _ in 1:10^3 part1(lines) end
@profview for _ in 1:10^3 part1_fast(ascii_str) end