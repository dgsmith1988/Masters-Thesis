classdef InterpDelayLagrange < handle
    properties
        M               %Interger delay length
        h               %Lagrange filter coefficients
        N               %Lagrange interpolation order
        L               %Length of filter for Lagrange interp
        circularBuffer  %Circular buffer to store the data
        D               %Delay implemented by Lagrange component, D = floor(D) + d
        D_min           %Minimum D based on N
        d               %Fractional delay component
    end
    
    methods
        function obj = InterpDelayLagrange(M, N, d)
            assert(mod(N, 2) ~= 0, "Lagrange interp order must be odd");
            
            %Calculate the various derived values
            obj.M = M;
            obj.N = N;
            obj.D_min = (N-1)/2;
            obj.D = (N-1)/2 + d; %TODO: This might not be named correctly
            obj.d = d;
            obj.L = N + 1;
            obj.h = hlagr2(obj.L, obj.d);
            
            %Setup the buffer to hold the data
            obj.circularBuffer = CircularBuffer(obj.M + obj.N);
        end
        
        function outputSample = tick(obj, inputSample)
            %hold x[n-M] to x[n-M-N] to perform the interpolation
            x = zeros(1, obj.L);
            
            %extract x[n-M]...x[n-M-N] from the circular buffer
            n = 1;
            for k = obj.M:obj.M+obj.N
                x(n) = obj.circularBuffer.getSampleAtDelay(k);
                n = n + 1;
            end
            
            %perform the convolution sum with the Lagrange filter kernel
            outputSample = sum((obj.h .* x));
            
            %update the buffer
            obj.circularBuffer.tick(inputSample);
        end
        
        function setDelay(obj, newValue)
            %Check to make sure the integer component doesn't change more
            %than 1 sample at a time            
            M_new = floor(newValue - obj.D_min);
            d_new = newValue - floor(newValue);
            
            diff_M = M_new - obj.M;
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
    end
end

