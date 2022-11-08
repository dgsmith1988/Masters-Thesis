classdef StringParams
    %STRINGPARAMS Class to hold string parameters based on specifications
    %from masters
   
    properties (GetAccess = public)
        number          %string number (6 = E, A = 5, ... 1 = e)
        decayRate       %noise pulse parameter
        pulseLength     %noise pulse parameter
        windsParam      %windings per cm on string
        f0              %fundamental frequency for tuning
    end
    
    methods
        function obj = StringParams(decayRate, pulseLength, windsParam, number, f0)
            obj.number = number;
            obj.decayRate = decayRate;
            obj.pulseLength = pulseLength;
            obj.windsParam = windsParam;
            obj.f0 = f0;
        end
    end
end

