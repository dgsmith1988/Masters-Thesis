classdef CouplingFilter < FilterObject
    %Keep this in place for now but ultimately if the filtering is shown to
    %be unnecessary then replace this with just a gain coefficient to make
    %things easier/simpler
    methods
        function obj = CouplingFilter(couplingType)
            b = [];
            a = [];
            switch couplingType
                case "Full"
                    b = 1;
                    a = 1;
                case "Partial"
                    b = .5;
                    a = 1;
                case "None"
                    b = 0;
                    a = 1;
                case "Filter"
                    error("This hasn't been implemented yet");
                otherwise
                    error("Invalid Coupling Type Passed");
            end
            obj@FilterObject(b, a, 0);
        end
    end
end

