classdef CSG_unwound < ContactSoundGenerator
    properties
        g_TV = 1;
        g_user = .10; 
        absoluteSlideSpeed
%         controlSignalProcessor
        lowPassFilter
    end
    
    methods
        function obj = CSG_unwound()
%             obj.controlSignalProcessor = ControlSignalProcessor(stringParams.n_w, L_n_1);
            
            %Generate the LPF coefficients and initalize the object to
            %noise as we are going to be filtering noise.
            [b, a] = butter(1, .5);
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