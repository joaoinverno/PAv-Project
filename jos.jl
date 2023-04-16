#
# Programação avançada - Extension for Julia programming Language
# Group 10
#
#
# This file contains all the macros to be used 
#
#

include("main.jl") 

### Macros

# Macro for class creation
macro defclass(x...)

    name::Symbol = x[1]
    superclasses::Vector = []
    slots::Vector = x[3].args

    superclasses = []

    for c in x[2].args
        push!(superclasses, eval(c))
    end

    return create_class(name, slots, superclasses)

end

# Macro for generic functions
macro defgeneric(x)

    name::Symbol = x.args[1]
    args::Vector{Symbol} = []

    for a in 2:length(x.args)
        push!(args, x.args[a])
    end

    return create_gen_func(name, args)

end

# Macro for generic methods
macro defmethod(x)

    name::Symbol = x.args[1].args[1]
    args::Vector{Symbol} = []
    types::Vector{Symbol} = []
    body = x.args[2].args[2]

    for a in 2:length(x.args[1].args)
        if typeof(x.args[1].args[a]) == Expr
            push!(args, x.args[1].args[a].args[1])
            push!(types, x.args[1].args[a].args[2])
        else
            push!(args, x.args[1].args[a])
            push!(types, :Top)
        end
    end

    return create_gen_method(name, args, types, body)

end
