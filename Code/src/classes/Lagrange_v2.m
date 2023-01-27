classdef Lagrange_v2 < CircularBuffer
    properties(GetAccess = public)
        M               %Interger delay length
        N               %Lagrange interpolation order
        L               %Length of filter for Lagrange interp
        h               %Lagrange filter coefficients
        D               %Delay implemented by Lagrange component, D = floor(D) + d
        D_min           %Minimum D based on N
        d               %Fractional delay component
        delay           %Total delay including fractional component
        x               %Internal buffer for computations, this holds x[n-M] to x[n-M-N] to perform the interpolation
    end
    
    methods
        function obj = Lagrange_v2(N, delay)
            assert(mod(N, 2) ~= 0, "Lagrange interp order must be odd");
            
            %Calculcate the delay components to be able to initialize the
            %parent
            [M, D_min, D, d] = calculateInterpDelayLineComponents(N, delay);
            
            obj@CircularBuffer(M + N);
            
            %Copy in the calculated values to the object
            obj.delay = delay;
            obj.M = M;
            obj.D_min = D_min;
            obj.D = D;
            obj.d = d;
            obj.N = N;
            
            %Calculate the various derived values
            obj.L = N + 1;
            obj.h = hlagr2(obj.L, obj.d);
            
            %Initialize the buffer for the interpolation computations
            obj.x = zeros(1, obj.L);
        end
        
        function outputSample = tick(obj, inputSample)
            %compute the next sample
            outputSample = obj.getCurrentSample();
            
            %write new sample
            obj.buffer(obj.writePointer) = inputSample;
            
            %increment pointers
            obj.incrementPointers();
        end
        
        function outputSample = getCurrentSample(obj)
            %extract x[n-M]...x[n-M-N] from the buffer
            n = 1;
            for k = obj.M:obj.M+obj.N
                obj.x(n) = obj.getSampleAtOffset(k);
                n = n + 1;
            end
            
            %perform the convolution sum with the Lagrange filter kernel
            outputSample = sum((obj.h .* obj.x));
        end
        
        function setDelay(obj, newValue)
            [M_new, ~, ~, d_new] = calculateInterpDelayLineComponents(obj.N, newValue);
            
            diff_M = M_new - obj.M;
            %Make sure we don't move more than 1 sample at a time as I
            %haven't tested the interpolation for that.
            assert(abs(diff_M) <= 1, "Integer part of delay line can't be adjusted more than one sample")
            
            if diff_M == 1
                obj.incrementDelay();
            elseif diff_M == -1
                obj.decrementDelay();
            end
            
            if d_new - obj.d ~= 0
                obj.setFractionalDelay(d_new);
            end
        end
        
        function setFractionalDelay(obj, newValue)
            obj.d = newValue;
            obj.D = floor(obj.D) + obj.d;
            obj.h = hlagr2(obj.L, obj.d);
        end
        
        function incrementDelay(obj)
            %Increment the delay line by one sample
            incrementDelay@CircularBuffer(obj);
            %Update the sub-class property
            obj.M = obj.M + 1;
        end
        
        function decrementDelay(obj)
            %Increment the delay line by one sample
            decrementDelay@CircularBuffer(obj);
            %Update the sub-class property
            obj.M = obj.M - 1;
        end
        
        function initializeNonInterpolatingPart(obj, newData)
            assert(length(newData) == obj.M, 'New data must have length M');
            obj.buffer(obj.N+1:obj.bufferDelay) = newData;
        end
    end
end