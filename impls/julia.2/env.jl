struct Env
    outer
    data

    Env(outer=nothing, binds=[], exprs=[]) =
        let env = new(outer, Dict())
            for (i, bind) in pairs(binds)
                if bind == :&
                    env_set!(env, binds[i+1], exprs[i:end])
                    break
                else
                    env_set!(env, bind, exprs[i])
                end
            end
            env
        end
end

env_set!(env::Env, key, value) = env.data[key] = value
env_get(_, _) = missing
env_get(env::Env, key) = haskey(env.data, key) ? env.data[key] : env_get(env.outer, key)
