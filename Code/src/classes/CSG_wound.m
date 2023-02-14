classdef CSG_wound < ContactSoundGenerator
    properties
        %Processing/generation objects
        noiseSource
        stringModeFilter
        harmonicAccentuator
        
        %Constant string parameters
        n_w
        
        %User specified tuning parameters which shouldn't change during
        %operation, but made non-constant to facilitate testing
        g_bal = .75; %favor the string winding noise as compared to modal resonators
    end
    
    properties (Constant)
        %Tuned values used to initialize objects, put here so the have a
        %name
        r = .99 %r value for resonators
        preTanhGain = 7
    end
    
    methods
        function obj = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator)                      
            obj.g_user = .5;
            
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
            
            obj.n_w = stringParams.n_w;
        end
        
        function [y_n, noiseSample] = tick(obj)
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
            obj.g_slide =.5*obj.slideSpeed_n;
            y_n = obj.g_user*(obj.g_slide*(v1 + v2));
        end
        
        function consumeControlSignal(obj, slideSpeed_n)
            %Calculate the new control signal parameters
            obj.slideSpeed_n = slideSpeed_n; 
            % units here should by cycles/sec as each winding represents
            % the start of a cycle as the slide impacts it and creates an
            % triggers an IR
            % cycles/sec = windings/meter * meters/sec
            obj.f_c_n = obj.n_w*obj.slideSpeed_n;
            
            %Update the corresponding objects
            obj.noiseSource.consumeControlSignal(obj.f_c_n);
            obj.harmonicAccentuator.consumeControlSignal(obj.f_c_n);
        end
    end
end