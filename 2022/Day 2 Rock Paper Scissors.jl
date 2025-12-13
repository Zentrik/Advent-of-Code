shapeScore = Dict('X' => 1, 'Y' => 2, 'Z' => 3)
outcomeScore = Dict(['A', 'X'] => 3, ['A', 'Y'] => 6, ['A', 'Z'] => 0,
                    ['B', 'X'] => 0, ['B', 'Y'] => 3, ['B', 'Z'] => 6,
                    ['C', 'X'] => 6, ['C', 'Y'] => 0, ['C', 'Z'] => 3,)

score = 0
for line in eachline("Day 2 Rock Paper Scissors.txt")
    opponent = line[1]
    you = line[3]

    score += outcomeScore[[opponent, you]] + shapeScore[you]
end

score

# Part 2

whichToPlay = Dict(['A', 'X'] => 'Z', ['A', 'Y'] => 'X', ['A', 'Z'] => 'Y',
                   ['B', 'X'] => 'X', ['B', 'Y'] => 'Y', ['B', 'Z'] => 'Z',
                   ['C', 'X'] => 'Y', ['C', 'Y'] => 'Z', ['C', 'Z'] => 'X',)

score = 0
for line in eachline("Day 2 Rock Paper Scissors.txt")
    opponent = line[1]
    youWant = line[3]
    you = whichToPlay[[opponent, youWant]]

    score += outcomeScore[[opponent, you]] + shapeScore[you]
end

score