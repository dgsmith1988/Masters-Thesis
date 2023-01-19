classdef DCBlocker < FilterObject
    %https://ccrma.stanford.edu/~jos/filters/DC_Blocker_Frequency_Response.html
    
    properties
        g
        R
    end
      
    methods
        function obj = DCBlocker(R)
            g = (1+R)/2;
            b = g*[1 -1];
            a = [1 -R];
            z_init = 0;
            
            obj@FilterObject(b, a, z_init);
            obj.R = R;
            obj.g = g;
        end
    end
end

