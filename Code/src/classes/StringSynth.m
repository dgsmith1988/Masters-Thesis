classdef StringSynth < Controllable & AudioGenerator
    %STRINGSYNTH Synthesizer for one particular string
    
    properties (GetAccess = public)
        feedbackLoop            %feedback loop which contains elements to implement string DWG
        contactSoundGenerator   %unit adding slide/string contact noise
        antiAliasingFilter      %what's in a name?
        lastOutputSample        %last output sample to implement feedback
        L_n_1                   %previous L_n value
    end
    
    methods
        function obj = StringSynth(stringParams, stringModeFilterSpec, L_0)
            %Initialize the member variables
            obj.L_n_1 = L_0;
            obj.lastOutputSample = 0;
            
            %Instaniate the different processing objects
            obj.feedbackLoop = FeedbackLoop(stringParams, L_0);
            
            %Determine which contact sound generator to use whether we have
            %a wound string or not. Dummy one is used to test the string
            %model without friction sounds.
            if(stringParams.n_w > 0)
                obj.contactSoundGenerator = CSG_wound(stringParams, stringModeFilterSpec, "PulseTrain", "ResoTanh", L_0);                
            elseif(stringParams.n_w == 0)
                obj.contactSoundGenerator = CSG_unwound(stringParams, L_0);
            else
                obj.contactSoundGenerator = CSG_dummy();
            end
            
            obj.antiAliasingFilter = AntiAliasing();
        end
        
        function pluck(obj)
            %This function prepares the string model to start generating
            %sound            
            obj.feedbackLoop.initializeDelayLine();            
        end
        
        function consumeControlSignal(obj, L_n)
            if(L_n ~= obj.L_n_1)
                %Update the various system parameters
                obj.feedbackLoop.consumeControlSignal(L_n);
                obj.contactSoundGenerator.consumeControlSignal(L_n);
                obj.L_n_1 = L_n;
            end
        end
        
        function [outputSample, feedbackLoopOutput, CSGOutput] = tick(obj)         
            %TODO:Add a block to scale the noise and generate plucks at a
            %specified scale? Well in a more controlled manner...
            feedbackLoopOutput = obj.feedbackLoop.tick(obj.lastOutputSample);
            CSGOutput = obj.contactSoundGenerator.tick();
            
            %Store this to implement the feedback on the next computation
            obj.lastOutputSample = feedbackLoopOutput + CSGOutput;
%             obj.lastOutputSample = feedbackLoopOutput;
            
            %Filter the output before sending it out incase aliasing
            %occured when the delay-line length changed
            outputSample = obj.antiAliasingFilter.tick(obj.lastOutputSample);
%             outputSample = obj.antiAliasingFilter.tick(CSGOutput + feedbackLoopOutput);
        end
    end
end

