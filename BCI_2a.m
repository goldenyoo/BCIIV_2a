% ----------------------------------------------------------------------- %
%    File_name: BCI_2a.m
%    Programmer: Seungjae Yoo                             
%                                           
%    Last Modified: 2020_01_29                            
%
% [s, h] = sload('C:\Users\유승재\Desktop\BCICIV_2a_gdf\A09E.gdf', 0);
% ----------------------------------------------------------------------- %
 %% input parameter
close all
clear all

% Ask user for input parameters
prompt = {'Data label: ', 'Feature vector length: ', 'Filter order','low cutoff freq', 'high cutoff freq'};
dlgtitle = 'Input';
dims = [1 50];
definput = {'1', '3','40','8','30'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

% Error detection
if isempty(answer), error("Not enough input parameters."); end

%% 
[M_1,M_2,M_3,M_4,Q_1,Q_2,Q_3,Q_4,P] = Calib(answer);
output = Eval(answer,M_1,M_2,M_3,M_4,Q_1,Q_2,Q_3,Q_4,P);

%% 
fprintf('Data_Label: %s\n',string(answer(1,1)));
disp(output)