classdef ContactSoundGenerator < Controllable & AudioGenerator
    %Base class for common parameters
    properties
        %These parameters change during run-time
        g_slide = 1
        %Initializing these to zero is no issue as they are given
        %values at each call to the consumeControlSignal() function
        f_c_n = 0
        slideSpeed_n = 0
        
        %This parameter is set by the different CSG Objects in their
        %constructors
        g_user
    end
end

