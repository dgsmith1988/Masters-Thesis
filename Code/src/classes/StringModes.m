classdef StringModes
    %Class for orgnaizing differnet mode filter data based on the slides
    %TODO: Think of a better name for this
    properties
        brass
        glass
        chrome
    end
    
    methods
        function obj = StringModes(brass, glass, chrome)
            obj.brass = brass;
            obj.glass = glass;
            obj.chrome = chrome;
        end
    end
end

