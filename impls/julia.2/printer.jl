module Printer
pr_str(value) = string(value)
pr_str(str::String; print_readably=true) =
    let processed_str = print_readably ? replace(str, "\\" => "\\\\", "\n" => "\\n", "\"" => "\\\"") : str
        startswith(str, '\u29e') ? ":$(str[3:end])" : "\"$processed_str\""
    end
pr_str(::Nothing) = "nil"

pr_str_seq(seq, prefix, suffix) = "$prefix$(join(map(pr_str, seq), " "))$suffix"
pr_str(hash_map::Dict) = let pairs = [[value for value in pair] for pair in hash_map]
    pr_str_seq(vcat(pairs...), "{", "}")
end
pr_str(vec::Tuple) = pr_str_seq(vec, "[", "]")
pr_str(list::Vector) = pr_str_seq(list, "(", ")")
end
