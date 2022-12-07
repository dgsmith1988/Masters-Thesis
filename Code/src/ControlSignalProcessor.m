classdef ControlSignalProcessor < handle
    %PROCESSCONTROLSIGNAL This class abstracts the context specific aspects
    %of the relative length control signal away and generates the
    %parameters for the CSG's constiuent processing objects as more
    %agnostic standard parameters (i.e. cut-off frequencies, durations)
    
    properties (GetAccess = public)
        L_n_1   %Previous relative length signal
        n_w     %String wind parameter
        f0      %Open string fundamental frequency
    end
    
    methods
        function obj = ControlSignalProcessor(n_w, f0, L_n_1)
            obj.n_w = n_w;
            obj.f0 = f0;
            obj.L_n_1 = L_n_1;
        end
        
        function [absoluteSlideVelocity, resonatorFrequency_Hz, triggerPeriod_ms] = tick(obj, L_n)
            
            
            %this formula is based on rearranging a calcuation for the
            %first order difference of the frequency of the pitch being
            %played by the DWG model.
            %p[n] = -12*log2(L[n])*f0
            %p[n] - p[n-1] = -12*f0*log2(L[n]/L[n-1])
            %the 50k value comes from the PD patch
            %TODO: Verify the PD calculations as it seems as if he
            %calculates the arugment for the cosine as opposed to the
            %frequency in Hz
%             resonatorFrequency_Hz = 50000*abs(-12*obj.f0*log2(L_n/obj.L_n_1));
            pitchDiff = -12*obj.f0*log2(L_n/obj.L_n_1);
            resonatorFrequency_Hz = 2*pi*50000*abs(pitchDiff)*(1/SystemParams.audioRate);
            
            %the bulk of this functionality comes from trigger.pd patch initially
            f_c = obj.n_w*abs(L_n - obj.L_n_1);
            triggerPeriod_ms = round(100/f_c);
            
            %compute the absolute slide velocity in meters per second. in 
            %the PD patch this is "muutos"
            absoluteSlideVelocity = (L_n - obj.L_n_1)*SystemParams.stringLengthMeters;
            
            %Update the previous value for the next iteration
            obj.L_n_1 = L_n;            
        end
    end
end

