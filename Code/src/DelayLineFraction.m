classdef DelayLineFraction < FilterObject
    %DELAYLINEFRACTION Class for fractional delay, uses 5th order Langrage
    %interpolation atm... 
    
    properties(GetAccess = public)
        fractionalDelay %fractional delay amount (0 <=x <= 1)
    end
    
    properties(Constant)
        L = 6           %number of taps - 6 was selected as best value for Lagrangian approach as per the papers
        integerDelay = 2;
    end
    
    methods
        function obj = DelayLineFraction(fractionalDelay)
            b = hlagr2(DelayLineFraction.L, fractionalDelay);
            a = 1;
            z_init = zeros(1, length(b)-1);
            obj@FilterObject(b, a, z_init)
%             obj.L = L;
            obj.fractionalDelay = fractionalDelay;
        end
        
        function setFractionalDely(newValue)
            fprintf("Warning: %s::%s() called and is a pass-thru function atm...\n", class(obj), dbstack.name);
        end
    end
end

