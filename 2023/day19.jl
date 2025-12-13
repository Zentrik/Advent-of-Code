using MLStyle

module Category
    @enum CategoryEnum::Int8 x=1 m=2 a=3 s=4
end
function CategoryEnum(s::AbstractString)
    @match s begin
        "x" => Category.x
        "m" => Category.m
        "a" => Category.a
        "s" => Category.s
    end
end

struct Part
    x::Int
    m::Int
    a::Int
    s::Int
end
Base.getindex(p::Part, c::Category.CategoryEnum) = getfield(p, Int(c))

@enum RuleType Less Greater None
struct Rule
    type::RuleType
    category::Category.CategoryEnum
    value::Int
    destination::String
end

function parse_part1(_io)
    io = eachline(_io)
    workflows = Dict{String, Vector{Rule}}()
    for line in io
        if isempty(line)
            break
        end

        rule_name, rules... = split(line, r"[,{}]"; keepempty=false)
        workflows[rule_name] = map(rules) do rule_str
            if ':' in rule_str
                category, value, destination = split(rule_str, r"[><:]"; keepempty=false)
                type = '>' in rule_str ? Greater : Less
                Rule(type, CategoryEnum(category), parse(Int, value), destination)
            else
                Rule(None, Category.x, 0, rule_str)
            end
        end
    end

    parts = Vector{Part}()
    for line in io
        push!(parts, Part(parse.(Int, split(line, !isdigit; keepempty=false))...))
    end

    workflows, parts
end

function part1(io="day19.txt")
    workflows, parts = parse_part1(io)

    sum(parts) do part
        current_workflow = "in"
        while current_workflow ∉ ("A", "R")
            for rule in workflows[current_workflow]
                if rule.type == None || rule.type == (part[rule.category] > rule.value ? Greater : Less)
                    current_workflow = rule.destination
                    break
                end
            end
        end
        if current_workflow == "A"
            sum(i->getfield(part, i), 1:4)
        else
            0
        end
    end
end

using Test
@test part1("""px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}""" |> IOBuffer) == 19114

@test part1() == 432434

struct IntervalPart
    x::Vector{UnitRange{Int}}
    m::Vector{UnitRange{Int}}
    a::Vector{UnitRange{Int}}
    s::Vector{UnitRange{Int}}
end
Base.getindex(p::IntervalPart, c::Category.CategoryEnum) = getfield(p, Int(c))
Base.copy(p::IntervalPart) = IntervalPart(copy(p.x), copy(p.m), copy(p.a), copy(p.s))
# function setindex(p::IntervalPart, v, c::Category.CategoryEnum)
#     p2 = Ref(p)
#     ptr = Base.unsafe_convert(Ptr{IntervalPart}, p2)
#     GC.@preserve p2 Base.unsafe_store!(Ptr{UnitRange{Int}}(ptr), v, Int(c))
#     p2[]
# end

function part2(io="day19.txt")
    workflows, _ = parse_part1(io)
    dfs(IntervalPart([1:4000], [1:4000], [1:4000], [1:4000]), workflows, "in")
end

function dfs(part, workflows, current_workflow)
    current_workflow == "A" && return prod(i->sum(length, getfield(part, i)), 1:4)
    current_workflow == "R" && return 0

    sum(workflows[current_workflow]) do rule
        rule.type == None && return dfs(part, workflows, rule.destination)

        ax, ay = if rule.type == Less
            1, rule.value-1
        elseif rule.type == Greater
            rule.value+1, 4000
        end

        new_part = copy(part)
        new_part_empty = true
        empty!(new_part[rule.category])
        n = part[rule.category] |> length
        for _ in 1:n
            interval = popfirst!(part[rule.category])
            x, y = first(interval), last(interval)
            if x < ax
                push!(part[rule.category], x:ax-1)
            end
            if y > ay
                push!(part[rule.category], ay+1:y)
            end
            if ax <= y || ay >= x
                push!(new_part[rule.category], max(x, ax):min(y, ay))
                new_part_empty = false
            end
        end
        new_part_empty && return 0

        dfs(new_part, workflows, rule.destination)
    end
end

@test part2("""px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}""" |> IOBuffer) == 167409079868000

@test part2() == 132557544578569

part2("day19-hard.txt")
231344100000000