classdef Lagrange < InterpolatedDelayLine
    properties(GetAccess = public)
        circularBuffer  %Circular buffer to store the data
        M               %Interger delay length
        N               %Lagrange interpolation order
        L               %Length of filter for Lagrange interp
        h               %Lagrange filter coefficients
        D               %Delay implemented by Lagrange component, D = floor(D) + d
        D_min           %Minimum D based on N
        d               %Fractional delay component
        x               %Internal buffer for computations, this holds x[n-M] to x[n-M-N] to perform the interpolation
    end
    
    methods
        function obj = Lagrange(N, delay)
            assert(mod(N, 2) ~= 0, "Lagrange interp order must be odd");
            obj.delay = delay;
            
            %Calculate the various derived values
            [obj.M, obj.D_min, obj.D, obj.d] = calculateInterpDelayLineComponents(N, delay);
            obj.N = N;
            obj.L = N + 1;
            obj.h = hlagr2(obj.L, obj.d);
            
            %Setup the buffer to hold the data
            obj.circularBuffer = CircularBuffer(obj.M + obj.N);
            
            %Initialize the buffer for the interpolation computations
            obj.x = zeros(1, obj.L);
        end
        
        function outputSample = tick(obj, inputSample)
%             %this holds x[n-M] to x[n-M-N] to perform the interpolation
%             x = zeros(1, obj.L);
%             
%             %extract x[n-M]...x[n-M-N] from the circular buffer
%             n = 1;
%             for k = obj.M:obj.M+obj.N
%                 x(n) = obj.circularBuffer.getSampleAtDelay(k);
%                 n = n + 1;
%             end
%             
%             %perform the convolution sum with the Lagrange filter kernel
%             outputSample = sum((obj.h .* x));
            outputSample = obj.getCurrentSample();
            
            %update the buffer
            obj.circularBuffer.tick(inputSample);
        end
        
        function outputSample = getCurrentSample(obj)
            %extract x[n-M]...x[n-M-N] from the circular buffer
            n = 1;
            for k = obj.M:obj.M+obj.N
                obj.x(n) = obj.circularBuffer.getSampleAtDelay(k);
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
            obj.circularBuffer.incrementDelay();
            obj.M = obj.M + 1;
        end
        
        function decrementDelay(obj)
            %Increment the delay line by one sample
            obj.circularBuffer.decrementDelay();
            obj.M = obj.M - 1;
        end
        
        function bufferLength = getBufferLength(obj)
            bufferLength = obj.circularBuffer.getBufferLength();
        end
        
        function bufferDelay = getBufferDelay(obj)
            bufferDelay = obj.circularBuffer.delay;
        end
        
        function initializeBuffer(obj, data)
            %Initialize the entire buffer associated with the delay line
            obj.circularBuffer.initializeBuffer(data);
        end
        
        function initializeDelayLine(obj, data)
            %The start the buffer associated with the current delay length.
            %Everything else will be zeros.
            obj.circularBuffer.initializeDelayLine(data);
        end
    end
end

