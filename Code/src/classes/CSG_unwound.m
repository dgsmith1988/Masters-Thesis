classdef CSG_unwound < ContactSoundGenerator
    properties
        g_TV = 1;
        g_user = 1; 
        absoluteSlideSpeed
        controlSignalProcessor
        lowPassFilter
    end
    
    methods
        function obj = CSG_unwound(stringParams, L_n_1)
            obj.controlSignalProcessor = ControlSignalProcessor(stringParams.n_w, L_n_1);
            
            [b, a] = butter(1, .5);
            %TODO: There is a larger question of is time-alignment
            %necessary between all the different synthesizer components?
            %We can initialize this to noise as we are filtering noise
            z_init = Noise.tick();
            
            obj.lowPassFilter = FilterObject(b, a, z_init);
        end
        
        function outputSample = tick(obj)
            noiseSample = Noise.tick();
            lowPassed = obj.lowPassFilter.tick(noiseSample);

            %Scale the signal by the slide speed and output it
            obj.g_TV = .5*obj.absoluteSlideSpeed;
            outputSample = obj.g_user*(obj.g_TV*lowPassed);
        end
        
        function consumeControlSignal(obj, L_n)
            %calculate the control parameters and update the corresponding
            %objects
            [~, obj.absoluteSlideSpeed] = obj.controlSignalProcessor.tick(L_n);
        end
    end
end