classdef CSG_dummy < ContactSoundGenerator
    properties
        controlSignalProcessor
        absoluteSlideSpeed = 0;
    end
    
    methods
        function obj = CSG_dummy(n_w, L_n_1)
            obj.controlSignalProcessor = ControlSignalProcessor(n_w, L_n_1);
        end
        
        function outputSample = tick(obj)
           outputSample = 0;
        end
        
        function consumeControlSignal(obj, L_n)
            [~, obj.absoluteSlideSpeed] = obj.controlSignalProcessor.tick(L_n);
        end
    end
end