classdef AudioProcessor < handle
    %Basic interfact any processing object needs to adhere to. This was
    %implemented later in the game and will gradually be added to the
    %inheritance tree of each object.   
    methods(Abstract)
        %All objects will have to implement this in order to produce a
        %sample of output based on whatever their desired purpose is.
        outputSample = tick(obj)
    end
    
    methods(Static)
        function outputSample = passThru(inputSample)
            %This method exists to make it easier to debug the signal
            %processing chain with minimal code changes. Use it if you want
            %to disable processing on a particular object to try and
            %isolate where artifacts might come from. Making it static
            %would add more code changes to the debugging process.
            outputSample = inputSample;
        end
    end
end

