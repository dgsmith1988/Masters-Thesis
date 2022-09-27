classdef Noise
    %NOISE Noise generator conforming to .tick() API
    %TODO: Determine the best type of noise to use here
    
    methods(Static)       
        function outputSample = tick()
            %TICK generate one sample of noise on -1.0 to 1.0 range
            outputSample = -1 + 2*rand();
        end
    end
end

