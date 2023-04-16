#
# Programação avançada - Extension for Julia programming Language
# Group 10
#
#
# This file contains all the main functions to be used 
# in the jos.jl file
#
#

include("auxiliary.jl") 

### Global structures

# Represents a class
struct Class
    name::Symbol
    direct_slots::Array{Symbol}
    direct_superclasses::Array{Class}
end

# Dictionary to save all created classes
classes = Dict()

### Main functions

# returns the name of a class
function class_name(c::Class)
    return c.name
end

# returns the class slots
function class_direct_slots(c::Class)
    return c.direct_slots
end

# returns all slots, including inherited
function class_slots(c::Class)
    slots::Vector{Symbol} = []
    order = compute_cpl_aux(c,[])
    order = append!([c], order)
    for class in order
        append!(slots,class.direct_slots)
    end
    return slots
end

# returns the superclasses of a given class
function class_direct_superclasses(c::Class)
    super::Vector{String} = []
    for class in c.direct_superclasses
        aux = "<Class $(class.name)>"
        append!(super,[aux])
    end

    return super
end

function class_cpl(c::Class)
    compute_cpl(c)
end

# Dynamically create Classes - With field names
function create_class(class_name::Symbol, field_slots::Vector, superclasses::Vector)

    new_class_name = Symbol(class_name,"Class")
    direct_slots = []
    isempty(superclasses) && class_name != :Top ? direct_super = [Object] : direct_super = superclasses
    #Q: Does the class not contain any Fields?
    if isempty(field_slots)
        #A: No, the class has no fields
        @eval mutable struct $new_class_name end

        #adds class to Dict
        classes[class_name] = eval(new_class_name)

        #creates global variable
        aux = Class(class_name,direct_slots,direct_super)
        globalvar = Symbol("$(class_name)")
        @eval global $globalvar = $aux

    else
        #A: Yes, we have to assign the fields to the struct
        field_decls = map(field_slots) do field
            slot = slots(:($field))
            field_name = slot[1]
            append!(direct_slots,[slot[1]])
            if length(slot) == 2
                :($field_name::$Any = $(slot[2]))
            elseif length(slot) == 4 
                :($field_name::$Any = $(slot[4]))
            end
        end

        # Creating the struct
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
end

# Create readers and writters for a given class
function getter_setter(name_getter::Symbol,name_setter::Symbol,class_name::Symbol,var_name::Symbol)
    create_gen_method(name_getter, [:o], [class_name], "return o.$var_name")
    create_gen_method(name_setter, [:o, :v], [class_name, :Any], "o.$var_name = v")
end

# Create instances from existing classes
function new(class_name::Class; kwargs...)
    c = classes[class_name.name]
    a = c(; kwargs...)
    print_object(a,IO)
    return a
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

# Top class
create_class(:Top,[],[])
# Object class
create_class(:Object,[],[Top])
# Print_object method used in the new function
create_gen_method(:print_object, [:obj, :io], [:Any, :Any], "println(\"<\$(class_name(class_of(obj))) \$(string(objectid(obj), base=62))>\")")