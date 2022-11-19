classdef LoopFilter < handle
    %TODO: Examine how to set the LoopFilter to make it so the synthesis
    %starts at full scale amplitude
    properties (Abstract, Constant, GetAccess = public) 
        phaseDelay
    end
%     methods
%         function obj = LoopFilter(b, a, z_init)
%             %Hacky but works... I'm beginning to dislike Matlabs
%             %implementation of OOP... I mean hmm... I could make this as
%             %part of the LoopFilter object... 
%             obj@FilterObject(b, a, z_init);
%         end
%         function updateFilter(obj, L)
%             %TODO: This function will take in the relative string length
%             %and adjust the coefficients appropriately
%         end
%     end
end

