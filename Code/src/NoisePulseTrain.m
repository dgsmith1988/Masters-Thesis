classdef NoisePulseTrain < handle    
    properties
        impulseTrain
        amplitudeEnvelope    %one-pole filter tuned to generate coeff
    end
    
    methods
        function obj = NoisePulseTrain(period_samp, decayRate)
            obj.impulseTrain = ImpulseTrain(period_samp);
            alpha = decayRate;
            b = 1;
            a = [1 -alpha];
            z_init = 0;
            obj.amplitudeEnvelope = FilterObject(b, a, z_init);
        end
        
        function outputSample = tick(obj, f_c_n)
            %Feed the impulse train into the IIR to generate the
            %exponentially decaying signal
            amplitude = obj.amplitudeEnvelope.tick(obj.impulseTrain.tick(f_c_n));
            outputSample = amplitude*abs(Noise.tick());
%             outputSample = amplitude;            
        end
    end
end

