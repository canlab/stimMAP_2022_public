% * *%% Before running:* *
% 1- Please check the ip_address
% 2- Please check the main() to trigger Medoc not be comment (two locations)
% 3- Change the directory to this program
% 4- Use pain(sub,session,run_number,1,0,T1,T2)
% 5- T1 and T2 are Medoc code number and not temperatures,
%    we obtained them in the calibration process
% 6- Check the last line in stimulation part not to be comment (main()
% 7- Please check the num_trials, it must be 12 for real expperiment
% 8- Screen('Preference', 'SkipSyncTests', 0);
% 9- you can choose one of Rating procedure by you or Heejung (circular)


%% based on run_numm, toggle biopac channel 7,8 in binary form
% run 1 = 0, 0 for channel 7, 8
% run 2 = 0, 1
% run 3 = 1, 0
% run 4 = 1, 1

function pain(sub, session,session_runnum, biopac, debug,Medoc_T_low,Medoc_T_high,experiment_order)

run_num=session;
num_trials=12;
num_blocks=1;

All_experiment=[Medoc_T_low Medoc_T_low Medoc_T_low Medoc_T_low Medoc_T_low Medoc_T_low Medoc_T_high Medoc_T_high Medoc_T_high Medoc_T_high Medoc_T_high Medoc_T_high];
xx =[Medoc_T_low,Medoc_T_high]';
a_rand =[];
for i=1:6
    a_rand = [a_rand; Shuffle(xx)];
end

Temp_Medoc = a_rand;
temperature_ranges_all=[45:0.1:50];
Num_determined_in_Medoc_software=147:197;
Temperature_ranges_Medoc_sontware=[temperature_ranges_all' Num_determined_in_Medoc_software'];

for pm=1:length(a_rand)
    sr=a_rand(pm);
    tq=find(Num_determined_in_Medoc_software==sr);
    real_temperature_stimulation_rand_out(pm)=temperature_ranges_all(tq);
end

protocol=rem(experiment_order(sub),4);

if protocol==1
    if session==1
        protocol_selction="Anodal_Positive Social Modelling";
    elseif session==2
        protocol_selction="Anodal_Negative Social Modelling";
    elseif session==3
        protocol_selction="Cathodal_Positive Social Modelling";
    else
        protocol_selction="Cathodal_Negative Social Modelling";
    end
elseif protocol==2
    if session==1
        protocol_selction="Cathodal_Positive Social Modelling";
    elseif session==2
        protocol_selction="Cathodal_Negative Social Modelling";
    elseif session==3
        protocol_selction="Anodal_Positive Social Modelling";
    else
        protocol_selction="Anodal_Negative Social Modelling";
    end
elseif protocol==3
    if session==1
        protocol_selction="Anodal Negative Social Modelling";
    elseif session==2
        protocol_selction="Anodal Positive Social Modelling";
    elseif session==3
        protocol_selction="Cathodeal Negative Social Modelling";
    else
        protocol_selction="Cathodal Positive Social Modelling";
    end
else
    if session==1
        protocol_selction="Cathodal_Negative Social Modelling";
    elseif session==2
        protocol_selction="Cathodal_Positive Social Modelling";
    elseif session==3
        protocol_selction="Anodal_Negative Social Modelling";
    else
        protocol_selction="Anodal_Positive Social Modelling";
    end
end


% define duration of pre cue fixation or ISI
first_jitter_mean = 5; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitter_min = 4; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitter_max = 6; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitter_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitters = zeros(num_trials,num_blocks);
for ind = 1:num_trials
    first_jitters(ind) = exp_sample(first_jitter_mean,first_jitter_min,first_jitter_max,first_jitter_interval);
end

% define duration of pre stimulus fixation
pre_stim_duration_mean = 6; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_min = 5; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_max = 7; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_duration_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
pre_stim_durations = zeros(num_trials,num_blocks);
for ind = 1:num_trials
    pre_stim_durations(ind) = exp_sample(pre_stim_duration_mean,pre_stim_duration_min,pre_stim_duration_max,pre_stim_duration_interval);
end


for ind = 1:num_trials
    
    post_stim_fixation_durations(ind)=19 - first_jitters(ind) - pre_stim_durations(ind);
end

Duration_get_ready=2;
Heat_stimulation=13;
Rating_duration=6;
Duration_run=40;

%% -----------------------------------------------------------------------------
%                           Parameters
% ------------------------------------------------------------------------------

%% A. Psychtoolbox parameters _________________________________________________
% ip_address = '192.168.0.114'; %ROOM 406 Medoc
% ip_address = '192.168.0.122'; % testing room B
ip_address = '192.168.0.114';  % testing room C
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
channel.run12     = 6;
channel.run34     = 7;

if channel.biopac == 1
    script_dir = pwd;
    %     cd('F:\LabJackPython-master');
    cd('C:\Users\Dartmouth\Documents\LabJackPython');
    pe = pyenv;
    try
        py.importlib.import_module('u3');
    catch
        warning("u3 already imported!");
    end
    % Check to see if u3 was imported correctly
    % py.help('u3')
    channel.d = py.u3.U3();
    % set every channel to 0
    channel.d.configIO(pyargs('FIOAnalog', int64(0), 'EIOAnalog', int64(0)));
    for FIONUM = 0:7
        channel.d.setFIOState(pyargs('fioNum', int64(FIONUM), 'state', int64(0)));
    end
    cd(script_dir);
end

%% C. Directories ______________________________________________________________
task_dir                       = pwd;
main_dir_subfolder=             fileparts((task_dir));
main_dir                       = fileparts(fileparts(task_dir));
repo_dir                       = (fileparts(fileparts(task_dir)));
taskname                       = 'pain';
bids_string                     = [strcat('sube-', sprintf('%04d', sub)), ...
    strcat('_ses-',sprintf('%02d', session)),...
    strcat('_task-social'),...
    strcat('_run-', sprintf('%02d', run_num),'-', taskname)];
sub_save_dir = fullfile(main_dir, 'data', strcat('sub-', sprintf('%04d', sub)),...
    strcat('ses-',sprintf('%02d', session)),...
    'beh'  );
repo_save_dir = fullfile(repo_dir, 'data', strcat('sub-', sprintf('%04d', sub)),...
    'task-social', strcat('ses-',sprintf('%02d', session)));
if ~exist(sub_save_dir, 'dir');    mkdir(sub_save_dir);     end
if ~exist(repo_save_dir, 'dir');    mkdir(repo_save_dir);   end

%% D. Circular rating scale _____________________________________________________
image_filepath                 = fullfile(main_dir_subfolder, 'cue');
image_scale_filename           = ['rating.png'];
image_scale                    = fullfile(image_filepath,image_scale_filename);

%% E. making output table ________________________________________________________
vnames = {'src_subject_id', 'session_id', 'tDCS_Protocol', 'param_task_name','temp_Medoc', 'stimulation_temp', ...
    'param_trigger_onset','param_start_biopac','Task_duration', 'Ramp_up_down', ... % param
    'anchor_start_time',... %start time for each trial
    'ITI_onset','ITI_biopac','Difference_between_ITI_onset_biopac','end_jitter_start_pre_cue','ITI_duration','first_jitters_jitter_pre_cue'... %end of first jitter
    'event_cue_onset','event_cue_biopac','end_event_cue','duration_cue','duration_cue_predetermined',... % cue
    'ISI01_onset','ISI01_biopac','ISI01_difference_between_onset_biopac','end_jitter_before_stimulation','ISI_jitter_before_stimulation_duration','pre_stimulation_durations',... % ISI 01
    'delay_between_medoc', 'event03_stimulus_displayonset', 'event03_stimulus_biopac','end_stimulation','duration_stimulation', 'event03_stimulus_P_trigger', ...
    'ISI03_onset','ISI03_biopac','end_jitter_after_stimulation', 'ISI_jitter_after_stimulation_duration','post_stim_fixation_durations' ...
    'event_rating_actual_displayonset','event_rating_actual_RT', 'event_rating_actual_responseonset','event_rating_actual_biopac', 'event_rating_actual_angle', ...
    'param_end_instruct_onset','param_end_biopac','param_experiment_duration',
    };

vtypes = { 'double','double','string','string','double','double',...
    'double','double','double','double', ... % param
    'double',...  %start time for each trial
    'double','double','double','double','double','double' ... % end of first jitter
    'double','double','double','double','double', ... % cue
    'double','double','double','double','double','double',... % ISI 01
    'double','double','double','double','double', 'string', ... % Stimulation
    'double','double','double','double','double', ... % Jitter after stimulation
    'double','double','double','double','double', ... % Rating
    'double','double','double'};

T = table('Size', [num_trials, size(vnames,2)], 'VariableNames', vnames, 'VariableTypes', vtypes);

T.src_subject_id(:)            = sub;
T.session_id(:)                = session;
T.tDCS_Protocol(:)=protocol_selction;
T.param_task_name(:)           = taskname;
T.temp_Medoc(:)                = a_rand';
T.stimulation_temp             =real_temperature_stimulation_rand_out';

%% F. Keyboard information _____________________________________________________
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

%% G. fmri Parameters if needed __________________________________________________________
TR                             = 1.3;
T.Task_duration(1:num_trials)                = 10.00;
T.Ramp_up_down(1:num_trials)                 =1.5;
plateau = 10;
ip = ip_address;
port = 20121;

%% H. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir_subfolder, 'cue');
instruct_start_name            = ['task-', taskname, '_start.png'];
instruct_trigger_name          = ['task-', taskname, '_trigger.png'];
instruct_end_name              = ['task-', taskname, '_end.png'];
instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_trigger               = fullfile(instruct_filepath, instruct_trigger_name);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);
HideCursor;

%% I. Make Images Into Textures ________________________________________________
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
Screen('Flip',p.ptb.window);

for trl = 1:num_trials
    cue_image = fullfile(main_dir_subfolder,'cue','rating.png');
    cue_tex = Screen('MakeTexture', p.ptb.window, imread(cue_image));
    actual_tex      = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
    start_tex       = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
    trigger_tex     = Screen('MakeTexture',p.ptb.window, imread(instruct_trigger));
    end_tex         = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
    DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*trl/100)),'center','center',p.ptb.white);
    Screen('Flip',p.ptb.window);
end
%
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
WaitKeyPress(p.keys.start);
fixation_cross(p);
WaitKeyPress(p.keys.trigger);
T.param_trigger_onset(:)                  = GetSecs;
T.param_start_biopac(:)                   = biopac_linux_matlab(channel, channel.trigger, 1);

switch(session_runnum)
    case 1
        biopac_linux_matlab(channel, channel.run12, 0);
        biopac_linux_matlab(channel, channel.run34, 0);
    case 2
        biopac_linux_matlab(channel, channel.run12, 0);
        biopac_linux_matlab(channel, channel.run34, 1);
    case 3
        biopac_linux_matlab(channel, channel.run12, 1);
        biopac_linux_matlab(channel, channel.run34, 0);
    case 4
        biopac_linux_matlab(channel, channel.run12, 1);
        biopac_linux_matlab(channel, channel.run34, 1);
    otherwise
        fprintf('Invalid run\n' );
end

%% ___________________________ Dummy scans ____________________________
Screen('Flip',p.ptb.window);
WaitSecs(TR*6);

%% ___________________________ 0. Experimental loop ____________________________
for trl = 1:num_trials
    %disp(trl)
    T.anchor_start_time(trl) = GetSecs;
    
    %% ____________________ 1. jitter 01 - 4-6 sec _________________________________
    T.ITI_onset(trl)         = trial_fixation(p);
    T.ITI_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
    T.Difference_between_ITI_onset_biopac(trl)=T.ITI_biopac(trl)-T.ITI_onset(trl); %to see difference between biopac and trial_fixation
    
    WaitSecs('UntilTime',T.anchor_start_time(trl) + first_jitters(trl));
    T.end_jitter_start_pre_cue(trl)                          = biopac_linux_matlab(channel, channel.fixation, 0);
    T.ITI_duration(trl)      = T.end_jitter_start_pre_cue(trl) -  T.ITI_onset(trl);
    T.first_jitters_jitter_pre_cue(trl)=first_jitters(trl);
    
    %% ____________________ 2. cue 2 s __________________________________
    biopac_linux_matlab(channel, channel.cue, 0);
    Screen('DrawTexture', p.ptb.window, trigger_tex, [], [], 0);
    T.event_cue_onset(trl)            = Screen('Flip',p.ptb.window);
    T.event_cue_biopac(trl)             = biopac_linux_matlab(channel, channel.cue, 1);
    
    % START THERMODE PROGRAM
    main(ip, port, 1, Temp_Modoc(trl));
    end_event_cue (trl) = WaitSecs('UntilTime',  T.anchor_start_time(trl) + first_jitters(trl) + Duration_get_ready);
    T.end_event_cue(trl)=biopac_linux_matlab(channel, channel.cue, 0);
    T.duration_cue_predetermined(trl) = Duration_get_ready;
    T.duration_cue(trl)=T.end_event_cue(trl)- T.event_cue_biopac(trl) ;
    
    %% ____________________ 3. jitter 02 - Fixtion Jitter - 5-7 sec __________________
    T.ISI01_onset(trl)         = fixation_cross(p);
    T.ISI01_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
    T.ISI01_difference_between_onset_biopac(trl) = T.ISI01_biopac(trl)-T.ISI01_onset(trl);
    end_jitter_after_cue(trl) = WaitSecs('UntilTime', T.anchor_start_time(trl) + Duration_get_ready + first_jitters(trl) + pre_stim_durations(trl));
    T.end_jitter_before_stimulation(trl) = biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI_jitter_before_stimulation_duration(trl)      = T.end_jitter_before_stimulation(trl) - T.ISI01_onset(trl);
    T.pre_stimulation_durations(trl)=pre_stim_durations(trl);
    
    %% TRIGGER THERMODE PROGRAM
    response = main(ip, port, 4, Temp_Modoc(trl)); %start trigger
    T.delay_between_medoc(trl) = GetSecs - end_jitter_after_cue(trl) ;
    T.event03_stimulus_displayonset(trl) = GetSecs;
    T.event03_stimulus_biopac(trl)      = biopac_linux_matlab( channel, channel.administer, 1);
    end_event03_stimulus(trl) = WaitSecs('UntilTime', T.anchor_start_time(trl) + Duration_get_ready + first_jitters(trl) + pre_stim_durations(trl) + Heat_stimulation);
    T.end_stimulation(trl) = biopac_linux_matlab( channel, channel.administer, 0);
    T.duration_stimulation(trl) =  T.end_stimulation(trl) - end_jitter_after_cue(trl);
    T.event03_stimulus_P_trigger(trl) = strcat(response{3}, '_AND_', response{6});
    
    %% ___________________ 7. jitter 04 Fixtion Jitter 6-10 sec _________________________
    T.ISI03_onset(trl)        = fixation_cross(p);
    T.ISI03_biopac(trl)       = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter04(trl) = WaitSecs('UntilTime',  T.anchor_start_time(trl) + 34); % the duration of experiment is 40 sec, we have only 6 sec for rating after this jitter, therefore from the start to end of this step must be 40-6=34 sec
    T.end_jitter_after_stimulation(trl) = biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI_jitter_after_stimulation_duration(trl)     = T.end_jitter_after_stimulation(trl) - T.ISI03_onset(trl);
    T.post_stim_fixation_durations(trl)=post_stim_fixation_durations(trl);
    
    %% ___________________ 8. event 04 post evaluation rating 6 s __________________________
    [trajectory{trl}, display_onset, RT, response_onset, biopac_display_onset, angle] = circular_rating_output1(Rating_duration, p, actual_tex, ' ', channel, channel.actual)
    biopac_linux_matlab(channel, channel.actual, 0);
    T.event_rating_actual_displayonset(trl)    = display_onset;
    T.event_rating_actual_RT(trl)              = RT;
    T.event_rating_actual_responseonset(trl)   = response_onset;
    T.event_rating_actual_biopac(trl)          = biopac_display_onset;
    T.event_rating_actual_angle(trl)           = angle;
    
    %% ________________________ 7. temporarily save file _______________________
    arr=[[strcat('sub-', sprintf('%02d', sub)), ...
        strcat('_ses-',sprintf('%02d', session)), ...
        strcat('_run-',sprintf('%02d', session_runnum))]];
    save(arr)
    as1=strcat(arr,'.csv');
    writetable(T,as1);
    
end

%% -----------------------------------------------------------------------------
%                              End of Experiment
% ------------------------------------------------------------------------------

%% _________________________ A. End Instructions _______________________________

Screen('DrawTexture',p.ptb.window,end_tex,[],[]);
T.param_end_instruct_onset(:) = Screen('Flip',p.ptb.window);
T.param_end_biopac(:)                     = biopac_linux_matlab(channel, channel.trigger, 0);
T.param_experiment_duration(:)        = T.param_end_instruct_onset(1) - T.param_trigger_onset(1);
WaitKeyPress(p.keys.end);

%% _________________________ B. Save files _____________________________________

save_Directory=strcat(fileparts(pwd),'\Results\');
if ~exist(save_Directory, 'dir');    mkdir(save_Directory);     end
cd(save_Directory)
ar=[[strcat('sub-', sprintf('%02d', sub)), ...
    strcat('_ses-',sprintf('%02d', session))]];
ar_check_directory=[[strcat('sub-', sprintf('%02d', sub))]];
Results_save_Directory_check_directory_exist_or_not=strcat(save_Directory,ar_check_directory);
Results_save_Directory=strcat(save_Directory,ar);
% Make directory for each participant
if ~exist(Results_save_Directory_check_directory_exist_or_not, 'dir');    mkdir(Results_save_Directory_check_directory_exist_or_not);     end
cd(Results_save_Directory_check_directory_exist_or_not)

% Make directory for each sesssion of each participant
ar_check_directory_session=[[strcat('sub-', sprintf('%02d', sub)), ...
    strcat('_ses-',sprintf('%02d', session))]];
Results_save_Directory_check_directory_session_exist_or_not=strcat(ar_check_directory_session);
if ~exist(Results_save_Directory_check_directory_session_exist_or_not, 'dir');    mkdir(Results_save_Directory_check_directory_session_exist_or_not);     end
cd(Results_save_Directory_check_directory_session_exist_or_not)

arr=[[strcat('sub-', sprintf('%02d', sub)), ...
    strcat('_ses-',sprintf('%02d', session)), ...
    strcat('_run-',sprintf('%02d', session_runnum))]];
save(arr)
as1=strcat(arr,'.csv');
writetable(T,as1);

%% _________________________ C. Clear parameters _______________________________

if channel.biopac;  channel.d.close();  end
clear p; clearvars; Screen('Close'); close all; sca;

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

    function WaitKeyPress(kID)
        while KbCheck(-3); end  % Wait until all keys are released.
        
        while 1
            % Check the state of the keyboard.
            [ keyIsDown, ~, keyCode ] = KbCheck(-3);
            % If the user is pressing a key, then display its code number and name.
            if keyIsDown
                
                if keyCode(p.keys.esc)
                    cleanup; break;
                elseif keyCode(kID)
                    break;
                end
                % make sure key is released
                while KbCheck(-3); end
            end
        end
    end

end
