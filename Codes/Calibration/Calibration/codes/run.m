%% Version 02-16-2022

clear 
Screen('Close');
clearvars;
sca;
% 1. grab participant number ___________________________________________________
prompt = 'Participant (in raw number form, e.g. 1, 2, ... ,60): ';
sub_num = input(prompt);

prompt = 'Session (1,2, 3, 4, ...): ';
ses_num = input(prompt);

prompt = 'BIOPAC (YES=1, NO=0) : ';
biopac = input(prompt);
debug = 0;

pain(sub_num,ses_num,biopac,debug)
