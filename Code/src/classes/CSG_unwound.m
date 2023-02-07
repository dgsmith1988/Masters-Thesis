classdef CSG_unwound < ContactSoundGenerator
    properties
        g_TV = 1;
        g_user = .10; 
        slideSpeed_n
        f_c_n   %Keep this here to provide a uniform interface for the testing code
        lowPassFilter
    end
    
    methods
        function obj = CSG_unwound()           
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
            obj.g_TV = .5*obj.slideSpeed_n;
            outputSample = obj.g_user*(obj.g_TV*lowPassed);
        end
        
        function consumeControlSignal(obj, slideSpeed_n)
            %f_c_n is kept as an argument to adhere to a constant interface
            %and simplify the SlideSynth programming
            obj.slideSpeed_n = slideSpeed_n;
            obj.f_c_n = slideSpeed_n;
        end
    end
end