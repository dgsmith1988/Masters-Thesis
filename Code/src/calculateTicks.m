function ticks = calculateTicks(duration_ms)
    ticks = round((duration_ms*10^-3)*SystemParams.audioRate);
end