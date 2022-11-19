classdef StringParams
    %STRINGPARAMS Class to hold string parameters based on specifications
    %from masters
   
    properties (GetAccess = public)
        number          %string number (6 = E, A = 5, ... 1 = e)
        decayRate       %noise pulse parameter
        pulseLength     %noise pulse parameter
        n_w             %windings per cm on string %TODO: Fix up units here
        f0              %fundamental frequency for tuning
        a_pol           %table 2 from 1996 - Developmentand Calibration of a Guitar Synthesizer          
        g_pol           %table 1 from 1996 - Developmentand Calibration of a Guitar Synthesizer          
    end
    
    methods
        function obj = StringParams(decayRate, pulseLength, n_w, number, f0, a_pol, g_pol)
            obj.number = number;
            obj.decayRate = decayRate;
            obj.pulseLength = pulseLength;
            obj.n_w = n_w;
            obj.f0 = f0;
            obj.a_pol = a_pol;
            obj.g_pol = g_pol;
        end
    end
end

