#
# Programação avançada - Extension for Julia programming Language
# Group 10
#
#
# This file contains all the auxiliary functions to be used 
# in the main.jl file
#
#

### Imports

using Parameters

### Auxiliary functions

# Auxiliary to compute_cpl
function compute_cpl_aux(class, order::Vector)

    if length(class.direct_superclasses) > 0
        for c in class.direct_superclasses
            if !(c in order)
                push!(order, c)
            end 
        end
        for c in order
            for sc in c.direct_superclasses
                if !(sc in order)
                    push!(order, sc)
                end
            end
        end
    end
    return order

end

# computes the class precedence list
function compute_cpl(class)

    order::Vector = compute_cpl_aux(class, [])
    order = append!([class], order)
    
    print("[")
    for c in order
        if c == Top
            println("<Class $(c.name)>]")
        else
            print("<Class $(c.name)>, ")
        end
    end
end

# Deals with the different slots formats
function slots(x::Any)
    if typeof(x) == Symbol
        return [x, missing]
    elseif typeof(x) == Expr
        if length(x.args) == 2
            return [x.args[1], eval(x)]
        elseif length(x.args) == 3
            if typeof(x.args[1]) == Symbol
                return [x.args[1], x.args[2].args[2], x.args[3].args[2], missing]
            else
                return [x.args[1].args[1], x.args[2].args[2], x.args[3].args[2], x.args[1].args[2]]
            end
        elseif length(x.args) == 4
            return [x.args[1].args[2], x.args[2].args[2], x.args[3].args[2], x.args[4].args[2]]
        end
    end
end

# Build the args for a generic method
function typesWithArgs(args::Vector{Symbol}, arg_types::Vector{Symbol})
    output = join([string(args[i], "::", arg_types[i]) for i in 1:length(args)], ", ")
    return output
end

# Throws error in case generic function or method is used incorrectly
function throwGenericError(func_name, args)
    error("ERROR: No applicable method for function $func_name with arguments $args")
end

# Deals with the different slots formats
function slots(x::Any)
    if typeof(x) == Symbol
        return [x, missing]
    elseif typeof(x) == Expr
        if length(x.args) == 2
            return [x.args[1], eval(x)]
        elseif length(x.args) == 3
            if typeof(x.args[1]) == Symbol
                return [x.args[1], x.args[2].args[2], x.args[3].args[2], missing]
            else
                return [x.args[1].args[1], x.args[2].args[2], x.args[3].args[2], x.args[1].args[2]]
            end
        elseif length(x.args) == 4
            return [x.args[1].args[2], x.args[2].args[2], x.args[3].args[2], x.args[4].args[2]]
        end
    end
end
