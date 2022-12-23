classdef Noise
    methods(Static)
        function outputSample = tick()
            %TICK generate one sample of noise on -1.0 to 1.0 range
            %TODO: Determine if this method/approach is even still valid
            outputSample = -1 + 2*rand();
        end
    end
end

