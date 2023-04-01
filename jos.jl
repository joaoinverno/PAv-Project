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


### Functions

# Dynamically create Classes
function create_class(struct_name::Symbol, field_names::Vector{Symbol})
    # Define the struct type dynamically using the @eval macro
    @eval mutable struct $struct_name
        $(map(field_names) do field_name
            # Define each field dynamically using the :($...) macro
            :($field_name::$Any)
        end...)
    end
end

function new(class, slotVals...)
    c = class(slotVals...)
    return c
end

create_class(:ComplexNumber, [:real, :imag])

c1 = new(ComplexNumber, 1, 2)
c1.real += 2
print(getproperty(c1, :real))
