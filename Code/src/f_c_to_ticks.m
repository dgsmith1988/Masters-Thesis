function [ticks] = f_c_to_ticks(f_c)
% units here should be ms / period
% (cycles / sec)^-1  * samples/sec = samples / cycle
ticks = round(1/f_c * SystemParams.audioRate);
end