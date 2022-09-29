classdef LongitudinalModeFilter
    %LONGITUDINALMODEFILTER Wrapper class to keep track of the various data
    %involved in specifiying and implementing the longitudinal mode filters
    
    properties
        f_zeros
        R_zeros
        complexZeros
        f_poles
        R_poles
        complexPoles
        b
        a
        Fs
    end
    
    methods
        function obj = LongitudinalModeFilter(f_zeros, R_zeros, f_poles, R_poles, dB_atten, Fs)
            %LONGITUDINALMODEFILTER k should be set so that the maximum
            %gain of the filter is unity to match the pictures from the CMJ
            %article. TODO: Examine why this is the case in more detail
            obj.f_zeros = f_zeros;
            obj.R_zeros = R_zeros;
            obj.complexZeros = linearToComplex(f_zeros, R_zeros, Fs);
            obj.f_poles = f_poles;
            obj.R_poles = R_poles;
            obj.complexPoles = linearToComplex(f_poles, R_poles, Fs);
            %TODO:Determine the proper setting for this k value
            [obj.b, obj.a] = zp2tf(obj.complexZeros', obj.complexPoles', db2mag(dB_atten));
            obj.Fs = Fs;
        end      
    end
end

