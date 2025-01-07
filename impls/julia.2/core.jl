module MalCore
include("printer.jl")

equal(a, b) = typeof(a) == typeof(b) && a == b
equal(a::Vector, b::Vector) = length(a) == length(b) && all(splat(equal), zip(a, b))
equal(a::Vector, b::Tuple) = equal(a, [b...])
equal(a::Tuple, b::Vector) = equal([a...], b)

const ns = Dict(
    :(=) => (head, tail...) -> all(value -> equal(head, value), tail),
    :prn => (args...) -> println(join((Printer.pr_str(arg) for arg in args), " ")),
    Symbol("pr-str") => (args...) -> join((Printer.pr_str(arg) for arg in args), " "),
    :str => (args...) -> join((Printer.pr_str(arg, print_readably=false) for arg in args), ""),
    :println => (args...) -> println(join((Printer.pr_str(arg, print_readably=false) for arg in args), " ")),
    :(<) => <,
    :(<=) => <=,
    :(>) => >,
    :(>=) => >=,
    :(+) => +,
    :(-) => -,
    :(*) => *,
    :(/) => (args...) -> reduce(div, args),
    :list => (args...) -> [args...],
    Symbol("list?") => arg -> arg isa Vector,
    Symbol("empty?") => isempty,
    :count => arg -> isnothing(arg) ? 0 : length(arg),
)
end
