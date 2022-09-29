classdef ResonatorFilter < handle
    %RESONATORFILTER Second order resonator filter with normalized gain
  
    properties
        b = [0, 0, 0];  %b1 should always be 0
        a = [1, 0, 0];  %a1 should always be 1
        z = [0, 0];
        Fs
        f_c
        r
    end
    
    methods
        function obj = ResonatorFilter(f_c, r, Fs)
            %RESONATORFILTER Construct an instance of this class
            %   Detailed explanation goes here
            obj.f_c = f_c;
            obj.r = r;
            obj.Fs = Fs;
            obj.updateCoefficients();
        end
        
        function outputSample = tick(obj, inputSample)
            [outputSample, obj.z] = filter(obj.b, obj.a, inputSample, obj.z);
        end
        
        function update_f_c(obj, f_c)
            obj.f_c = f_c;
            obj.update_a2Coefficient()
        end
        
        function update_r(obj, r)
            %Calculate filter coefficients based on value passed in
            obj.r = r;
            obj.updateCoefficients();         
        end
        
        function updateCoefficients(obj)
            obj.update_a2Coefficient();
            obj.a(3) = obj.r^2;
            obj.b(1) = (1 - obj.r^2)/2;
            obj.b(3) = -obj.b(1);
        end
        
        function update_a2Coefficient(obj)
            obj.a(2) = -2*obj.r*cos(2*pi*obj.f_c/obj.Fs);
        end
    end
end

