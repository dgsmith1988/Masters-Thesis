classdef OnePole < LoopFilter & FilterObject
    %Class matching the parametrization of the loop filter specified in the
    %CMJ paper. One-pole low-pass parametrized by gain (g) and cut-off (a)
    %           g*(1 + a)
    %   H(z) = -----------
    %           1 + a*z^-1
    
    properties(GetAccess = public)
        %Polynomial coefficients for interpolation based on string length
        %to generate the a and g values
        a_pol
        g_pol
        
        %Corresponding a and g values from filter's H(z). Renamed due to
        %name clash with "a" in parent class FilterObject
        g_param
        a_param
    end
    
    properties(Constant)
        phaseDelay = 1/2;
    end
       
    methods
        function obj = OnePole(a_pol, g_pol, L_n)
            %L = relative string length
            %as we only have one pole there is only one delay element to
            %contend with
            obj@FilterObject(0, 0, 1);
            obj.a_pol = a_pol;
            obj.g_pol = g_pol;
            obj.updateFilter(L_n);
        end
        
        function updateFilter(obj, L_n)
            %Calculations taken from 1998 paper on developing calibration
            %for electric guitar synthesizer
            m_fret = relativeLengthToFretNumber(L_n);
            %g = g_0 + m_fret*g_1
            obj.g_param = obj.g_pol(1) + m_fret*obj.g_pol(2);
            %a = a_0 + m_fret*a_1
            obj.a_param = obj.a_pol(1) + m_fret*obj.a_pol(2);
            obj.b = obj.g_param*(1 + obj.a_param);
            obj.a = [1 obj.a_param];
        end
    end
end

