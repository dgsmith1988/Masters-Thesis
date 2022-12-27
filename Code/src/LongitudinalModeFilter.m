classdef LongitudinalModeFilter < FilterObject
    %LONGITUDINALMODEFILTER - TODO:Rename this to something more
    %functionality agnostic as technically this doesn't have any code in it
    %which is aware of the larger processing context that this operates in
    methods
        function obj = LongitudinalModeFilter(filterSpec)
            %LONGITUDINALMODEFILTER 
            complexZeros = linearToComplex(filterSpec.zeros.F, filterSpec.zeros.R, SystemParams.audioRate);
            complexPoles = linearToComplex(filterSpec.poles.F, filterSpec.poles.R, SystemParams.audioRate);
            [b, a] = zp2tf(complexZeros', complexPoles', db2mag(filterSpec.dB_atten));
            %start the filter to start from scratch
            z_init = zeros(1, max(length(filterSpec.zeros.F), length(filterSpec.poles.F))); 
            obj@FilterObject(b, a, z_init);
        end      
    end
end