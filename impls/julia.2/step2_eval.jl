include("readline.jl")
include("reader.jl")
include("printer.jl")

READ(str) = Reader.read_str(str)

EVAL(ast, _) = ast
EVAL(ast::Symbol, env) = haskey(env, ast) ? env[ast] : throw("$ast not found")
EVAL(ast::Vector, env) =
    let members = [EVAL(member, env) for member in ast]
        isempty(ast) ? [] : members[1](members[2:end]...)
    end
EVAL(ast::Tuple, env) = map(member -> EVAL(member, env), ast)
EVAL(ast::Dict, env) = Dict(pair[1] => EVAL(pair[2], env) for pair in ast)

PRINT(exp) = Printer.pr_str(exp)

rep(str, env) = PRINT(EVAL(READ(str), env))

repl_env = Dict(:(+) => +, :(-) => -, :(*) => *, :(/) => div)

for line in REPLInput(eachline())
    try
        println(rep(line, repl_env))
    catch error
        if error != Reader.NoValues()
            println("Error: ", error)
        end
    end
end
