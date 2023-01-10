classdef InterpolatedDelayLine < AudioProcessor
    properties (GetAccess = public)
        delay  %float indicating amount of dealy implemented
    end
    
    properties (Abstract)
        %There the values to be interpolated are stored. This is made
        %abstract to simplify sub-class constructor implementation.
        circularBuffer  
    end
end

