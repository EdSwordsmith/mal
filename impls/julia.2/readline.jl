struct REPLInput
    iterator
end

function Base.iterate(itr::REPLInput, state=nothing)
    print("user> ")
    iterate(itr.iterator, state)
end
