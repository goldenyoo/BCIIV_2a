% ----------------------------------------------------------------------- %
%    File_name: 2a.m
%    Programmer: Seungjae Yoo                             
%                                           
%    Last Modified: 2020_01_13                            
%                                                            
 % ----------------------------------------------------------------------- %
 %% Call raw data
close all
clear all

[s, h] = sload('C:\Users\유승재\Desktop\BCICIV_2a_gdf\A01E.gdf', 0, 'OVERFLOWDETECTION:OFF');
