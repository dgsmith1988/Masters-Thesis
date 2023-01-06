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
%         integerDelayLine        %delay line implementing integer component
%         fractionalDelayLine     %delay line implementing fractional component
        farrowDelay             %temporary proof of concept until I can write my own
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
            
            %These objects are created before the delay line lengths are
            %calculated to facilitate how Matlab handles OOP
            obj.loopFilter = OnePole(stringParams.a_pol, stringParams.g_pol, L_0);
%             obj.fractionalDelayLine = LagrangeDelay(.5); %any value can be used here, as we update it later
%             [p_int, p_frac_delta] = calculateDelayLineLengths(obj.DWGLength, obj.loopFilter.phaseDelay, obj.fractionalDelayLine.integerDelay);
            
            %Construct/update the processing objects based on the parameters
%             obj.integerDelayLine = IntegerDelay(p_int);
%             obj.fractionalDelayLine.setFractionalDelay(p_frac_delta);
%             obj.farrowDelay = dsp.VariableFractionalDelay('InterpolationMethod', 'Farrow', 'FilterLength', 6, 'MaximumDelay', SystemParams.maxDelayLineLength);
            obj.energyScaler = EnergyScaler(obj.DWGLength);
        end
        
        function outputSample = tick(obj, feedbackSample)
            %Run through all the various processing objects to generate the
            %next sample
%             integerDelayOut = obj.integerDelayLine.tick(feedbackSample);
%             fractionalDelayOut = obj.fractionalDelayLine.tick(integerDelayOut);
            fractionalDelayOut = obj.farrowDelay(feedbackSample, obj.DWGLength);
            outputSample = obj.loopFilter.tick(obj.g_c_n*fractionalDelayOut);
        end
        
        function consumeControlSignal(obj, L_n)
            obj.pitch_f0 = calculatePitchF0(L_n, obj.openString_f0);
            obj.DWGLength = calculateTotalDWGLength(obj.pitch_f0, SystemParams.audioRate);
            obj.g_c_n = obj.energyScaler.tick(obj.DWGLength);
            
%             [p_int, p_frac_delta] = calculateDelayLineLengths(obj.DWGLength, obj.loopFilter.phaseDelay, obj.fractionalDelayLine.integerDelay);
%             if p_int ~= obj.integerDelayLine.delay
%                 obj.integerDelayLine.setDelay(p_int);
%             end
%             if p_frac_delta ~= obj.fractionalDelayLine.fractionalDelay
%                 obj.fractionalDelayLine.setFractionalDelay(p_frac_delta);
%             end
            
            obj.loopFilter.updateFilter(L_n);
        end
    end
end

