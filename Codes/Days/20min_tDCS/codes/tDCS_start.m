%This program is only for stating data acqusition and turn it on tDCS
%ramp up = 30 sec, ramp down = 30 sec,  stimulation duration = 20 min (1200 sec)

clear
close all
clc

time_start_program=GetSecs;

% tDCS_stimulation_duration= ramp_up+ramp_off+stimulation_duration=30+30+1200=1300 sec
tDCS_stimulation_duration_experiment=1300;

prompt = 'PARTICIePANT (in raw number form, e.g. 1, 2,...,60): ';
sub_num = input(prompt);
prompt = 'SESSION (1 , 2, 3, or 4): ';
session = input(prompt);
biopac=0;
prompt = 'CURRENT (in raw number form, e.g. 0.5, 1, 1.5, 2 mA): ';
sub_current = input(prompt);
debug = 0;

% Duration from the start of program before cobbect to tDCS
Duration_before_connectDCS=GetSecs-time_start_program;
time_before_connect_tDCS=GetSecs;
[ret, status, socket] = MatNICConnect('localhost');

% Duration for connect to NIC, software of tDCS
Duration_connect_tDCS=GetSecs-time_before_connect_tDCS;
time_after_connect_tDCS=GetSecs;

% To select which of 4 types of stimulation will be for each participant
load(strcat(fileparts(fileparts(fileparts(pwd))),'\All orders\participant_orders.mat'));
protocol=rem(experiment_order(sub_num),4);

if protocol==1
    if session==1
        protocol_selction="Anodal_Positive_Social_Modelling";
    elseif session==2
        protocol_selction="Anodal_Negative_Social_Modelling";
    elseif session==3
        protocol_selction="Cathodal_Positive_Social_Modelling";
    else
        protocol_selction="Cathodal_Negative_Social_Modelling";
    end
elseif protocol==2
    if session==1
        protocol_selction="Cathodal_Positive_Social_Modelling";
    elseif session==2
        protocol_selction="Cathodal_Negative_Social_Modelling";
    elseif session==3
        protocol_selction="Anodal_Positive_Social_Modelling";
    else
        protocol_selction="Anodal_Negative_Social_Modelling";
    end
elseif protocol==3
    if session==1
        protocol_selction="Anodal_Negative_Social_Modelling";
    elseif session==2
        protocol_selction="Anodal_Positive_Social_Modelling";
    elseif session==3
        protocol_selction="Cathodeal_Negative_Social_Modelling";
    else
        protocol_selction="Cathodal_Positive_Social_Modelling";
    end
else
    if session==1
        protocol_selction="Cathodal_Negative_Social_Modelling";
    elseif session==2
        protocol_selction="Cathodal_Positive_Social_Modelling";
    elseif session==3
        protocol_selction="Anodal_Negative_Social_Modelling";
    else
        protocol_selction="Anodal_Positive_Social_Modelling";
    end
end

% define duration of jitter at start
first_jitter_mean = 6; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitter_min = 5; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitter_max = 7; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitter_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitters = 0;
jitter_duration = exp_sample(first_jitter_mean,first_jitter_min,first_jitter_max,first_jitter_interval);

%% A. Psychtoolbox parameters _________________________________________________
% ip_address = '192.168.0.114'; %ROOM 406 Medoc
ip_address = '10.64.1.10'; % DBIC MRI MEDOC

global p
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
if debug
    ListenChar(0);
    PsychDebugWindowConfiguration;
end
screens                        = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber             = max(screens); % Draw to the external screen if avaliable
p.ptb.white                    = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                    = BlackIndex(p.ptb.screenNumber);
[p.ptb.window, p.ptb.rect]     = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize', p.ptb.window);
p.ptb.ifi                      = Screen('GetFlipInterval', p.ptb.window);
Screen('BlendFunction', p.ptb.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextSize', p.ptb.window, 36);
[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
p.fix.sizePix                  = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];

%% B. Biopac parameters ________________________________________________________
% biopac channel
channel = struct;
channel.biopac = biopac;
channel.trigger    = 0;
channel.fixation   = 1;
channel.cue        = 2;
channel.expect     = 3;
channel.administer = 4;
channel.actual     = 5;
%% C. Directories ______________________________________________________________
task_dir                       = pwd;
main_dir_subfolder=             fileparts((task_dir));
main_dir                       = fileparts(fileparts(task_dir));
repo_dir                       = (fileparts(fileparts(task_dir)));
taskname                       = 'tDCS';

%% D. Circular rating scale _____________________________________________________
image_filepath                 = fullfile(main_dir_subfolder, 'cue');
image_scale_filename           = ['rating.png'];
image_scale                    = fullfile(image_filepath,image_scale_filename);

%% E. Keyboard information _____________________________________________________
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

%% F. fmri Parameters if any __________________________________________________________
TR                             = 0.46;
task_duration                  = 13.00;
ip = ip_address;
port = 20121;
%% F. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir_subfolder, 'cue');
instruct_start_name            = ['task-', taskname, '_start.png'];
instruct_get_ready             = ['task-', taskname, '_get_ready.png'];
instruct_end_name              = ['task-', taskname, '_end.png'];
instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_ready               = fullfile(instruct_filepath, instruct_get_ready);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);
HideCursor;

%% G. Make Images Into Textures ________________________________________________
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
Screen('Flip',p.ptb.window);
cue_image = fullfile(main_dir_subfolder,'cue','rating.png');
cue_tex   = Screen('MakeTexture', p.ptb.window, imread(cue_image));
% instruction, actual texture ______________________________________________
actual_tex      = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
start_tex       = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
trigger_tex     = Screen('MakeTexture',p.ptb.window, imread(instruct_ready));
end_tex         = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
% To select the fractal images for each session
load(strcat(fileparts(fileparts(fileparts(pwd))),'\All orders\Fractal_images_order.mat'));
fractal_image            = ['fractal-', taskname, '_', num2str(Fractal_images_order(sub_num,session)), '.jpg']
image_tDCS                 = imresize(imread(fullfile(instruct_filepath, fractal_image)),[p.ptb.screenYpixels*0.75 p.ptb.screenXpixels*0.75]);
tDCS_image = Screen('MakeTexture',p.ptb.window, (image_tDCS));
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', 1),'center','center',p.ptb.white);
Screen('Flip',p.ptb.window);

%% -----------------------------------------------------------------------------
%                              Start Experiment
% ------------------------------------------------------------------------------

%% ______________________________ Instructions _________________________________
HideCursor;
Screen('TextSize',p.ptb.window,72);
Screen('DrawTexture',p.ptb.window,start_tex,[],[]);
Screen('Flip',p.ptb.window);

%% _______________________ Wait for Trigger to Begin ___________________________
% 1) wait for 's' key, once pressed, automatically flips to fixation
% 2) wait for trigger '5'
DisableKeysForKbCheck([]);

% Duration after connect to tDCS up to before pishing "s" bu operator to % start
Duration_aftertDCS_before_starttrigger=GetSecs-time_after_connect_tDCS;
time_before_starttrigger=GetSecs;
WaitKeyPress(p.keys.start);

%Duration of start trigger as "s" key
Duration_starttrigger=GetSecs-time_before_starttrigger;
time_before_MR_trigger=GetSecs;
fixation_cross(p);
WaitKeyPress(p.keys.trigger);

%Duration of MR trigger as "s" key
Duration_MR_trigger=GetSecs-time_before_MR_trigger;
time_after_MRtrigger = GetSecs;

Screen('Flip',p.ptb.window);

%% ___________________________ 0. Experimental loop ____________________________

time_before_get_ready=GetSecs;

%% ____________________  event 01 - cue 1 s __________________________________
Screen('DrawTexture', p.ptb.window, trigger_tex, [], [], 0);
T_event01_cue_onset            = Screen('Flip',p.ptb.window);
end_event01 = WaitSecs(2);

%Duration of Cue
Duration_cue=GetSecs-time_before_get_ready;
Screen('Flip',p.ptb.window);
Screen('DrawTexture', p.ptb.window, tDCS_image, [], [], 0);
Screen('Flip',p.ptb.window);

%% ____________________ tDCS __________________
%ramp up = 30 sec, ramp down = 30 sec,  stimulation duration = 20 min (1200 sec)
time_start_tDCS=GetSecs;
Protocol_No_Stimulation = MatNICLoadProtocol(protocol_selction, socket);  %load protocol
Duration_Protocolloading=GetSecs-time_start_tDCS;
ret = MatNICStartProtocol (socket);
Duration_loadandtriggertDCS=GetSecs- time_start_tDCS;
time_start_aftertriggertDCS=GetSecs;
tDCS_stimulation_duration_waiting = WaitSecs('UntilTime', time_start_aftertriggertDCS + tDCS_stimulation_duration_experiment);
Duration_total_tDCS=GetSecs-time_start_aftertriggertDCS;  % it should be 1300 sec
Duration_experiment_afterMRItrigger_endoftdcsstimulation=GetSecs-time_after_MRtrigger;
time_press_end_button=GetSecs;
Screen('TextSize',p.ptb.window,72);
Screen('DrawTexture',p.ptb.window,end_tex,[],[]);
Screen('Flip',p.ptb.window);
WaitKeyPress(p.keys.end);
Duration_end_buttom=GetSecs-time_press_end_button;
save_Directory=strcat(fileparts(pwd),'\Results\');
cd(save_Directory)
ar=[[strcat('sub-', sprintf('%02d', sub_num)), ...
    strcat('_ses-',sprintf('%02d', session)),strcat('_tDCS_current-', sprintf('%01d', sub_current),'mA')]];
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

arr=[[strcat('sub-', sprintf('%02d', sub_num)), ...
    strcat('_ses-',sprintf('%02d', session)),strcat('_tDCS_current-', sprintf('%01d', sub_current),'mA')]];

vnames = {'protocol','tDCS_stimulation_duration', 'sub_num','session','sub_current','biopac', ...
    'Duration_before_connectDCS','Duration_connect_tDCS','Duration_aftertDCS_before_starttrigger', ...
    'Duration_starttrigger','Duration_MR_trigger','Duration_cue','Duration_Protocolloading',...
    'Duration_loadandtriggertDCS','tDCS_stimulation_duration_waiting','Duration_total_tDCS',...
    'Duration_experiment_afterMRItrigger_endoftdcsstimulation','Duration_end_buttom'};

vtypes = { 'string','double','double','double','double','double','double','double','double','double','double','double','double',...
    'double','double','double','double','double'};
T = table('Size', [1, 18], 'VariableNames', vnames, 'VariableTypes', vtypes);
T.protocol=protocol_selction;
T.tDCS_stimulation_duration=tDCS_stimulation_duration_experiment;
T.sub_num=sub_num;
T.session=session;
T.sub_current=sub_current;
T.biopac=biopac;
T.Duration_before_connectDCS=Duration_before_connectDCS;
T.Duration_connect_tDCS=Duration_connect_tDCS;
T.Duration_aftertDCS_before_starttrigger=Duration_aftertDCS_before_starttrigger;
T.Duration_starttrigger=Duration_starttrigger;
T.Duration_MR_trigger=Duration_MR_trigger;
T.Duration_cue=Duration_cue;
T.Duration_Protocolloading=Duration_Protocolloading;
T.Duration_loadandtriggertDCS=Duration_loadandtriggertDCS;
T.tDCS_stimulation_duration_waiting=tDCS_stimulation_duration_waiting;
T.Duration_total_tDCS=Duration_total_tDCS;
T.Duration_experiment_afterMRItrigger_endoftdcsstimulation=Duration_experiment_afterMRItrigger_endoftdcsstimulation;
T.Duration_end_buttom=Duration_end_buttom;
save(arr)
as1=strcat(arr,'.csv');
writetable(T,as1);
Screen('Close'); close all; sca;

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

