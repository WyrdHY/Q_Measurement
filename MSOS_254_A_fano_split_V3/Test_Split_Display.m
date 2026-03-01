trans = load('C:\Users\Eric\OneDrive - California Institute of Technology\Q_Measurement-main\MSOS_254_A_fano_split_V3\Typical Split Mode\data_splitmzi\osc_trans.mat');
mzi = load('C:\Users\Eric\OneDrive - California Institute of Technology\Q_Measurement-main\MSOS_254_A_fano_split_V3\Typical Split Mode\data_splitmzi\osc_mzi_5.98MHz.mat');


trans = trans.w;
mzi = mzi.e;

trans= trans(1:length(trans)/1);
mzi= mzi(1:length(mzi)/1);

% Demo
example_obj = Cao_3(trans,mzi,5.98,1550,0.95,'splitmzi');

%%
clc;
figure;
ax = axes;
example_obj.plot_trace_stat(ax); 