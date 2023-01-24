function filterSpec = getModeFilterSpec(stringName, slideType)
    switch stringName
        case "E"
            stringModes = SystemParams.E_string_modes;
        case "A"
            stringModes = SystemParams.A_string_modes;
        case "D"
            stringModes = SystemParams.D_string_modes;
        case "C"
            stringModes = SystemParams.E_string_modes;
        otherwise
            error("Invalid stringName passed. Only pass wound strings.");
    end
    
    switch slideType
        case "Brass"
            filterSpec = stringModes.brass;
        case "Chrome"
            filterSpec = stringModes.chrome;
        case "Glass"
            filterSpec = stringModes.glass;
        otherwise
            error("Invalid slide type passed. Use chrome, glass or brass.");
    end
end

