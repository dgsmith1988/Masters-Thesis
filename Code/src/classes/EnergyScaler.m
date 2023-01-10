classdef EnergyScaler < handle
    %Class to implement the zero-order energy-preserving interpolation
    %associated with time-varying fractional delay-lines
    properties
        prevDWGLength
    end
    
    methods
        function obj = EnergyScaler(initialDWGLength)
             obj.prevDWGLength = initialDWGLength;
        end
        
        function g_c = tick(obj, currentDWGLength)            
            delta_x = currentDWGLength - obj.prevDWGLength;
            g_c = sqrt(abs(1-delta_x));
            obj.prevDWGLength = currentDWGLength;
        end
    end
end

