#
# Programação avançada - Extension for Julia programming Language
# Group 10
#
#

#####################
### 2.1 - Classes ###
#####################

###
### This structure is used
### for keeping the defined classes
### Key     -->    Class name
### Value   -->    Class struct
### 

classesDictionary = Dict();


struct Class 
    name
    superClasses::Vector
    slotNames::Vector
end

macro defclass(name, superClasses::Vector, slotNames::Vector)
    quote
        newClass = Class(name, superClasses, slotNames);
        # Should probably check if the name already exists
        # And maybe throw some error if it does
        classesDictionary[name] = newClass;
    end
end

#######################
### 2.2 - Instances ###
#######################

function new(className, slotVals...)
    # Should probably check if the className exists
    # And maybe throw some error if it does not

    # Loop over slot values
    for slotVal in slotVals
        # Do something
    end

end


#########################
### 2.3 - Slot Access ###
#########################


###########################################
### 2.4 - Generic Functions and Methods ###
###########################################


#######################################################
### 2.5 - Pre-defined Generic Functions and Methods ###
#######################################################


#########################
### 2.6 - MetaObjects ###
#########################


###########################
### 2.7 - Class Options ###
###########################


#################################
### 2.8 - Readers and Writers ###
#################################



print("Hello")