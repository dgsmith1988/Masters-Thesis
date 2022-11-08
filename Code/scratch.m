Fs = SystemParams.audioRate;
pulseLength_ms = SystemParams.E_string_params.pulseLength;
m = 1/(pulseLength_ms*10^-3);
totalSamples = round((pulseLength_ms*10^-3)*Fs);

y = zeros(1, totalSamples);

for n = 2:totalSamples+2
    y(n) = m/Fs + y(n-1);
end

plot(y);