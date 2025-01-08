include("readline.jl")
include("types.jl")
include("reader.jl")
include("printer.jl")
include("env.jl")
include("core.jl")

READ(str) = Reader.read_str(str)

quasiquote(ast) = ast
quasiquote(ast::Symbol) = [:quote, ast]
quasiquote(ast::Dict) = [:quote, ast]
quasiquote(ast::Tuple) =
    let
        result = []
        for elt in Iterators.reverse(ast)
            if elt isa Vector && !isempty(elt) && elt[1] == Symbol("splice-unquote")
                result = [:concat, elt[2], result]
            else
                result = [:cons, quasiquote(elt), result]
            end
        end
        [:vec, result]
    end
quasiquote(ast::Vector) =
    if !isempty(ast) && ast[1] == :unquote
        ast[2]
    else
        result = []
        for elt in Iterators.reverse(ast)
            if elt isa Vector && !isempty(elt) && elt[1] == Symbol("splice-unquote")
                result = [:concat, elt[2], result]
            else
                result = [:cons, quasiquote(elt), result]
            end
        end
        result
    end

EVAL(ast, env) =
    while true
        debug_eval = env_get(env, Symbol("DEBUG-EVAL"))
        if !ismissing(debug_eval) && !isnothing(debug_eval) && debug_eval !== false
            println("EVAL: ", PRINT(ast))
        end

        if ast isa Symbol
            value = env_get(env, ast)
            return ismissing(value) ? throw("$ast not found") : value
        elseif ast isa Tuple
            return map(form -> EVAL(form, env), ast)
        elseif ast isa Dict
            return Dict(key => EVAL(value, env) for (key, value) in ast)
        elseif ast isa Vector && length(ast) > 0
            if ast[1] == :def!
                return env_set!(env, ast[2], EVAL(ast[3], env))
            elseif ast[1] == Symbol("let*")
                env = Env(env)
                for i in 1:2:length(ast[2])
                    env_set!(env, ast[2][i], EVAL(ast[2][i+1], env))
                end
                ast = ast[3]
            elseif ast[1] == :do
                for form in ast[2:end-1]
                    EVAL(form, env)
                end
                ast = ast[end]
            elseif ast[1] == :if && length(ast) == 4
                cond = EVAL(ast[2], env)
                if isnothing(cond) || cond === false
                    ast = ast[4]
                else
                    ast = ast[3]
                end
            elseif ast[1] == :if && length(ast) == 3
                cond = EVAL(ast[2], env)
                if isnothing(cond) || cond === false
                    return nothing
                else
                    ast = ast[3]
                end
            elseif ast[1] == Symbol("fn*")
                fn = (args...) -> EVAL(ast[3], Env(env, ast[2], [args...]))
                return Types.MalFunction(ast[3], ast[2], env, fn)
            elseif ast[1] == :quote
                return ast[2]
            elseif ast[1] == :quasiquote
                ast = quasiquote(ast[2])
            else
                members = [EVAL(member, env) for member in ast]
                if members[1] isa Types.MalFunction
                    env = Env(members[1].env, members[1].params, members[2:end])
                    ast = members[1].ast
                else
                    return members[1](members[2:end]...)
                end
            end
        else
            return ast
        end
    end

PRINT(exp) = Printer.pr_str(exp)

rep(str, env) = PRINT(EVAL(READ(str), env))

const repl_env = Env()
for binding in MalCore.ns
    env_set!(repl_env, binding[1], binding[2])
end

env_set!(repl_env, :eval, ast -> EVAL(ast, repl_env))
env_set!(repl_env, Symbol("*ARGV*"), ARGS[2:end])

rep("(def! not (fn* (a) (if a false true)))", repl_env)
rep("(def! load-file (fn* (f) (eval (read-string (str \"(do \" (slurp f) \"\\nnil)\")))))", repl_env)

if isempty(ARGS)
    for line in REPLInput(eachline())
        try
            println(rep(line, repl_env))
        catch error
            if error != Reader.NoValues()
                println("Error: ", error)
            end
        end
    end
else
    rep("(load-file \"$(ARGS[1])\")", repl_env)
end
