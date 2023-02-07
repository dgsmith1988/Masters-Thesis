classdef SlideSynth < Controllable & AudioGenerator
    %STRINGSYNTH Synthesizer for one particular string
    
    properties (GetAccess = public)
        controlSignalProcessor  %this handles pre-processing the incoming control signal
        stringDWG               %object which generates the string sound
        contactSoundGenerator   %unit adding slide/string contact noise
        couplingFilter          %TODO: Determine this later
        antiAliasingFilter      %what's in a name?
    end
    
    methods
        function obj = SlideSynth(params, L_0)
            stringParams = getStringParams(params.stringName);
            
            %Determine which contact sound generator to use whether we have
            %a wound string or not. Dummy one is used to test the slide
            %model without friction sounds.
            if params.enableCSG
                if(stringParams.n_w > 0)
                    stringModeFilterSpec = getModeFilterSpec(params.stringName, params.slideType);
                    obj.contactSoundGenerator = CSG_wound(stringParams, stringModeFilterSpec, "PulseTrain", "ResoTanh");
                elseif(stringParams.n_w == 0)
                    obj.contactSoundGenerator = CSG_unwound();
                else
                    error("Invalid n_w passed");
                end                
            else
                obj.contactSoundGenerator = CSG_dummy();
            end
            
            %TODO: Coupling filter is currently a place holder
            obj.couplingFilter = CouplingFilter("None");
            obj.stringDWG = StringDWG(stringParams, L_0, params.stringNoiseSource, params.useNoiseFile);
            obj.antiAliasingFilter = AntiAliasing();
            obj.controlSignalProcessor = ControlSignalProcessor(L_0);
        end
        
        function pluck(obj)
            %Prepare the stringDWG to start generating sound
            obj.stringDWG.pluck();
        end
        
        function consumeControlSignal(obj, L_m)
            %TODO: Add a check on the value of L_m to make sure it has
            %changed enough to warrant running the update routines to save
            %on computations
            
            %Update the various system parameters
            obj.controlSignalProcessor.consumeControlSignal(L_m);
        end
        
        function [y_n, stringDWGOutput, CSGOutput] = tick(obj)
            %Generate the various control signals at audio rate
            [L_n, slideSpeed_n] = obj.controlSignalProcessor.tick();
            
            %Update the different processing objects accordingly
            obj.stringDWG.consumeControlSignal(L_n);
            obj.contactSoundGenerator.consumeControlSignal(slideSpeed_n);
            
            %Run through the various processing objects
            CSGOutput = obj.contactSoundGenerator.tick();
            
            %TODO: Come back and experiment with different coupling methods
            couplingFilterOutput = obj.couplingFilter.passThru(0.0);
            stringDWGOutput = obj.stringDWG.tick(couplingFilterOutput);
            
            %Filter the output before sending it out incase aliasing
            %occured when the delay-line length changed
            y_n = obj.antiAliasingFilter.tick(stringDWGOutput + CSGOutput);
        end
    end
end