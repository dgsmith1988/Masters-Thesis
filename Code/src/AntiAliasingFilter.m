classdef AntiAliasingFilter < FilterObject  
    properties (Constant)
        order = 6
        cutOffFreq = .35 %normalized specification
    end
    
    methods
        function obj = AntiAliasingFilter()
            [b, a] = butter(AntiAliasingFilter.order, AntiAliasingFilter.cutOffFreq);
            z_init = zeros(1, max(length(b), length(a))-1); 
            obj@FilterObject(b, a, z_init);
        end       
    end
end

