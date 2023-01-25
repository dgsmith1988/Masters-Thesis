classdef StringDWG < Controllable & AudioGenerator  
    properties
        openString_f0           %open string fundamental frequency in Hz
        pitch_f0                %selected pitch based on relative string length
        g_c_n                   %compensation coefficient
        DWGLength               %current DWG length in samples
        
        interpolatedDelayLine   %delay line which allows for fractional delay components
        energyScaler            %calculates compensation coefficient
        loopFilter              %loop filter implementing string decay/body effects
        
        y_n_1 = 0               %last output sample to implement feedback
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
        
        function [y_n, interpDelayOut, loopFilterOut] = tick(obj, x_n)
            %See signal flow diagram for signal names.
            %https://github.com/dgsmith1988/Masters-Thesis/blob/main/LaTeX/Thesis/images/diagrams/StringDWG.svg
            
            %Implement the feedback loop
            interpDelayOut = obj.interpolatedDelayLine.tick(obj.y_n_1);
            loopFilterOut = obj.loopFilter.tick(obj.g_c_n*interpDelayOut);
            
            %Generate the current output sample
            y_n = x_n + loopFilterOut;
            
            %Store the output for the next iteration
            obj.y_n_1 = y_n;
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
            bufferLength = obj.interpolatedDelayLine.getBufferLength();
            
            switch obj.noiseType
                case "White"
                    if obj.useNoiseFile
                        bufferData = audioread("sounds\whiteNoise.wav");
                    else
                        bufferData = 1 - 2*rand(1, bufferLength+1);
                    end
                case "Pink"
                    if obj.useNoiseFile
                        bufferData = audioread("sounds\pinkNoise.wav");
                    else
                        bufferData = pinknoise(1, bufferLength+1);
                    end
            end
            
            if ~obj.useNoiseFile
                %Remove the DC component and normalize the data. This has
                %has already been done on the saved waveforms.
                bufferData = bufferData - mean(bufferData);           
                bufferData = bufferData / max(abs(bufferData));
            end
            
            %put that baby in the delay line!
            obj.loopFilter.z = bufferData(1);
            obj.interpolatedDelayLine.initializeBuffer(bufferData(2:end));
        end
    end
end

