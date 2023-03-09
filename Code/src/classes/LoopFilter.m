classdef LoopFilter < Controllable & FilterObject
    %TODO: Examine how to set the LoopFilter to make it so the synthesis
    %starts at full scale amplitude
    
    methods
        function obj = LoopFilter(b, a, z_init)
            obj@FilterObject(b, a, z_init);
        end
    end
    properties (Abstract, GetAccess = public) 
        phaseDelay
    end
end

