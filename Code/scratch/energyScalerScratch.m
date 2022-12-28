%Look into why the two different calculation methods for the g_c theory
%produce different results... perhaps some sort of a rounding issue?

%Generate the sweep signal to test the block with by sampling the
%continuous domain signal
a = (sweepStop - sweepStart) / duration_sec^2;
c = sweepStart;
DWGLengthSweep = a*(nRange*Ts).^2 + c;

%Reset the internal state of the energy sscaler. Use this value based on
%the parametrization above to produce continuity and agreement between the
%theory and measured.
energyScaler.prevLengthSamples = a*(-1*Ts)^2 + c;

%Processing loop
for n = nRange + 1
    g_c(n) = energyScaler.tick(DWGLengthSweep(n));
end

figure;
yyaxis left;
plot(nRange, g_c);
ylabel("g_c (Linear gain)");
ylim([.98 1.02])
yyaxis right;
plot(nRange, DWGLengthSweep);
ylabel("DWG Length (Samples)");
xlabel("n (Time-step)");
title("g_c for Paraobolic DWG Length");

DWG_n_theory = a*(nRange*Ts).^2 + c;
DWG_n_1_theory = a*((nRange-1)*Ts).^2 + c;
delta_x_theory_1 = a*(2*nRange-1)*Ts^2;
delta_x_theory_2 = DWG_n_theory - DWG_n_1_theory;
g_c_theory_1 = sqrt(abs(1-delta_x_theory_1));
g_c_theory_2 = sqrt(abs(1-delta_x_theory_2));
g_c_err_1 = g_c_theory_1 - g_c;
g_c_err_2 = g_c_theory_2 - g_c;

figure;
subplot(2, 1, 1);
plot(nRange, g_c_err_1)
title("Method 1 Error")
subplot(2, 1, 2);
plot(nRange, g_c_err_2)
title("Method 2 Error")