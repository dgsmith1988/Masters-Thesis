clear;
close all;

R = .995;
dcBlocker = DCBlocker(R);
figure;
dcBlocker.plotFrequencyResponse();
% title(sprintf("DC Blocker Frequency Response - R = %.3f", R));
title(sprintf("R = %.3f", R));

% figure;
% dcBlocker.update_f_c(250);
% dcBlocker.plotFrequencyResponse();
% title("Resonator Frequency Response - update_f_c() test", 'interpreter', 'none');
% grid on;
% grid minor;

subplot(2, 1, 1);
xlim([-500 24000]);
ylim([-15 2]);
grid on; grid minor;

subplot(2, 1, 2);
xlim([-500 24000]);
ylim([-2 90]);
grid on; grid minor;
