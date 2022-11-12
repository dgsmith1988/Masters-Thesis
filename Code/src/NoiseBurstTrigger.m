classdef NoiseBurstTrigger < handle
    %NOISEBURSTTRIGGER Porting of "trigger.pd" patch from the Master's
    %thesis. TODO: Determine if this needs to be renamed once you get
    %everything worked out.
    
    properties
        metroToTrigger
        f_c_n_1 = -1    %previous incoming control signal
        delay_mS = 500;
        %TODO: tune this parameter to be more well known in terms of it's
        %impacts and what sort of changes to expect
        threshold = .000001
    end
    
    methods
        function obj = NoiseBurstTrigger(metroToTrigger)
            obj.metroToTrigger = metroToTrigger;
        end
        
        function tick(obj, f_c_n)
            %detect the changes first
            if (f_c_n - obj.f_c_n_1 > obj.threshold)
                if f_c_n == 0
                    %disable the metro after 500 milliseconds it looks like here
                    %Not entirely sure what was going on in the patch so
                    %this might need to get reworked
                    obj.metroToTrigger.delayedDisable(obj.delay_mS);
                elseif f_c_n > 0
                    newMetroPeriod = round(100 * 1/f_c_n);
                    obj.metroToTrigger.setPeriod(newMetroPeriod);
                end
                %update the value for the next iteration
                obj.f_c_n_1 = f_c_n;
            end
        end
    end
end

