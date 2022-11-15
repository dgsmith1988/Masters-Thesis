classdef LoopFilter < FilterObject
    %LOOPFILTER     
    properties (GetAccess = public) 
        phaseDelay
        %Todo: It might be useful to develop a better naming scheme as the
        %parent class already has attributes named a
        g_LPF
        a_LPF
    end
    
    methods
        function obj = LoopFilter(g, a)
            %TODO: For now this is the LPF as specified in the KS paper to
            %get things working but will be configured to match the paper
            %later
            b_coeff = [.5, .5];
            a_coeff = 1;
            %TODO: Should this be initialized to noise as well?
            z_init = zeros(1, max(length(b_coeff), length(a_coeff))-1); 
            obj@FilterObject(b_coeff, a_coeff, z_init);
            obj.phaseDelay = 1/2; %Needs to come after the parent constructor for some reason...
            obj.g_LPF = g;
            obj.a_LPF = a;
        end
        function updateFilter(obj, L)
            %TODO: This function will take in the relative string length
            %and adjust the coefficients appropriately
        end
    end
end

