classdef ResonatorFilter < FilterObject
    %RESONATORFILTER Second order resonator filter with normalized gain
    %TODO: Reparametrize this to match the specifications from the second
    %order resonator in PD. This would include adding a Q factor as well as
    %some sort of interpolation to handle changing between center
    %frequencies more cleanly.
    
    properties
        f_c
        r
        f0 = SystemParams.E_string_params.f0; %TODO: Figure out where exactly to put this later
    end
    
    methods
        function obj = ResonatorFilter(f_c, r)
            %RESONATORFILTER Construct an instance of this class

            %Populate the superclass first
            b = [0, 0, 0];  %b1 should always be 0
            a = [1, 0, 0];  %a1 should always be 1
            z_init = [0, 0];     %start filter from fresh
            obj@FilterObject(b, a, z_init);
            
            %Populate the subclass properties
            obj.f_c = f_c;
            obj.r = r;
            obj.updateCoefficients();
        end
        
        function outputSample = tick(obj, inputSample)
            [outputSample, obj.z] = filter(obj.b, obj.a, inputSample, obj.z);
        end
        
        function consumeSlideVelocity(slideVelocity)
            %Porting of the bp_bw.pd patch from the Master's thesis. the
            %the formula they use can be re-written into the 2*pi*f_c*Ts
            %form which is more standardized and matches how this was
            %originally written
            new_f_c = (50*10^3)*slideVelocity*obj.f0;
            obj.update_f_c(new_f_c);
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
            obj.a(2) = -2*obj.r*cos(2*pi*obj.f_c/SystemParams.audioRate);
        end
    end
end

