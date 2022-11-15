classdef FractionalDelay < handle
    %Abstract class to define common parameters all sub-subclasses must
    %adhere to
    
    properties(GetAccess = public)
        fractionalDelay %fractional delay amount (0 <=x <= 1)
    end
    
    properties(Abstract, Constant)
        %This is abstract as each filter type will have it's own value
        %here. We are assuming they are constant as well and each filter
        %approach has a particular range of delay values where it operates
        %best from a frequency response standpoint.
        integerDelay
    end
    
    methods(Abstract)
        setFractionalDelay(obj, newValue)
    end
end