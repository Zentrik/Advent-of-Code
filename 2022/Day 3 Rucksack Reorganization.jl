score = 0

for line in eachline("Day 3 Rucksack Reorganization.txt")
    len = length(line)
    left = line[1:len ÷ 2]
    right = line[len ÷ 2 + 1:end]

    for char in left
        if char in right
            score += islowercase(char) * (Int(char) - 96) + isuppercase(char) * (Int(char) - 38)
            break
        end
    end
end

score

# Part 2

score = 0

input = split(String(read("Day 3 Rucksack Reorganization.txt")), "\n")[1:end-1]
len = length(input)

for i in 0:len ÷ 3 - 1
    for char in input[3 * i + 1]
        if char in input[3 * i + 2] && char in input[3 * i + 3]
            score += islowercase(char) * (Int(char) - 96) + isuppercase(char) * (Int(char) - 38)
            break
        end
    end
end

score