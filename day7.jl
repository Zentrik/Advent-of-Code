@enum CardType High_Card One_Pair Two_Pair Three_Kind Full_House Four_Kind Five_Kind

struct Literal{T} end
Base.:(*)(x, ::Type{Literal{T}}) where {T} = T(x)
const u8 = Literal{UInt8}

struct Hand
    x::NTuple{5, UInt8}
end
function Hand(str)
    function parse_card(card, i)::UInt8
        c = card[i]
        if c <= '9'
            UInt8(c - '0')
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
    Hand(ntuple(i->parse_card(str, i), Val(5)))
end
Base.getindex(hand::Hand, i) = hand.x[i]
function Base.isless(x::Hand, y::Hand)
    typex = type(x)
    typey = type(y)
    typex < typey || (typex == typey && isless(x.x, y.x))
end

function type(hand::Hand)
    visited = 0u8
    trio = false
    num_pairs = 0u8

    i = 1
    while i <= 5
        card = hand[i]
        count = 0u8
        for j in 1:5
            count += card == hand[j]
            visited |= UInt8(card == hand[j]) << (j-1)
        end
        i = 1+trailing_ones(visited)

        if count == 5
            return Five_Kind
        elseif count == 4
            return Four_Kind
        end
        trio |= count == 3
        num_pairs += count == 2
    end

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
    hand_bets = Vector{Tuple{Hand, UInt16}}(undef, 3*10^2)
    resize!(hand_bets, 0)

    for line in io
        hand = Hand(@inbounds @view line[1:5])
        bid = parse(UInt16, @inbounds @view line[7:end])

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


function Hand(str)
    function parse_card(card, i)::UInt8
        c = card[i]
        if c <= '9'
            UInt8(c - '0')
        elseif c == 'T'
            10
        elseif c == 'J'
            1
        elseif c == 'Q'
            12
        elseif c == 'K'
            13
        elseif c == 'A'
            14
        end
    end
    Hand(ntuple(i->parse_card(str, i), Val(5)))
end
function type(hand::Hand)
    visited = 0u8
    trio = false
    num_pairs = 0u8

    num_joker = 0
    for j in 1:5
        num_joker += (hand[j] == 1)
        visited |= UInt8(hand[j] == 1) << (j-1)
    end
    if num_joker == 5
        return Five_Kind
    end

    i = 1+trailing_ones(visited)
    while i <= 5
        card = hand[i]
        count = 0u8
        for j in 1:5
            count += card == hand[j]
            visited |= UInt8(card == hand[j]) << (j-1)
        end
        i = 1+trailing_ones(visited)

        if count + num_joker == 5
            return Five_Kind
        elseif count + num_joker == 4
            return Four_Kind
        end
        trio |= count + num_joker == 3
        num_pairs += count == 2
    end
    num_pairs += num_joker

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

using Test
@test type(Hand("QQQJA")) == Four_Kind
@test type(Hand("QJJA3")) == Three_Kind
@test type(Hand("QJA42")) == One_Pair
@test type(Hand("AJJ23")) == Three_Kind
@test type(Hand("AJJ32")) == Three_Kind

function part2(io=eachline("day7.txt"))
    hand_bets = Vector{Tuple{Hand, UInt16}}(undef, 3*10^2)
    resize!(hand_bets, 0)

    for line in io
        hand = Hand(@inbounds @view line[1:5])
        bid = parse(UInt16, @inbounds @view line[7:end])

        push!(hand_bets, (hand, bid))
    end
    sort!(hand_bets; by=first)
    sum(enumerate(hand_bets)) do e
        first(e) * last(last(e))
    end |> Int
end
part2("""32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483""" |> IOBuffer |> eachline)

part2()