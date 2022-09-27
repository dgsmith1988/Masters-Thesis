%Script for generating filter coefficients base on the specification used
%in the CMJ paper (i.e. pole/zero locations based on linear frequencies and
%radius values)

close all;
clear;

Fs = 48000;
k = 1;
num_strings = 3;
num_slides = 3;
dB_atten = zeros(1, num_strings*num_slides);

%the first iteration finds the values to scale the filters down by
%the second iteration generates the filters using the values found
for m = 1:2
    LongitudinalModeFilters.E_string.brass = LongitudinalModeFilter(...
        [0, 0, 1400, -1400],...             %zeros linear frequencies
        [.9485, .8510, .9079, .9079],...    %zeros R
        [643 -643 1400 -1400],...           %poles linear frequencies
        [.9894, .9894, .9922, .9922],...    %poles R
        dB_atten(1), Fs);
    
    LongitudinalModeFilters.E_string.glass = LongitudinalModeFilter(...
        [0, 0, 1400, -1400],...             %zeros linear frequencies
        [.9272, .8222, .9608, .9608],...    %zeros R
        [850, -850, 1400, -1400],...        %poles linear frequencies
        [.9957, .9957, .9984, .9984],...    %poles R
        dB_atten(2), Fs);
    
    LongitudinalModeFilters.E_string.chrome = LongitudinalModeFilter(...
        [696, -696, 1422, -1422],...        %zeros linear frequencies
        [.9608, .9608, .8042, .8042],...    %zeros R
        [748 -748 1422 -1422],...           %poles linear frequencies
        [.9929, .9929, .9937, .9937],...  %poles R
        dB_atten(3), Fs);
    
    LongitudinalModeFilters.A_string.brass = LongitudinalModeFilter(...
        [0, 0, 1600, -1600],...             %zeros linear frequencies
        [.9406, .8105, .9478, .9478],...    %zeros R
        [793 -793 1600 -1600],...           %poles linear frequencies
        [.9957, .9957, .9948, .9948],...    %poles R
        dB_atten(4), Fs);
    
    LongitudinalModeFilters.A_string.glass = LongitudinalModeFilter(...
        [0, 0, 1640, -1640],...             %zeros linear frequencies
        [.9646, .7902, .9217, .9217],...    %zeros R
        [644, -644, 1640, -1640],...        %poles linear frequencies
        [.9957, .9957, .9922, .9922],...    %poles R
        dB_atten(5), Fs);
    
    LongitudinalModeFilters.A_string.chrome = LongitudinalModeFilter(...
        [0, 0, 1640, -1640],...             %zeros linear frequencies
        [.9686, .7752, .8042, .8042],...    %zeros R
        [622 -622 1640 -1640],...           %poles linear frequencies
        [.9859, .9859, .9937, .9937],...    %poles R
        dB_atten(6), Fs);
    
    LongitudinalModeFilters.D_string.brass = LongitudinalModeFilter(...
        [0, 0, 2000, -2000],...             %zeros linear frequencies
        [.8727, .7269, .9687, .9687],...    %zeros R
        [1449 -1449 2000 -2000],...         %poles linear frequencies
        [.9930, .9930, .9948, .9948],...    %poles R
        dB_atten(7), Fs);
    
    LongitudinalModeFilters.D_string.glass = LongitudinalModeFilter(...
        [0, 0, 1920, -1920],...             %zeros linear frequencies
        [.9887, .0543, .9826, .9826],...    %zeros R
        [980, -980, 1920, -1920],...        %poles linear frequencies
        [.9720, .9720, .9948, .9948],...    %poles R
        dB_atten(8), Fs);
    
    LongitudinalModeFilters.D_string.chrome = LongitudinalModeFilter(...
        [0, 0, 2000, -2000],...             %zeros linear frequencies
        [.9644, .6564, .9217, .9217],...    %zeros R
        [859 -859 2000 -2000],...           %poles linear frequencies
        [.9929, .9929, .9922, .9922],...    %poles R
        dB_atten(9), Fs);
    
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
            [h, f] = freqz(b, a, N, Fs);
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
end