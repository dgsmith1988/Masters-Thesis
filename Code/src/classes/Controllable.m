classdef Controllable < handle
    %CONTROLLABLE Defines interface for objects which consume control
    %signals and are related more to the synthesis context here as opposed
    %to a more generic DSP object.
    
    methods(Abstract)
        consumeControlSignal(L_n)
    end
end

