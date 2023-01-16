classdef HighPassOnePole < FilterObject
    %http://msp.ucsd.edu/techniques/v0.11/book-html/node141.html
    properties
        p
    end
    
    methods
        function obj = HighPassOnePole(p)
            b = p*[1 -1];
            a = [1, -p];
            z_init = 0;
            
            obj@FilterObject(b, a, z_init)            
            obj.p = p;
        end
    end
end

