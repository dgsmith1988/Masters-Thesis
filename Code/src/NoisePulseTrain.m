classdef NoisePulseTrain < handle    
    properties
        exponentialDecay
    end
    
    methods
        function obj = NoisePulseTrain(period_samp, T60)
            obj.exponentialDecay = ExponentialDecay(period_samp, T60);
        end
        
        function outputSample = tick(obj)
            %Feed the impulse train into the IIR to generate the
            %exponentially decaying signal
            amplitude = obj.exponentialDecay.tick();
            outputSample = amplitude*abs(Noise.tick());
        end
        
        function consumeControlSignal(obj, f_c_n)
            obj.exponentialDecay.consumeControlSignal(f_c_n);
        end
    end
end

