struct Env
    outer
    data

    Env() = new(nothing, Dict())
    Env(outer) = new(outer, Dict())
end

env_set!(env::Env, key, value) = env.data[key] = value
env_get(_, _) = missing
env_get(env::Env, key) = haskey(env.data, key) ? env.data[key] : env_get(env.outer, key)
