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
numSamples_audio = numSamples_ctrl*R+1;

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

L_interp(end) = L(end);

n_ctrl = 0:numSamples_ctrl - 1;
n_audio = 0:numSamples_audio - 1;

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

figure;
t = tiledlayout(1, 1);
ax1 = axes(t);
plot(ax1, n_ctrl, L, "*k",  "DisplayName", "L");
ax1.XColor = "k";
ax1.YColor = "k";
ax1.XAxisLocation = "top";
ax1.YAxisLocation = "right";
xlim([-1 n_ctrl(end)]);
% ylim([-.1 1.1]);
xlabel("Control Rate Index (m)");
ylabel("L[m]");
grid on;
grid minor;

ax2 = axes(t);
plot(ax2, n_audio, L_interp, "-or", "DisplayName", "L interp");
ax2.XColor = "r";
ax2.YColor = "r";
ax2.XAxisLocation = "bottom";
ax2.YAxisLocation = "left";
ax2.Color = 'none';
xlabel("Audio Rate Index (n)");
ylabel("L[n]");
ax1.Box = 'off';
ax2.Box = 'off';
xticks([0 R 2*R 3*R 4*R 5*R]);