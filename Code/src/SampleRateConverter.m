classdef SampleRateConverter < handle & AudioProcessor
    %SAMPLERATECONVERTOR - TODO: Fill this class in later once you get a
    %better sense for how the various components are going to relate and
    %process the different control signals... 
    properties
    end
    
    methods
        function obj = SampleRateConverter()
            
        end
        
        function L_n_audioRate = tick(obj, L_n_controlRate)
            %simple pass through for now and i can put something more
            %appropriate in here later
            L_n_audioRate = L_n_controlRate;
        end
    end
end

