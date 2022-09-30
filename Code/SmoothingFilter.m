classdef SmoothingFilter < FilterObject
    %SMOOTHIGNFILTER Dummy class until this is necessary to implement. 
    %Eventually this will contain a polynomial interpolation filter.
    
    properties
    end
    
    methods
        function obj = SmoothingFilter()
            %SMOOTHINGFILTER 
        end
        
        function outputSample = tick(obj, inputSample)
            %TICK Simple pass-thru for now
            outputSample = inputSample;
            fprintf("Warning: %s::%s() called and is a pass-thru function atm...\n", class(obj), dbstack.name);
        end
    end
end

