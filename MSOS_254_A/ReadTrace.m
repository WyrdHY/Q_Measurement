function ReadTrace(filename,myosc,point,trans_ch,mzi_ch,overwrite)
if nargin < 6
    overwrite = 0;
end
if exist([filename,'.mat'],'file')
    warning('File already exists!')
    if ~overwrite
        movefile([filename,'.mat'],[filename,'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.mat']);
        warning('Old file was renamed!')
    end
end
myosc.Stop;
[time,trans] = myosc.readtrace(trans_ch, point);
[~,mzi] = myosc.readtrace(mzi_ch, point);

data_length = min([numel(trans),numel(mzi),numel(time)]);
trans = trans(1:data_length);
mzi = mzi(1:data_length);
time = time(1:data_length);
data_matrix = [time,trans,mzi];
save([filename,'.mat'],'data_matrix','-mat');

waveform_figure=figure;
k = 2;
for j=[trans_ch,mzi_ch]
    chanstr=['Channel ',num2str(j)];
    plot(data_matrix(:,1),data_matrix(:,k),'DisplayName',chanstr);
    k = k + 1;
    legend('-DynamicLegend');
    hold on
end
xlabel('Time (s)');
ylabel('Volts (V)');
title('Oscilloscope Data');
% grid on;
% if data_length < 1e6
%     saveas(waveform_figure,[filename,'.fig']);
% end
% saveas(waveform_figure,[filename,'.png']);
end