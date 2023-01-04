%The goal here is to see if linear interpolation between the different
%control signal values helps reduce the transient issue I had run into
%before.

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

%Delay values control signal
numPeriods = 10;     %the discontinuity should be introduced 10-1 = 9 times
controlPeriod = numSamples_control/numPeriods;
start = 0;
stop = 1;
increment = (stop - start)/(controlPeriod-1);
D = start:increment:stop;
D = repmat(D, 1, numPeriods);
% D = filter(1/8*[1 1 1 1 1 1 1 1], 1, D);
% D = D + 2.5;

%Input signal is a sine wave to make things clearer. Put it in the filter's
%pass band.
f0 = 480;
x = sin(2*pi*f0/Fs_audio*nRange_audio);
% x = [1, zeros(1, numSamples-1)];
% x = ones(1, numSamples);
% x = repmat([1, zeros(1, 11)], 1, numSamples/12);

%Processing object initialization
lagrangeDelay = LagrangeDelay(L, D(1));
farrowDelay = dsp.VariableFractionalDelay('InterpolationMethod', 'Farrow', 'FilterLength', L);
y_lagrange = zeros(1, numSamples_audio);
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

D_interp = filter(1/8*[1 1 1 1 1 1 1 1], 1, D_interp);
D_farrow = D_interp + 2;
y_theoretical = sin(2*pi*f0/Fs_audio*(nRange_audio - D_farrow));
% y_theoretical = sin(2*pi*f0/Fs_audio*(nRange_audio - 2 - D_interp));
%add the two sample delay from the filter starting from scratch
y_theoretical(1:2) = 0;

figure
subplot(2, 1, 1);
plot(nRange_control, D);
title("D");
subplot(2, 1, 2);
plot(nRange_audio, D_interp);
title("D interp");
figure;
subplot(2, 1, 1);
stem(nRange_control, D);
title("D");
lower = numSamples_control/numPeriods-50;
upper = lower+ 100;
xlim([lower upper ]);
subplot(2, 1, 2);
stem(nRange_audio, D_interp);
lower = R*numSamples_control/numPeriods-50;
upper = lower + 100;
xlim([lower upper]);
title("D interp");

%Processing loop
% n_audio = 1;
for n_audio = nRange_audio+1
    if(mod(n_audio, 100) == 0)
        fprintf("n_audio = %i/%i\n", n_audio, numSamples_audio);
    end
    
    lagrangeDelay.setFractionalDelay(D_interp(n_audio));
    y_lagrange(n_audio) = lagrangeDelay.tick(x(n_audio));
    y_farrow(n_audio) = farrowDelay(x(n_audio), D_farrow(n_audio));
%     y_farrow(n_audio) = farrowDelay(x(n_audio), D_interp(n_audio));
end

figure;
% stem(nRange_audio, x);
% hold on;
% stem(nRange_audio, y_lagrange);
% hold off;
% plot(nRange_audio, x, nRange_audio, y_lagrange, nRange_audio, y_farrow);
stem(nRange_audio, x);
hold on;
stem(nRange_audio, y_lagrange);
stem(nRange_audio, y_farrow);
hold off;

% hold on;
% stem(transitionSample-1, y_lagrange(transitionSample));
% hold off;
legend('x', 'y lagrange', 'y farrow');
xlim([lower upper]);
% xlim([11975 12050]);
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

% figure; plot(nRange_audio, y_lagrange-y_farrow); xlabel("Time (sec)");
err_farrow = y_theoretical - y_farrow;
err_lagrange = y_theoretical - y_lagrange;
figure;
subplot(2, 1, 1);
plot(nRange_audio, err_farrow);
title("Farrow Error");
subplot(2, 1, 2);
plot(nRange_audio, err_lagrange);
title("Lagrange Error");
% legend('err farrow', 'err lagrange');