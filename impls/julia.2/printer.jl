module Printer
pr_str(value; args...) = string(value)
pr_str(str::String; print_readably=true) =
    if startswith(str, '\u29e')
        ":$(str[3:end])"
    elseif print_readably
        "\"$(replace(str, "\\" => "\\\\", "\n" => "\\n", "\"" => "\\\""))\""
    else
        str
    end
pr_str(::Nothing; args...) = "nil"

pr_str_seq(seq, prefix, suffix, print_readably) = "$prefix$(join((pr_str(el; print_readably) for el in seq), " "))$suffix"
pr_str(hash_map::Dict; print_readably=true) =
    let pairs = [[value for value in pair] for pair in hash_map]
        pr_str_seq(vcat(pairs...), "{", "}", print_readably)
    end
pr_str(vec::Tuple; print_readably=true) = pr_str_seq(vec, "[", "]", print_readably)
pr_str(list::Vector; print_readably=true) = pr_str_seq(list, "(", ")", print_readably)
pr_str(::Function; args...) = "#<function>"
end
