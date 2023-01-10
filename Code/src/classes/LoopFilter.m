classdef LoopFilter < Controllable
    %TODO: Examine how to set the LoopFilter to make it so the synthesis
    %starts at full scale amplitude
    properties (Abstract, Constant, GetAccess = public) 
        phaseDelay
    end
end

