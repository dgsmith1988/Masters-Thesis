classdef ImpulseTrain < handle
    
    properties
        tickCount           %counter used to trigger start of a noise pulse
        tickLimit           %number of samples corresponding to the trigger period
        enableFlag = true   %flag indicating whether or not to trigger pulses
        f_c_n_1 = 0;
    end
    
    methods
        function obj = ImpulseTrain(tickLimit)
            obj.tickLimit = tickLimit;
            obj.tickCount = tickLimit; %ensures an impulse at time 0
            if tickLimit == 0
                obj.enableFlag = false;
            end
        end
        
        function outputSample = tick(obj, f_c_n)
            %process the new parameter first
            if f_c_n == 0
                obj.enableFlag = false;
            elseif f_c_n ~= obj.f_c_n_1
                obj.tickLimit = f_c_to_ticks(f_c_n);
                obj.f_c_n_1 = f_c_n;
                
                if obj.enableFlag == false
                    %ensure an impulse is generated the first sample the
                    %object starts back up
                    obj.tickCount = obj.tickLimit;
                end
                
                obj.enableFlag = true;
            end
            
            outputSample = 0;
            if obj.enableFlag
                if obj.tickCount >= obj.tickLimit
                    outputSample = 1;
                    obj.tickCount = 0;
                end
                obj.tickCount = obj.tickCount + 1;               
            end
        end
    end
end

