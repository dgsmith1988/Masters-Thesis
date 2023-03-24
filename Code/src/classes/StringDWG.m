classdef StringDWG < Controllable & AudioGenerator
    properties
        openString_f0           %open string fundamental frequency in Hz
        pitch_f0                %selected pitch based on relative string length
        g_c_n                   %compensation coefficient
        DWGLength               %current DWG length in samples
        
        interpolatedDelayLine   %delay line which allows for fractional delay components
        energyScaler            %calculates compensation coefficient
        loopFilter              %loop filter implementing string decay/body effects
        
        noiseType               %what type of noise to put in the initial buffer
        useNoiseFile            %flag indicating whether to generate the data or load it from a file
    end
    
    methods
        function obj = StringDWG(stringParams, L_init, noiseType, useNoiseFile)
            %L_init is the string length the system starts at as at each
            %time sample (including n = 0) a value for L[n] will be passed
            %into the larger synthesis context
            obj.g_c_n = 1;
            obj.openString_f0 = stringParams.f0;
            obj.pitch_f0 = calculatePitchF0(L_init, obj.openString_f0);
            obj.DWGLength = calculateTotalDWGLength(obj.pitch_f0, SystemParams.audioRate);
            
            %Construct/update the processing objects based on the parameters
            obj.loopFilter = LoopOnePole(stringParams.a_pol, stringParams.g_pol, L_init);
            obj.interpolatedDelayLine = Lagrange(SystemParams.lagrangeOrder, obj.DWGLength);
            obj.energyScaler = EnergyScaler(obj.DWGLength);
            
            %Save the flags which configure the generated sound
            obj.noiseType = noiseType;
            obj.useNoiseFile = useNoiseFile;
        end
        
        function [y_n, w_n, v_n] = tick(obj, x_n)
            %See signal flow diagram for signal names.
            %https://github.com/dgsmith1988/Masters-Thesis/blob/main/LaTeX/Thesis/images/diagrams/StringDWG.svg
            
            %Get the delay line output and scale it
            w_n = obj.g_c_n * obj.interpolatedDelayLine.getCurrentSample();
            
            %Compute the loop filter output
            v_n = obj.loopFilter.tick(w_n);
            
            %Compute the output sample
            y_n = x_n + v_n;
            
            %Implement the feedback to prepare things for next iteration
            obj.interpolatedDelayLine.writeSample(y_n);
            obj.interpolatedDelayLine.incrementPointers();
        end
        
        function consumeControlSignal(obj, L_n)
            %Calculate the various derived parameters first
            obj.pitch_f0 = calculatePitchF0(L_n, obj.openString_f0);
            obj.DWGLength = calculateTotalDWGLength(obj.pitch_f0, SystemParams.audioRate);
            delayLineLength = calculateInterpDelayLineLength(obj.DWGLength, obj.loopFilter.phaseDelay);
            
            %Update the different processing objects based on the new
            %derived parameters
            obj.g_c_n = obj.energyScaler.tick(obj.DWGLength);
            obj.interpolatedDelayLine.setDelay(delayLineLength);
            obj.loopFilter.consumeControlSignal(L_n);
        end
        
        function bufferData = pluck(obj)
            bufferData = [];
            
            %We only want to initialize the integer component of the delay
            %line as not having the interpolation part start from zero
            %produces undesirable results. A DC component is introduced
            %with pink noise for one... 
            bufferLength = obj.interpolatedDelayLine.M;
            
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
            obj.interpolatedDelayLine.initializeNonInterpolatingPart(bufferData);
        end
    end
end

