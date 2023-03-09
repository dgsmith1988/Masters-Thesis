%********Test 3 - Phase Delay for range of L*********
%Run L through a range of parameters to determine the phase delay at each
%setting. This is done for all strings.

%Note the e and the D strings have a negative phase delay associated
%with a relative string lenght of .25. They are also the only filters which
%exhibit a positive gain value there (and in general). It is also
%interesting to note that the E string has an increasing phase delay as the
%string gets shorter, whereas all the other exhibit the opposite behavior.

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
    w = zeros(1, FilterObject.N);
    phi = zeros(numSamples, FilterObject.N);
    
    figure;
    for n = 1:numSamples
        loopFilter.consumeControlSignal(L(n));
        [phi(n,:), w] = loopFilter.computePhaseDelay();
        hold on;
        plot(w/pi, phi(n, :), 'DisplayName', sprintf("L = %.2f", L(n)));
        text(w(1+409)/pi, phi(n, 410), sprintf("L = %.2f", L(n)));
    end
    hold off;
    xlabel("Normalized Frequency (\times\pi rad/sample)");
    ylabel("Phase delay (Samples)");
    title(sprintf("String #%i - Phase Delay for Various L Values", string.number));
    grid on;
    grid minor;
    legend();
end