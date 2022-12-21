function [triggerPeriod_ms] = f_c2period_ms(f_c)
% units here should be ms / period
% ms / sec * (cycles / sec)^-1 = ms / cycle
triggerPeriod_ms = round(1000./f_c);
end