###
### Group 10
###
### auxiliary.jl contains all the auxiliary functions used 
### in jos.jl

using Parameters

# Represents the structure of a class
struct Class
    name::Symbol
    direct_slots::Array{Symbol}
    direct_superclasses::Array{Class}
end

function topological_sort_aux(graph)
    branches::Dict = Dict()
    sources::Dict = Dict()
    toVisit::Vector{Symbol} = []
    order::Vector{Class} = []
    visited::Dict{Symbol, Bool} = Dict()
    isSource::Dict{Symbol, Bool} = Dict()

    for cclass in graph
        if cclass !== nothing
            merge!(visited, Dict(cclass.first => false))
            merge!(isSource, Dict(cclass.first => true))
        end

    end

    for cclass in graph
        for c in graph[cclass.first]
            if isSource[c.name]
                isSource[c.name] = false
            end
        end
    end

    for cclass in graph
        if isSource[cclass.first]
            merge!(sources, Dict(cclass))
            push!(order, eval(cclass.first))
        end
    end

    for cclass in graph
        if !visited[cclass.first]
            visited[cclass.first] = true
            for sclass in graph[cclass.first]
                push!(toVisit, sclass.name)
            end
            for c in toVisit
                merge!(branches, Dict(c => graph[c]))
                append!(order, topological_sort_aux(branches))
            end
        end
    end
    return order
end

# Given the inheritance graph it calculates its
# topological sort 
function topological_sort(graph)
    order = topological_sort_aux(graph)
    #append!(order, [:Object, :Top])
    return order
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