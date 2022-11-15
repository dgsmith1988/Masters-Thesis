classdef NoisePulse2 < handle
    %NOISEPULSE2 Class modeled after noise pulse as specified in PD code
    %from the masters thesis
    
    properties
        linearRamp
        pulseLength_ms
        decayRate
    end
    
    methods
        function obj = NoisePulse2(pulseLength_ms, decayRate)
            obj.pulseLength_ms = pulseLength_ms;
            obj.decayRate = decayRate;
            obj.linearRamp = LinearRamp(pulseLength_ms);
        end
        
        function outputSample = tick(obj)
            %Rescale the linear ramp so it goes from 1 to pulseLength_ms
            expArgument = ((obj.pulseLength_ms - 1)*obj.linearRamp.tick()) + 1;
            %Feed this into decaying exponential which scales the noise
            %TODO: Determine why there is an absolute value here
            outputSample = exp(-expArgument/obj.decayRate)*abs(Noise.tick_static());
        end
        
        function reset(obj)
            obj.linearRamp.reset()
        end
    end
end
