classdef ContactSoundGenerator < handle
    properties
        %Todo: Set these to be passed through the constructor?
        g_bal = .5;
        g_TV = 1;
        g_user = 1;  
        controlSignalProcessor
        noisePulse %TODO: this will eventually be changed to noiseSource to support unwound strings
        metro
        noiseBurstTrigger
        stringModeFilter
        resonator
        
        %TODO: Add a waveshaper function property? Can Matlab do this?
    end
    
    methods
        function obj = ContactSoundGenerator(stringParams, stringModeFilterSpec)
            obj.controlSignalProcessor = ControlSignalProcessor(stringParams.n_w);
            obj.noisePulse = NoisePulse2(stringParams.pulseLength, stringParams.decayRate);
            obj.metro = Metro(stringParams.pulseLength, obj.noisePulse);
            obj.noiseBurstTrigger = NoiseBurstTrigger(obj.metro);
            obj.stringModeFilter = LongitudinalModeFilter(stringModeFilterSpec);
            obj.resonator = ResonatorFilter(250, .99); %TODO: Change these to not be magic constants once more things come into place
        end
        
        function outputSample = tick(obj, L)
            f_c = obj.controlSignalProcessor.tick(L);
            obj.noiseBurstTrigger.tick(f_c);
            obj.metro.tick()
            noiseSample = obj.noisePulse.tick();
            obj.resonator.update_f_c(f_c);
            v1 = (1-obj.g_bal)*obj.stringModeFilter.tick(noiseSample);
            v2 = obj.g_bal*(obj.resonator.tick(noiseSample));
            %convert f_c back to muutos to match the PD patch for now
            %TODO: Refactor this in your own way to make more sense
            muutos = f_c * SystemParams.stringLengthMeters / obj.controlSignalProcessor.n_w;
            obj.g_TV = .5*muutos;
            outputSample = obj.g_user*(obj.g_TV*(v1 + v2));
        end
        
        function set_g_user(obj, newValue)
            obj.g_user = newValue;
        end
    end
end