classdef LoopFilter < handle
    %LOOPFILTER Wrapper class to make it easier to manage the loop filter
    %in a more consistent paradigm with the rest of the model
    
    properties
        a   %IIR coefficients
        b   %FIR coefficients
        z   %Filter state
    end
    
    methods
        function obj = LoopFilter(b, a, z_init)
            %FILTEROBJECT Construct an instance of this class
            obj.b = b;
            obj.a = a;
            obj.z = z_init;
        end
        
        function y = filter(obj, x)
            %FILTER Filter x to produce y based on current filter state
            [y, obj.z] = filter(obj.b, obj.a, x, obj.z);
        end
    end
end

