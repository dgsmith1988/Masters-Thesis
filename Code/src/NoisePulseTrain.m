classdef NoisePulseTrain < handle    
    properties
        exponentialDecay
    end
    
    methods
        function obj = NoisePulseTrain(period_samp, T60)
            obj.exponentialDecay = ExponentialDecay(period_samp, T60);
        end
        
        function outputSample = tick(obj, f_c_n)
            %Feed the impulse train into the IIR to generate the
            %exponentially decaying signal
            amplitude = obj.exponentialDecay.tick(f_c_n);
            outputSample = amplitude*abs(Noise.tick());
        end
    end
end

