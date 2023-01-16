classdef NoiseBurst < Controllable & AudioGenerator
    
    properties
        exponentialDecay
    end
    
    methods
        function obj = NoiseBurst(period_samples, T60)
            obj.exponentialDecay = ExponentialDecay(period_samples, T60);
        end
        
        function outputSample = tick(obj)
            %Feed the impulse train into the IIR to generate the
            %exponentially decaying signal
            amplitude = obj.exponentialDecay.tick();
            
            %Hard clip the signal to make sure the noise doesn't get too
            %high.
            if amplitude > 1
                amplitude = 1;
            end
            
            outputSample = amplitude*Noise.tick();
        end
        
        function consumeControlSignal(obj, f_c_n)
            obj.exponentialDecay.consumeControlSignal(f_c_n);
        end
    end
end

