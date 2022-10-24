classdef ExpDecay < handle
    %EXPDECAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dB_decay
        samples
        tau
        a
        currentValue
    end
    
    methods
        function obj = ExpDecay(dB_decay, samples)
            %EXPDECAY Exponentially decay to dB_decay over number of samples
            %specified in "samples" at Fs
            obj.dB_decay = dB_decay;
            obj.samples = samples;
            obj.tau = (-samples/SystemParams.audioRate) / log(db2mag(dB_decay));
            obj.currentValue = 1;
            obj.a = exp(-1/(obj.tau*SystemParams.audioRate));
        end
        
        function outputSample = tick(obj)
            %TICK output the next sample         
            outputSample = obj.currentValue;
            obj.currentValue = obj.a*obj.currentValue;
            if obj.currentValue < db2mag(obj.dB_decay)
                obj.currentValue = 0;
            end
        end
        
        function reset(obj)
            obj.currentValue = 1;
        end
        
        function setSamples(obj, newValue)
            obj.samples = newValue;
            obj.reset();
        end
    end
end

