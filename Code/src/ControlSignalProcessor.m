classdef ControlSignalProcessor < handle
    %PROCESSCONTROLSIGNAL This class takes in the time varying length
    %signal and spits out the center frequecny control signal and other
    %signals which the CSG will need. The L_n signal comes in at the audio
    %rate.
    
    properties (GetAccess = public)
        L_n_1;  %Previous relative length signal
        n_w     %String wind parameter
    end
    
    methods
        function obj = ControlSignalProcessor(n_w, L_n_1)
            obj.n_w = n_w;
            obj.L_n_1 = L_n_1;
        end
        
        %TODO:rename this to slide speed as we use an absolute value which
        %removes the direction aspect from things... 
        function [slideVelocity, f_c_n] = tick(obj, L_n)         
            %Compute the slide velocity
            slideVelocity = abs(L_n - obj.L_n_1);
            
            %Compute the output based on the string windings and smoothed
            %output            
            f_c_n = slideVelocity*obj.n_w;
            
            %Update the previous value for the next iteration
            obj.L_n_1 = L_n;            
        end
    end
end

