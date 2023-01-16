classdef HarmonicResonatorBank < HarmonicAccentuator
    %HARMONICRESONATORBANK Haromnic accentuator formed by a bank of six
    %harmonically linked resonators controlled by f_c[n]
    
    properties
        %each number corresponds to the haromnic the resonator emphasizes
        %6 resonators were chosen based on the number of haromnics which
        %appear in the spectrograms of figure 2 in the CMJ article
        resonator_1
        resonator_2
        resonator_3
        resonator_4
        resonator_5
        resonator_6
        lowPass
        %TODO: Determine the best values to tune these to through
        %measurement for each string/slide type
        h = db2mag([0 -2.5 -5 -7.5 -10 -12.5 -15]); %this holds the different relative strengths of each harmonic
%         h = db2mag(zeros(1, HarmonicResonatorBank.numResonators)); %this holds the different relative strengths of each harmonic
    end
    
    properties(Constant)
        numResonators = 6;
    end
    
    methods
        function obj = HarmonicResonatorBank(f_c, r)
            obj.resonator_1 = Resonator(f_c, r);
            obj.resonator_2 = Resonator(f_c, r);
            obj.resonator_3 = Resonator(f_c, r);
            obj.resonator_4 = Resonator(f_c, r);
            obj.resonator_5 = Resonator(f_c, r);
            obj.resonator_6 = Resonator(f_c, r);
            obj.lowPass = LowPass(f_c);
        end
        
        function outputSample = tick(obj, inputSample)
            %Buffer to store the outputs
            y = zeros(1, obj.numResonators+1);
            
            y(1) = obj.resonator_1.tick(inputSample);
            y(2) = obj.resonator_2.tick(inputSample);
            y(3) = obj.resonator_3.tick(inputSample);
            y(4) = obj.resonator_4.tick(inputSample);
            y(5) = obj.resonator_5.tick(inputSample);
            y(6) = obj.resonator_6.tick(inputSample);
%             y(7) = obj.lowPass.passThru(0);
            
            %Apply the relative amplitdues and sum the filter outputs to
            %generate the total output
            outputSample = sum(obj.h .* y);
        end
        
        function consumeControlSignal(obj, f_c_n)
            obj.resonator_1.update_f_c(1*f_c_n);
            obj.resonator_2.update_f_c(2*f_c_n);
            obj.resonator_3.update_f_c(3*f_c_n);
            obj.resonator_4.update_f_c(4*f_c_n);
            obj.resonator_5.update_f_c(5*f_c_n);
            obj.resonator_6.update_f_c(6*f_c_n);
%             obj.lowPass.update_f_c(6.5*f_c_n);
        end
    end
end