classdef ContactSoundGenerator < handle
    properties
        g_bal = .5; %TODO: how to tune this?
        g_TV = 1;
        g_user = 1;
        n_w = 1; %TODO: how to tune this?
        stringModeFilter
        resonator
        noiseSource
        smoothingFilter = SmoothingFilter();
        L_n_1 = 0;
        %TODO: Add a waveshaper function property? Can Matlab do this?
    end
    
    methods
        function obj = ContactSoundGenerator()
            %These values came from nowhere atm...
            pulsePeriod = .05*SystemParams.audioRate;
%             obj.noiseSource = NoisePulse(pulsePeriod, -1, -60, pulsePeriod);
            obj.noiseSource = Noise();
            obj.resonator = ResonatorFilter(500, .99);
            obj.stringModeFilter = LongitudinalModeFilter(SystemParams.E_string.brass);
        end
        
        function outputSample = tick(obj, L_n)
            %TICK - L_n is the current value for the string length
            
            %calculate the lower branch first to obtain the cut-off
            %frequency value
            f_c_n = obj.n_w*abs(obj.smoothingFilter.tick(L_n - obj.L_n_1));
            
            %update the objects which rely on the cut-off frequency
            obj.resonator.update_f_c(f_c_n);
            obj.noiseSource.consume_f_c(f_c_n);
            obj.g_TV = f_c_n/100; %TODO: Eventually tune this parameter
            
            %compute the upper branches
            noiseSample = obj.noiseSource.tick();        
            v1 = (1-obj.g_bal)*obj.stringModeFilter.tick(noiseSample);
            %tanh is the waveshaping function here
            v2 = obj.g_bal*tanh(obj.resonator.tick(noiseSample));           
            
            %combine the various branches and scale appropriately
            outputSample = obj.g_user*obj.g_TV*(v1 + v2);
%             outputSample = noiseSample;
            
            %update any delay elements as need be. only the string length
            %to be concerned with here...
            obj.L_n_1 = L_n;
        end
        
        function set_g_user(obj, newValue)
            obj.g_user = newValue;
        end
    end
end