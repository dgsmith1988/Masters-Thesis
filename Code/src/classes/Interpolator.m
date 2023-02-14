classdef Interpolator < Controllable & Tickable
   
    properties(GetAccess = public)
        x_m         %Target value
        x_m_1       %Departure value
        R           %number of points to interpolate, R = audioRate/controlRate
        increment   %increment to be added each audiorate time-step
        k           %current calulcation step (out of R)
    end
    
    methods
        function obj = Interpolator(R, x_init)
            obj.R = R;
            %Given that consumeControlSignal() will need to be called, this
            %value passed in will become L_n_1 at that point...
            obj.x_m = x_init;
        end
        
        function x_interp = tick(obj)
            %Calculate the next sample to get from L[n-1] to L[n]
            if obj.k >= obj.R
                error("New x_m value should have been given by now... Check calling context...");
            end
            
            %TODO: Simplfy this to keep track of the current value and just
            %add the increment each time
            x_interp = obj.x_m_1 + obj.k*obj.increment;
            
            obj.k = obj.k + 1;
        end
        
        function consumeControlSignal(obj, x_m)
            obj.x_m_1 = obj.x_m;
            obj.x_m = x_m;
            obj.increment = (obj.x_m - obj.x_m_1)/obj.R;
            obj.k = 0;
        end
    end
end

