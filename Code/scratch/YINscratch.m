Fs = SystemParams.audioRate;
duration_sec = 2;
numSamples = duration_sec*Fs;
f0 = 480;
n = 0:numSamples-1;
t = n/Fs;
x = sin(2*pi*f0*t);

yin_out = yin(x', Fs);