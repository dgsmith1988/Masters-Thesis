classdef Noise
    %NOISE Noise generator conforming to .tick() API
    %TODO: Determine the best type of noise to use here
    methods
        function obj = Noise()
        end
        
        function outputSample = tick(obj)
            %Wrapper function to make swapping classes easier
            outputSample = Noise.tick_static();
        end
        
        function consume_f_c(obj, f_c_n)
            %Pass through
        end
    end
    methods(Static)       
        function outputSample = tick_static()
            %TICK generate one sample of noise on -1.0 to 1.0 range
            outputSample = -1 + 2*rand();
        end
    end
end

