%This script compares the output of three different variable fraciton delay
%methods to find a solution which eliminates and reduces the transients.
%The three methods are:
% - Lagrange via DFII filter structure
% - Lagrange via Farrow method structure
% - Sinc based FIR filter

clear;
close all;

%System parameters
Fs_audio = SystemParams.audioRate;
Fs_control = SystemParams.controlRate;
% Fs_control = Fs_audio;
R = Fs_audio/Fs_control;
duration_sec = 2;
numSamples_audio = duration_sec*Fs_audio;
numSamples_control = duration_sec*Fs_control;
nRange_audio = 0:numSamples_audio-1;
nRange_control = 0:numSamples_control-1;
L = 6; %Filter length
M = 8; %Smoothing factor
intDelay = floor((L-1)/2);

%Delay values control signal
numPeriods = 10;     %the discontinuity should be introduced 10-1 = 9 times
controlPeriod = numSamples_control/numPeriods;
start = 0;
stop = 1;
increment = (stop - start)/(controlPeriod-1);
d = start:increment:stop;
d = repmat(d, 1, numPeriods);

%Input signal is a sine wave to make things clearer. Put it in the filter's
%pass band.
f0 = 480;
x = sin(2*pi*f0/Fs_audio*nRange_audio);

%Processing object initialization
lagrangeDelay = LagrangeDelay(L, d(1));
farrowDelay = dsp.VariableFractionalDelay('InterpolationMethod', 'Farrow', 'FilterLength', L, 'MaximumDelay', intDelay+1);
sincDelay = dsp.VariableFractionalDelay('InterpolationMethod', 'FIR', 'FilterLength', L, 'MaximumDelay', intDelay+1);
y_lagrange = zeros(1, numSamples_audio);
y_farrow = zeros(1, numSamples_audio);
y_sinc = zeros(1, numSamples_audio);

%apply interpolation to the D(n) control signal
d_interp = zeros(1, Fs_audio);
n_audio = 1;
for n_control = nRange_control+1
    %Hold the last value as we have nothing to interpolate to
    if n_control == nRange_control(end) + 1
        increment = 0;
    else
        %calculate the increment to be added each sample
        increment = (d(n_control+1) - d(n_control))/R;
    end
    
    for k = 0:R-1
        d_interp(n_audio) = d(n_control) + k*increment;
        n_audio = n_audio + 1;
    end
end

%Smooth the signal
% d_smooth = filter(1/M*ones(1, M), 1, d_interp);
D_interp = d_interp + intDelay;
y_theoretical = sin(2*pi*f0/Fs_audio*(nRange_audio - D_interp));

%add the sample delay from the filter starting from scratch
y_theoretical(1:intDelay) = 0;

figure
subplot(3, 1, 1);
plot(nRange_control, d);
title("d");
subplot(3, 1, 2);
plot(nRange_audio, d_interp);
title("d interp");

figure;
subplot(2, 1, 1);
stem(nRange_control, d);
title("d");
lower = numSamples_control/numPeriods-50;
upper = lower+ 100;
xlim([lower upper ]);
subplot(2, 1, 2);
stem(nRange_audio, d_interp);
lower = R*numSamples_control/numPeriods-50;
upper = lower + 100;
xlim([lower upper]);
title("d interp");

%Processing loop
% n_audio = 1;
for n_audio = nRange_audio+1
    if(mod(n_audio, 100) == 0)
        fprintf("n_audio = %i/%i\n", n_audio, numSamples_audio);
    end
    
    lagrangeDelay.setFractionalDelay(d_interp(n_audio));
    y_lagrange(n_audio) = lagrangeDelay.tick(x(n_audio));
    y_farrow(n_audio) = farrowDelay(x(n_audio), D_interp(n_audio));
    y_sinc(n_audio) = sincDelay(x(n_audio), D_interp(n_audio));
end

figure;
plot(nRange_audio, x, nRange_audio, y_theoretical, nRange_audio, y_lagrange, nRange_audio, y_farrow, nRange_audio, y_sinc);
% stem(nRange_audio, x);
% hold on;
% stem(nRange_audio, y_lagrange);
% stem(nRange_audio, y_farrow);
% stem(nRange_audio, y_sinc);
% hold off;
legend('x', 'y theoretical', 'y lagrange', 'y farrow', 'y sinc');
xlim([lower upper]);
grid on;
grid minor;

figure;
plot(nRange_audio, y_theoretical, nRange_audio, y_farrow);
legend('y theoretical', 'y farrow');
grid on; grid minor;

frameLength = 300;
overlap = .5;
hopSize = frameLength*(1-overlap);
for i = 1:numSamples_audio/(hopSize)
    start = (i-1)*hopSize+1;
    stop = start + frameLength;
    xlim([start, stop]);
    disp("Hit enter for next frame...");
    pause;
end

% figure; plot(nRange_audio, y_lagrange-y_farrow); xlabel("Time (sec)");
err_lagrange = y_theoretical - y_lagrange;
err_farrow = y_theoretical - y_farrow;
err_sinc = y_theoretical - y_sinc;

figure;
subplot(3, 1, 1);
plot(nRange_audio, err_lagrange);
title("Lagrange Error");
subplot(3, 1, 2);
plot(nRange_audio, err_farrow);
title("Farrow Error");
subplot(3, 1, 3);
plot(nRange_audio, err_sinc);
title("Sinc Error");

windowLength = 12*10^-3*Fs_audio; %12 ms window
window = blackmanharris(windowLength);
% window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
figure;
% spectrogram(y_theoretical, window, overlap, N, Fs_audio, "yaxis");  
spectrogram(y_sinc, window, overlap, N, "yaxis");  
y_upperLim = .1;
ylim([0 y_upperLim]);
title('y theoretical');