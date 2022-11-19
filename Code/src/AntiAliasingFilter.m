classdef AntiAliasingFilter < FilterObject
    %Just use a 6th Order Butterworth LPF here for now... 
    
    properties (Constant)
        order = 6
        cutOffFreq = .5 %normalized specification
    end
    
    methods
        function obj = AntiAliasingFilter()
            %ANTIALIASINGFILTER Construct an instance of this class
            %   Detailed explanation goes here
            [b, a] = butter(AntiAliasingFilter.order, AntiAliasingFilter.cutOffFreq);
            z_init = zeros(1, max(length(b), length(a))-1); 
            obj@FilterObject(b, a, z_init);
        end       
    end
end

