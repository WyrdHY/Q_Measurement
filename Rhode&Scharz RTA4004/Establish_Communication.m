%Configure the setup
ipAddress = '169.254.218.202';  
port = 5025;  
scope = tcpclient(ipAddress, port);
scope.Timeout = 5;  
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
    fprintf(scope, '*IDN?'); 
    fprintf(scope, 'CHAN:TYPE HRES');
    fprintf(scope, 'TIM:SCAL 200E-3');
    fprintf(scope, 'FORM REAL');
    fprintf(scope, 'FORM:BORD LSBF');
    fprintf(scope, 'CHAN:DATA:POIN DMAX');
    %fprintf(scope, 'SING;*OPC?');
    opcResponse = fscanf(scope);
    disp(['Acquisition complete: ', opcResponse]);
    fprintf(scope, 'CHAN:DATA:HEAD?');
    header = fscanf(scope);
    % Parse header to determine record length (number of samples)
    headerValues = sscanf(header, '%f,%f,%f,%f');
    recordLength = headerValues(3);
    disp(['Header: ', header]);

    maxReadSize = min(recordLength * 4, scope.InputBufferSize);  % 4 bytes per 'float32'


    fprintf(scope, 'CHAN:DATA?');
    waveformData = fread(scope, maxReadSize/4, 'float32');  % Read the data as 4-byte floating point numbers
end

if try_2nd
    % Read header information for the displayed data
    fprintf(scope, 'CHAN1:DATA:HEAD?');
    header = fscanf(scope);
    disp(['Header: ', header]);

    % Parse header to determine record length (number of samples)
    headerValues = sscanf(header, '%f,%f,%f,%f');
    recordLength = headerValues(3);
    set(scope, 'InputBufferSize', recordLength * 4);

    % Read the waveform data corresponding to the displayed data
    fprintf(scope, 'CHAN1:DATA?');
    waveformData = fread(scope,recordLength , 'float32');  % Read the data as 4-byte floating point numbers
end



%%
% Process and plot the waveform data
waveformData = waveformData(:); % Ensure waveformData is a column vector
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
