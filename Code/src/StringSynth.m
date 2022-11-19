classdef StringSynth < handle
    %STRINGSYNTH Synthesizer for one particular string
    
    properties (GetAccess = public)
        woundFlag               %boolean indicating wound string or not       
        feedbackLoop            %feedback loop which contains elements to implement string DWG
        %contactSoundGenerator  %unit adding slide/string contact noise
        antiAliasingFilter      %what's in a name, numbnuts?
        L_n                     %current relative string length
        lastOutputSample         %last output sample to implement feedback
    end
    
    methods
        function obj = StringSynth(stringParams, L_0)
            %L_0 = initial relative string length
            %Parse the string parameters
            obj.woundFlag = stringParams.n_w > 0;
            obj.L_n = L_0;
            obj.lastOutputSample = 0;
            %Calculate the derived object parameters
            obj.feedbackLoop = FeedbackLoop(stringParams, L_0);
%             obj.constactSoundGenerator = ContactSoundGenerator();
            obj.antiAliasingFilter = AntiAliasingFilter();
        end
        
        function pluck(obj)
            %This function prepares the string model to start generating
            %sound
            %TODO: Examine how different types of noise/exictations could
            %be used here to make the string sound better
            %             bufferData = 1 - 2*rand(1, length(obj.integerDelayLine.buffer));
            bufferData = pinknoise(length(obj.feedbackLoop.integerDelayLine.buffer))';
            %Normalize the signal to make it stronger
            bufferData = bufferData / max(abs(bufferData));
            obj.feedbackLoop.integerDelayLine.initializeBuffer(bufferData);
        end
              
        function outputSample = tick(obj, L_n)
            %check to if anything changed before making adjustments to
            %underlying objects
            if (L_n ~=obj.L_n)
                obj.L_n = L_n;
                obj.feedbackLoop.consumeControlSignal(L_n);
                obj.contactSoundGenerator.consumeControlSignal(L_n);                
            end
            
            %TODO:Add the CSG component
            loopOutput = obj.feedbackLoop.tick(obj.lastOutputSample);
%             CSGoutput = obj.contactSoundGenerator.tick();
            CSGOutput = 0;
            
            %Store this to implement the feedback on the next computation
            obj.lastOutputSample = loopOutput + CSGOutput;
            
            %Filter the output before sending it out incase aliasing
            %occured when the delay-line length changed
            outputSample = obj.antiAliasingFilter.tick(obj.lastOutputSample);
        end
    end
end

