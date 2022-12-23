classdef CSG_wound < handle
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
        function obj = CSG_wound(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L_n_1)
            obj.controlSignalProcessor = ControlSignalProcessor(stringParams.n_w, L_n_1);
            %TODO:10,000 was established from tuning it would be good to
            %redo the decay rates in general
            obj.noisePulseTrain = NoisePulseTrain(0, exp(-10000/(stringParams.decayRate*SystemParams.audioRate)));
            obj.stringModeFilter = LongitudinalModeFilter(stringModeFilterSpec);
            obj.resonator = ResonatorFilter(250, .99); %TODO: Change these to not be magic constants once more things come into place
            obj.waveshaperFunctionHandle = waveshaperFunctionHandle;
        end
        
        function outputSample = tick(obj, L_n)
            %calculate the control parameters and update the corresponding
            %objects
            [f_c_n, ~] = obj.controlSignalProcessor.tick(L_n);
            noiseSample = obj.noisePulseTrain.tick(f_c_n);
            obj.resonator.update_f_c(f_c_n);
            
            %compute the upper branch from the longitudinal modes first
            %TODO: Use a different type of noise source here? The noise
            %pulse train might not be the best as it is harmonic signal...
            v1 = (1-obj.g_bal)*obj.stringModeFilter.tick(noiseSample);
            %compute the lower branch due to the time-varying harmonic
            %component
            v2 = obj.resonator.tick(noiseSample);
            v2 = obj.waveshaperFunctionHandle(obj.preScalingGain*v2);
            v2 = obj.g_bal*v2;
            
            %Scale the signal by the slide speed and output it
            obj.g_TV = 100/f_c_n;
            outputSample = obj.g_user*(obj.g_TV*(v1 + v2));
        end
        
        function set_g_user(obj, newValue)
            obj.g_user = newValue;
        end
    end
end