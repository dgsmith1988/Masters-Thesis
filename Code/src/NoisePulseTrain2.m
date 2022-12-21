classdef NoisePulseTrain2 < handle
    %Class which controls the NoisePulseGen and its associating timing
    %characteristics
    
    properties
        impulseTrain
        amplitudeEnvelope    %one-pole filter tuned to generate coeff
    end
    
    methods
        function obj = NoisePulseTrain2(period_samp, decayRate)
            obj.impulseTrain = ImpulseTrain(period_samp);
            %TODO: Determine how to convert the decay rates into the filter
            %parameters
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
            outputSample = amplitude*abs(Noise.tick_static());
%             outputSample = amplitude;            
        end
    end
end

