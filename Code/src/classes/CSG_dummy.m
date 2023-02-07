classdef CSG_dummy < ContactSoundGenerator
    properties
        f_c_n
        slideSpeed_n
    end
    
    methods
        function obj = CSG_dummy()
            
        end
        
        function outputSample = tick(obj)
            outputSample = 0;
        end
        
        function consumeControlSignal(obj, f_c_n, slideSpeed_n)
            obj.f_c_n = f_c_n;
            obj.slideSpeed = slideSpeed_n;
        end
    end
end