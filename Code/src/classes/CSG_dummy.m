classdef CSG_dummy < ContactSoundGenerator
    methods
        function outputSample = tick(obj)
           outputSample = 0;
        end
        
        function consumeControlSignal(obj, L_n)
            %Dummy call, do nothing
        end
    end
end