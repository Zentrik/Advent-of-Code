@enum Type High_Card One_Pair Two_Pair Three_Kind Full_House Four_Kind Five_Kind

struct Hand
    x::NTuple{5, Int8}
end
function Hand(str)
    function parse_card(i)
        c = str[i]
        if c <= '9'
            c - '0'
        elseif c == 'T'
            10
        elseif c == 'J'
            11
        elseif c == 'Q'
            12
        elseif c == 'K'
            13
        elseif c == 'A'
            14
        end
    end
    Hand(NTuple{5, Int8}(parse_card(i) for i in 1:5))
end
Base.getindex(hand::Hand, i) = hand.x[i]
function Base.isless(x::Hand, y::Hand)
    isless(type(x), type(y)) || (isequal(type(x), type(y)) && isless(x.x, y.x))
end

# function type_slow(hand::Hand)
#     d = Dict()
#     for a in hand.x
#         d[a] = 1 + get!(d, a, 0)
#     end
#     if any(isequal(5) ∘ last, d)
#         return Five_Kind
#     elseif any(isequal(4) ∘ last, d)
#         return Four_Kind
#     elseif any(isequal(3) ∘ last, d) && any(isequal(2) ∘ last, d)
#         return Full_House
#     elseif any(isequal(3) ∘ last, d)
#         return Three_Kind
#     elseif count(isequal(2) ∘ last, d) == 2
#         return Two_Pair
#     elseif count(isequal(2) ∘ last, d) == 1
#         return One_Pair
#     else
#         return High_Card
#     end
# end

function type(hand::Hand)
    visited = falses(5)
    trio = false
    num_pairs = Int8(0)

    i = 1
    while !isnothing(i) && i <= length(visited)
        card = hand[i]
        @assert(!visited[i])
        count = 0
        for j in i:length(visited)
            count += card == hand[j]
            visited[j] |= card == hand[j]
        end
        i = findnext(!, visited, i+1)

        if count == 5
            return Five_Kind
        elseif count == 4
            return Four_Kind
        elseif count == 3
            trio = true
        elseif count == 2
            num_pairs += 1
        end
    end
    @assert(all(visited))

    if trio & num_pairs == 1
        return Full_House
    elseif trio
        return Three_Kind
    elseif num_pairs == 2
        return Two_Pair
    elseif num_pairs == 1
        return One_Pair
    else
        return High_Card
    end
end

function part1(io=eachline("day7.txt"))
    hand_bets = Vector{Tuple{Hand, Int}}(undef, 10^2)
    resize!(hand_bets, 0)

    for line in io
        hand = Hand(@inbounds @view line[1:5])
        bid = parse(Int, @inbounds @view line[7:end])

        push!(hand_bets, (hand, bid))
    end
    sort!(hand_bets; by=first)
    sum(enumerate(hand_bets)) do e
        first(e) * last(last(e))
    end |> Int
end

part1("""32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483""" |> IOBuffer |> eachline)

part1()

# function test_type(io=eachline("day7.txt"))
#     for line in io
#         hand = Hand(@inbounds @view line[1:5])
#         if type(hand) != type_slow(hand)
#             @show hand
#             @show type(hand)
#             @show type_slow(hand)
#         end
#     end
# end
# test_type()