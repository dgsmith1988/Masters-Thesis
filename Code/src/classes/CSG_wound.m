classdef CSG_wound < ContactSoundGenerator
    properties
        g_bal = .25; %favor the modal resonators as they can get burried
        g_TV = 1;
        g_user = 1;
        controlSignalProcessor
        noisePulseTrain
        stringModeFilter
        resonator
        waveshaperPreScalingGain = 7
        waveshaperFunctionHandle
        f_c_n
        absoluteSlideSpeed
        
        highPassFilter
    end
    
    methods
        function obj = CSG_wound(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L_n_1)
            %TODO: Determine the best way to initialize these later
            obj.f_c_n = 0;
            obj.absoluteSlideSpeed = 0;
            obj.controlSignalProcessor = ControlSignalProcessor(stringParams.n_w, L_n_1);
            obj.noisePulseTrain = NoisePulseTrain(0, stringParams.T60);
            obj.stringModeFilter = LongitudinalMode(stringModeFilterSpec);
            obj.resonator = Resonator(obj.f_c_n, .99); %TODO: Change these to not be magic constants once more things come into place
            obj.waveshaperFunctionHandle = waveshaperFunctionHandle;
            obj.highPassFilter = HighPassOnePole(.99);
        end
        
        function [outputSample, noiseSample] = tick(obj)
            %The noise pulse train is made available for debugging
            %and comparison purposes
            noiseSample = obj.noisePulseTrain.tick();
            %compute the upper branch from the longitudinal modes first
            %TODO: Use a different type of noise source here? The noise
            %pulse train might not be the best as it is harmonic signal...
            v1 = (1-obj.g_bal)*obj.stringModeFilter.tick(noiseSample);
            %compute the lower branch due to the time-varying harmonic
            %component
            v2 = obj.resonator.tick(noiseSample);
            v2 = obj.waveshaperFunctionHandle(obj.waveshaperPreScalingGain*v2);
            v2 = obj.g_bal*v2;
            
            %highpass it to see if we can eliminate the issue of build up
            %in the DWG
%             v2 = obj.highPassFilter.tick(v2);
            
            %Scale the signal by the slide speed and output it
            obj.g_TV =.5*obj.absoluteSlideSpeed;
%             obj.g_TV = f_c_n/100;
            outputSample = obj.g_user*(obj.g_TV*(v1 + v2));
        end
        
        function consumeControlSignal(obj, L_n)
            %calculate the control parameters and update the corresponding
            %objects
            [obj.f_c_n, obj.absoluteSlideSpeed] = obj.controlSignalProcessor.tick(L_n);    
            obj.noisePulseTrain.consumeControlSignal(obj.f_c_n);
            obj.resonator.update_f_c(obj.f_c_n);
        end
    end
end