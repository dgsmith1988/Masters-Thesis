classdef SlideSynth < Controllable & AudioGenerator
    %STRINGSYNTH Synthesizer for one particular string
    
    properties (GetAccess = public)
        stringDWG
        contactSoundGenerator   %unit adding slide/string contact noise
        couplingFilter          %TODO: Determine this later
        antiAliasingFilter      %what's in a name?
    end
    
    methods
        function obj = SlideSynth(stringParams, stringModeFilterSpec, L_0)           
            %Determine which contact sound generator to use whether we have
            %a wound string or not. Dummy one is used to test the string
            %model without friction sounds.
            if(stringParams.n_w > 0)
                obj.contactSoundGenerator = CSG_wound(stringParams, stringModeFilterSpec, "PulseTrain", "ResoTanh", L_0);
            elseif(stringParams.n_w == 0)
                obj.contactSoundGenerator = CSG_unwound(stringParams, L_0);
            else
                obj.contactSoundGenerator = CSG_dummy();
            end
            
            %TODO: Coupling filter is currently a place holder
            obj.couplingFilter = FilterObject(1, 1, 0);
            obj.stringDWG = StringDWG(stringParams, L_0);
            obj.antiAliasingFilter = AntiAliasing();
        end
        
        function pluck(obj)
            %Prepare the stringDWG to start generating sound
            obj.stringDWG.pluck();
        end
        
        function consumeControlSignal(obj, L_n)
            %Update the various system parameters
            obj.stringDWG.consumeControlSignal(L_n);
            obj.contactSoundGenerator.consumeControlSignal(L_n);
        end
        
        function [y_n, stringDWGOutput, CSGOutput] = tick(obj)
            %Run through the various processing objects
            CSGOutput = obj.contactSoundGenerator.tick();
            
            %TODO: Come back and experiment with different coupling methods
            couplingFilterOutput = obj.couplingFilter.passThru(CSGOutput);
            stringDWGOutput = obj.stringDWG.tick(couplingFilterOutput);
                      
            %Filter the output before sending it out incase aliasing
            %occured when the delay-line length changed
            y_n = obj.antiAliasingFilter.tick(stringDWGOutput + CSGOutput);
        end
    end
end