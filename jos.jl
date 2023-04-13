#
# Programação avançada - Extension for Julia programming Language
# Group 10
#
#

### Imports

using Parameters

### Auxiliary functions

function topological_sort(graph)
    
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
        return [x]
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


### Types

abstract type Class end

inh_graph = []

### Main functions

# Dynamically create Classes - With field names
function create_class(class_name::Symbol, field_slots::Vector, superclasses::Vector)
    if isempty(field_slots)
        @eval mutable struct $class_name <: Class end
    else
        field_decls = map(field_slots) do field
            slot = slots(:($field))
            field_name = slot[1]
            if length(slot) == 1
                :($field_name::$Any)
            elseif length(slot) == 2
                :($field_name::$Any = $(slot[2]))
            elseif length(slot) == 4 && !ismissing(slot[4])
                :($field_name::$Any = $(slot[4]))
            elseif length(slot) == 4 && ismissing(slot[4])
                :($field_name::$Any)
            end
        end


        @eval @with_kw mutable struct $class_name <: Class
            $(field_decls...)
        end

        for field in field_slots
            slot = slots(field)
            if length(slot) == 4
                getter_setter(slot[2],slot[3],class_name,slot[1])
            end
        end

    end
    # set superClasses in inheritance graph
    append!(inh_graph, Dict(class_name => superclasses))
end

function getter_setter(name_getter::Symbol,name_setter::Symbol,class_name::Symbol,var_name::Symbol)
    create_gen_method(name_getter, [:o], [class_name], "return o.$var_name")
    create_gen_method(name_setter, [:o, :v], [class_name, :Any], "o.$var_name = v")
end

# Create instances from existing classes
function new(class::Type{T}; kwargs...) where {T}
    c = class(; kwargs...)
    return c
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
    args_with_types = typesWithArgs(args, arg_types)
    func_string = "function $func_name($args_with_types)\n  $func_body\nend"
    eval(Meta.parse(func_string))
end

### Gets class name of instance c
function class_of(c)
    if c == Class
        return Class
    else 
        t = typeof(c)
        super_type = supertype(t) 
        if super_type == Class       
            return t
        else
            return supertype(c)
        end
    end
end

### Playground

create_class(:Line, [:from, :to], [])

create_class(:Circle, [:center, :radius], [])

create_class(:Screen, [], [])

create_class(:Printer, [], [])

create_gen_func(:draw, [:shape, :device])

create_gen_method(:draw, [:shape, :device], [:Line, :Screen], "println(\"Drawing a Line on Screen\")")

create_gen_method(:draw, [:shape, :device], [:Circle, :Screen], "println(\"Drawing a Circle on Screen\")")

create_gen_method(:draw, [:shape, :device], [:Line, :Printer], "println(\"Drawing a Line on Printer\")")

create_gen_method(:draw, [:shape, :device], [:Circle, :Printer], "println(\"Drawing a Circle on Printer\")")

let devices = [new(Screen), new(Printer)],
    shapes = [new(Line, from = 1, to = 2), new(Circle, center=1, radius=2)]
    for device in devices
        for shape in shapes
            draw(shape, device)
        end
    end
end


slots(:foo)
slots(:(foo=123))
slots(:[foo=123, reader=get_foo, writer=set_foo!])
slots(:[friend, reader=get_friend, writer=set_friend!])

# Define the ComplexNumber class
create_class(:ComplexNumber, [:[real=2, reader=get_real, writer=set_real!],:[imag, reader=get_imag, writer=set_imag!]])
println(fieldnames(ComplexNumber))
# Create an instance of ComplexNumber and test its class
c1 = new(ComplexNumber, imag= 3)
# Test modifying a slot of the instance
c1.real += 2
println(getproperty(c1, :real)) # 4
println(getproperty(c1, :imag)) # 3

#Testing method generation
create_gen_func(:add, [:a,:b])
create_gen_method(:add, [:a,:b], [:Int64,:Int64], "return a + b")
println(add(1,2))

#Testing getter and setter method
#getter_setter(:get_real,:set_real,:ComplexNumber,:real)
get_real(c1)
set_real!(c1,5)
println(getproperty(c1, :real)) # 5
get_imag(c1)
set_imag!(c1,8)
println(getproperty(c1, :imag)) # 8
