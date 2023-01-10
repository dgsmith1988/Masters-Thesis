classdef ExponentialDecay < AudioGenerator
    %Exponential decay implemented by feeding impulse signals into an IIR
    %tuned to have a specific decay rate
    
    properties
        impulseTrain
        onePoleIIR      %one-pole filter tuned to generate coeff
        T60
        tau
        alpha
    end
    
    methods
        function obj = ExponentialDecay(period_samp, T60)
            obj.impulseTrain = ImpulseTrain(period_samp);
            obj.T60 = T60;
            obj.tau = ExponentialDecay.calculateTimeConsant(T60);
            obj.alpha = exp(-1/(obj.tau*SystemParams.audioRate));
            b = 1;
            a = [1 -obj.alpha];
            z_init = 0;
            obj.onePoleIIR = FilterObject(b, a, z_init);
        end
        
        function outputSample = tick(obj)
            outputSample = obj.onePoleIIR.tick(obj.impulseTrain.tick());
        end
        
        function consumeControlSignal(obj, f_c_n)
            obj.impulseTrain.consumeControlSignal(f_c_n);
        end
    end
    
    methods(Static)
        function tau = calculateTimeConsant(T60)
            %Calculate the T60 value for the amplitude envelope based on the number of
            %samples and sampling rate. T60 is specified in seconds.
            
            assert(sum(T60>0) == length(T60) > 0, "Must have a positive value for the duration");
            
            tau = -T60 / log(.001);
        end
    end
end

