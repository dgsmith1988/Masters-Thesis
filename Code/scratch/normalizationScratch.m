clear all;
close all;

%System parameters
% Fs = 48000;
% duration_sec = 3;
% numSamples = Fs*duration_sec;
 numSamples = 10;

x_white = 1 - 2*rand(1, numSamples);
x_pink = pinknoise(1, numSamples);
x_white_mean = mean(x_white);
x_pink_mean = mean(x_pink);

%Remove the DC bias
x_white_ndc = x_white - mean(x_white);
x_pink_ndc = x_pink - mean(x_pink);
x_white_ndc_mean = mean(x_white_ndc);
x_pink_ndc_mean = mean(x_pink_ndc);

%Normalize the signals
x_white_nm = x_white / max(abs(x_white));
x_pink_nm = x_pink / max(abs(x_pink));
x_white_nm_mean = mean(x_white_nm);
x_pink_nm_mean = mean(x_pink_nm);

%Now combine the operations
%Normalize the signals with the DC component removed
x_white_ndc_nm = x_white_ndc / max(abs(x_white_ndc));
x_pink_ndc_nm = x_pink_ndc / max(abs(x_pink_ndc));
x_white_ndc_nm_mean = mean(x_white_ndc_nm);
x_pink_ndc_nm_mean = mean(x_pink_ndc_nm);

%Remove the DC component from the normalized signals
x_white_nm_ndc = x_white_nm - mean(x_white_nm);
x_pink_nm_ndc = x_pink_nm - mean(x_pink_nm);
x_white_nm_ndc_mean = mean(x_white_nm_ndc);
x_pink_nm_ndc_mean = mean(x_pink_nm_ndc);

figure;
subplot(2, 1, 1);
stem(x_white);
yline(x_white_mean, "--r");
title("White Noise");
subplot(2, 1, 2);
stem(x_pink);
yline(x_pink_mean, "--r");
title("Pink Noise");

figure;
subplot(2, 1, 1);
stem(x_white_ndc);
yline(x_white_ndc_mean, "--r");
title("White Noise - No DC");
subplot(2, 1, 2);
stem(x_pink_ndc);
yline(x_pink_ndc_mean, "--r");
title("Pink Noise - No DC");

figure;
subplot(2, 1, 1);
stem(x_white_nm);
yline(x_white_nm_mean, "--r");
title("White Noise - Normalized");
subplot(2, 1, 2);
stem(x_pink_nm);
yline(x_pink_nm_mean, "--r");
title("Pink Noise - Normalized");

figure;
subplot(2, 1, 1);
stem(x_white_nm_ndc);
yline(x_white_nm_ndc_mean, "--r");
title("White Noise - Normalized then DC Removal");
subplot(2, 1, 2);
stem(x_pink_nm_ndc);
yline(x_pink_nm_ndc_mean, "--r");
title("Pink Noise - Normalized then DC Removal");

figure;
subplot(2, 1, 1);
stem(x_white_ndc_nm);
yline(x_white_ndc_nm_mean, "--r");
title("White Noise - DC Removal then Normalization");
subplot(2, 1, 2);
stem(x_pink_ndc_nm);
yline(x_pink_ndc_nm_mean, "--r");
title("Pink Noise - DC Removal then Normalization");

figure;
% stem(1, x_white_mean);
hold on;
% stem(2, x_white_ndc_mean);
% stem(3, x_white_nm_mean);
stem(4, x_white_nm_ndc_mean);
stem(5, x_white_ndc_nm_mean);
hold off;
xlim([0 6]);

figure;
% stem(1, x_pink_mean);
hold on;
% stem(2, x_pink_ndc_mean);
% stem(3, x_pink_nm_mean);
stem(4, x_pink_nm_ndc_mean);
stem(5, x_pink_ndc_nm_mean);
hold off;
xlim([0 6]);
