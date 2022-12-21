classdef ControlSignalProcessor < handle
    %PROCESSCONTROLSIGNAL This class abstracts the context specific aspects
    %of the relative length control signal away and generates the
    %parameters for the CSG's constiuent processing objects as more
    %agnostic standard parameters (i.e. cut-off frequencies, durations)
    
    properties (GetAccess = public)
%         alpha = 50000   %scaling parameter for calcualted f_c, value taken from PD code
        L_n_1           %Previous relative length signal
        n_w             %String wind parameter
%         f0              %Open string fundamental frequency
    end
    
    methods
        function obj = ControlSignalProcessor(n_w, L_n_1)
            obj.n_w = n_w;         
            obj.L_n_1 = L_n_1;
        end
        
%         function obj = ControlSignalProcessor(n_w, f0, L_n_1)
%             obj.n_w = n_w;
%             obj.f0 = f0;
%             obj.L_n_1 = L_n_1;
%         end
        
        %         function [absoluteSlideVelocity, resonatorFrequency_Hz, triggerPeriod_ms] = tick(obj, L_n)
        %             %this formula is based on rearranging a calcuation for the
        %             %first order difference of the frequency of the pitch being
        %             %played by the DWG model.
        %             %p[n] = -12*log2(L[n])*f0
        %             %p[n] - p[n-1] = -12*f0*log2(L[n]/L[n-1])
        % %             pitchDiff = -12*obj.f0*log2(L_n/obj.L_n_1);
        % %             resonatorFrequency_Hz = 2*pi*obj.alpha*abs(pitchDiff)*(1/SystemParams.audioRate);
        %             resonatorFrequency_Hz = obj.alpha*obj.f0*abs(1/L_n - 1/obj.L_n_1);
        %
        %
        %             %the bulk of this functionality comes from trigger.pd patch initially
        %             f_c = obj.n_w*abs(L_n - obj.L_n_1);
        %             triggerPeriod_ms = round(100/f_c);
        %
        %             %compute the absolute slide velocity in meters per second. in
        %             %the PD patch this is "muutos"
        %             absoluteSlideVelocity = (L_n - obj.L_n_1)*SystemParams.stringLengthMeters;
        %
        %             %Update the previous value for the next iteration
        %             obj.L_n_1 = L_n;
        %         end
        
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

