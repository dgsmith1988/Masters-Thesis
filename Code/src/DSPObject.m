classdef DSPObject
    %Basic interfact any processing object needs to adhere to. This was
    %implemented later in the game and will gradually be added to the
    %inheritance tree of each object.
    properties
        Property1
    end
    
    methods(Abstract)
        outputSample = tick(obj)
    end
    
    methods
        function outputSample = tick_passThru(obj, inputSample)
            %This method exists to make it easier to debug the signal
            %processing chain with minimal code changes. Use it if you want
            %to disable processing on a particular object to try and
            %isolate where artifacts might come from.
            outputSample = inputSample;
        end
    end
end

