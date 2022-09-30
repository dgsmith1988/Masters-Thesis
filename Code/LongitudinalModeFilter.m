classdef LongitudinalModeFilter < FilterObject
    %LONGITUDINALMODEFILTER  
    methods
        function obj = LongitudinalModeFilter(filterSpec)
            %LONGITUDINALMODEFILTER 
            complexZeros = linearToComplex(filterSpec.zeros.F, filterSpec.zeros.R, SystemParams.audioRate);
            complexPoles = linearToComplex(filterSpec.poles.F, filterSpec.poles.R, SystemParams.audioRate);
            [b, a] = zp2tf(complexZeros', complexPoles', db2mag(filterSpec.dB_atten));
            %start the filter to start from scratch
            z_init = zeros(1, max(length(filterSpec.zeros.F), length(filterSpec.poles.F))-1); 
            obj@FilterObject(b, a, z_init);
%             [obj.b, obj.a] = zp2tf(complexZeros', complexPoles', db2mag(0));
        end      
    end
end