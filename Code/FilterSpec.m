classdef FilterSpec
    properties
        poles
        zeros
        dB_atten
    end
    
    methods
        function obj = FilterSpec(zeros, poles, dB_atten)        
            obj.poles = poles;
            obj.zeros = zeros;
            obj.dB_atten = dB_atten;
        end       
    end
end

