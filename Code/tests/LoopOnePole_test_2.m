%********Test 2 - Frequency Resposne for range of L*********
%Run L through a range of parameters to determine the frequency response
%effects and ensure that the resulting systems would be stable in a
%feedback loop. This is done for all strings.

%Note that string 1 (e) and 4 (D) generate filters with positive gains for 
%a relative string length of L = .25 (and perhaps others) which would 
%create an unstable system in the context of a feedback loop. This
%effectively puts a bounds on the values of L which are usable.
%TODO: Find this transition point for L which they switch to unstable and
%examine the a and g parameters there.

clear;
close all;

L_min = SystemParams.minRelativeStringLength;
L_max = SystemParams.maxRelativeStringLength;
numSamples = 8;
decrement = (L_min - L_max) / (numSamples - 1);
L = L_max:decrement:L_min;

stringParams = [SystemParams.e_string_params, SystemParams.B_string_params,...
    SystemParams.G_string_params, SystemParams.D_string_params....
    SystemParams.A_string_params, SystemParams.E_string_params];

for string = stringParams
    %Initialize/instantiate the processing object
    %Initial value doesn't really matter here as much
    loopFilter = LoopOnePole(string.a_pol, string.g_pol, L(1));
    
    %Output buffers to store values
    f = zeros(1, FilterObject.N);
    h = zeros(numSamples, FilterObject.N);
    
    figure;
    for n = 1:numSamples
        loopFilter.consumeControlSignal(L(n));
        [h(n,:), f] = loopFilter.computeFrequencyResponse();
        subplot(2, 1, 1);
        hold on;
        plot(f, mag2db(abs(h(n, :))), 'DisplayName', sprintf("L = %.2f", L(n)));
        hold off;
        text(f(end-350), mag2db(abs(h(n, end)))-.015, sprintf("L = %.2f", L(n)));
        subplot(2, 1, 2);
        hold on;
        plot(f, angle(h(n, :)), 'DisplayName', sprintf("L = %.2f", L(n)));
        hold off;
    end
    subplot(2, 1, 1);
    xlabel("Frequency (Hz)");
    ylabel("Magnitude (dB)");
    title(sprintf("String #%i - Magnitude Response for Various L Values", string.number));
    grid on;
    grid minor;
    subplot(2, 1, 2);
    xlabel("Frequency (Hz)");
    ylabel("Phase (rad)");
    title(sprintf("String #%i - Phase Response for Various L Values", string.number));
    grid on;
    grid minor;
    legend('Location', 'southeast');
    % legend();
end