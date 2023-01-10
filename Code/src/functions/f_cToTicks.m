function [ticks] = f_cToTicks(f_c, Fs)
%Deteremine the number of ticks/samples which need to pass in order for one
%period at f_c to occur.

arguments
    f_c double  {mustBePositive, mustBeFinite}
    Fs          {mustBePositive, mustBeFinite, mustBeInteger}
end

% units here should be samples / period (or cycle)
% (cycles / sec)^-1  * samples/sec = samples / cycle
ticks = round((1./f_c) .* Fs);
end