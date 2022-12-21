classdef NoisePulseTrain < handle
    %Class which controls the NoisePulseGen and its associating timing 
    %characteristics
    
    properties
        %TODO: Determine the best initialization values once the control
        %signals are more well understood
        f_c_n_1 = -1;           %previous incoming control signal
        threshold = .000001;    %threshold to determine if f_c_n has changed enough
        noisePulseGen           %object which synthesizes the noise pulses
        tickCount = 0;          %counter used to trigger start of a noise pulse
        triggerPeriod_ms        %time to wait between triggering pulses
        tickLimit               %number of samples corresponding to the trigger period
        enableFlag              %flag indicating whether or not to trigger pulses
        disableFlag = false;    %flag indicating to initiate the delayed disable sequence
        disableCount
    end
    
    properties (Constant)
        %TODO:Make this a global parameter? how much is this going to be
        %tweaked?
        disableDelay_ms = 500;  %amount of time to wait before disabling the noise pulse (as appears in PD patch)
    end
    
    methods
        function obj = NoisePulseTrain(triggerPeriod_ms, pulseLength_ms, decayRate)
            %TODO: Determine what is necessary and what isn't after the
            %behavior and functionality is more well defined
            %calculate all the various parameters
            obj.triggerPeriod_ms = triggerPeriod_ms;
            obj.tickLimit = calculateTicks(obj.triggerPeriod_ms);
            obj.noisePulseGen = NoisePulseGen(pulseLength_ms, decayRate);
            obj.enableFlag = false; %derive when the start the train from the control signal as opposed to defaulting it
        end
        
        %TODO: Is this really the f_c_n signal, or is this the slide
        %velocity?
        %TODO: Determine whether or not to make the initial value something
        %you can pass in
        function outputSample = tick(obj, newTriggerPeriod_ms)
            if(abs(newTriggerPeriod_ms - obj.triggerPeriod_ms) > obj.threshold)
                if newTriggerPeriod_ms == 0
                    %diasble the noisePulseGen after 500 ms as per how the
                    %PD patch descibres the functionality
                    obj.disableCount = calculateTicks(obj.disableDelay_ms);
                    obj.disableFlag = true;
                elseif newTriggerPeriod_ms > 0
                    assert(newTriggerPeriod_ms > 1/SystemParams.audioRate);
                    obj.triggerPeriod_ms = newTriggerPeriod_ms;
                    obj.tickLimit = calculateTicks(newTriggerPeriod_ms);
                    obj.enableFlag = true;
                end
                %update the value for the next iteration
                obj.triggerPeriod_ms = newTriggerPeriod_ms;
            end
            
            if obj.disableFlag
                obj.disableCount = obj.disableCount - 1;
                if obj.disableCount == 0
                   obj.disableFlag = false;
                   obj.enableFlag = false;
                end
            end
            
            if obj.enableFlag
                %TODO: Come back and verify there isn't an off-by-one bug
                %here. Also, look into what if there is overshoot?
                obj.tickCount = obj.tickCount + 1;
                %>= handles the case where the period shortens
                if obj.tickCount >= obj.tickLimit
                    obj.tickCount = 0;
                    obj.noisePulseGen.reset();
                end
            end
            
            outputSample = obj.noisePulseGen.tick();
        end
    end
end

