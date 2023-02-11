function y = synthesizeSinglePluck(synthesizerParams, L)
%Easier to copy these here rather than make arguments atm... Fix this
%later...
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;
R = Fs_audio / Fs_ctrl;

%Derived parameters
numSamples_ctrl = length(L);
numSamples_audio = R * numSamples_ctrl;

%Processing objects
slideSynth = SlideSynth(synthesizerParams, L(1));
y = zeros(1, numSamples_audio);

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
        n = n + 1;
    end
end
end

