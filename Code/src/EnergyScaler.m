classdef EnergyScaler < handle
    %Class to implement the zero-order energy-preserving interpolation
    %associated with time-varying fractional delay-lines
    properties
        prevLengthSamples
    end
    
    methods
        function obj = EnergyScaler(initialLengthSamples)
             obj.prevLengthSamples = initialLengthSamples;
        end
        
        function g_c = tick(obj, currentLengthSamples)            
            delta_x = currentLengthSamples - obj.prevLengthSamples;
            g_c = sqrt(abs(1-delta_x));
            obj.prevLengthSamples = currentLengthSamples;
        end
    end
end

