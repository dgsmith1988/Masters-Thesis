classdef AudioGenerator < Tickable
    %Basic interfact any audio generator object needs to adhere to.
    
    methods(Static)
        function outputSample = outputZero(inputSample)
            %This method exists to make it easier to debug the signal
            %processing chain with minimal code changes. Use it if you want
            %to disable processing on a particular object to try and
            %isolate where artifacts might come from. Making it static
            %would add more code changes to the debugging process.
            outputSample = 0;
        end
    end
end

