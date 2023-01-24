function stringParams = getStringParams(stringName)
    switch stringName
        case "E"
            stringParams = SystemParams.E_string_params;
        case "A"
            stringParams = SystemParams.A_string_params;
        case "D"
            stringParams = SystemParams.D_string_params;
        case "G"
            stringParams = SystemParams.G_string_params;
        case "B"
            stringParams = SystemParams.B_string_params;
        case "e"
            stringParams = SystemParams.e_string_params;
        case "C"
            stringParams = SystemParams.C_string_params;
        otherwise
            error("Invalid stringName passed");
    end
end

