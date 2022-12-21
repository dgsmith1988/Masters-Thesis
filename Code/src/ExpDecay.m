classdef ExpDecay < handle
    %EXPDECAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        impulseTrainGen
        onePole
    end
    
    methods
        function obj = ExpDecay(dB_decay, samples)

        end
        
        function outputSample = tick(obj)
            %TICK output the next sample         
            outputSample = obj.currentValue;
            obj.currentValue = obj.a*obj.currentValue;
            if obj.currentValue < db2mag(obj.dB_decay)
                obj.currentValue = 0;
            end
        end
    end
end

