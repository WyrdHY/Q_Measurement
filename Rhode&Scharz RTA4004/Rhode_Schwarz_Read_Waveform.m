hey = str2num('3');
[x,y] = Rhode_Read_Waveform(hey);
figure;
plot(x,y)
 


%%
function [x,y] = Rhode_Read_Waveform(channel)
    %Configure the setup
    ipAddress = '169.254.218.202';  
    port = 5025;  
    scope = tcpclient(ipAddress, port);
    scope.Timeout = 5;  
    scope.ByteOrder = 'little-endian';
    %Open commuication 
    fopen(scope);

    %Get the header for the selected channel 
    %This is used to determine the buffersize
    fprintf(scope, 'FORM REAL');         % Set data format to REAL (floating point)
    fprintf(scope, 'FORM:BORD LSBF');    % Set byte order to Little-Endian
    content = sprintf('CHAN%d:DATA:HEAD?',channel);
    disp(content);
    fprintf(scope, content);
    header = fscanf(scope);
    disp(['Header: ', header]);

    % Parse header to determine record length (number of samples)
    headerValues = sscanf(header, '%f,%f,%f,%f');
    recordLength = headerValues(3);
    set(scope, 'InputBufferSize', recordLength * 4);

    % Read the waveform data corresponding to the displayed data
    content = sprintf('CHAN%d:DATA?',channel);
    fprintf(scope, content);

    y = fread(scope,recordLength , 'float32');  % Read the data as 4-byte floating point numbers
    x = linspace(headerValues(1), headerValues(2), headerValues(3));

    delete(scope);
    clear scope
end 
