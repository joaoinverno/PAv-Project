#
# Programação avançada - Extension for Julia programming Language
# Group 10
#
#

### Imports

using Parameters

### Auxiliary functions

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

function topological_sort(graph)
    order = topological_sort_aux(graph)
    #append!(order, [:Object, :Top])
    return order
end

function compute_cpl_aux(class, order::Vector)

    if length(class.direct_superclasses) > 0
        for c in class.direct_superclasses
            if !(c in order) && c !== Object && c !== Top
                push!(order, c)
            end
        end
        for c in class.direct_superclasses
            order = compute_cpl_aux(c, order)
        end
    end
    return order

end

function compute_cpl(class)

    order::Vector = compute_cpl_aux(class, [])
    order = append!([class], order)
    order = append!(order, [Object, Top])
    
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

struct Class
    name::Symbol
    direct_slots::Array{Symbol}
    direct_superclasses::Array{Class}
end

classes = Dict()

inh_graph::Dict = Dict()

### Introspection

function class_name(c::Class)
    return c.name
end

function class_direct_slots(c::Class)
    return c.direct_slots
end

function class_slots(c::Class)
    slots::Vector{Symbol} = []
    order = compute_cpl_aux(c,[])
    order = append!([c], order)
    for class in order
        append!(slots,class.direct_slots)
    end
    return slots
end

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

create_class(:Top,[],[])
create_class(:Object,[],[Top])

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
create_class(:ComplexNumber, [:[real=2, reader=get_real, writer=set_real!],:[imag, reader=get_imag, writer=set_imag!]], [])
# Create an instance of ComplexNumber and test its class
c1 = new(ComplexNumber, imag= 3)

#test class_of function
println(class_of(c1) === ComplexNumber) #true
println(class_of(class_of(c1)) === Class) #true
println(class_of(class_of(class_of(c1))) === Class) #true
println(ComplexNumber.direct_superclasses == [Object]) #true

# Test modifying a slot of the instance
c1.real += 2
println(getproperty(c1, :real)) # 4
println(getproperty(c1, :imag)) # 3

#Testing method generation
create_gen_func(:add, [:a,:b])
create_gen_method(:add, [:a,:b], [:Int64,:Int64], "return a + b")
println(add(1,2)) #3

#Testing getter and setter method
#getter_setter(:get_real,:set_real,:ComplexNumber,:real)
get_real(c1)
set_real!(c1,5)
println(getproperty(c1, :real)) # 5
get_imag(c1)
set_imag!(c1,8)
println(getproperty(c1, :imag)) # 8

#Testing topological sorting
println(classes)
create_class(:SpecialPrinter, [], [Printer])
println(SpecialPrinter.direct_superclasses == [Printer]) #true

#Testing compute_cpl
#println(inh_graph)
#println(SpecialPrinter)
println("------------------------------")

create_class(:A, [:a,:b], [])
create_class(:B, [], [])
create_class(:C, [], [])
create_class(:D, [:d], [A, B])
create_class(:E, [], [A, C])
create_class(:F, [], [D, E])

compute_cpl(F)

println("------------------------------")
println("testing Introspection functions for class D")
println("class name: ",class_name(D))
println("class direct slots: ", class_direct_slots(D))
println("class slots: ", class_slots(D))
println("class superclasses: ", class_direct_superclasses(D))
class_cpl(D)