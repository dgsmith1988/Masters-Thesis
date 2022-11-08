classdef LinearRamp < handle
    %LINEARRAMP Class which generates a linear ramp from 0 to 1 over the
    %specified number of milliseconds
    
    properties
        m
        currentValue = 0
        
    end
    
    methods
        function obj = LinearRamp(rampLength_ms)
            obj.m = 1/(rampLength_ms*10^-3);
        end
        
        function outputSample = tick(obj)
            if obj.currentValue == 1
                outputSample = obj.currentValue;
            else
                outputSample = obj.m/SystemParams.audioRate + obj.currentValue;
                if outputSample > 1
                    %clamp it at one to ensure convergence
                    %Todo: Comeback and do a proper sample-by-sample check
                    outputSample = 1;
                end
                obj.currentValue = outputSample;
            end
        end
        
        function reset(obj)
            obj.currentValue = 0;
        end
    end
end

