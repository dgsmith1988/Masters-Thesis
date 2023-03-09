classdef ResoTanh < HarmonicAccentuator
    %RESOTANH Haromnic accentuator formed by a 2nd order resonator in
    %series with a tanh function
    
    properties
        preTanhGain
        resonator
    end
    
    methods
        function obj = ResoTanh(f_c, r, preTanhGain)
            obj.resonator = Resonator(f_c, r);
            obj.preTanhGain = preTanhGain;
        end
        
        function [outputSample, resonatorOutput] = tick(obj, inputSample)
            resonatorOutput = obj.resonator.tick(inputSample);
            outputSample = tanh(obj.preTanhGain*resonatorOutput);
        end
        
        function consumeControlSignal(obj, f_c_n)
            obj.resonator.update_f_c(f_c_n);
        end
    end
end

