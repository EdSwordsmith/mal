module Types
struct MalFunction <: Function
    ast
    params
    env
    fn
    ismacro

    MalFunction(ast, params, env, fn) = new(ast, params, env, fn, false)
    MalFunction(ast, params, env, fn, ismacro) = new(ast, params, env, fn, ismacro)
end

asmacro(fn::MalFunction) =
    MalFunction(fn.ast, fn.params, fn.env, fn.fn, true)

mutable struct MalAtom
    value
end
end
