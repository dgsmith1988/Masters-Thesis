classdef Note
    %NOTE Simple class to hold syntehsized note sounds to help organize
    %code
    
    properties
        rhythmicDuration    %quarter note = 1, eigth-note = 1/2
        fret
        slideInFlag
        vibratoFlag
        
        %Derived properties
        duration_sec
    end
    
    properties (Constant)
        BPM = 75
        slideRhythmicDuration = 1/4
        slideDuration_sec = Note.calucalateDuration(Note.slideRhythmicDuration, Note.BPM)
    end
    
    methods
        function obj = Note(rhythmicDuration, fret, slideInFlag, vibratoFlag)
            obj.rhythmicDuration = rhythmicDuration;
            obj.fret = fret;
            obj.slideInFlag = slideInFlag;
            obj.vibratoFlag = vibratoFlag;
            obj.duration_sec = obj.calucalateDuration(obj.rhythmicDuration, obj.BPM);
        end
        
        function L = generateLCurve(obj, Fs_ctrl)
            L = [];
            soundDuration_sec = obj.duration_sec;
            
            if obj.slideInFlag
                L = generateLCurve(obj.fret-1, obj.fret, obj.slideDuration_sec, Fs_ctrl);
                soundDuration_sec = soundDuration_sec - obj.slideDuration_sec;
            end
            
            %Concatentate a a straight or vibrato signal depending on the flag
            if obj.vibratoFlag
                %All the vibrato terms are in frets which are then mapped to the relative
                %string length
                centerFret = obj.fret;
                vibratoWidth = 1/8;
                vibratoFreq = 1.75;
                t = (0:Fs_ctrl*soundDuration_sec-1)/Fs_ctrl;
                fretTrajectory = vibratoWidth*sin(2*pi*vibratoFreq*t) + centerFret;
                L = [L, fretNumberToRelativeLength(fretTrajectory)];
            else
                %Single note pluck with no-sliding whatsoever
                L_note = fretNumberToRelativeLength(obj.fret);
                L = [L, L_note*ones(1, round(soundDuration_sec*Fs_ctrl))];
            end
        end
    end
    
    methods(Static)
        function duration_sec = calucalateDuration(rhythmicDuration, BPM)
            duration_sec = rhythmicDuration / BPM * 60;
        end
    end
end

