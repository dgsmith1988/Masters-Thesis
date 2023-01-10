classdef Tickable < handle
    %TICKABLE Class defining an interface for objects which operate using
    %tick()
   
    methods(Abstract)
       output = tick()
    end
end

