classdef AntiAliasing < FilterObject  
    properties (Constant)
        order = 6
        cutOffFreq = .35 %normalized specification
    end
    
    methods
        function obj = AntiAliasing()
            [b, a] = butter(AntiAliasing.order, AntiAliasing.cutOffFreq);
            z_init = zeros(1, max(length(b), length(a))-1); 
            obj@FilterObject(b, a, z_init);
        end       
    end
end

