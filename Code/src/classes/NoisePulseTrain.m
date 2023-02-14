classdef NoisePulseTrain < NoiseSource
    properties
        exponentialDecay
        dcBlocker
    end
    
    properties(Constant)
        R = .995;
    end
    
    methods
        function obj = NoisePulseTrain(period_samples, T60)
            obj.exponentialDecay = ExponentialDecay(period_samples, T60);
            obj.dcBlocker = DCBlocker(obj.R);
        end
        
        function outputSample = tick(obj)
            %Feed the impulse train into the IIR to generate the
            %exponentially decaying signal
            amplitude = obj.exponentialDecay.tick();
            scaledNoise = amplitude*abs(Noise.tick());
            outputSample = obj.dcBlocker.tick(scaledNoise);
        end
        
        function consumeControlSignal(obj, f_c_n)
            obj.exponentialDecay.consumeControlSignal(f_c_n);
        end
    end
end

