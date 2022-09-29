classdef ZeroPoleSpec
    %ZeroPoleSpec Keeps track of the data similar to how longitudinal mode
    %filters are specifed in CMJ paper
    
    properties
        F
        R
    end
    
    methods
        function obj = ZeroPoleSpec(F, R)           
            obj.F = F;
            obj.R = R;
        end
    end
end

