classdef SystemParams
    %SYSTEMPARAMS Global system parameter constants to keep everything
    %defined in one place
    
    properties(Constant)
        audioRate = 48000;
%         audioRate = 8000;
        controlRate = 1000;
%         controlRate = SystemParams.audioRate;

        %Although this code is syntactically atrocious it seems to be the
        %best approach given how Matlab implements constants
        E_string_modes = StringModes(...
            FilterSpec(...  %Brass slide
                ZeroPoleSpec([0, 0, 1400, -1400], [.9485, .8510, .9079, .9079]),...     %zeros
                ZeroPoleSpec([643 -643 1400 -1400], [.9894, .9894, .9922, .9922]),...   %poles
                -25.3780833903291),...                                                  %dB attenuation
            FilterSpec(...  %Glass slide
                ZeroPoleSpec([0, 0, 1400, -1400], [.9272, .8222, .9608, .9608]),...     %zeros
                ZeroPoleSpec([850, -850, 1400, -1400], [.9957, .9957, .9984, .9984]),...%poles
                -34.5101240774396),...                                                  %dB attenuation
            FilterSpec(...  %Chrome slide
                ZeroPoleSpec([696, -696, 1422, -1422], [.9608, .9608, .8042, .8042]),...%zeros
                ZeroPoleSpec([748 -748 1422 -1422], [.9929, .9929, .9937, .9937]),...   %poles
                -31.1454965842834));                                                    %dB attenuation
        A_string_modes = StringModes(...
            FilterSpec(...  %Brass slide
                ZeroPoleSpec([0, 0, 1600, -1600], [.9406, .8105, .9478, .9478]),...     %zeros
                ZeroPoleSpec([793 -793 1600 -1600], [.9957, .9957, .9948, .9948]),...   %poles
                -29.5613276937785),...                                                  %dB attenuation
            FilterSpec(...  %Glass slide
                ZeroPoleSpec([0, 0, 1640, -1640], [.9646, .7902, .9217, .9217]),...     %zeros
                ZeroPoleSpec([644, -644, 1640, -1640], [.9957, .9957, .9922, .9922]),...%poles
                -29.9583871404878),...                                                   %dB attenuation
            FilterSpec(...  %Chrome slide
                ZeroPoleSpec([0, 0, 1640, -1640], [.9686, .7752, .8042, .8042]),...     %zeros
                ZeroPoleSpec([622 -622 1640 -1640], [.9859, .9859, .9937, .9937]),...   %poles
                -34.0518108566464));                                                    %dB attenuation
        D_string_modes = StringModes(...
            FilterSpec(...  %Brass slide
                ZeroPoleSpec([0, 0, 2000, -2000], [.8727, .7269, .9687, .9687]),...     %zeros
                ZeroPoleSpec([1449 -1449 2000 -2000], [.9930, .9930, .9948, .9948]),... %poles
                -28.9378575357895),...                                                  %dB attenuation
            FilterSpec(...  %Glass slide
                ZeroPoleSpec([0, 0, 1920, -1920],  [.9887, .0543, .9826, .9826]),...    %zeros
                ZeroPoleSpec([980, -980, 1920, -1920], [.9720, .9720, .9948, .9948]),...%poles
                -24.6653413504916),...                                                  %dB attenuation
            FilterSpec(...  %Chrome slide
                ZeroPoleSpec([0, 0, 2000, -2000], [.9644, .6564, .9217, .9217]),...     %zeros
                ZeroPoleSpec([859 -859 2000 -2000], [.9929, .9929, .9922, .9922]),...   %poles
                -28.9746725110396));                                                    %dB attenuation        
        
        %Numbers taken from the patch in Appendix B of the master's thesis
        %TODO: Revamp and potentially extend these parameters later
        E_string_params = StringParams(15*10^-3, 2000, 6, 82.41, ...
            [-0.08135045114297, -0.00085796015850],...  %a_pol
            [0.97816203269973 , 0.00061375406757]);     %g_pol
        A_string_params = StringParams(13*10^-3, 2600, 5, 110, ...
            [-0.05928143968051, 0.00171045642780],...  
            [0.98347976839019 , 0.00040239847018]);     
        D_string_params = StringParams(11*10^-3, 3800, 4, 146.83, ...
            [-0.06091679973956, 0.00298025530804],...  
            [0.98780640700360 , 0.00037712305083]);
        G_string_params = StringParams(0, 0, 3, 196, ...
            [-0.03840938807507, 0.00081125415233],...  
            [0.99012478445221 , 0.00025250158133]);     
        B_string_params = StringParams(0, 0, 2, 246.94, ...
            [-0.03042891937178, 0.00113090288951],...  
            [0.99247813966550 , 0.00012644399078]);     
        e_string_params = StringParams(0, 0, 1, 329.63, ...
            [-0.02955827361150, 0.00134421335136],...  
            [0.99402123928178 , 0.00008928138142]);     
        
        stringLengthMeters = .65;
        lowest_f0 = 65.41; %Corresponds to C2 to support open C tuning
        maxDelayLineLength = ceil(SystemParams.audioRate/SystemParams.lowest_f0); %TODO: Fine tune these calculations later
    end
end

