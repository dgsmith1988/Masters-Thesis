classdef FeedbackLoop < handle
    %Class to encapsulate the various processing elements in the feedback
    %loop to make it eaiser to debug and understand things. It is like the
    %String DWG minus the feedback connection which causes the reflection
    %essentially.
    
    %TOOD: Is there a way to run this at half the sampling rate to save
    %computations?
    
    properties
        openString_f0           %open string fundamental frequency in Hz
        pitch_f0                %selected pitch based on relative string length
        interpolatedDelayLine   %delay line which allows for fractional delay components
        energyScaler            %calculates compensation coefficient
        g_c_n                   %compensation coefficient
        loopFilter              %loop filter implementing string decay/body effects
        DWGLength               %current DWG length in samples
    end
    
    methods
        function obj = FeedbackLoop(stringParams, L_0)
            obj.g_c_n = 1;
            obj.openString_f0 = stringParams.f0;
            obj.pitch_f0 = calculatePitchF0(L_0, obj.openString_f0);
            obj.DWGLength = calculateTotalDWGLength(obj.pitch_f0, SystemParams.audioRate);
            
            %Construct/update the processing objects based on the parameters
            obj.loopFilter = OnePole(stringParams.a_pol, stringParams.g_pol, L_0);
            obj.interpolatedDelayLine = InterpDelayLagrange(SystemParams.lagrangeOrder, obj.DWGLength);
            obj.energyScaler = EnergyScaler(obj.DWGLength);
        end
        
        function outputSample = tick(obj, feedbackSample)
            %Run through all the various processing objects to generate the
            %next sample
            interpDelayOut = obj.interpolatedDelayLine.tick(feedbackSample);
            outputSample = obj.loopFilter.tick(obj.g_c_n*interpDelayOut);
        end
        
        function consumeControlSignal(obj, L_n)
            %Calculate the various derived parameters first
            obj.pitch_f0 = calculatePitchF0(L_n, obj.openString_f0);
            obj.DWGLength = calculateTotalDWGLength(obj.pitch_f0, SystemParams.audioRate);
            
            %Update the different processing objects based on the new
            %derived parameters
            obj.g_c_n = obj.energyScaler.tick(obj.DWGLength);
            obj.interpolatedDelayLine.setDelay(obj.DWGLength);           
            obj.loopFilter.updateFilter(L_n);
        end
        
        function initializeDelayLine(obj)
            %TODO: Examine how different types of noise/exictations could
            %be used here to make the string sound better
            %             bufferData = 1 - 2*rand(1, length(obj.feedbackLoop.integerDelayLine.buffer));
            
            bufferLength = obj.interpolatedDelayLine.getBufferLength;
            bufferData = pinknoise(1, bufferLength);
            bufferData = bufferData / max(abs(bufferData));
            obj.interpolatedDelayLine.initializeDelayLine(bufferData);
        end
    end
end

