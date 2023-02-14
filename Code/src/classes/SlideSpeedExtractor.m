classdef SlideSpeedExtractor < Tickable
    %Calculate the slide speed from the control signal L[m]
    %This should run at the control rate.
    
    properties (GetAccess = public)
        L_m_1           %Previous relative length signal        
    end
    
    methods
        function obj = SlideSpeedExtractor(L_m_1)                       
            obj.L_m_1 = L_m_1;
        end
        
        %TODO: Determine the best names to use here
        function [slideSpeed_m] = tick(obj, L_m)
            % units here should be in meters per second
            % abs(L[n] - L[n-1])/ 1 sample = Δunit length/sample
            % stringLength = meters, Fs = samples/sec
            % (Δunit length / sample)* (meters/unit length) * (samples/sec) = meters/sec
            slideVelocity_m = (L_m - obj.L_m_1)*SystemParams.controlRate*SystemParams.stringLengthMeters;
            slideSpeed_m = abs(slideVelocity_m);
                      
            %Update the previous value for the next iteration
            obj.L_m_1 = L_m;
        end
    end
end

