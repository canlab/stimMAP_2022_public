% This code is for question after tDCS
clear
clc

prompt = 'PARTICIPANT (in raw number form, e.g. 1, 2,...,60): ';
sub_num = input(prompt);
prompt = 'SESSION (1 , 2, 3, or 4): ';
session = input(prompt);
prompt = 'CURRENT (in raw number form, e.g. 0.5, 1, 1.5, 2 mA): ';
sub_current = input(prompt);
prompt = 'Electrod Location (Posterior or Anterior): ';
Electrode_location = input(prompt,'s');

%time to waite for each question
time_wait_each_question=6;

% time to waite for circular rating
rating_duration=6;

%%  Biopac parameters if needed ________________________________________________________
channel = struct;
channel.biopac = 0;
channel.trigger    = 0;
channel.fixation   = 1;
channel.cue        = 2;
channel.expect     = 3;
channel.administer = 4;
channel.actual     = 5;
screens                        = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber             = max(screens); % Draw to the external screen if avaliable
p.ptb.white                    = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                    = BlackIndex(p.ptb.screenNumber);
[p.ptb.window, p.ptb.rect]     = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize', p.ptb.window);
p.ptb.ifi                      = Screen('GetFlipInterval', p.ptb.window);
Screen('BlendFunction', p.ptb.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextSize', p.ptb.window, 50);
[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
p.fix.sizePix                  = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];

%% Directories ______________________________________________________________
task_dir                       = pwd;
main_dir_subfolder=             fileparts((task_dir));
main_dir                       = fileparts(fileparts(task_dir));

%% Keyboard information _____________________________________________________
KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('3#');
p.keys.left                    = KbName('1!');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.trigger                 = KbName('5%');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');
[id, name]                     = GetKeyboardIndices;
trigger_index                  = find(contains(name, 'Current Designs'));
trigger_inputDevice            = id(trigger_index);
keyboard_index                 = find(contains(name, 'AT Translated Set 2 Keyboard'));
keyboard_inputDevice           = id(keyboard_index);

%% Instructions _____________________________________________________
taskname='tDCS-rating';
instruct_filepath              = fullfile(main_dir_subfolder, 'cue');
instruct_start_name            = ['task-', taskname, '_start.png'];
instruct_end_name              = ['task-', taskname, '_end.png'];
instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);
HideCursor;

%% Make Images Into Textures ________________________________________________
start_tex       = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
end_tex         = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
HideCursor;
Screen('TextSize',p.ptb.window,72);
Screen('DrawTexture',p.ptb.window,start_tex,[],[]);
Screen('Flip',p.ptb.window);
WaitKeyPress(p.keys.start);

%% _______________________ Wait for Trigger to Begin ___________________________
% 1) wait for 's' key, once pressed, automatically flips to fixation
% 2) wait for trigger '5'
DisableKeysForKbCheck([]);
fixation_cross(p);
WaitKeyPress(p.keys.trigger);

Experiment_type={'Pain','Itching','Tingling/Electrial','Warmth/Heat','Metallic/Iron taste','Pleasant','Pleasant'};
cue_image = fullfile(main_dir_subfolder,'cue','Question_0.png');
cue_tex = Screen('MakeTexture', p.ptb.window, imread(cue_image));
Screen('DrawTexture',p.ptb.window,cue_tex,[],[]);
Screen('Flip',p.ptb.window);
WaitSecs(time_wait_each_question);

for i=1:6
    cue_image = fullfile(main_dir_subfolder,'cue',strcat('Question_',num2str(i),'.png'));
    cue_tex = Screen('MakeTexture', p.ptb.window, imread(cue_image));
    Screen('DrawTexture',p.ptb.window,cue_tex,[],[]);
    Screen('Flip',p.ptb.window);
    WaitSecs(time_wait_each_question);
    if i<6
        cue_image = fullfile(main_dir_subfolder,'cue','1.png');
    else
        cue_image = fullfile(main_dir_subfolder,'cue','2.png');
        
    end
    
    cue_tex = Screen('MakeTexture', p.ptb.window, imread(cue_image));
    [trajectory{i}, display_onset(i), RT(i), response_onset(i), biopac_display_onset(i), response(i)] = circular_rating_output1(rating_duration, p, cue_tex,'', channel, channel.expect);
end
Screen('TextSize',p.ptb.window,72);
Screen('DrawTexture',p.ptb.window,end_tex,[],[]);
Screen('Flip',p.ptb.window);
WaitKeyPress(p.keys.end);

%% _______________________ Save Results ___________________________

save_Directory=strcat(fileparts(pwd),'\Results\');
if ~exist(save_Directory, 'dir');    mkdir(save_Directory);     end
cd(save_Directory)
ar=[[strcat('sub-', sprintf('%02d', sub_num)), ...
    strcat('_ses-',sprintf('%02d', session))]];

ar_check_directory=[[strcat('sub-', sprintf('%02d', sub_num))]];

Results_save_Directory_check_directory_exist_or_not=strcat(save_Directory,ar_check_directory);
Results_save_Directory=strcat(save_Directory,ar);
% Make directory for each participant
if ~exist(Results_save_Directory_check_directory_exist_or_not, 'dir');    mkdir(Results_save_Directory_check_directory_exist_or_not);     end
cd(Results_save_Directory_check_directory_exist_or_not)

% Make directory for each sesssion of each participant
ar_check_directory_session=[[strcat('sub-', sprintf('%02d', sub_num)), ...
    strcat('_ses-',sprintf('%02d', session))]];

Results_save_Directory_check_directory_session_exist_or_not=strcat(ar_check_directory_session);
if ~exist(Results_save_Directory_check_directory_session_exist_or_not, 'dir');    mkdir(Results_save_Directory_check_directory_session_exist_or_not);     end
cd(Results_save_Directory_check_directory_session_exist_or_not)
Screen('Close'); close all; sca;
arr=[[strcat('sub-', sprintf('%02d', sub_num)), ...
    strcat('_ses-',sprintf('%02d', session)),'-',Electrode_location]];

vnames = {'Electrode_location', 'Pain', 'Itching', 'Tingling_Electrial', 'Warmth_Heat', 'Metalic_Iron', 'Pleasant'};
vtypes = {'string', 'double','double','double','double','double','double'};
T = table('Size', [1, 7], 'VariableNames', vnames, 'VariableTypes', vtypes);
T.Electrode_location=Electrode_location;
T.Pain                = response(1) ;
T.Itching              = response(2) ;
T.Tingling_Electrial= response(3) ;
T.Warmth_Heat                = response(4) ;
T.Metalic_Iron                = response(5) ;
T.Pleasant             = response(6) ;
save(arr)
as1=strcat(arr,'.csv');
writetable(T,as1);

%% _________________________ C. Clear parameters _______________________________
clear p; clearvars; Screen('Close'); close all; sca;
clear

%-------------------------------------------------------------------------------
%                                   Function
%-------------------------------------------------------------------------------
function [time] = fixation_cross(p)
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
time = Screen('Flip', p.ptb.window);
end
function [time] = trial_fixation(p)
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, [0 255 255], [p.ptb.xCenter p.ptb.yCenter], 2);
time = Screen('Flip', p.ptb.window);
end
