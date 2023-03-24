function y = runSlideSynthTest(synthesizerParams, L)
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;
R = Fs_audio / Fs_ctrl;

%Derived parameters
numSamples_ctrl = length(L);
numSamples_audio = R*numSamples_ctrl;

n_audio = 0:numSamples_audio - 1;
n_ctrl = 0:numSamples_ctrl - 1;

%Processing objects
slideSynth = SlideSynth(synthesizerParams, L(1));
y = zeros(1, numSamples_audio);
slideSpeed = zeros(1, numSamples_audio);
f_c = zeros(1, numSamples_audio);

%Processing loop
slideSynth.pluck(); %Set up the string to generate noise...
n = 1;
for m = 1:numSamples_ctrl
    slideSynth.consumeControlSignal(L(m))
    for k = 1:R
        if(mod(n, 1000) == 0)
            fprintf("n = %i/%i\n", n, numSamples_audio);
        end
        y(n) = slideSynth.tick();
        %Extract the parameters here as they don't get updated until the
        %call to slideSynth.tick() due to interpolation
        slideSpeed(n) = slideSynth.contactSoundGenerator.slideSpeed_n;
        f_c(n) = slideSynth.contactSoundGenerator.f_c_n;
        n = n + 1;
    end
end

%Generate the various plots
figure;
subplot(4, 1, 1)
% plot(n_audio, y);
% xlabel("n");
plot(n_audio/Fs_audio, y);
xlabel("Sec");
ylabel("Amplitude");
title("y[n]");

subplot(4, 1, 2);
plot(n_ctrl/Fs_ctrl, L);
title("L[m]");
% xlabel("n");
xlabel("Sec");
ylabel("Relative length");

subplot(4, 1, 3);
% plot(n_audio, f_c);
% xlabel("n");
plot(n_audio/Fs_audio, f_c);
xlabel("Sec");
ylabel("Hz");
title("f_c[n]");

subplot(4, 1, 4);
% plot(n_audio, slideSpeed);
% xlabel("n");
plot(n_audio/Fs_audio, slideSpeed);
xlabel("Sec");
ylabel("m/s");
title("slideSpeed[n]");
end
