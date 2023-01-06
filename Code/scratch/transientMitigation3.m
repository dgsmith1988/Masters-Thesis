%Experiment with the Farrow object to more correctly understand its
%parametrization

clear;
close all;

%System parameters
Fs_audio = SystemParams.audioRate;
Fs_control = SystemParams.controlRate;
R = Fs_audio/Fs_control;
duration_sec = 2;
numSamples_audio = duration_sec*Fs_audio;
numSamples_control = duration_sec*Fs_control;
nRange_audio = 0:numSamples_audio-1;
nRange_control = 0:numSamples_control-1;
L = 6;
phaseDelay = floor((L-1)/2);

%Delay values control signal
start = 0;
stop = 5;
increment = (stop - start)/(numSamples_control-1);
D = start:increment:stop;

%Input signal is a sine wave to make things clearer. Put it in the filter's
%pass band.
f0 = 480;
x = sin(2*pi*f0/Fs_audio*nRange_audio);

%Processing object initialization
farrowDelay = dsp.VariableFractionalDelay('InterpolationMethod', 'Farrow', 'FilterLength', L);
y_farrow = zeros(1, numSamples_audio);

%apply interpolation to the D(n) control signal
D_interp = zeros(1, Fs_audio);
n_audio = 1;
for n_control = nRange_control+1
    %Hold the last value as we have nothing to interpolate to
    if n_control == nRange_control(end) + 1
        increment = 0;
    else
        %calculate the increment to be added each sample
        increment = (D(n_control+1) - D(n_control))/R;
    end
    
    for k = 0:R-1
        D_interp(n_audio) = D(n_control) + k*increment;
        n_audio = n_audio + 1;
    end
end

% D_interp = filter(1/8*[1 1 1 1 1 1 1 1], 1, D_interp);
y_theoretical = sin(2*pi*f0/Fs_audio*(nRange_audio - phaseDelay - D_interp));

%add the two sample delay from the filter starting from scratch
y_theoretical(1:phaseDelay) = 0;

figure
subplot(2, 1, 1);
plot(nRange_control, D);
title("D");
subplot(2, 1, 2);
plot(nRange_audio, D_interp);
title("D interp");

% figure;
% subplot(2, 1, 1);
% stem(nRange_control, D);
% title("D");
% lower = numSamples_control/numPeriods-50;
% upper = lower+ 100;
% xlim([lower upper ]);
% subplot(2, 1, 2);
% stem(nRange_audio, D_interp);
% lower = R*numSamples_control/numPeriods-50;
% upper = lower + 100;
% xlim([lower upper]);
% title("D interp");

%Processing loop
for n_audio = nRange_audio+1
    if(mod(n_audio, 100) == 0)
        fprintf("n_audio = %i/%i\n", n_audio, numSamples_audio);
    end
    
    y_farrow(n_audio) = farrowDelay(x(n_audio), D_interp(n_audio));
end

figure;
plot(nRange_audio, x, nRange_audio, y_farrow, nRange_audio, y_theoretical);
% stem(nRange_audio, x);
% hold on;
% stem(nRange_audio, y_farrow);
% stem(nRange_audio, y_theoretical);
% hold off;

legend('x', 'y farrow', 'y theoretical');
% xlim([lower upper]-10);
grid on;
grid minor;

% frameLength = 300;
% overlap = .5;
% hopSize = frameLength*(1-overlap);
% for i = 1:numSamples_audio/(hopSize)
%     start = (i-1)*hopSize+1;
%     stop = start + frameLength;
%     xlim([start, stop]);
%     disp("Hit enter for next frame...");
%     pause;
% end

err_farrow = y_theoretical - y_farrow;
figure;
plot(nRange_audio, err_farrow);
title("Farrow Error");

windowLength = 12*10^-3*Fs_audio; %12 ms window
window = blackmanharris(windowLength);
% window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5;

figure;
subplot(2, 1 , 1);
spectrogram(y_theoretical, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim]);
title('y theoretical');
subplot(2, 1, 2);
spectrogram(y_farrow, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim]);
title('y farrow');
