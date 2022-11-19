classdef EnergyScaler < handle
    %TODO: I believe this could easily be integerated into the DWG model
    %itself
    properties
        prevLengthSamples
    end
    
    methods
        function obj = EnergyScaler(initialLengthSamples)
             obj.prevLengthSamples = initialLengthSamples;
        end
        
        function g_c = tick(obj, currentLengthSamples)
            %TODO: Fine tune these and debug them later
            delta_x = currentLengthSamples - obj.prevLengthSamples;
            g_c = sqrt(abs(1-delta_x));
            obj.prevLengthSamples = currentLengthSamples;
        end
    end
end

