close all;
clear;
dbstop if error;

slideVelocity = .0001;
L = 5:-slideVelocity:slideVelocity;
contactSoundGenerator = ContactSoundGenerator();

y = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    y(n) = contactSoundGenerator.tick(L(n));
end

plot(y);
title("CSG Test Output");