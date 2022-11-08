classdef SmoothingFilter < FilterObject
    %SMOOTHIGNFILTER Dummy class until this is necessary to implement. 
    %Eventually this will contain a polynomial interpolation filter.
    
    properties
    end
    
    methods
        function obj = SmoothingFilter()
            obj@FilterObject(0, 0, 0);
        end
        
        function outputSample = tick(obj, inputSample)
            %TICK Simple pass-thru for now
            outputSample = inputSample;
%             st = dbstack;
%             fprintf("Warning: %s() called and is a pass-thru function atm...\n", st(1).name);
        end
    end
end

