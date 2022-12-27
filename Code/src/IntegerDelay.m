classdef IntegerDelay < handle & AudioProcessor
    %DELAYLINE Simple delay line to simplify implementations. Input and
    %output pointers are used here as the length will be adjusted in real
    %time.
    
    properties(GetAccess = public)
        readPointer     %points to the next location which will be read from
        writePointer    %points to the next location which will be read to
        buffer          %contains the contents of the delay line
        delay           %delay amount - not sure how useful this is... could be removed...
    end
       
    methods
        function obj = IntegerDelay(delay)
            %DELAYLINE Construct an instance of this class initialized to
            %zeros
            obj.buffer = zeros(1, SystemParams.maxDelayLineLength);
            obj.readPointer = 1;
            obj.writePointer = delay + 1; %Add one as Matlab starts indexing at 1
            obj.delay = delay;
        end
        
        function outputSample = tick(obj, newSample)
            %return latest sample and write new sample
            outputSample = obj.buffer(obj.readPointer);
            obj.buffer(obj.writePointer) = newSample;
            
            %increment pointers
            obj.incrementReadPointer();
            obj.incrementWritePointer();
        end
        
        function currentSample = getCurrentSample(obj)
            %return the sample where the pointer is looking
            currentSample = obj.buffer(obj.readPointer);
        end
        
        function writeSample(obj, inputSample)
            %write incoming sample
            obj.buffer(obj.writePointer) = inputSample;
        end
        
        function setDelay(obj, newValue)
            assert(newValue <= SystemParams.maxDelayLineLength, "New delay value is too long")
            assert(newValue > 0, "New delay value must be greater than zero")
            obj.delay = newValue;
            
            if obj.writePointer >= obj.delay
                obj.readPointer = obj.writePointer - obj.delay;
            else
                obj.readPointer = length(obj.buffer) + obj.writePointer - obj.delay;
            end
        end
               
        function initializeBuffer(obj, newData)
            assert(length(newData) == length(obj.buffer), 'New data must match existing buffer dimensions')
            obj.buffer = newData;
        end
    end
    
    methods(Access = private)
        %I believe that Matlab arrays/vectors are value objects are this
        %length so these functions cannot be condensed easily into one
        %which operates on a handle (aka. Matlab style pointer)
        function incrementReadPointer(obj)
            obj.readPointer = obj.readPointer + 1;
            if obj.readPointer > length(obj.buffer)
                obj.readPointer = 1;
            end
        end
        function incrementWritePointer(obj)
            obj.writePointer = obj.writePointer + 1;
            if obj.writePointer > length(obj.buffer)
                obj.writePointer = 1;
            end
        end
    end
end