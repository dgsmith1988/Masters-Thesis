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
        bufferDelay     %delay amount
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
            %Add one as Matlab starts indexing at 1
            %Add another one so it points to the next location to be
            %written to (and one sample behind is x[n])
            obj.writePointer = obj.readPointer + delay; 
            obj.bufferDelay = delay;
        end
        
        function outputSample = tick(obj, newSample)
            %return latest sample and write new sample
            outputSample = obj.buffer(obj.readPointer);
            obj.buffer(obj.writePointer) = newSample;
            
            %increment pointers
            obj.incrementPointers();
        end
        
        function currentSample = getCurrentSample(obj)
            %return the sample where the read pointer is looking
            currentSample = obj.buffer(obj.readPointer);
        end
        
        function writeSample(obj, inputSample)
            %write sample to the current write pointer location
            obj.buffer(obj.writePointer) = inputSample;
        end
        
        function sample = getSampleAtOffset(obj, offset)
            %Indexing here is done relative to the current location of the
            %write pointer. This allows for more flexability but more
            %caution is required. Assuming that you are starting at the
            %beginning of a time-step n, this would put the writePointer at
            %the next location to be written to. One location behind it
            %corresponds to x[n-1], and after writing to the location it
            %will point to x[n] and need to be updated.
            
            indexPointer = obj.writePointer - offset;
            
            %If we go beyond the start of the buffer we need to wrap things
            %around to the other end.
            if(indexPointer < 1)
                indexPointer = indexPointer + length(obj.buffer);
            end
            
            sample = obj.buffer(indexPointer);
        end
        
        function incrementDelay(obj)
            assert(obj.bufferDelay ~= obj.maxDelay, "We have reached the maximum delay line length.")
            obj.bufferDelay = obj.bufferDelay + 1;
            obj.decrementReadPointer()
        end
        
        function decrementDelay(obj)
            assert(obj.bufferDelay ~= obj.minDelay)
            obj.bufferDelay = obj.bufferDelay - 1;
            obj.incrementReadPointer()
            
        end
        
        function incrementPointers(obj)
            obj.incrementWritePointer();
            obj.incrementReadPointer();
        end
        
        function incrementWritePointer(obj)
            obj.writePointer = obj.writePointer + 1;
            if obj.writePointer > length(obj.buffer)
                obj.writePointer = 1;
            end
        end
        
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
        
        function bufferLength = getBufferLength(obj)
            bufferLength = length(obj.buffer);
        end
        
        function initializeBuffer(obj, newData)
            %This initializes all the locations allocated to the buffer.
            assert(length(newData) == length(obj.buffer), 'New data must match existing buffer dimensions');
            %TODO: Should this also reset the read/write pointers?
            obj.buffer = newData;
        end
        
        function initializeDelayLine(obj, newData)
            %This only initializes the locations assocaited with the
            %current delay setting.
            assert(length(newData) == obj.bufferDelay, 'New data must match current delay setting');
            obj.buffer(1:obj.bufferDelay) = newData;
        end
    end
end