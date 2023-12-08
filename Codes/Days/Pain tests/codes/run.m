% *% We ask to enter:*

% #  Participant number (1,2,,3, ... 60)
% #  Session number reated to anadoal cathodal: 1,2,3,4
% #  Run number as we have 4 runs in each session: 1,2,3,4
% #  Biopac using or not: 0 or 1
% #  Medoc code number related to low threshold temperature: 147, ... 190
% #  Medoc code number related to high threshold temperature: 147, ...190
%% 
clear 
Screen('Close');
clearvars;
sca;

% 1.  participant number __________________________________________________

prompt = 'Participant (in raw number form, e.g. 1, 2, ... ,60): ';
sub_num = input(prompt);

% 2.  participant session (For Anadol or Cathodal stimulation______________

prompt = 'Session (1,2, 3, 4): ';
ses_num = input(prompt);

% 3.  run number (4 runs on forearm as we have 4 tests ____________________
% in each session on two location on foream, on each locations 2 runs)_____

prompt = 'run number (1,2,3,4,5,6,7,8): ';
run_num = input(prompt);

% 4.  Biopac: 1 if we want to use biopac and 0 if we don't want ___________

prompt = 'BIOPAC (YES=1, NO=0) : ';
biopac = input(prompt);

% 5.  Debug mode or not ___________________________________________________

debug = 0;

% 6.  participant calibration temperatures ________________________________
%  Medoc_T_low: predetermined value for pain related temperature
%  Medoc_T_high: redetermined value for tolerance related temperature

prompt = 'Medoc low Tempresure (in raw number form, e.g. 147, 148, ... ,190): ';
Medoc_T_low = input(prompt);

prompt = 'Medoc High Tempresure (in raw number form, e.g. 147, 148, ... ,190): ';
Medoc_T_high = input(prompt);

load(strcat((fileparts((fileparts(pwd)))),'\All orders\participant_orders.mat')); 

% 7. Running the main program _____________________________________________
pain(sub_num,ses_num,run_num,biopac,debug,Medoc_T_low,Medoc_T_high,experiment_order)