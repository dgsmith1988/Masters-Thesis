classdef CircularBuffer < handle & AudioProcessor
    %Circular buffer to help facilitate the interpolated delay line class.
    
    properties(Constant)
        %TODO: Eventually figure out the best places to put these things
        %based on proper program structure
        maxDelay = SystemParams.maxDelayLineLength + SystemParams.lagrangeOrder;
        minDelay = SystemParams.minDelayLineLength;
    end
    
    properties(GetAccess = public)
        readPointer     %points to the next location which will be read from
        writePointer    %points to the next location which will be read to
        buffer          %contains the contents of the delay line
        delay           %delay amount - not sure how useful this is... could be removed...
    end
    
    methods       
        function obj = CircularBuffer(delay)
            %Construct an instance of this class initialized to zeros
            
            %TODO: This could be made more memory efficient by doing it on
            %a per-string basis using the min and max L values as well.
            
            %Allocate the buffer to be the maximum value possible to
            %support the worst case scenario.
            obj.buffer = zeros(1, obj.maxDelay);
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
            %write sample to the current write pointer location
            obj.buffer(obj.writePointer) = inputSample;
        end
        
        function sample = getSampleAtDelay(obj, delay)
            %Indexing starts at 0 here instead of one to make it easier to
            %mesh with DSP notation. This assumes that the write pointer is
            %currently pointing to the next buffer location to be written
            %to so the previous buffer location would contain x[n-1].
            
            indexPointer = obj.writePointer - delay;
            
            %If we go beyond the start of the buffer we need to wrap things
            %around to the other end.
            if(indexPointer < 1)
                indexPointer = indexPointer + length(obj.buffer);
            end
            
            sample = obj.buffer(indexPointer);
        end
        
        function incrementDelay(obj)
            assert(obj.delay ~= obj.maxDelay, "We have reached the maximum delay line length.")
            obj.delay = obj.delay + 1;
            obj.decrementReadPointer()
        end
        
        function decrementDelay(obj)
            assert(obj.delay ~= obj.minDelay)
            obj.delay = obj.delay - 1;
            obj.incrementReadPointer()
            
        end
        
        function initializeBuffer(obj, newData)
            assert(length(newData) == length(obj.buffer), 'New data must match existing buffer dimensions');
            %TODO: Should this also reset the read/write pointers?
            obj.buffer = newData;
        end
        
        function initializeDelayLine(obj, newData)
            assert(length(newData) == obj.delay, 'New data must match current delay setting');
            obj.buffer(1:obj.delay) = newData;
        end
        
        function bufferLength = getBufferLength(obj)
            bufferLength = length(obj.buffer);
        end
    end
    
    methods(Access = private)
        %I believe that Matlab arrays/vectors are value objects so these
        %functions cannot be condensed easily into one which operates on a
        %handle (aka. Matlab style pointer)
        function incrementReadPointer(obj)
            obj.readPointer = obj.readPointer + 1;
            if obj.readPointer > length(obj.buffer)
                obj.readPointer = 1;
            end
        end
        
        function decrementReadPointer(obj)
            obj.readPointer = obj.readPointer - 1;
            if obj.readPointer == 0
                obj.readPointer = length(obj.buffer);
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