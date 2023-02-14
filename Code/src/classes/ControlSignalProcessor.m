classdef ControlSignalProcessor < Tickable & Controllable
    %This class handles extracting the derived parameters from the relative
    %length signal as well as interpolating between values to handle
    %control/audio rate mismatches and smoothing to mitigate
    %discontinuities.
    
    properties (GetAccess = public)
        interpolator_L
        interpolator_slideSpeed
        smoother_L
        smoother_slideSpeed
        slideSpeedExtractor
    end
    
    properties(Constant)
        M = 10;     %Smoothing filter order
    end
    
    methods
        function obj = ControlSignalProcessor(L_m_1)
            obj.slideSpeedExtractor = SlideSpeedExtractor(L_m_1);
            
            %Smoothing filter kernel
            b = 1/obj.M * ones(1, obj.M);
            
            %In terms of the intialization here, we assume that the before
            %the synthesizer starts, the L[m] signal is the same as when it
            %initially starts generating sound. This helps avoid massive
            %changes in the L[n] which aren't supported by the interpolated
            %delay line. It only moves one sample at a time max. z_init is
            %specified in this manner as filter() iplements things via
            %DFII Transposed.
            z_init = L_m_1 * 1/obj.M * (obj.M-1:-1:1);
            obj.smoother_L = FilterObject(b, 1, z_init);
            obj.interpolator_L = Interpolator(SystemParams.R, L_m_1);
            
            %Correspondingly, as the L signal is assumed to be static, then
            %the slide speed is zero as it is derived from the first 
            %derivative of L.
            obj.smoother_slideSpeed = FilterObject(b, 1, zeros(1, obj.M-1));           
            obj.interpolator_slideSpeed = Interpolator(SystemParams.R, 0);
        end
        
        function [L_n, slideSpeed_n] = tick(obj)
            L_n = obj.interpolator_L.tick();
            L_n = obj.smoother_L.tick(L_n);
            
            slideSpeed_n = obj.interpolator_slideSpeed.tick();
            slideSpeed_n = obj.smoother_slideSpeed.tick(slideSpeed_n);
        end
        
        function consumeControlSignal(obj, L_m)
            %Update the easy one first
            obj.interpolator_L.consumeControlSignal(L_m);
            
            %As this object operates at the control rate, call its tick
            %function here.
            slideSpeed_m = obj.slideSpeedExtractor.tick(L_m);
            %Update its interpolator to go to the new value
            obj.interpolator_slideSpeed.consumeControlSignal(slideSpeed_m);
        end
    end
end

