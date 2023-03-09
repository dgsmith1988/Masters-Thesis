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