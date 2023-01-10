classdef ControlSignalProcessor < handle
    %This class abstracts the context specific aspects of the relative 
    %length control signal away and generates the parameters for the CSG's
    %constiuent processing objects as more agnostic standard parameters 
    %(i.e. cut-off frequencies, durations)
    
    properties (GetAccess = public)
        L_n_1           %Previous relative length signal
        n_w             %String wind parameter
    end
    
    methods
        function obj = ControlSignalProcessor(n_w, L_n_1)
            if n_w == 0
                %unwound strings have an n_w value of 0 so 
                obj.n_w = 1;
            else
                obj.n_w = n_w;   
            end
            
            obj.L_n_1 = L_n_1;
        end
        
        %TODO: Determine the best names to use here
        function [f_c_n, absoluteSlideSpeed] = tick(obj, L_n)
            % units here should be in meters per second
            % abs(L[n] - L[n-1])/ 1 sample = Δunit length/sample
            % stringLength = meters, Fs = samples/sec
            % (Δunit length / sample)* (meters/unit length) * (samples/sec) = meters/sec
            absoluteSlideSpeed = abs(L_n - obj.L_n_1)*SystemParams.stringLengthMeters*SystemParams.audioRate;
            
            % units here should by cycles/sec as each winding represents
            % the start of a cycle as the slide impacts it and creates an
            % triggers an IR
            % cycles/sec = windings/meter * meters/sec
            f_c_n = obj.n_w*absoluteSlideSpeed;
                                   
            %Update the previous value for the next iteration
            obj.L_n_1 = L_n;
        end
    end
end

