classdef FilterObject < handle & AudioProcessor
    %LOOPFILTER Wrapper class to make it easier to manage the coefficients
    %and state of a filter across multiple calculations
    properties(GetAccess = public)
        a           %IIR coefficients
        b           %FIR coefficients
        z           %Filter state
    end
    
    properties (Constant)
        N = 4096;   %Number of FFT points
    end
    
    methods
        function obj = FilterObject(b, a, z_init)
            %FILTEROBJECT Construct an instance of this class
            obj.b = b;
            obj.a = a;
            obj.z = z_init;
        end
        
        function y = tick(obj, x)
            %FILTER Filter x to produce y based on current filter state
            [y, obj.z] = filter(obj.b, obj.a, x, obj.z);
        end
        
        function plotFrequencyResponse(obj)
            freqz(obj.b, obj.a, obj.N, SystemParams.audioRate);
        end
        
        function [h, f] = computeFrequencyResponse(obj)
            [h, f] = freqz(obj.b, obj.a, obj.N, SystemParams.audioRate);
        end
    end
end