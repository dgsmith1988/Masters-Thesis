classdef LagrangeDelay < FilterObject & FractionalDelay  
    properties(Constant)
        integerDelay = 2
        order = 6   %Best filter order as per recommendation of the papers
    end
    
    methods
        function obj = LagrangeDelay(fractionalDelay)
            b = hlagr2(LagrangeDelay.order, fractionalDelay);
            a = 1;  %As we are dealing with an FIR filter here
            z_init = zeros(1, length(b)-1);
            obj@FilterObject(b, a, z_init)
            obj.fractionalDelay = fractionalDelay;
        end
        
        function setFractionalDelay(obj, newValue)
            obj.fractionalDelay = newValue;
            obj.b = hlagr2(LagrangeDelay.order, obj.fractionalDelay);            
        end
    end
end

