duration_sec = 2;
numSamples = round(Fs*duration_sec);
f0 = 250;
Fs = SystemParams.audioRate;
Ts = 1/Fs;
alpha = -127/128;
% alpha = -exp(-1/Fs)
b = [1];
a = [1 alpha];

samplesPerPeriod = Fs/f0;
cyclesPerDuration = (duration_sec*Fs) / samplesPerPeriod;

impulse = [1, zeros(1, samplesPerPeriod-1)];
impulseTrain = repmat(impulse, 1, cyclesPerDuration);

figure;
y1 = filter(b, a, impulse);
n = 0:length(y1)-1;
subplot(3, 1, 1)
stem(n, y1);

y2 = filter(b, a, impulseTrain);
n = 0:length(y2)-1;
subplot(3, 1, 2)
stem(n, y2);
xlim([0 500]);

amplitudeEnvelope = y2;
noise = rand(1, numSamples);
y3 = amplitudeEnvelope .* noise;
subplot(3, 1, 3)
stem(y3);
xlim([0 500]);