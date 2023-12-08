function [time] = trial_fixation(p)
        Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
            p.fix.lineWidthPix, [0 255 255], [p.ptb.xCenter p.ptb.yCenter], 2);
        time = Screen('Flip', p.ptb.window);
    end