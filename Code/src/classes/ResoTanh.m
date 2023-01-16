classdef ResoTanh < HarmonicAccentuator
    %RESOTANH Haromnic accentuator formed by a 2nd order resonator in
    %series with a tanh function
    
    properties
        preTanhGain = 7;
        resonator
    end
    
    methods
        function obj = ResoTanh(f_c, r)
            obj.resonator = Resonator(f_c, r);
        end
        
        function outputSample = tick(obj, inputSample)
            outputSample = tanh(obj.preTanhGain*obj.resonator.tick(inputSample));
        end
        
        function consumeControlSignal(obj, f_c_n)
            obj.resonator.update_f_c(f_c_n);
        end
    end
end

