classdef ContactSoundGenerator < handle
    properties
        %Todo: Set these to be passed through the constructor?
        g_bal = .5;
        g_TV = 1;
        g_user = 1;  
        controlSignalProcessor
        noisePulseTrain
        stringModeFilter
        resonator
        preScalingGain = 10
        waveshaperFunctionHandle
    end
    
    methods
        function obj = ContactSoundGenerator(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L_n_1)
            obj.controlSignalProcessor = ControlSignalProcessor(stringParams.n_w, L_n_1);
            %TODO: Replace this with the decay rate from the strings once
            %you get a formula to achieve that
            obj.noisePulseTrain = NoisePulseTrain2(7, 127/128);
            obj.stringModeFilter = LongitudinalModeFilter(stringModeFilterSpec);
            obj.resonator = ResonatorFilter(250, .99); %TODO: Change these to not be magic constants once more things come into place
            obj.waveshaperFunctionHandle = waveshaperFunctionHandle;
        end
        
%         function outputSample = tick(obj, L_n)
%             [absoluteSlideVelocity, resonatorFrequency_Hz, triggerPeriod_ms] = obj.controlSignalProcessor.tick(L_n);
%             noiseSample = obj.noisePulseTrain.tick(triggerPeriod_ms);
%             obj.resonator.update_f_c(resonatorFrequency_Hz);
%             %compute the upper branch from the longitudinal modes first
%             v1 = (1-obj.g_bal)*obj.stringModeFilter.tick(noiseSample);
%             %compute the lower branch due to the time-varying harmonic
%             %component
%             v2 = obj.resonator.tick(noiseSample);
%             %this value of 40 comes from the PD patch
%             v2 = obj.waveshaperFunctionHandle(40*v2);
%             v2 = obj.g_bal*v2;           
%             obj.g_TV = .5*abs(absoluteSlideVelocity);
%             outputSample = obj.g_user*(obj.g_TV*(v1 + v2));
%         end

        function outputSample = tick(obj, L_n)
            %calculate the control parameters and update the corresponding
            %objects
            [f_c_n, absoluteSlideSpeed] = obj.controlSignalProcessor.tick(L_n);
            noiseSample = obj.noisePulseTrain.tick(f_c_n);
            obj.resonator.update_f_c(f_c_n);
            
            %compute the upper branch from the longitudinal modes first
            %TODO: Use a different type of noise source here? The noise
            %pulse train might not be the best as it is harmonic signal...
            v1 = (1-obj.g_bal)*obj.stringModeFilter.tick(noiseSample);
            %compute the lower branch due to the time-varying harmonic
            %component
            v2 = obj.resonator.tick(noiseSample);
            %this value of 40 comes from the PD patch
            v2 = obj.waveshaperFunctionHandle(obj.preScalingGain*v2);
            v2 = obj.g_bal*v2;
            %disable the velocity scaling for now
            obj.g_TV = .5*abs(absoluteSlideSpeed);
            outputSample = obj.g_user*(obj.g_TV*(v1 + v2));
        end
        
        function set_g_user(obj, newValue)
            obj.g_user = newValue;
        end
    end
end