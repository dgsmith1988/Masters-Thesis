classdef StringDWGInt < Controllable & AudioGenerator
    %Class which has no loop filter/energey scaler and uses an integer 
    %delay line for illustrative purposes on bandwidth limitations
    properties
        openString_f0           %open string fundamental frequency in Hz
        pitch_f0                %selected pitch based on relative string length
        DWGLength               %current DWG length in samples
        
        integerDelayLine        %integer delay line
        
        noiseType               %what type of noise to put in the initial buffer
        useNoiseFile            %flag indicating whether to generate the data or load it from a file
    end
    
    methods
        function obj = StringDWGInt(stringParams, L_init, noiseType, useNoiseFile)
            %L_init is the string length the system starts at as at each
            %time sample (including n = 0) a value for L[n] will be passed
            %into the larger synthesis context
            obj.openString_f0 = stringParams.f0;
            obj.pitch_f0 = calculatePitchF0(L_init, obj.openString_f0);
            obj.DWGLength = calculateTotalDWGLength(obj.pitch_f0, SystemParams.audioRate);
            
            %Construct/update the processing objects based on the parameters            
            obj.integerDelayLine = CircularBuffer(round(obj.DWGLength));
            
            %Save the flags which configure the generated sound
            obj.noiseType = noiseType;
            obj.useNoiseFile = useNoiseFile;
        end
        
        function [y_n, v_n] = tick(obj, x_n)
            %See signal flow diagram for signal names.
            %https://github.com/dgsmith1988/Masters-Thesis/blob/main/LaTeX/Thesis/images/diagrams/StringDWG.svg
            
            %Get the delay line output and scale it
            v_n = obj.integerDelayLine.getCurrentSample();
            
            %Compute the output sample
            y_n = x_n + v_n;
            
            %Implement the feedback to prepare things for next iteration
            obj.integerDelayLine.writeSample(y_n);
            obj.integerDelayLine.incrementPointers();
        end
        
        function consumeControlSignal(obj, L_n)
            %Calculate the various derived parameters first
            obj.pitch_f0 = calculatePitchF0(L_n, obj.openString_f0);
            obj.DWGLength = calculateTotalDWGLength(obj.pitch_f0, SystemParams.audioRate);
            
            %Update the delay line depending on the new value
            newDelay = round(obj.DWGLength);
            if newDelay == obj.integerDelayLine.bufferDelay - 1
                obj.integerDelayLine.decrementDelay();
            elseif newDelay == obj.integerDelayLine.bufferDelay + 1
                obj.integerDelayLine.incrementDelay();
            end
        end
        
        function bufferData = pluck(obj)
            bufferData = [];
            
            %We only want to initialize the integer component of the delay
            %line as not having the interpolation part start from zero
            %produces undesirable results. A DC component is introduced
            %with pink noise for one... 
            bufferLength = obj.integerDelayLine.bufferDelay;
            
            switch obj.noiseType
                case "White"
                    if obj.useNoiseFile
                        bufferData = audioread("sounds\whiteNoise.wav");
                    else
                        bufferData = 1 - 2*rand(1, bufferLength);
                    end
                case "Pink"
                    if obj.useNoiseFile
                        bufferData = audioread("sounds\pinkNoise.wav");
                    else
                        bufferData = pinknoise(1, bufferLength);
                    end
            end
            
            if ~obj.useNoiseFile
                %Remove the DC component and normalize the data.
                bufferData = bufferData - mean(bufferData);
                bufferData = bufferData / max(abs(bufferData));
            end
            
            %put that baby in the delay line!
            obj.integerDelayLine.initializeDelayLine(bufferData);
        end
    end
end

