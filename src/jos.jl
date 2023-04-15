###
### Group 10
###
### main file containing all the macros and main functions
###

### Imports

include("auxiliary.jl")

### Macros

macro defclass(name, superClasses, slotNames)
    quote
        print("Hello");
    end
end


macro defgeneric(name, args...)
    quote
        print("Hello again");
    end
end

macro defmethod(name, args...)
    quote
        print("Hello... again");
    end
end

### Variables

classes = Dict()

inh_graph::Dict = Dict()

### Main functions

# Dynamically create Classes - With field names
function create_class(class_name::Symbol, field_slots::Vector, superclasses::Vector)

    new_class_name = Symbol(class_name,"Class")
    direct_slots = []
    isempty(superclasses) && class_name != :Top ? direct_super = [Object] : direct_super = superclasses
    if isempty(field_slots)
        @eval mutable struct $new_class_name end

        #adds class to Dict
        classes[class_name] = eval(new_class_name)

        #creates global variable
        aux = Class(class_name,direct_slots,direct_super)
        globalvar = Symbol("$(class_name)")
        @eval global $globalvar = $aux

    else
        field_decls = map(field_slots) do field
            slot = slots(:($field))
            field_name = slot[1]
            append!(direct_slots,[slot[1]])
            if length(slot) == 2 && ismissing(slot[2])
                :($field_name::$Any)
            elseif length(slot) == 2 && !ismissing(slot[2])
                :($field_name::$Any = $(slot[2]))
            elseif length(slot) == 4 && !ismissing(slot[4])
                :($field_name::$Any = $(slot[4]))
            elseif length(slot) == 4 && ismissing(slot[4])
                :($field_name::$Any)
            end
        end


        @eval @with_kw mutable struct $new_class_name
            $(field_decls...)
        end

        #adds class to Dict
        classes[class_name] = eval(new_class_name)

        #creates global variable
        aux = Class(class_name,direct_slots,direct_super)
        globalvar = Symbol("$(class_name)")
        @eval global $globalvar = $aux

        #create reader and writer
        for field in field_slots
            slot = slots(field)
            if length(slot) == 4
                getter_setter(slot[2],slot[3],class_name,slot[1])
            end
        end

    end

    # set superClasses in inheritance graph
    merge!(inh_graph, Dict(class_name => direct_super))
end

# Create getters and setters for a class
function getter_setter(name_getter::Symbol,name_setter::Symbol,class_name::Symbol,var_name::Symbol)
    create_gen_method(name_getter, [:o], [class_name], "return o.$var_name")
    create_gen_method(name_setter, [:o, :v], [class_name, :Any], "o.$var_name = v")
end

# Create instances from existing classes
function new(class_name::Class; kwargs...)
    c = classes[class_name.name]
    return c(; kwargs...)
end

# Create generic functions
function create_gen_func(func_name::Symbol, args::Vector{Symbol})
    arg_string = join(args, ", ")
    func_string = "function $func_name($arg_string)\n   throwGenericError($func_name, $args)\nend"
    eval(Meta.parse(func_string))
end

# Create generic methods
function create_gen_method(func_name::Symbol, args::Vector{Symbol}, arg_types::Vector{Symbol}, func_body)
    # Q: Does the generic function exist
    if !isdefined(Main, func_name)
        #A: No, we have to define it
        arg_string = join(args, ", ")
        func_string = "function $func_name($arg_string)\n   throwGenericError($func_name, $args)\nend"
        eval(Meta.parse(func_string))
    end

    replace!(x -> haskey(classes,x) ? Symbol(x,"Class") : x, arg_types)
    args_with_types = typesWithArgs(args, arg_types)
    func_string = "function $func_name($args_with_types)\n  $func_body\nend"
    eval(Meta.parse(func_string))
end

### Gets class name of instance c
function class_of(c)
    if c == Class
        return Class
    elseif typeof(c) === Class
        return typeof(c)
    else
        aux = chop(string(Symbol(typeof(c))),tail=5)
        return eval(Symbol(aux))
    end
end