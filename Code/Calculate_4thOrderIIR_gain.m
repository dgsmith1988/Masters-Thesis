%Script for finding the appropriate gain vlaues to make the peaks of the
%longitudinal mode filters unity. This script assumes that the dB_atten
%values are currently set to zero in the filter specs. After running this
%script the values should be copied into SystemParams.m

close all;
clear;

num_strings = 3;
num_slides = 3;
dB_atten = zeros(1, num_strings*num_slides);

LongitudinalModeFilters.E_string.brass = LongitudinalModeFilter(SystemParams.E_string.brass);
LongitudinalModeFilters.E_string.glass = LongitudinalModeFilter(SystemParams.E_string.glass);
LongitudinalModeFilters.E_string.chrome = LongitudinalModeFilter(SystemParams.E_string.chrome);
LongitudinalModeFilters.A_string.brass = LongitudinalModeFilter(SystemParams.A_string.brass);
LongitudinalModeFilters.A_string.glass = LongitudinalModeFilter(SystemParams.A_string.glass);
LongitudinalModeFilters.A_string.chrome = LongitudinalModeFilter(SystemParams.A_string.chrome);
LongitudinalModeFilters.D_string.brass = LongitudinalModeFilter(SystemParams.D_string.brass);
LongitudinalModeFilters.D_string.glass = LongitudinalModeFilter(SystemParams.D_string.glass);
LongitudinalModeFilters.D_string.chrome = LongitudinalModeFilter(SystemParams.D_string.chrome);

%Now lets generate the frequency responses to see how they compare to what
%the paper displays.
N = 8192;
strings = fieldnames(LongitudinalModeFilters);
slides = fieldnames(LongitudinalModeFilters.(strings{1}));

%Plot them all individually
% for k = 1:numel(strings)
%     for l = 1:numel(slides)
%         b = LongitudinalModeFilters.(strings{k}).(slides{l}).b;
%         a = LongitudinalModeFilters.(strings{k}).(slides{l}).a;
%         figure;
%         [h, f] = freqz(b, a, N, Fs);
%         semilogx(f, mag2db(abs(h)));
%         ylabel('Magnitdue (dB)');
%         xlabel('Frequency (Hz)');
%         title_string = sprintf("%s - %s slide", strings{k}, slides{l});
%         title(strrep(title_string, '_', ' '));
%         grid on;
%     end
% end

%Plot them all on a 3x3 grid similar to the paper
figure;
n = 1; %subplot index counter
for k = 1:numel(strings)
    for l = 1:numel(slides)
        b = LongitudinalModeFilters.(strings{k}).(slides{l}).b;
        a = LongitudinalModeFilters.(strings{k}).(slides{l}).a;
        [h, f] = freqz(b, a, N, SystemParams.audioRate);
        subplot(3, 3, n);
        semilogx(f, mag2db(abs(h)));
        ylabel('Magnitude (dB)');
        xlabel('Frequency (Hz)');
        title_string = sprintf("%s - %s slide", strings{k}, slides{l});
        dB_atten(n) = -max(mag2db(abs(h)));
        title(strrep(title_string, '_', ' '));
        grid on;
        n = n + 1;
    end
end