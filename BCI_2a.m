% ----------------------------------------------------------------------- %
%    File_name: BCI_2a.m
%    Programmer: Seungjae Yoo                             
%                                           
%    Last Modified: 2020_03_30                            
%
% [s, h] = sload('C:\Users\유승재\Desktop\BCICIV_2a_gdf\A09E.gdf', 0);
% ----------------------------------------------------------------------- %
 %% input parameter
clc
close all
clear all

% Ask user for input parameters
prompt = {'Data label: ', 'Feature vector length: ','low cutoff freq', 'high cutoff freq'};
dlgtitle = 'Input';
dims = [1 50];
definput = {'1', '2','8','30'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

ref_method = [0 1]; % Non(0), CAR(1), LAP(2)


ref = 10;

% Error detection
if isempty(answer), error("Not enough input parameters."); end

%% 
for i = 1:length(ref_method)
    answer(5,1) = {ref_method(i)};
    [P,V_train,X_train] = Calib(answer,ref);
    [output] = Eval(answer,P,V_train,X_train,ref);
    [conf_mat, kappa] = Check(answer,output);
    
    %%
    fprintf('\nData_Label: %s\n',string(answer(1,1)));
    fprintf('Re-referencing: %d\n',ref_method(i));
    fprintf("\nKappa value: %f\n\n", kappa);
    disp(conf_mat);
end