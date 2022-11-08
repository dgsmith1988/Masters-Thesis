classdef DelayLineFraction < FilterObject
    %DELAYLINEFRACTION Class for fractional delay, uses 5th order Langrage
    %interpolation atm... 
    
    properties(GetAccess = public)
        L               %number of taps
        fractionalDelay %fractional delay amount (0 <=x <= 1)
    end
    
    methods
        function obj = DelayLineFraction(L, fractionalDelay)
            %DELAYLINEFRACTION Construct an instance of this class
            
            b = hlagr2(L, fractionalDelay);
            a = 1;
            z_init = zeros(1, length(b)-1);
            obj@FilterObject(b, a, z_init)
            obj.L = L;
            obj.fractionalDelay = fractionalDelay;
        end
        
        function setFractionalDely(newValue)
            fprintf("Warning: %s::%s() called and is a pass-thru function atm...\n", class(obj), dbstack.name);
        end
    end
end

