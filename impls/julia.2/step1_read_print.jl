include("readline.jl")
include("types.jl")
include("reader.jl")
include("printer.jl")

READ(str) = Reader.read_str(str)
EVAL(ast, _) = ast
PRINT(exp) = Printer.pr_str(exp)
rep(str) = PRINT(EVAL(READ(str), ""))

for line in REPLInput(eachline())
    try
        println(rep(line))
    catch error
        if error != Reader.NoValues()
            println("Error: ", error)
        end
    end
end
