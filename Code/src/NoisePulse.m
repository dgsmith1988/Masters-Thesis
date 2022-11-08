classdef NoisePulse < handle
    %NOISEPULSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        amplitudeEnvelope   %Object for generating amplitude profile
        pulseCount = -1     %How many pulses left to generate, -1 for infinite
        pulsePeriod         %Pulse period in samples
        remainingSamples    %Samples left to generate for current pulse
    end
    
    methods
        function obj = NoisePulse(pulsePeriod, pulseCount, dB_decay, envelopeLength)
            %NOISEPULSE
            %	First two parameters pertain to this class, while the others correspond to the amplitude envelope
            obj.pulsePeriod = pulsePeriod;
            obj.pulseCount = pulseCount;
            obj.amplitudeEnvelope = ExpDecay(dB_decay, envelopeLength);
            obj.remainingSamples = pulsePeriod;
        end
        
        function outputSample = tick(obj)
            %TICK Generate one sample of output
            if obj.pulseCount == 0
                outputSample = 0;
            else
                outputSample = obj.amplitudeEnvelope.tick()*Noise.tick();
                obj.remainingSamples = obj.remainingSamples - 1;
                if obj.remainingSamples == 0                    
                    obj.remainingSamples = obj.pulsePeriod;
                    obj.amplitudeEnvelope.reset()
                    if obj.pulseCount ~= -1
                        obj.pulseCount = obj.pulseCount - 1;
                    end
                end
            end
        end
        
        function consume_f_c(obj, f_c)
            newPulsePeriod = round(1/f_c * SystemParams.audioRate);
            obj.pulsePeriod = newPulsePeriod;
            obj.amplitudeEnvelope.setSamples(newPulsePeriod);
        end
    end
end