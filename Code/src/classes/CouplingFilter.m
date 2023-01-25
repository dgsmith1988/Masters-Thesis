classdef CouplingFilter < FilterObject
   
    properties
        Property1
    end
    
    methods
        function obj = CouplingFilter(couplingType)
            b = [];
            a = [];
            switch couplingType
                case "Full"
                    b = 1;
                    a = 1;
                case "None"
                    b = 0;
                    a = 1;
                otherwise
                    error("Invalid Coupling Type Passed");
            end
            obj@FilterObject(b, a, 0);
        end
    end
end

