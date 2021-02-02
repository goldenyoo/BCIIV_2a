clear all

[s, h] = sload('C:\Users\유승재\Desktop\BCICIV_2a_gdf\A01E.gdf', 0,'OVERFLOWDETECTION',1);

sparse(isnan(s))