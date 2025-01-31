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
    fprintf(scope, 'FORM FLOAT,32'); % Set data format to 32-bit float
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

%{
function [x, y] = Rhode_Read_Waveform(channel)
    % Configure the setup
    ipAddress = '169.254.218.202';  
    port = 5025;  
    scope = tcpclient(ipAddress, port);
    scope.Timeout = 5;  
    scope.ByteOrder = 'little-endian';

    % --- Set the data format and acquisition settings ---
    fprintf(scope, 'FORM FLOAT,32');       % Explicitly set to 32-bit floating point
    fprintf(scope, 'FORM:BORD LSBF');      % Set byte order to Little-Endian
    fprintf(scope, 'CHAN:TYPE HRES');      % Set high-resolution mode (16-bit data)
    fprintf(scope, 'TIM:SCAL 1E-7');       % Set time base
    fprintf(scope, 'ACQ:POIN MAX');        % Use maximum available memory depth
    fprintf(scope, 'CHAN:DATA:POIN MAX');  % Set sample range to full memory
    fprintf(scope, 'SING;*OPC?');          % Start single acquisition and wait

    pause(1); % Ensure acquisition completes

    % --- Get actual record length ---
    fprintf(scope, 'CHAN:DATA:POIN?');
    recordLength = str2double(fscanf(scope));
    disp(['Record Length: ', num2str(recordLength)]);

    % --- Get the header for the selected channel ---
    content = sprintf('CHAN%d:DATA:HEAD?', channel);
    fprintf(scope, content);
    header = fscanf(scope);
    disp(['Header: ', header]);

    % Parse header values (Xstart, Xstop)
    headerValues = sscanf(header, '%f,%f,%f,%f');

    % --- Read waveform data ---
    content = sprintf('CHAN%d:DATA?', channel);
    fprintf(scope, content);

    % Read the data as 32-bit floating point numbers
    y = fread(scope, recordLength, 'float32');

    % Generate the time axis
    x = linspace(headerValues(1), headerValues(2), recordLength);

    % Close connection
    delete(scope);
    clear scope;
end

}%
