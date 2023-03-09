classdef TwoPointAverage < LoopFilter
    %Class matching the filter from the original K&S Paper for testing
    %purposes
    
    properties(GetAccess = public)

        phaseDelay = .5;
    end
           
    methods
        function obj = TwoPointAverage()
            %initialize everything in the parent to zero to keep matlab
            %happy. in the call to consumeControlSignal() the coefficients
            %will be generated.
            obj@LoopFilter([.5, .5], 1, 0);
        end
        
        function consumeControlSignal(obj, L_n)
            %Dummy function call as it is necessary to adhere to interface
        end
    end
end

