classdef HarmonicResonatorBank < HarmonicAccentuator
    %HARMONICRESONATORBANK Haromnic accentuator formed by a bank of six
    %harmonically linked resonators controlled by f_c[n]
    
    properties
        resonatorBank = []; %Array of Resonator filters
        h                   %Holds the relative linear strength of each harmonic
        y                   %Buffer to hold the filter outputs
    end
    
    methods
        function obj = HarmonicResonatorBank(h_dB, f_c, r)
            %Convert the dB values to linear for easier implmentation
            obj.h = db2mag(h_dB);
            
            %Fill the resonator bank array with the number of resonators
            %specified
            for k = 1:length(obj.h)
                obj.resonatorBank = [obj.resonatorBank, Resonator(f_c, r)];
            end
            
            %Initialize the output buffer
            obj.y = zeros(1, length(obj.h));
        end
        
        function outputSample = tick(obj, inputSample)
            %Loop through the resonator bank array and compute each
            %filter's output
            for k = 1:length(obj.resonatorBank)
                obj.y(k) = obj.resonatorBank(k).tick(inputSample);
            end
            
            %Apply the relative amplitdues and sum the filter outputs to
            %generate the total output
            outputSample = sum(obj.h .* obj.y);
        end
        
        function consumeControlSignal(obj, f_c_n)
            %Loop through the resonator bank array and compute each
            %filter's centre frequency
            for k = 1:length(obj.resonatorBank)
                obj.resonatorBank(k).update_f_c(k*f_c_n);
            end
        end
    end
end