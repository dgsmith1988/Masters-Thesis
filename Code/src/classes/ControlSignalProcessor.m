classdef ControlSignalProcessor < Tickable & Controllable
    %This class abstracts the context specific aspects of the relative
    %length control signal away and generates the parameters for the CSG's
    %constiuent processing objects as more agnostic standard parameters
    %(i.e. cut-off frequencies, durations)
    
    properties (GetAccess = public)
        interpolator_L
        interpolator_SV     
        smoother_L
        smoother_SV  %Slide velocity smoothing filter
        
        L_m_1           %Previous relative length signal
        n_w             %String wind parameter
    end
    
    properties(Constant)
        M = 10;
    end
    
    methods
        function obj = ControlSignalProcessor(n_w, L_m_1)
            if n_w == 0
                %unwound strings have an n_w value of 0 so
                obj.n_w = 1;
            else
                obj.n_w = n_w;
            end
            
            obj.L_m_1 = L_m_1;
            
            b = 1/obj.M * ones(1, obj.M);
            obj.smoother_L = FilterObject(b, 1, zeros(1, obj.M-1));
            obj.smoother_SV = FilterObject(b, 1, zeros(1, obj.M-1));
            
            %TODO: Come back and determine this correct value to intialize
            %the interpolators with
            R = SystemParams.audioRate / SystemParams.controlRate;
            obj.interpolator_L = Interpolator(R, 0);
            obj.interpolator_SV = Interpolator(R, 0);
        end
        
        %TODO: Determine the best names to use here
        function [L_n, f_c_n, slideSpeed_n] = tick(obj)
            L_n = obj.interpolator_L.tick();
            
            slideVelocity_interp = obj.interpolator_SV.tick();
            slideVelocity_smooth = obj.smoother_SV.tick(slideVelocity_interp);
            slideSpeed_n = abs(slideVelocity_smooth);
            
            % units here should by cycles/sec as each winding represents
            % the start of a cycle as the slide impacts it and creates an
            % triggers an IR
            % cycles/sec = windings/meter * meters/sec
            f_c_n = obj.n_w*slideSpeed_n;
        end
        
        function consumeControlSignal(obj, L_m)
            %Update the easy one first
            obj.interpolator_L.consumeControlSignal(L_m);
            
            % units here should be in meters per second
            % L[m] - L[m-1] = Δunit length/sample
            % stringLength = meters 
            % Fs = samples/sec
            % (Δunit length / sample)* (meters/unit length) * (samples/sec) = meters/sec
            slideVelocity_m = (L_m - obj.L_m_1)*SystemParams.audioRate*SystemParams.stringLengthMeters;           
            obj.interpolator_SV.consumeControlSignal(slideVelocity_m);
            
            %Update the value for the next iterator
            obj.L_m_1 = L_m;
        end
    end
end

