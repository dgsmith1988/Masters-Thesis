classdef StringParams
    %STRINGPARAMS Class to hold string parameters based on specifications
    %from masters
   
    properties (GetAccess = public)
        number          %string number (6 = E, A = 5, ... 1 = e)
        f0              %fundamental frequency for tuning
        n_w             %windings per meter on string
        T60             %noise pulse parameter specifying T60 in seconds
        a_pol           %table 2 from 1996 - Developmentand Calibration of a Guitar Synthesizer          
        g_pol           %table 1 from 1996 - Developmentand Calibration of a Guitar Synthesizer          
    end
    
    methods
        function obj = StringParams(number, f0, n_w, T60, a_pol, g_pol)
            obj.number = number;
            obj.f0 = f0;
            obj.n_w = n_w;
            obj.T60 = T60;           
            obj.a_pol = a_pol;
            obj.g_pol = g_pol;
        end
    end
end

