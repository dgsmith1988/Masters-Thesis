%Script to plot filter responses to compare them to what is displayed in
%the CMJ article

close all;
clear;
% addpath("..\src");

num_strings = 3;
num_slides = 3;

LongitudinalModeFilters.E_string.brass = LongitudinalMode(SystemParams.E_string_modes.brass);
LongitudinalModeFilters.E_string.glass = LongitudinalMode(SystemParams.E_string_modes.glass);
LongitudinalModeFilters.E_string.chrome = LongitudinalMode(SystemParams.E_string_modes.chrome);
LongitudinalModeFilters.A_string.brass = LongitudinalMode(SystemParams.A_string_modes.brass);
LongitudinalModeFilters.A_string.glass = LongitudinalMode(SystemParams.A_string_modes.glass);
LongitudinalModeFilters.A_string.chrome = LongitudinalMode(SystemParams.A_string_modes.chrome);
LongitudinalModeFilters.D_string.brass = LongitudinalMode(SystemParams.D_string_modes.brass);
LongitudinalModeFilters.D_string.glass = LongitudinalMode(SystemParams.D_string_modes.glass);
LongitudinalModeFilters.D_string.chrome = LongitudinalMode(SystemParams.D_string_modes.chrome);

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
        xlim([300 5000]);
        ylim([-35 5]);
        text(500, -30, sprintf("String #%i", 6-(k-1)));
        grid on;
        xticklabels({});
        xlabel({});
        
        %Add the slide type only on the top row
        if n == 1 || n == 2 || n == 3
            title_string = sprintf("%s slide", slides{l});
            title_string{1}(1) = upper(title_string{1}(1));
            title(title_string);
        end
        
        %Add the tick labels and xlabel only on the bottom row
        if n == 7 || n == 8 || n == 9
            xticks(1000*[.4 .5 .6 .7 .8 .9 1 2 3 4 5]);
            xticklabels({'', '.5', '', '', '', '', '1', '2', '3', '4', '5'});
            xtickangle(0);
            xlabel("Frequency (kHz)");
        end
        
        n = n + 1;
    end
end
