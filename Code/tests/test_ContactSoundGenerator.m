close all;
clear;
dbstop if error;

slideVelocity = .001;
L = .25:slideVelocity:1;
stringParams = SystemParams.E_string_params;
stringModeFilterSpec = SystemParams.E_string_modes.brass;
contactSoundGenerator = ContactSoundGenerator(stringParams, stringModeFilterSpec);

y = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    y(n) = contactSoundGenerator.tick(L(n));
end

plot(y);
title("CSG Test Output");