classdef Metro < handle
    %METRO Class used to trigger a periodic action. Similar to the metro
    %object in PD/Max/MSP.
    
    properties
        enableFlag
        tickCount
        period_mS
        tickLimit
        objectToResetHandle
    end
    
    methods
        function obj = Metro(period_mS, objectToResetHandle)
            obj.tickCount = 0;
            obj.period_mS = period_mS;
            obj.tickLimit = Metro.calculateTickLimit(period_mS);
            obj.objectToResetHandle = objectToResetHandle;
            obj.enableFlag = 1;
        end
        
        function tick(obj)
            if obj.enableFlag
                obj.tickCount = obj.tickCount + 1;
                %TODO: Come back and veryify there isn't an off-by-one bug here
                if obj.tickCount == obj.tickLimit
                    obj.tickCount = 0;
                    %TODO: Triggers some sort of functionality here...
                    obj.objectToResetHandle.reset();
                end
            end
        end
        
        function enable(obj)
            obj.enableFlag = true;
            obj.tickCount = 0;
        end
        
        function disable(obj)
            obj.enableFlag = false;
        end
        
        function delayedDisable(obj, delay_mS)
            %Hmm... this functionalty might take some doing... I think I'll
            %need to add an estra counter or something to handle this
            %properly...
            obj.enableFlag = false;
        end
        
        function setPeriod(obj, newPeriod_mS)
            if newPeriod_mS > 0
                obj.period_mS = newPeriod_mS;
                obj.tickLimit = Metro.calculateTickLimit(newPeriod_mS);
                obj.tickCount = 0;
                obj.enableFlag = true;
            end
            %TODO: Determine whether or not trigger the event again after
            %resetting the period here
        end
    end
    
    methods (Static)
        function tickLimit = calculateTickLimit(period_mS)
            tickLimit = round((period_mS*10^-3)*SystemParams.audioRate);
        end
    end
end

