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
        
        function consumeControlSignal(obj, slideSpeed_n)
            obj.f_c_n = slideSpeed_n;
            obj.slideSpeed_n = slideSpeed_n;
        end
    end
end