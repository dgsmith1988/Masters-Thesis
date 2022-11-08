classdef DelayLineInteger < handle
    %DELAYLINE Simple delay line to simplify implementations
    %TODO: Determine how to handle the 0 delay case more robustly
    
    properties
        pointer
        buffer
    end
    
    methods
        function obj = DelayLineInteger(delay)
            %DELAYLINE Construct an instance of this class
            obj.pointer = 1;
            obj.buffer = zeros(1, delay);
        end
        
        function len = getLength(obj)
            len = length(obj.buffer);
        end
        
        function outputSample = tick(obj, newSample)
            %return latest sample and write new sample
            outputSample = obj.buffer(obj.pointer);
            obj.buffer(obj.pointer) = newSample;
            obj.pointer = obj.pointer + 1;
            if obj.pointer > length(obj.buffer)
                obj.pointer = 1;
            end
        end
       
        function currentSample = getCurrentSample(obj)
            %return the sample where the pointer is looking
            currentSample = obj.buffer(obj.pointer);
        end
        
        function writeSample(obj, inputSample)
            %write incoming sample and increase pointer
            obj.buffer(obj.pointer) = inputSample;
            obj.pointer = obj.pointer + 1;
            if obj.pointer > length(obj.buffer)
                obj.pointer = 1;
            end
        end
    end
end