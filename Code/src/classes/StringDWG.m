classdef StringDWG < Controllable & AudioGenerator     
    properties
        openString_f0           %open string fundamental frequency in Hz
        pitch_f0                %selected pitch based on relative string length        
        g_c_n                   %compensation coefficient
        DWGLength               %current DWG length in samples
        interpolatedDelayLine   %delay line which allows for fractional delay components
        energyScaler            %calculates compensation coefficient
        loopFilter              %loop filter implementing string decay/body effects
        y_n_1 = 0               %last output sample to implement feedback
    end
    
    methods
        function obj = StringDWG(stringParams, L_init)
            %L_init is the string length the system starts at as at each
            %time sample (including n = 0) a value for L[n] will be passed
            %into the larger synthesis context
            obj.g_c_n = 1;
            obj.openString_f0 = stringParams.f0;
            obj.pitch_f0 = calculatePitchF0(L_init, obj.openString_f0);
            obj.DWGLength = calculateTotalDWGLength(obj.pitch_f0, SystemParams.audioRate);
            
            %Construct/update the processing objects based on the parameters
            obj.loopFilter = LoopOnePole(stringParams.a_pol, stringParams.g_pol, L_init);
            obj.interpolatedDelayLine = Lagrange(SystemParams.lagrangeOrder, obj.DWGLength);
            obj.energyScaler = EnergyScaler(obj.DWGLength);
        end
        
        function y_n = tick(obj, x_n)
            %See signal flow diagram for signal names.
            
            %Implement the feedback
            v_n = obj.y_n_1 + x_n;
            
            %Run through all the various processing objects to generate the
            %next sample.
            interpDelayOut = obj.interpolatedDelayLine.tick(v_n);
            y_n = obj.loopFilter.tick(obj.g_c_n*interpDelayOut);
            
            %Store the output for the next iteration
            obj.y_n_1 = y_n;
        end
        
        function consumeControlSignal(obj, L_n)
            %Calculate the various derived parameters first
            obj.pitch_f0 = calculatePitchF0(L_n, obj.openString_f0);
            obj.DWGLength = calculateTotalDWGLength(obj.pitch_f0, SystemParams.audioRate);
            delayLineLength = calculateInterpDelayLineLength(obj.DWGLength, obj.loopFilter.phaseDelay);
            
            %Update the different processing objects based on the new
            %derived parameters
            obj.g_c_n = obj.energyScaler.tick(obj.DWGLength);
            obj.interpolatedDelayLine.setDelay(delayLineLength);           
            obj.loopFilter.consumeControlSignal(L_n);
        end
        
        function pluck(obj)
            %TODO: Examine how different types of noise/exictations could
            %be used here to make the string sound better
            
            bufferLength = obj.interpolatedDelayLine.getBufferLength;
%             bufferData = 1 - 2*rand(1, bufferLength);
            bufferData = pinknoise(1, bufferLength);
            
            %normalize the data and remove the DC bias
            bufferData = bufferData / max(abs(bufferData));
%             bufferData = highpass(bufferData, 200, SystemParams.audioRate, Steepness=.99, StopBandAttenuation=80);
%             bufferData = bufferData - mean(bufferData);
%             bufferData = obj.dcBlocker.tick(bufferData);
            obj.interpolatedDelayLine.initializeDelayLine(bufferData);
        end
    end
end

