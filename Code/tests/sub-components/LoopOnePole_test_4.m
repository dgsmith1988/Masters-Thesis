%********Test 4 - Phase Delay with Average*********
%Plot the phase delay and average phase delay on the same figure.

clear;
close all;

L = SystemParams.maxRelativeStringLength;

stringParams = [SystemParams.e_string_params, SystemParams.B_string_params,...
    SystemParams.G_string_params, SystemParams.D_string_params....
    SystemParams.A_string_params, SystemParams.E_string_params];

%Output buffers to store values
w = zeros(1, FilterObject.N);
phi = zeros(1, FilterObject.N);
avg = 0;

for string = stringParams
    %Initialize/instantiate the processing object
    loopFilter = LoopOnePole(string.a_pol, string.g_pol, L);  
    
    figure;
    [phi, w, avg] = loopFilter.computePhaseDelay();
    plot(w/pi, phi, 'DisplayName', sprintf("L = %.2f", L));    
    yline(avg, "--k", "DisplayName", "Avg");
    xlabel("Normalized Frequency (\times\pi rad/sample)");
    ylabel("Phase delay (Samples)");
    title(sprintf("String #%i - Phase Delay", string.number));
    grid on;
    grid minor;
    legend();
end