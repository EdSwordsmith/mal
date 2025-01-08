module MalCore
import ..Reader
import ..Printer
import ..Types

const Sequence = Union{Vector,Tuple}
list(list::Vector) = list
list(vec::Tuple) = Any[vec...]

equal(a, b) = typeof(a) == typeof(b) && a == b
equal(a::Sequence, b::Sequence) = length(a) == length(b) && all(splat(equal), zip(a, b))

read_file(filename) = open(io -> read(io, String), filename)

cons(value, seq::Sequence) = Any[value, seq...]
concat(seqs::Sequence...) = vcat(map(list, seqs)...)

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
    :list => (args...) -> list(args),
    Symbol("list?") => arg -> arg isa Vector,
    Symbol("empty?") => isempty,
    :count => arg -> isnothing(arg) ? 0 : length(arg),
    Symbol("read-string") => Reader.read_str,
    :slurp => read_file,
    :atom => Types.MalAtom,
    Symbol("atom?") => atom -> atom isa Types.MalAtom,
    :deref => atom -> atom.value,
    :reset! => (atom, value) -> atom.value = value,
    :swap! => (atom, fn, args...) ->
        let fn = fn isa Types.MalFunction ? fn.fn : fn
            atom.value = fn(atom.value, args...)
        end,
    :concat => concat,
    :cons => cons,
    :vec => list -> tuple(list...),
    :nth => (list, index) -> list[index+1],
    :first => list -> isnothing(list) || isempty(list) ? nothing : list[1],
    :rest => seq -> isnothing(seq) ? [] : list(seq[2:end]),
    Symbol("macro?") => fn -> fn isa Types.MalFunction && fn.ismacro,
)
end
