classdef StringSynth < handle
    %STRINGSYNTH Synthesizer for one particular string
    
    properties
        woundFlag               %boolean indicating wound string or not
        f0                      %fundamental frequency in Hz
        integerDelayLine        %delay line implementing integer component
        fractionalDelayLine     %dealy line implementing fractional component
%         g_c                   %energy compensation coefficient
        loopFilter              %loop filter implementing string decay/body effects
%         contactSoundGenerator %unit adding slide/string contact noise
    end
    
    methods
        function obj = StringSynth(stringParams)
            %Parse the string parameters
            obj.woundFlag = stringParams.n_w > 0;
            obj.f0 = stringParams.f0;
            
            %Construct the loop filter. Object construction order is a bit
            %odd based on dependency of the parameters
            obj.loopFilter = LoopFilter(0, 0);
            
            %Calculate the parameters for the delay lines
            %loop filter delay
            p_loop = obj.loopFilter.phaseDelay;
            %integer aspect of the fractional delay
            p_frac_int = DelayLineFraction.integerDelay;
            %integer delay line length
            p_int = floor(SystemParams.audioRate/obj.f0 - p_loop - p_frac_int);
            %fractional component of fractional delay
            p_frac_delta = SystemParams.audioRate/obj.f0 - p_int - p_loop;
            
            %Construct the delay lines based on the parameters
            obj.integerDelayLine = DelayLineInteger(p_int);
            obj.integerDelayLine.fillWithNoise();
            obj.fractionalDelayLine = DelayLineFraction(p_frac_delta);
            %TODO:Figure out how to initialze all these different strings
        end
        
        function outputSample = tick(obj)
            %Todo: Come up with better names for these and perhaps label
            %them on a graph
            integerDelayOut = obj.integerDelayLine.getCurrentSample();
            fractionalDelayOut = obj.fractionalDelayLine.tick(integerDelayOut);
            loopFilterOut = obj.loopFilter.tick(fractionalDelayOut);
            outputSample = loopFilterOut; %TODO:Eventually add the CSG component
            %Implement the feedback
            obj.integerDelayLine.writeSample(outputSample);
        end
    end
end

