classdef OnePole < LoopFilter & FilterObject
    %Class matching the parametrization of the loop filter original
    %specified in the CMJ paper
    %TODO: Determine the best way to verify correct implementation here
    
    properties
        a_pol
        g_pol
%         g_loop  %a and g parameters in the filter
%         a_loop
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
            m_fret = relativeLengthToFretNum(L_n);
            %g = g_0 + m_fret*g_1
            g_loop = obj.g_pol(1) + m_fret*obj.g_pol(2);
            %a = a_0 + m_fret*a_1
            a_loop = obj.a_pol(1) + m_fret*obj.a_pol(2);
            obj.b = g_loop*(1 + a_loop);
            obj.a = [1 a_loop];
            %TODO: Come back and revamp the tick function to more closely
            %match the PD patch calculations
            %TODO: Verify these calculations more in depth, i.e. plot the
            %different Fig 18/19 from the 1998 paper
        end
    end
end

