clear all;
close all;

%System parameters
Fs_audio = 48000;
Fs_ctrl = Fs_audio / 4;
R = Fs_audio / Fs_ctrl;

%Control signal
L = [0, 1, 0, 1, .5];
L_init = .5;

%Derived parameters
numSamples_ctrl = length(L);
numSamples_audio = numSamples_ctrl*R;

%Processing objects/buffers
interpolator = Interpolator(R, L_init);
L_interp = zeros(1, numSamples_audio);

n = 1;
for j = 1:length(L)
    interpolator.consumeControlSignal(L(j));
    for k = 1:R
        L_interp(n) = interpolator.tick();
        n = n + 1;
    end
end

n_ctrl = 0:numSamples_ctrl - 1;
n_audio = 0:numSamples_audio - 1;

% figure;
% subplot(2, 1, 1);
% stem(n_ctrl, L);
% title("L[n]");
% subplot(2, 1, 2);
% stem(n_audio, L_interp);
% title("L[n] interp");

figure;
plot(R*(1+n_ctrl), L, "DisplayName", "L");
hold on;
stem(n_audio, L_interp, "DisplayName", "L interp");
hold off;
legend("AutoUpdate", "off", "Location", "NorthWest");
title("Interpolator Test");
xline(R*(1:j-1), "--k", "Displayname", "Frame");
% xline(R*(1:j-1), "--k");
xlabel("Time-index (n)");

% figure;
% t = tiledlayout(1, 1);
% 
% ax1 = axes(t);
% plot(ax1, n_ctrl, L, "-r");
% ax1.XColor = "r";
% ax1.YColor = "r";
% 
% ax2 = axes(t);
% stem(ax2, n_audio, L_interp);
% ax2.XAxisLocation = "top";
% ax2.YAxisLocation = "right";
% ax2.Color = "none";
% ax1.Box = "off";
% ax2.Box = "off";