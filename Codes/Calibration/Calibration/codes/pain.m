% * *%% Before running:* *
% 1- Please check the ip_address
% 2- Please check the main() to trigger Medoc not be comment
% 3- Change the directory
% 4- Use pain(sub,session,0,0)
% 6- Please check the num_trials, it must be 24 for real expperiment

function pain(sub, session, biopac, debug)

num_trials=24;

% run 1
run1_temperature=[47 47 47 47 47 47];
protocol_selction='Calibration';

%run 2
% We have three temperatures and we want to apply them on 6 skin locations
% Therefore each temperature will be used on two skin locations
% First we Suffle these teperatures, I mean [45 45 47 47 49 49];
run2_temperature=Shuffle([45 45 47 47 48.9 48.9]);

%  run3 will be low=1 or high =2, and therefore shuffle again
run3_temperature=Shuffle([1 1 1 2 2 2]);

% run 4  will be viceversa of run 3
run4_temperature=3-run3_temperature;

All_runs=[run1_temperature run2_temperature run3_temperature run4_temperature];
All_conditions=All_runs';
Stimulation_temp=All_runs(1:12);

%% Calibration process 
%  order of trials:  Get ready -Jitter1-Heat-Jitter2-Rate-ISI
% Get ready = 2s;    5 < Jitter1 < 7  -
% Heat: 10 sec plateu , 1.5 sec for ramp up and 1.5 sec for rampt down
% Rate = 6 sec;       ISI= the rest of timing to have 40 sec for each run
Duration_get_ready=2;

% define duration of first jitter
first_jitter_mean = 6; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitter_min = 5; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitter_max = 7; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitter_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
first_jitters = zeros(num_trials,1);
for ind = 1:num_trials
    first_jitters(ind) = exp_sample(first_jitter_mean,first_jitter_min,first_jitter_max,first_jitter_interval);
end

% define duration of second jitter
second_jitter_mean = 7; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
second_jitter_min = 6; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
second_jitter_max = 8; % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
second_jitter_interval = 0.5;  % in secs; will be randomly chosen from an exp distribution based on mean, min, max and intervals values
second_jitters = zeros(num_trials,1);
for ind = 1:num_trials
    second_jitter(ind) = exp_sample(second_jitter_mean,second_jitter_min,second_jitter_max,second_jitter_interval);
end

Heat_stimulation=13;
Rating_duration=6;
Duration_run=40;

%% A. Psychtoolbox parameters ________________________________________________________

% ip_address = '192.168.0.114'; %ROOM 406 Medoc
%     ip_address = '192.168.0.122'; % testing room B
ip_address = '192.168.0.114'; % testing room B
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
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
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
taskname                       = 'pain';
%% D. Circular rating scale _____________________________________________________
image_filepath                 = fullfile(main_dir_subfolder, 'cue');
image_scale_filename           = ['rating.png'];
image_scale                    = fullfile(image_filepath,image_scale_filename);
T.src_subject_id(:)            = sub;
T.tDCS_Protocol(:)=protocol_selction;
T.param_task_name(:)           = taskname;

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

%% F. fmri Parameters __________________________________________________________
TR                             = 0.525;
T.Task_duration(1:num_trials)                = 13.00;
T.Ramp_up_down(1:num_trials)                 =1.5;
plateau = 10;
ip = ip_address;
port = 20121;

%% G. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir_subfolder, 'cue');
instruct_start_name            = ['task-', taskname, '_start.png'];
instruct_trigger_name          = ['task-', taskname, '_trigger.png'];
instruct_end_name              = ['task-', taskname, '_end.png'];
instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_trigger               = fullfile(instruct_filepath, instruct_trigger_name);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);
HideCursor;

%% H. Make Images Into Textures ________________________________________________
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
Screen('Flip',p.ptb.window);
cue_image = fullfile(main_dir_subfolder,'cue','rating.png');
cue_tex = Screen('MakeTexture', p.ptb.window, imread(cue_image));

% instruction, actual texture ______________________________________________
actual_tex      = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
start_tex       = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
trigger_tex     = Screen('MakeTexture',p.ptb.window, imread(instruct_trigger));
end_tex         = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
pain_image=fullfile(main_dir_subfolder,'cue','painful.png');
cue_painful=Screen('MakeTexture', p.ptb.window, imread(pain_image));
tol_image=fullfile(main_dir_subfolder,'cue','tolerance.png');
cue_tolerance=Screen('MakeTexture', p.ptb.window, imread(tol_image));
answer_image=fullfile(main_dir_subfolder,'cue','Response.png');
cue_answer=Screen('MakeTexture', p.ptb.window, imread(answer_image));
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
Screen('Flip',p.ptb.window);

%% -----------------------------------------------------------------------------
%                              Start Experiment

%% ______________________________ Instructions _________________________________
HideCursor;
Screen('TextSize',p.ptb.window,72);
Screen('DrawTexture',p.ptb.window,start_tex,[],[]);
Screen('Flip',p.ptb.window);

for trl = 1:num_trials
    
    if trl>12
        
        %The first run (trials 1-6) were as familarization
        % Therefore we selected trials 7 up to previous trial
        pain_previous=participant_response_pain_binary(7:trl-1);
        
        % Find which trials were NaN (not responded by participant to pain question as "Was it painful")
        NAN_participant_response_pain=isnan(pain_previous);
        
        % Selected only responded pain question by particpant
        RT_participant_response_pain=find(NAN_participant_response_pain==0);
        rate_pain=pain_previous(RT_participant_response_pain);
        
        % Select temperatures for responded questions
        Temp_not_Nan_pain=All_runs(7:trl-1);
        Stimulation_temp_logisticregression_pain=Temp_not_Nan_pain(RT_participant_response_pain);
        
        % Same procedure for tolerance to find responded questions
        tolerance_previous=participant_response_tolerance_binary(7:trl-1);
        NAN_participant_response_tolerance=isnan(tolerance_previous);
        RT_participant_response_tolerance=find(NAN_participant_response_tolerance==0);
        rate_tolerance=tolerance_previous(RT_participant_response_tolerance);
        
        Temp_not_Nan_tolerance=All_runs(7:trl-1);
        Stimulation_temp_logisticregression_tolerance=Temp_not_Nan_tolerance(RT_participant_response_tolerance);
        
        % Temperature range for logistic regression
        temp_range=[45:0.1:49.9];
        
        mdl_pain = fitglm(Stimulation_temp_logisticregression_pain, rate_pain, "Distribution", "binomial");
        predicted_rate_mdl_temp_range_pain=predict(mdl_pain, temp_range');
        
        % The output of prediction will be in the range of 0-1, we want 90%
        % response, therefore we find the index which is near to 0.9
        min_predicted_temp_error_pain=min(abs(predicted_rate_mdl_temp_range_pain-0.9));
        idx_pain= find(abs(predicted_rate_mdl_temp_range_pain-0.9)==min_predicted_temp_error_pain);
        low_threshold_temp=temp_range(min(idx_pain));
        
        if low_threshold_temp>48.9
            low_threshold_temp=48.9;
        end
        
        mdl_tolerance = fitglm(Stimulation_temp_logisticregression_tolerance, rate_tolerance, "Distribution", "binomial");
        predicted_rate_mdl_temp_range_tolerance=predict(mdl_tolerance, temp_range');
        
        min_predicted_temp_error_tolerance=min(abs(predicted_rate_mdl_temp_range_tolerance-0.9));
        idx_tolerance= find(abs(predicted_rate_mdl_temp_range_tolerance-0.9)==min_predicted_temp_error_tolerance);
        high_threshold_temp=temp_range(max(idx_tolerance));
        
        if high_threshold_temp>48.9
            high_threshold_temp=48.9;
        end
        
        if All_runs(trl)==1
            
            Stimulation_temp(trl) = low_threshold_temp;
            
        else
            
            Stimulation_temp(trl) = high_threshold_temp;
        end
        
        Low_threshold_pain(trl,1)=low_threshold_temp;
        High_threshold_tolerance(trl,1)=high_threshold_temp;
        
    end
    
    All_runs(trl)=Stimulation_temp(trl);
    
    %to find code in Medoc
    % temperature_range_Medoc tempraturerange
    temperature_range_Medoc=45:0.1:50;
    
    %Pre-determined coded for each temperature in Medoc
    Num_determined_in_Medoc=147:197;
    
    diff_Stimulation_temp_and_temperature_range_Medoc=temperature_range_Medoc-Stimulation_temp(trl);
    min_diff_Stimulation_temp_and_temperature_range_Medoc=min(abs(diff_Stimulation_temp_and_temperature_range_Medoc));
    
    idx_Medoc=find(abs(diff_Stimulation_temp_and_temperature_range_Medoc)==min_diff_Stimulation_temp_and_temperature_range_Medoc);
    
    Temp_Modoc(trl) = Num_determined_in_Medoc(max(idx_Medoc));
    
    %% _______________________ Wait for Trigger to Begin ___________________________
    % 1) wait for 's' key, once pressed, automatically flips to fixation
    % 2) wait for trigger '5'
    DisableKeysForKbCheck([]);
    T.param_trigger_onset(:)                  = GetSecs;
    T.param_start_biopac(:)                   = biopac_linux_matlab(channel, channel.trigger, 1);
    Screen('Flip',p.ptb.window);
    HideCursor;
    Screen('TextSize',p.ptb.window,72);
    Screen('DrawTexture',p.ptb.window,start_tex,[],[]);
    Screen('Flip',p.ptb.window);
    
    % 1) wait for 's' key, once pressed, automatically flips to fixation
    % 2) wait for trigger '5'
    %     DisableKeysForKbCheck([]);
    WaitKeyPress(p.keys.start);
    fixation_cross(p);
    T.param_trigger_onset(:)                  = GetSecs;
    T.param_start_biopac(:)                   = biopac_linux_matlab(channel, channel.trigger, 1);
    disp(trl)
    T.anchor_start_time(trl) = GetSecs;
    
    %% ____________________ 1. event 1 - cue 2 s __________________________________
    biopac_linux_matlab(channel, channel.cue, 0);
    Screen('DrawTexture', p.ptb.window, trigger_tex, [], [], 0);
    T.event_cue_onset(trl)            = Screen('Flip',p.ptb.window);
    T.event_cue_biopac(trl)             = biopac_linux_matlab(channel, channel.cue, 1);
    
    %% START THERMODE PROGRAM
    main(ip, port, 1, Temp_Modoc(trl));
    end_event_cue = WaitSecs('UntilTime',  T.anchor_start_time(trl)  + Duration_get_ready);
    T.end_event_cue(trl)=biopac_linux_matlab(channel, channel.cue, 0);
    T.duration_cue_predetermined(trl) = 2;
    T.duration_cue(trl)=T.end_event_cue(trl)- T.event_cue_biopac(trl) ;
    
    %% ____________________ 2. event 2 - jitter 01 - Fixtion Jitter  __________________
    T.jitter1_onset(trl)         = fixation_cross(p);
    T.jitter1_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter1(trl) = WaitSecs('UntilTime', T.anchor_start_time(trl) + Duration_get_ready + first_jitters(trl));
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI_jitter1(trl)      = end_jitter1(trl) - T.jitter1_onset(trl);
    
    %% %% ___________________ 3. event 3  - TRIGGER THERMODE PROGRAM 0
    T.event_stimulus_displayonset(trl) = GetSecs;
    response = main(ip, port, 4, Temp_Modoc(trl)); %start trigger
    T.delay_between_medoc(trl) = GetSecs - end_jitter1(trl) ;
    T.event_stimulus_biopac(trl)      = biopac_linux_matlab( channel, channel.administer, 1);
    end_event_stimulus(trl) = WaitSecs('UntilTime', T.event_stimulus_displayonset(trl) + Heat_stimulation);
    T.end_stimulation(trl) = biopac_linux_matlab( channel, channel.administer, 0);
    T.duration_stimulation(trl) =  T.end_stimulation(trl) - T.event_stimulus_displayonset(trl);
    
    %% ___________________ 4. event 4 - jitter 02 Fixtion Jitter 3-5 sec _________________________
    T.jitter2_onset(trl)        = fixation_cross(p);
    T.jitter2_biopac(trl)       = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter02(trl)  = WaitSecs('UntilTime', T.jitter2_onset(trl) +  second_jitter(trl));
    T.end_jitter2_(trl) = biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI_jitter2_after_stimulation_duration(trl)     = end_jitter02(trl) - T.jitter2_onset(trl);
    
    %% ___________________ 5. event 5 -  event 04 post evaluation rating 6 s __________________________
    [trajectory_thermode{trl}, display_onset, RT, response_onset, biopac_display_onset, angle] = circular_rating_output1(Rating_duration, p, actual_tex, ' ', channel, channel.actual)
    biopac_linux_matlab(channel, channel.actual, 0);
    rating(trl)               = angle;
    T.event_rating_actual_displayonset(trl)    = display_onset;
    T.event_rating_actual_RT(trl)              = RT;
    T.event_rating_actual_responseonset(trl)   = response_onset;
    T.event_rating_actual_biopac(trl)          = biopac_display_onset;
    T.event_rating_actual_angle(trl)           = angle;
    
    %% ___________________ 6. event 06    ISI __________________________
    
    T.ISI_end_run_onset(trl)         = fixation_cross(p);
    T.jitter1_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
    end_ISI_end_trial(trl) = WaitSecs('UntilTime', T.anchor_start_time(trl) + Duration_run);
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI_end(trl)      = end_ISI_end_trial(trl) - T.ISI_end_run_onset(trl);
    
    %%
    Screen('DrawTexture', p.ptb.window, cue_painful, [], [], 0);
    Screen('Flip',p.ptb.window);
    WaitSecs(2);
    Screen('Flip',p.ptb.window);
    [trajectory_pain{trl}, display_onset, RT, response_onset, biopac_display_onset, angle] = circular_rating_output(4, p, cue_answer,' ', channel, channel.actual);
    response_painful(trl)=angle;
    %To check if participant push the mouse for response
    AR=isnan(angle);
    
    if (angle<90 & AR<0.5)
        participant_response_pain{trl}='Yes';
        participant_response_pain_binary(trl)=1;
    elseif (angle>90 & AR<0.5)
        participant_response_pain{trl}='No';
        participant_response_pain_binary(trl)=0;
        
    else
        participant_response_pain{trl}='No Response';
        participant_response_pain_binary(trl)=NaN;
        
    end
    
    Screen('Flip',p.ptb.window);
    Screen('DrawTexture', p.ptb.window, cue_tolerance, [], [], 0);
    Screen('Flip',p.ptb.window);
    WaitSecs(2);
    [trajectory_tolerance{trl}, display_onset, RT, response_onset, biopac_display_onset, angle] = circular_rating_output(4, p, cue_answer,' ', channel, channel.actual);
    response_tolerance(trl)=angle;
    
    %To check if participant push the mouse for response
    AR=isnan(angle);
    if (angle<90 & AR<0.5)
        participant_response_tolerance{trl}='Yes';
        participant_response_tolerance_binary(trl)=1;
        
    elseif (angle>90 & AR<0.5)
        participant_response_tolerance{trl}='No';
        participant_response_tolerance_binary(trl)=0;
        
    else
        participant_response_tolerance{trl}='No Response';
        participant_response_tolerance_binary(trl)=NaN;
        
    end
    
end
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

%% ___________________ Save results __________________________

save_Directory=strcat(fileparts(pwd),'\Results\');

if ~exist(save_Directory, 'dir');    mkdir(save_Directory);     end
cd(save_Directory)
ar=[[strcat('sub-', sprintf('%02d', sub)), '_Calibration']];
ar_check_directory=[[strcat('sub-', sprintf('%02d', sub))]];
Results_save_Directory_check_directory_exist_or_not=strcat(save_Directory,ar_check_directory);
if ~exist(Results_save_Directory_check_directory_exist_or_not, 'dir');    mkdir(Results_save_Directory_check_directory_exist_or_not);     end
cd(Results_save_Directory_check_directory_exist_or_not)
Randomized_Temperature=All_runs(1:trl)';
Stimulation_temp=Stimulation_temp(1:trl)';
Participant_gLMS_rating=rating';
for iii=1:trl
    if participant_response_pain{iii}=="Yes"
        Pain(iii)="Yes";
    elseif participant_response_pain{iii}=="No"
        Pain(iii)="No";
    else
        Pain(iii)="No Response";
    end
    
    if participant_response_tolerance{iii}=="Yes"
        
        Tolerance(iii)="Yes";
    elseif participant_response_tolerance{iii}=="No"
        Tolerance(iii)="No";
    else
        Tolerance(iii)="No Response";
    end
    
end

Pain=Pain';
Tolerance=Tolerance';

vnames={'All_conditions','Stimulation_temp','Participant_gLMS_rating','Pain','Tolerance','Low_threshold_pain','High_threshold_tolerance'};
vtypes = { 'double','double','double','string','string','double','double'};

%Make output as table
Results = table(All_conditions,Stimulation_temp,Participant_gLMS_rating,Pain,Tolerance,Low_threshold_pain,High_threshold_tolerance)

as=strcat(ar,'.csv');
writetable(Results,as);

% We want to use linear regression between circular ratings and Temperatures
% We will not use the first run (6 trials) which were for familarization
%Find runs not rated by participant
Participant_gLMS_rating1=Participant_gLMS_rating(7:end);
Stimulation_temp1=Stimulation_temp(7:end);

% Find Nan items
TF = isnan(Participant_gLMS_rating1);

% Non-Nan items
RT=find(TF==0);

% linear regression
mdl_linear_temperature_rating = fitglm(Stimulation_temp1(RT), Participant_gLMS_rating1(RT));
%
% predicted rates from the model by linear regression
output=predict(mdl_linear_temperature_rating,Stimulation_temp1(RT));

output_all(1:18)=nan;
for mp=1:length(RT)
    
    output_all(RT(mp))=output(mp);
end

% Error
error_reg=output_all'-Participant_gLMS_rating1;
% reshape erroe to 6*3 matric, 6 is number of regions and 3 number of runs
error_region=reshape(error_reg,6,(length(error_reg))/6);

% As some trials may not be rated by participant, we made them NaN and not
% enter to calculate the mean error

for region=1:6
    %dr is error for each region, as we had 18 trials, therefore qw will
    %have t trials for each region
    dr=error_region(region,:);
    %find nan for each trial in each region
    region_nan= isnan(dr);
    % Non-Nan tirals
    region_non_nan=find(region_nan==0);
    
    if length(region_non_nan)>0       % to check if all trials of each region not to be Nan
        mean_eerorr_region(region)=sum(dr(region_non_nan))/length(region_non_nan);
    else
        mean_eerorr_region(region)=nan;
        
    end
end

% Find two regions with minimum mean error
mean_eerorr_region_abs=abs(mean_eerorr_region);
HO=sort(mean_eerorr_region_abs);
Final_Calibration_regingos=[find(mean_eerorr_region_abs==HO(1)) find(mean_eerorr_region_abs==HO(2))];

Regions = Final_Calibration_regingos';

pain_all=participant_response_pain_binary(7:trl);
NAN_participant_response_pain=isnan(pain_all);
RT_participant_response_pain=find(NAN_participant_response_pain==0);

rate_pain=pain_all(RT_participant_response_pain);

Temp_not_Nan_pain=All_runs(7:trl);
Stimulation_temp_logisticregression_pain=Temp_not_Nan_pain(RT_participant_response_pain);

tolerance_all=participant_response_tolerance_binary(7:trl);
NAN_participant_response_tolerance=isnan(tolerance_all);
RT_participant_response_tolerance=find(NAN_participant_response_tolerance==0);

rate_tolerance=tolerance_all(RT_participant_response_tolerance);

Temp_not_Nan_tolerance=All_runs(7:trl);
Stimulation_temp_logisticregression_tolerance=Temp_not_Nan_tolerance(RT_participant_response_tolerance);


temp_range=[45:0.1:49.9];
mdl_pain = fitglm(Stimulation_temp_logisticregression_pain, rate_pain, "Distribution", "binomial");
predicted_rate_mdl_temp_range_pain=predict(mdl_pain, temp_range');

% The output of prediction will be in the range of 0-1, we want 90%
% response, therefore we find the index which is near to 0.9
min_predicted_temp_error_pain=min(abs(predicted_rate_mdl_temp_range_pain-0.9));
idx_pain= find(abs(predicted_rate_mdl_temp_range_pain-0.9)==min_predicted_temp_error_pain);
low_threshold_temp=temp_range(min(idx_pain));

if low_threshold_temp>48.9
    low_threshold_temp=48.9;
end

mdl_tolerance = fitglm(Stimulation_temp_logisticregression_tolerance, rate_tolerance, "Distribution", "binomial");
predicted_rate_mdl_temp_range_tolerance=predict(mdl_tolerance, temp_range');

min_predicted_temp_error_tolerance=min(abs(predicted_rate_mdl_temp_range_tolerance-0.9));
idx_tolerance= find(abs(predicted_rate_mdl_temp_range_tolerance-0.9)==min_predicted_temp_error_tolerance);
high_threshold_temp=temp_range(max(idx_tolerance));

if high_threshold_temp>48.9
    high_threshold_temp=48.9;
end

tmp_pain=abs(temperature_range_Medoc-low_threshold_temp);
min_temp_pain=min(tmp_pain);
idx_Medoc_pain=find(tmp_pain==min_temp_pain);

Temp_Modoc_output_pain= Num_determined_in_Medoc(min(idx_Medoc_pain));

tmp_tol=abs(temperature_range_Medoc-high_threshold_temp);
min_temp_tol=min(tmp_tol);

idx_Medoc_tol=find(tmp_tol==min_temp_tol);
Temp_Modoc_output_tol= Num_determined_in_Medoc(max(idx_Medoc_tol));
Medoc_output=[Temp_Modoc_output_pain;Temp_Modoc_output_tol];

Temperatures=[low_threshold_temp;high_threshold_temp];
vnames={'Regions','Temperatures','Medoc_output'};
vtypes = { 'double','double','double'};


%Make output as table
Calibrtion_output = table(Regions,Temperatures,Medoc_output)
as1=strcat(ar,'_output','.csv');
writetable(Calibrtion_output,as1);
save(ar)
Screen('Close'); close all; sca;


end