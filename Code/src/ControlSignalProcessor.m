classdef ControlSignalProcessor < handle
    %PROCESSCONTROLSIGNAL This class takes in the time varying length
    %signal and spits out the center frequecny control signal. L(n) and
    %f_c(n) respectively in the signal processing diagram.
    
    properties (GetAccess = public)
        L_n_1   %Previous relative length signal
        n_w     %String wind parameter
        smoothingFilter %Filter to handle the upsampling if need be
    end
    
    methods
        function obj = ControlSignalProcessor(n_w)
            obj.L_n_1 = 0;
            obj.n_w = n_w;
            obj.smoothingFilter = SmoothingFilter();
        end
        
        function [slideVelocity, f_c_n] = tick(obj, L_n)
            %Todo: This might need to be reworked once everything has been
            %laid out due to ambiguities and discrepancies between the
            %labled signal diagrams and the PD code from the master's
            %thesis.
            
            %Compute the difference between samples and upsample the
            %control signal if need be
            smoothedOutput = obj.smoothingFilter.tick(L_n - obj.L_n_1);
            
            %Compute the output based on the string windings and smoothed
            %output            
            f_c_n = abs(smoothedOutput)*obj.n_w;
            
            %Update the previous value for the next iteration
            obj.L_n_1 = L_n;
            
            %Todo: Should I add output parameters for the various derived
            %control signal parameters to make it easier for each of the
            %individual objects to just perform one function? i mean it
            %would be nice to have all the control signal calculation
            %functionality related to one place... 
            slideVelocity = abs(smoothedOutput);
        end
    end
end

