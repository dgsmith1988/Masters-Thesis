classdef StringSynth < handle
    %STRINGSYNTH Synthesizer for one particular string
    
    properties (GetAccess = public)
        sampleRateConverter;    %this takes the control signal and makes it at audio rate
        feedbackLoop            %feedback loop which contains elements to implement string DWG
        contactSoundGenerator   %unit adding slide/string contact noise
        antiAliasingFilter      %what's in a name?
        lastOutputSample        %last output sample to implement feedback
        L_n_1
    end
    
    methods
        function obj = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L_0)
            %Initialize the member variables
            obj.L_n_1 = L_0;
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
%             bufferData = pinknoise(length(obj.feedbackLoop.integerDelayLine.buffer))';
%             bufferLength = length(obj.feedbackLoop.integerDelayLine.buffer);
%             n = 0:bufferLength-1;
%             bufferData = sin(2*pi/bufferLength * n);
%             bufferData = [1 zeros(1, bufferLength-1)];
            %Normalize the signal to make it stronger
%             bufferData = bufferData / max(abs(bufferData));
%             obj.feedbackLoop.integerDelayLine.initializeBuffer(bufferData);
            D = SystemParams.maxDelayLineLength;
            L = 6;
            bufferData = pinknoise(D+floor(L/2));
            bufferData = bufferData / max(abs(bufferData));
            obj.feedbackLoop.farrowDelay =  dsp.VariableFractionalDelay('InterpolationMethod', 'Farrow',...
                'FilterLength', L, 'MaximumDelay', D, 'InitialConditions', bufferData);
        end
        
        function consumeControlSignal(obj, L_n)
            if(L_n ~= obj.L_n_1)
                %Update the various system parameters
                obj.feedbackLoop.consumeControlSignal(L_n);
                obj.contactSoundGenerator.consumeControlSignal(L_n);
                obj.L_n_1 = L_n;
            end
        end
        
        function outputSample = tick(obj)         
            %TODO:Add a block to scale the noise and generate plucks at a
            %specified scale? Well in a more controlled manner...
            loopOutput = obj.feedbackLoop.tick(obj.lastOutputSample);
            CSGOutput = obj.contactSoundGenerator.tick();
            
            %Store this to implement the feedback on the next computation
            obj.lastOutputSample = loopOutput + CSGOutput;
            
            %Filter the output before sending it out incase aliasing
            %occured when the delay-line length changed
            outputSample = obj.antiAliasingFilter.tick(obj.lastOutputSample);
        end
    end
end

