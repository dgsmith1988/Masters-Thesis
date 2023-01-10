classdef FilterSpec
    %Class for organizing the longitudinal mode filter specifications based
    %on how they are provided in the CMJ article
    properties
        zeros
        poles
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

