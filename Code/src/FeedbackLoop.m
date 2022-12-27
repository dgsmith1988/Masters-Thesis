classdef FeedbackLoop < handle
    %Class to encapsulate the various processing elements in the feedback
    %loop to make it eaiser to debug and understand things. It is like the
    %String DWG minus the feedback loop essentially.
    
    %TOOD: Is there a way to run this at half the sampling rate to save
    %computations?
    
    properties
        f0                      %open string fundamental frequency in Hz
        integerDelayLine        %delay line implementing integer component
        fractionalDelayLine     %dealy line implementing fractional component
        energyScaler            %calculates compensation coefficient
        loopFilter              %loop filter implementing string decay/body effects
        DWGLength               %current DWG length in samples
    end
    
    methods
        function obj = FeedbackLoop(stringParams, L_0)
            obj.f0 = stringParams.f0;
            obj.DWGLength = obj.calculateTotalDWGLength(L_0, obj.f0);
            
            %These objects are created before the delay line lengths are
            %calculated to facilitate how Matlab handles OOP
            obj.loopFilter = OnePole(stringParams.a_pol, stringParams.g_pol, L_0);
            obj.fractionalDelayLine = LagrangeDelay(.5); %any value can be used here, as we update it later
            [p_int, p_frac_delta] = obj.calculateDelayLineLengths();
            
            %Construct/update the processing objects based on the parameters
            obj.integerDelayLine = IntegerDelay(p_int);
            obj.fractionalDelayLine.setFractionalDelay(p_frac_delta);
            obj.energyScaler = EnergyScaler(obj.DWGLength);
        end
        
        function outputSample = tick(obj, feedbackSample)           
            %Run through all the various processing objects to generate the
            %next sample
            integerDelayOut = obj.integerDelayLine.tick(feedbackSample);
            fractionalDelayOut = obj.fractionalDelayLine.tick(integerDelayOut);
            g_c = obj.energyScaler.tick(obj.DWGLength);
            outputSample = obj.loopFilter.tick(g_c*fractionalDelayOut);
        end
        
        %Save this for now as you might be able to move this outside to the
        %calling object
        function consumeControlSignal(obj, L_n)
            obj.DWGLength = obj.calculateTotalDWGLength(L_n, obj.f0);
            
            [p_int, p_frac_delta] = obj.calculateDelayLineLengths(obj.DWGLength, obj.loopFilter.phaseDelay, obj.fractionalDelayLine.integerDelay);
            if p_int ~= obj.integerDelayLine.delay
                obj.integerDelayLine.setDelay(p_int);
            end
            if p_frac_delta ~= obj.fractionalDelayLine.fractionalDelay
                obj.fractionalDelayLine.setFractionalDelay(p_frac_delta);
            end
            
            obj.loopFilter.updateFilter(L_n);
        end
        
%         function [p_int, p_frac_delta] = calculateDelayLineLengths(obj)
%             %Calculate the parameters for the delay lines based on the
%             %current filter objects in the DWG and system parameters
%             
%             %integer delay line length
%             p_int = floor(obj.DWGLength - obj.loopFilter.phaseDelay - obj.fractionalDelayLine.integerDelay);
%             %fractional component of fractional delay
%             p_frac_delta = obj.DWGLength - p_int - obj.loopFilter.phaseDelay - obj.fractionalDelayLine.integerDelay;
%         end
        
%         function DWGLength = calculateTotalDWGLength(obj, L_n)
%             %Calculate the overall delay line length based on the string
%             %length, open string f0 and audioRate
%             DWGLength = SystemParams.audioRate * (L_n / obj.f0);
%         end
        
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
    end
    
    methods(Static)
        %This logic has been separated to make it easier to verify the
        %functionality is correct without instantiating an object. After
        %this has been verified then the objects will call the functions
        %using their own internal state and update the parameters
        %accordingly.
        
        function DWGLength = calculateTotalDWGLength(L_n, f0)
            DWGLength = SystemParams.audioRate * (L_n / f0);
        end
        
        function [p_int, p_frac_delta] = calculateDelayLineLengths(DWGLength, loopFilterDelay, fractionalDelayInteger)
            %Calculate the parameters for the delay lines based on the
            %various filter delays in the feedback loop. All lengths are in
            %samples
            %
            %Inputs:
            % DWGLength = total length of the digital wave guide
            % loopFilterDleay = phase delay associated with loop filter
            % fractionalDelayInteger = integer component associated with
            %   fractional delay implementation (i.e. 2 if delay = 2.5)
            %
            %Outputs:
            % p_int = integer delay line length
            % p_frac_delta = fractional component of fractional delay
                        
            p_int = floor(DWGLength - loopFilterDelay - fractionalDelayInteger);
            p_frac_delta = DWGLength - p_int - loopFilterDelay - fractionalDelayInteger;
        end
    end
end

