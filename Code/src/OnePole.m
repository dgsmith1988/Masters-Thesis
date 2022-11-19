classdef OnePole < LoopFilter & FilterObject
    %Class matching the parametrization of the loop filter original
    %specified in the CMJ paper
    %TODO: Determine the best way to verify correct implementation here
    
    properties
        a_pol
        g_pol 
    end
    
    properties(Constant)
        phaseDelay = 1/2;
    end
       
    methods
        function obj = OnePole(a_pol, g_pol, L)
            %L = relative string length
            %as we only have one pole there is only one delay element to
            %contend with
            obj@FilterObject(0, 0, 1);
            obj.a_pol = a_pol;
            obj.g_pol = g_pol;
            obj.updateFilter(L);
        end
        
        function updateFilter(obj, L)
            %TODO: Determine the best way to approach interpolation here
            %g = g_0 + 12*(L-1)*g_1
            g_loop = obj.g_pol(1) + 12*(L-1)*obj.g_pol(2);
            %g = (g_0 + 12*(L-1)*g_1) / 1000
            a_loop = (obj.a_pol(1) + 12*(L-1)*obj.a_pol(2))/1000;
            obj.b = g_loop*(1 + a_loop);
            obj.a = [1 a_loop];
        end
    end
end

