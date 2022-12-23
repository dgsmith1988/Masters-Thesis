classdef ExponentialDecay
    %Exponential decay implemented by feeding impulse signals into an IIR
    %tuned to have a specific decay rate
    
    properties
        impulseTrain
        onePoleIIR      %one-pole filter tuned to generate coeff
    end
    
    methods
        function obj = ExponentialDecay(period_samp, decayRate)
            obj.impulseTrain = ImpulseTrain(period_samp);
            alpha = decayRate;
            b = 1;
            a = [1 -alpha];
            z_init = 0;
            obj.onePoleIIR = FilterObject(b, a, z_init);
        end
        
        function outputSample = tick(obj, f_c_n)
            outputSample = obj.onePoleIIR.tick(obj.impulseTrain.tick(f_c_n));
        end
    end
end

