classdef CSG_unwound < handle
    properties
        g_TV = 1;
        g_user = 1;  
        controlSignalProcessor
    end
    
    methods
        function obj = CSG_unwound(stringParams, L_n_1)
            obj.controlSignalProcessor = ControlSignalProcessor(stringParams.n_w, L_n_1);
        end
        
        function outputSample = tick(obj, L_n)
            %calculate the control parameters and update the corresponding
            %objects
            [~, absoluteSlideSpeed] = obj.controlSignalProcessor.tick(L_n);
            noiseSample = Noise.tick();
            
            %TODO: Experiment with filtering the noise like he does in the
            %patch
            %Scale the signal by the slide speed and output it
            obj.g_TV = .5*absoluteSlideSpeed;
            outputSample = obj.g_user*(obj.g_TV*noiseSample);
        end
        
        function set_g_user(obj, newValue)
            obj.g_user = newValue;
        end
    end
end