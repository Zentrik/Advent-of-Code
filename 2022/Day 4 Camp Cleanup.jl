count = 0

for line in eachline("Day 4 Camp Cleanup.txt")
    xi, xf, yi, yf = parse.(Int, split(line, r"[,-]"))
    if xi:xf ⊆ yi:yf || xi:xf ⊇ yi:yf
        count += 1
    end
end

count

count = 0

for line in eachline("Day 4 Camp Cleanup.txt")
    xi, xf, yi, yf = parse.(Int, split(line, r"[,-]"))
    if (xi:xf) ∩ (yi:yf) != []
        count += 1
    end
end

count