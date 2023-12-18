# Part 1
input = String(read("Day 1 Calorie Counting.txt"))

ElfCalorieList = map(elf -> sum(parse.(Int, split(elf, "\n", keepempty=false))), split(input, "\n\n"))

# argmax(ElfCalorieList)
maximum(ElfCalorieList)

# Part 2
sum(sort(ElfCalorieList)[end-2:end])