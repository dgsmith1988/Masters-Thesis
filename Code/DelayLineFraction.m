classdef DelayLineFraction < handle
    %DELAYLINEFRACTION Class for fractional delay, uses 5th order Langrage
    %interpolation atm... 
    
    properties
        L               %number of taps
        fractionalDelay %fractional delay amount (0 <=x <= 1)
        b               %FIR filter coefficents
        z               %filter memory state
    end
    
    methods
        function obj = DelayLineFraction(L, fractionalDelay)
            %DELAYLINEFRACTION Construct an instance of this class
            obj.L = L;
            obj.fractionalDelay = fractionalDelay;
            obj.b = hlagr2(L, fractionalDelay);
            obj.z = zeros(1, length(obj.b)-1);
        end
        
        function outputSample = tick(obj, inputSample)
            %tick Compute one-sample of output
            [outputSample, obj.z] = filter(obj.b, 1, inputSample, obj.z);
        end
    end
end

