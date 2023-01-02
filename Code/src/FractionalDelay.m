classdef FractionalDelay < handle
    %Abstract class to define common parameters all sub-subclasses must
    %adhere to
    
    properties(GetAccess = public)
        fractionalDelay %fractional delay amount (0 <= x <= 1)
        integerDelay
    end
       
    methods(Abstract)
        setFractionalDelay(obj, newValue)
    end
end