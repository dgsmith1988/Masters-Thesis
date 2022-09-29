classdef SmoothingFilter
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
        end
    end
end

