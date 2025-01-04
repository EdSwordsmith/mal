include("readline.jl")

READ(str) = str
EVAL(ast, _) = ast
PRINT(exp) = exp
rep(str) = PRINT(EVAL(READ(str), ""))

for line in REPLInput(eachline())
    println(rep(line))
end
