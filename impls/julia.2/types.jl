module Types
struct MalFunction <: Function
    ast
    params
    env
    fn
end

mutable struct MalAtom
    value
end
end
