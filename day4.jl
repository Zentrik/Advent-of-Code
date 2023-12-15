function part1(io=eachline("day4.txt"))
    sum(io) do line
        _, winners, nums = split(line, r"[:|]")
        winning_numbers = parse.(Int, split(winners))

        matches = count(split(nums)) do number
            parse(Int, number) in winning_numbers
        end
        1 << (matches-1)
    end
end

part1(["Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53"])

part1(split("""Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11""", '\n'))

part1()

function part2(io=eachline("day4.txt"))
    no_of_cards = [1]

    sum(enumerate(io)) do (card, line)
        _, winners, nums = split(line, r"[:|]")
        winning_numbers = parse.(Int, split(winners))

        matches = count(split(nums)) do number
            parse(Int, number) in winning_numbers
        end
        sizehint!(no_of_cards, card+matches)
        while card+matches > length(no_of_cards)
            push!(no_of_cards, 1)
        end

        no_of_cards[card+1:card+matches] .+= no_of_cards[card]
        
        no_of_cards[card]
    end
end

part2(split("""Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11""", '\n'))

part2()
