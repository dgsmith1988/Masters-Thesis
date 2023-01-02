classdef LagrangeDelay < FilterObject & FractionalDelay  
    properties(GetAccess = public)
        filterLength
    end
    
    methods
        function obj = LagrangeDelay(filterLength, fractionalDelay)
            assert(mod(filterLength, 2) == 0, "Filter length must be even");
            b = hlagr2(filterLength, fractionalDelay);
            a = 1;  %As we are dealing with an FIR filter here
            z_init = zeros(1, length(b)-1);
            obj@FilterObject(b, a, z_init)
            obj.filterLength = filterLength;
            obj.fractionalDelay = fractionalDelay;
            obj.integerDelay = filterLength/2-1;
        end
        
        function setFractionalDelay(obj, newValue)
            obj.fractionalDelay = newValue;
            obj.b = hlagr2(obj.filterLength, obj.fractionalDelay);
        end
    end
end

