%Configure the setup R2024A
ipAddress = '131.215.42.231';  %IP address for Tek M5054
port = 4000;%Port Number for Tek M5054  
scope = tcpclient(ipAddress, port);
scope.Timeout = 6;  
scope.ByteOrder = 'little-endian';
%Open commuication 
fopen(scope);

ID = 0;
TRY = 0;
try_2nd = 1;
if ID
    fprintf(scope, '*IDN?');
    idnResponse = fscanf(scope);
    disp(['Instrument ID: ', idnResponse]);
end


if TRY
    john = talk('HORizontal:RECordlength?');
    temp = tek_read(1);
    plot(temp);
end

if try_2nd
    % Select the waveform source (Channel 3 in this case)
    fprintf(scope, 'DATa:SOUrce CH1');
    
    % Specify the waveform encoding format (binary, signed, 16-bit)
    fprintf(scope, 'DATa:ENCdg ASCII');
    
    % Specify the number of bytes per data point (2 bytes)
    fprintf(scope, 'WFMOutpre:BYT_Nr 2');
    
    % Specify the portion of the waveform to transfer (from point 1 to point 1250000)
    fprintf(scope, 'DATa:STARt 1');
    fprintf(scope, 'DATa:STOP 1250000');
    
    % Transfer waveform preamble information (WFMOutpre?)
    fprintf(scope, 'WFMOutpre?');
    preamble = readline(scope);
    disp('Waveform Preamble:');
    disp(preamble);
    
    % Transfer the waveform data from the instrument (CURVe?)
    fprintf(scope, 'CURVe?');
    pause(3)
    % Read whatever data is returned, without interpreting it
    rawData = readline(scope); % Read raw data without specifying data type or length
    waveformData = str2double(split(rawData, ','));
    disp('finished');
end

delete(scope);
clear scope;
%%
fig=1;
if fig
    % voltage = (raw -y_offset)*y_scale + y_zero
    figure;
    plot(waveformData)
end



%%
% Process and plot the waveform data
waveformData = waveformArray; % Ensure waveformData is a column vector
headerValues = sscanf(header, '%f,%f,%f,%f');
Xstart = headerValues(1);
Xstop = headerValues(2);
recordLength = headerValues(3);

% Generate time axis based on header information
time = linspace(Xstart, Xstop, recordLength);

% Plot the waveform
figure;
plot(time', waveformData);
xlabel('time');
ylabel('Amplitude');
title('Waveform Data');

%%
delete(scope);
clear scope;
%%
temp = tek_read(1);
temp2 = tek_read(4);
figure;
subplot(2,1,1);
plot(temp);
subplot(2,1,2)
plot(temp2);

%% Test Q
Cao_2(temp,temp2,10,1064,0.95,'MZI')


%%
function [Response]=talk(content)
    %Configure the setup
    ipAddress = '131.215.42.231';  %IP address for Tek M5054
    port = 4000;%Port Number for Tek M5054  
    scope = tcpclient(ipAddress, port);
    scope.Timeout = 5;  
    scope.ByteOrder = 'little-endian';

    %Open commuication 
    fopen(scope);
    fprintf(scope, content);
    Response = fscanf(scope);
    disp(['Ask: ',content])
    disp(['Response: ', Response]);
end

function [waveform_data] = tek_read(ch)
%Configure Communication Port Through IP
ipAddress = '131.215.42.231';  %IP address for Tek M5054
port = 4000; %Port Number for Tek M5054  
scope = tcpclient(ipAddress, port);
scope.Timeout = 3;  
scope.ByteOrder = 'little-endian';
fopen(scope);

%Setup the Oscilloscope for acquisition 
channel_source = sprintf('DATa:SOUrce CH%d',ch);
%disp(channel_source);
fprintf(scope, channel_source);
fprintf(scope, 'DATa:ENCdg DOUBLE');
fprintf(scope, 'WFMOutpre:BYT_Nr 8');
%Always capture the whole screen
fprintf(scope,'HORizontal:RECordlength?');
range = fscanf(scope);
%disp(range)
fprintf(scope, 'DATa:STARt 1');
fprintf(scope, 'DATa:STOP %s',range);

%Ask the waveform in the oscilloscope 
fprintf(scope, 'CURVe?');
pause(2);
rawData = readline(scope); % As I set to ASCII, they should be string
%un_convert_waveformData = str2double(split(rawData, ','));

% Convert the string to numeric array using textscan for faster processing
temp = textscan(rawData, '%f', 'Delimiter', ',');
un_convert_waveformData=temp{1};
%Do the conversion
% Actual Voltage = (raw_value - y_off)*y_scale + y_zero
fprintf(scope, 'WFMOutpre:YMULT?');
y_scale = str2double(readline(scope));

fprintf(scope, 'WFMOutpre:YOFF?');
y_off = str2double(readline(scope));

fprintf(scope, 'WFMOutpre:YZERO?');
y_zero = str2double(readline(scope));

waveform_data = (un_convert_waveformData-y_off)*y_scale+y_zero;

%Close the scope
delete(scope);
clear scope;
end
