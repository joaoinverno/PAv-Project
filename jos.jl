#
# Programação avançada - Extension for Julia programming Language
# Group 10
#
#


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

abstract type Class end

# Dynamically create Classes
function create_class(struct_name::Symbol, field_names::Vector{Symbol})
    @eval mutable struct $struct_name <: Class
        $(map(field_names) do field_name
            :($field_name::$Any)
        end...)
    end
end

function new(class, slotVals...)
    c = class(slotVals...)
    return c
end

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

# Define the ComplexNumber class
create_class(:ComplexNumber, [:real, :imag])

# Create an instance of ComplexNumber and test its class
c1 = new(ComplexNumber, 1, 2)


# Test modifying a slot of the instance
c1.real += 2
println(getproperty(c1, :real)) # 3


println(class_of(c1) === ComplexNumber) # true
class_of(class_of(c1)) === Class
class_of(class_of(class_of(c1))) === Class

# Deals witht the different slots formats
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

slots(:foo)
slots(:(foo=123))
slots(:[foo=123, reader=get_foo, writer=set_foo!])
slots(:[friend, reader=get_friend, writer=set_friend!])

