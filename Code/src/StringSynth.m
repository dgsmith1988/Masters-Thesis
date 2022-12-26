classdef StringSynth < handle
    %STRINGSYNTH Synthesizer for one particular string
    
    properties (GetAccess = public)
        sampleRateConverter;    %this takes the control signal and makes it at audio rate
        feedbackLoop            %feedback loop which contains elements to implement string DWG
        contactSoundGenerator   %unit adding slide/string contact noise
        antiAliasingFilter      %what's in a name?
        lastOutputSample        %last output sample to implement feedback
    end
    
    methods
        function obj = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L_0)           
            %Initialize the member variables
            obj.lastOutputSample = 0;
            
            %Instaniate the different processing objects
            obj.sampleRateConverter = SampleRateConverter();
            obj.feedbackLoop = FeedbackLoop(stringParams, L_0);
            
            %Determine which contact sound generator to use whether we have
            %a wound string or not. Dummy one is used to test the string
            %model without friction sounds.
            if(stringParams.n_w > 0)
                obj.contactSoundGenerator = CSG_wound(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L_0);
                
            elseif(stringParams.n_w == 0)
                obj.contactSoundGenerator = CSG_unwound(stringParams, L_0);
            else
                obj.contactSoundGenerator = CSG_dummy();
            end
            
            obj.antiAliasingFilter = AntiAliasingFilter();
        end
        
        function pluck(obj)
            %This function prepares the string model to start generating
            %sound
            %TODO: Examine how different types of noise/exictations could
            %be used here to make the string sound better
            %             bufferData = 1 - 2*rand(1, length(obj.feedbackLoop.integerDelayLine.buffer));
            %TODO: Examine if bandlimiting this helps with crackle issue
            bufferData = pinknoise(length(obj.feedbackLoop.integerDelayLine.buffer))';
            %Normalize the signal to make it stronger
            bufferData = bufferData / max(abs(bufferData));
            obj.feedbackLoop.integerDelayLine.initializeBuffer(bufferData);
        end
        
        function outputSample = tick(obj, L_n)
            %TODO:Add a block to scale the noise and generate plucks at a
            %specified scale? Well in a more controlled manner...
            loopOutput = obj.feedbackLoop.tick(obj.lastOutputSample, L_n);
            CSGOutput = obj.contactSoundGenerator.tick(L_n);
            
            %Store this to implement the feedback on the next computation
            obj.lastOutputSample = loopOutput + CSGOutput;
            
            %Filter the output before sending it out incase aliasing
            %occured when the delay-line length changed
            outputSample = obj.antiAliasingFilter.tick(obj.lastOutputSample);
        end
    end
end

