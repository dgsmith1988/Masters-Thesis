classdef StringSynth < handle
    %STRINGSYNTH Synthesizer for one particular string
    
    properties (GetAccess = public)
        woundFlag               %boolean indicating wound string or not  
        sampleRateConverter;    %this takes the control signal and makes it at audio rate
        feedbackLoop            %feedback loop which contains elements to implement string DWG
        %contactSoundGenerator  %unit adding slide/string contact noise
        antiAliasingFilter      %what's in a name, numbnuts?
        L_n                     %current relative string length
        lastOutputSample        %last output sample to implement feedback
    end
    
    methods
        function obj = StringSynth(stringParams, L_0)
            %L_0 = initial relative string length
            %Parse the string parameters
            obj.woundFlag = stringParams.n_w > 0;
            
            %Initialize the member variables
            obj.L_n = L_0;
            obj.lastOutputSample = 0;
            
            %Instaniate the different processing objects
            obj.sampleRateConverter = SampleRateConverter();
            obj.feedbackLoop = FeedbackLoop(stringParams, L_0);
%             obj.constactSoundGenerator = ContactSoundGenerator();
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
              
        function outputSample = tick(obj, L_n_controlRate)
            
            %upsample the control signal to the audio rate
            %TODO: Determine the best approach to this computationally
            %later, as for now this is just a pass-through and to serve as
            %a reminder.
            L_n_audioRate = obj.sampleRateConverter.tick(L_n_controlRate);
            
            %check to if the string length has changed before making any
            %adjustments to the underlying processing objects
            if (L_n_audioRate ~= obj.L_n)
                obj.L_n = L_n_audioRate;
                obj.feedbackLoop.consumeControlSignal(L_n_audioRate);
%                 obj.contactSoundGenerator.consumeControlSignal(L_n);                
            end
            
            %TODO:Add a block to scale the noise and generate plucks at a
            %specified scale? Well in a more controlled manner...
            loopOutput = obj.feedbackLoop.tick(obj.lastOutputSample);
%             CSGoutput = obj.contactSoundGenerator.tick();
            CSGOutput = 0;
            
            %Store this to implement the feedback on the next computation
            obj.lastOutputSample = loopOutput + CSGOutput;
            
            %Filter the output before sending it out incase aliasing
            %occured when the delay-line length changed
            outputSample = obj.antiAliasingFilter.tick(obj.lastOutputSample);
%             outputSample = obj.lastOutputSample;
        end
    end
end

