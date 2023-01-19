classdef CSG_wound < ContactSoundGenerator
    properties
        %Processing/generation objects
        controlSignalProcessor
        noiseSource
        stringModeFilter
        harmonicAccentuator
        
        %Parameters which change during run-time
        g_TV = 1;
        f_c_n
        absoluteSlideSpeed
        
        %User specified tuning parameters which shouldn't change during
        %operation, but made non-constant to facilitate testing
        g_bal = .25; %favor the modal resonators as they can get buried
        g_user = 1;
    end
    
    properties (Constant)
        %Tuned values used to initialize objects
        r = .99
        preTanhGain = 7
    end
    
    methods
        function obj = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator, L_n_1)
            %Initializing these to zero is no issue as they are given
            %values at each call to the consumeControlSignal() function
            obj.f_c_n = 0;
            obj.absoluteSlideSpeed = 0;
            
            obj.controlSignalProcessor = ControlSignalProcessor(stringParams.n_w, L_n_1);
            
            if noiseSource == "Burst"
                obj.noiseSource = NoiseBurst(0, stringParams.T60);
            elseif noiseSource == "PulseTrain"
                obj.noiseSource = NoisePulseTrain(0, stringParams.T60);
            else
                ME = MException("CSG_wound:invalid noise source", "Specified noise source does not exist");
                throw(ME);
            end
            
            obj.stringModeFilter = LongitudinalMode(stringModeFilterSpec);
            
            if harmonicAccentuator == "HarmonicResonatorBank"
                obj.harmonicAccentuator = HarmonicResonatorBank(obj.f_c_n, CSG_wound.r);
            elseif harmonicAccentuator == "ResoTanh"
                obj.harmonicAccentuator = ResoTanh(obj.f_c_n, CSG_wound.r, CSG_wound.preTanhGain);
            else
                ME = MException("CSG_wound:invalid harmonic accentuator", "Specified haromnic accentuator does not exist");
                throw(ME);
            end
        end
        
        function [outputSample, noiseSample] = tick(obj)
            %The noise source is made available for debugging
            %and comparison purposes
            noiseSample = obj.noiseSource.tick();
            
            %compute the upper branch from the longitudinal modes first
            v1 = (1-obj.g_bal)*obj.stringModeFilter.tick(noiseSample);
            
            %compute the lower branch due to the time-varying harmonic
            %component
            v2 = obj.harmonicAccentuator.tick(noiseSample);
            v2 = obj.g_bal*v2;
            
            %Scale the signal by the slide speed and output it
            obj.g_TV =.5*obj.absoluteSlideSpeed;
            outputSample = obj.g_user*(obj.g_TV*(v1 + v2));
        end
        
        function consumeControlSignal(obj, L_n)
            %calculate the control parameters and update the corresponding
            %objects
            [obj.f_c_n, obj.absoluteSlideSpeed] = obj.controlSignalProcessor.tick(L_n);
            obj.noiseSource.consumeControlSignal(obj.f_c_n);
            obj.harmonicAccentuator.consumeControlSignal(obj.f_c_n);
        end
    end
end