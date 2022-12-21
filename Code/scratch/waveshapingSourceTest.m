clear all;

Fs = SystemParams.audioRate;
duration_sec = 2;
numSamples = round(Fs*duration_sec);
f0 = 250;
A = 10;

n = 0:numSamples-1;

%pure sine signal
figure;
subplot(3, 1, 1);
x1 = sin(2*pi*f0*n/Fs);
y1 = tanh(A*x1);
plot(x1, 'DisplayName', 'x1');
hold on;
plot(y1, 'DisplayName', 'y1');
xlim([0 250]);
legend();

%sine + noise signal
snr = 3;
x2 = awgn(x1, snr);
y2 = tanh(A*x2);
subplot(3, 1, 2);
plot(x2, 'DisplayName', 'x2');
hold on;
plot(y2, 'DisplayName', 'y2');
xlim([0 250]);
legend();

%filtered noise burst
r = .99;
resonator = ResonatorFilter(f0, r);
noiseBurst = -1 + 2*rand(1, numSamples);
x3 = filter(resonator.b, resonator.a, noiseBurst);
y3 = tanh(A*x3);
subplot(3, 1, 3);
plot(x3, 'DisplayName', 'x3');
hold on;
plot(y3, 'DisplayName', 'y3');
xlim([0 250]);
legend();

%filtered decaying noise bursts
% alpha = -31/32;
alpha = -127/128;
b = [1];
a = [1 alpha];

samplesPerPeriod = Fs/f0;
cyclesPerDuration = (duration_sec*Fs) / samplesPerPeriod;

impulse = [1, zeros(1, samplesPerPeriod-1)];
impulseTrain = repmat(impulse, 1, cyclesPerDuration);

amplitudeEnvelope = filter(b, a, impulseTrain);
noise = rand(1, numSamples);
pulseTrain = amplitudeEnvelope .* noise;
figure;
x4 = filter(resonator.b, resonator.a, pulseTrain);
y4 = tanh(A*x4);
plot(x4, 'DisplayName', 'x4');
hold on;
plot(y4, 'DisplayName', 'y4');
xlim([0 250]);
legend();

% frameSize = 250;
% numFrames = numSamples/frameSize;
% for n = 1:numFrames
%     start = (n-1)*frameSize + 1
%     stop = n*frameSize
%     xlim([start stop]);
%     pause
% end
windowLength = 12*10^-3*Fs;
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5;
figure;
subplot(3, 1, 1); spectrogram(x3, window, overlap, N, Fs, "yaxis"); title('x3'); ylim([0 y_upperLim]);
subplot(3, 1, 2); spectrogram(x4, window, overlap, N, Fs, "yaxis"); title('x4'); ylim([0 y_upperLim]);
subplot(3, 1, 3); spectrogram(y4, window, overlap, N, Fs, "yaxis"); title('y4'); ylim([0 y_upperLim]);

figure;
subplot(3, 1, 1); spectrogram(pulseTrain, window, overlap, N, Fs, "yaxis"); title('pulseTrain'); ylim([0 y_upperLim]);
subplot(3, 1, 2); spectrogram(x4, window, overlap, N, Fs, "yaxis"); title('x4'); ylim([0 y_upperLim]);
subplot(3, 1, 3); spectrogram(y4, window, overlap, N, Fs, "yaxis"); title('y4'); ylim([0 y_upperLim]);