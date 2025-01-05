module Reader
struct NoValues end

const tokens_regex = r"[\s,]*(~@|[\[\]{}()'`~^@]|\"(?:\\.|[^\\\"])*\"?|;.*|[^\s\[\]{}('\"`,;)]*)"
should_ignore(token) = isempty(token) || token[1] == ';'
tokenize(str) = collect(filter(!should_ignore, map(match -> match.captures[1], eachmatch(tokens_regex, str))))

next(itr) = isnothing(peek(itr)) ? nothing : first(iterate(itr))

read_str(str) =
    let tokens = tokenize(str)
        isempty(tokens) ? throw(NoValues()) : read_form(Iterators.Stateful(tokens))
    end

function read_form(state)
    token = peek(state)
    isnothing(token) && return nothing

    if token == "("
        read_list(state)
    elseif token == "["
        tuple(read_list(state, end_token="]")...)
    elseif token == "{"
        read_hash_map(state)
    elseif token == "'"
        next(state)
        [:quote, read_form(state)]
    elseif token == "~"
        next(state)
        [:unquote, read_form(state)]
    elseif token == "`"
        next(state)
        [:quasiquote, read_form(state)]
    elseif token == "~@"
        next(state)
        [Symbol("splice-unquote"), read_form(state)]
    elseif token == "@"
        next(state)
        [:deref, read_form(state)]
    elseif token == "^"
        next(state)
        meta = read_form(state)
        obj = read_form(state)
        [Symbol("with-meta"), obj, meta]
    else
        read_atom(state)
    end
end

function read_hash_map(state)
    sequence = read_list(state, end_token="}")
    map = Dict()

    for pair in Iterators.partition(sequence, 2)
        length(pair) != 2 && throw("temp")
        map[pair[1]] = pair[2]
    end

    map
end

function read_list(state; end_token=")")
    next(state)
    list = []
    while !isempty(state) && peek(state) != end_token
        push!(list, read_form(state))
    end
    next(state) != end_token && throw("unbalanced")
    list
end

function read_atom(state)
    token = next(state)

    int = tryparse(Int, token)
    isnothing(int) || return int

    bool = tryparse(Bool, token)
    isnothing(bool) || return bool

    token[1] == '"' && return parse_string(token)

    token == "nil" && return nothing

    token[1] == ':' && return "\u29e$(token[2:end])"

    Symbol(token)
end

function parse_string(token)
    backslash = false
    str = ""

    for char in token[2:end]
        if backslash && char == 'n'
            str *= '\n'
            backslash = false
        elseif backslash
            str *= char
            backslash = false
        elseif char == '\\'
            backslash = true
        elseif char == '"'
            return str
        else
            str *= char
        end
    end

    throw("unbalanced")
end
end
