include("readline.jl")
include("types.jl")
include("reader.jl")
include("printer.jl")
include("env.jl")

READ(str) = Reader.read_str(str)

EVAL(ast, env) =
    let debug_eval = env_get(env, Symbol("DEBUG-EVAL"))
        if !ismissing(debug_eval) && !isnothing(debug_eval) && debug_eval !== false
            println("EVAL: ", PRINT(ast))
        end

        eval_ast(ast, env)
    end

eval_ast(ast, _) = ast
eval_ast(ast::Symbol, env) =
    let value = env_get(env, ast)
        ismissing(value) ? throw("$ast not found") : value
    end
eval_ast(ast::Vector, env) =
    if isempty(ast)
        []
    elseif ast[1] == :def!
        env_set!(env, ast[2], EVAL(ast[3], env))
    elseif ast[1] == Symbol("let*")
        env = Env(env)
        for i in 1:2:length(ast[2])
            env_set!(env, ast[2][i], EVAL(ast[2][i+1], env))
        end
        EVAL(ast[3], env)
    else
        let members = [EVAL(member, env) for member in ast]
            members[1](members[2:end]...)
        end
    end
eval_ast(ast::Tuple, env) = map(member -> EVAL(member, env), ast)
eval_ast(ast::Dict, env) = Dict(pair[1] => EVAL(pair[2], env) for pair in ast)

PRINT(exp) = Printer.pr_str(exp)

rep(str, env) = PRINT(EVAL(READ(str), env))

repl_env = Env()
env_set!(repl_env, :(+), +)
env_set!(repl_env, :(-), -)
env_set!(repl_env, :(*), *)
env_set!(repl_env, :(/), div)

for line in REPLInput(eachline())
    try
        println(rep(line, repl_env))
    catch error
        if error != Reader.NoValues()
            println("Error: ", error)
        end
    end
end
