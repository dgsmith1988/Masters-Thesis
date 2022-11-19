classdef StringSynth < handle
    %STRINGSYNTH Synthesizer for one particular string
    
    properties (GetAccess = public)
        woundFlag               %boolean indicating wound string or not
        f0                      %fundamental frequency in Hz
        integerDelayLine        %delay line implementing integer component
        fractionalDelayLine     %dealy line implementing fractional component
        energyScaler            %calculates compensation coefficient
        loopFilter              %loop filter implementing string decay/body effects
        %contactSoundGenerator %unit adding slide/string contact noise
        antiAliasingFilter      %what's in a name, numbnuts?
        L_n;                    %current relative string length
        DWGLength;              %current DWG length in samples
    end
    
    methods
        function obj = StringSynth(stringParams, L_0)
            %L_0 = initial relative string length
            %Parse the string parameters
            obj.woundFlag = stringParams.n_w > 0;
            obj.f0 = stringParams.f0;
            obj.L_n = L_0;
            %Calculate the derived object parameters
            obj.DWGLength = obj.calculateTotalDWGLength();
            
            %These objects are created before the delay line lengths are
            %calculated to facilitate how Matlab handles OOP
            obj.loopFilter = OnePole(stringParams.a_pol, stringParams.g_pol, obj.L_n);
            obj.fractionalDelayLine = LagrangeDelay(.5);
            [p_int, p_frac_delta] = obj.calculateDelayLineLengths();
            
            %Construct/update the processing objects based on the parameters
            obj.integerDelayLine = IntegerDelay(p_int);
            obj.fractionalDelayLine.setFractionalDelay(p_frac_delta);
            obj.energyScaler = EnergyScaler(obj.DWGLength);
            obj.antiAliasingFilter = AntiAliasingFilter();
        end
        
        function pluck(obj)
            %This function prepares the string model to start generating
            %sound
            %TODO: Examine how different types of noise/exictations could
            %be used here to make the string sound better
%             bufferData = 1 - 2*rand(1, length(obj.integerDelayLine.buffer));
            bufferData = pinknoise(length(obj.integerDelayLine.buffer))';
            %Normalize the signal to make it stronger
            bufferData = bufferData / max(abs(bufferData));
            obj.integerDelayLine.initializeBuffer(bufferData);
        end
        
        function outputSample = tick(obj, L_n)
            %check to if anything changed before making adjustments to the
            %delay line lengths
            if (L_n ~=obj.L_n)
                obj.L_n = L_n;
                obj.DWGLength = obj.calculateTotalDWGLength();
                
                [p_int, p_frac_delta] = obj.calculateDelayLineLengths();
                if p_int ~= obj.integerDelayLine.delay
                    obj.integerDelayLine.setDelay(p_int);
                end
                if p_frac_delta ~= obj.fractionalDelayLine.fractionalDelay
                    obj.fractionalDelayLine.setFractionalDelay(p_frac_delta);
                end
                
                obj.loopFilter.updateLoopFilter(L_n);
            end
            
            %Run through all the various processing objects to generate the
            %next sample
            integerDelayOut = obj.integerDelayLine.getCurrentSample();
            fractionalDelayOut = obj.fractionalDelayLine.tick(integerDelayOut);
            g_c = obj.energyScaler.tick(obj.DWGLength);
            loopFilterOut = obj.loopFilter.tick(g_c*fractionalDelayOut);
            %TODO:Add the CSG component
            %Implement the feedback. Use tick here to coordiate the pointer
            %updates inside the delay line and ignore the output.
            obj.integerDelayLine.tick(loopFilterOut);
            outputSample = obj.antiAliasingFilter.tick(loopFilterOut);
        end
        
        function [p_int, p_frac_delta] = calculateDelayLineLengths(obj)
            %Calculate the parameters for the delay lines based on the
            %current filter objects in the DWG and system parameters
            
            %integer delay line length
            p_int = floor(obj.DWGLength - obj.loopFilter.phaseDelay - obj.fractionalDelayLine.integerDelay);
            %fractional component of fractional delay
            p_frac_delta = obj.DWGLength - p_int - obj.loopFilter.phaseDelay - obj.fractionalDelayLine.integerDelay;
        end
        
        function DWGLength = calculateTotalDWGLength(obj)
            %Calculate the overall delay line length based on the string
            %length, open string f0 and audioRate
            DWGLength = SystemParams.audioRate * (obj.L_n / obj.f0);
        end
    end
end

