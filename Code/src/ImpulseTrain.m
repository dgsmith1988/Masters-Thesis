classdef ImpulseTrain < handle
    
    properties
        tickCount;          %counter used to trigger start of a noise pulse
        tickLimit           %number of samples corresponding to the trigger period
        enableFlag = false  %flag indicating whether or not to trigger pulses
        f_c_n_1 = 0;
    end
    
    methods
        function obj = ImpulseTrain(tickLimit)
            obj.tickLimit = tickLimit;
            obj.tickCount = tickLimit; %ensures an impulse at time 0
        end
        
        function outputSample = tick(obj, f_c_n)
            %TODO: Add the code which processes the f_c signal changes
            %process the new parameter first
            if f_c_n == 0
                obj.enableFlag = false;
            elseif f_c_n ~= obj.f_c_n_1
                newTickLimit = round(1/f_c_n * SystemParams.audioRate);
                obj.tickLimit = newTickLimit;
                obj.enableFlag = true;
                obj.f_c_n_1 = f_c_n;
            end
            
            outputSample = 0;
            if obj.enableFlag
                if obj.tickCount >= obj.tickLimit
                    outputSample = 1;
                    obj.tickCount = 0;
                end
            end
            obj.tickCount = obj.tickCount + 1;
        end
    end
end

