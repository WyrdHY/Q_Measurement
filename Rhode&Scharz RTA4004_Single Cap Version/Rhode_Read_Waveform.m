function [x, y] = Rhode_Read_Waveform(channel)

ipAddress = '169.254.218.202';
port = 5025;

scope = tcpclient(ipAddress, port, "Timeout", 10);

% Configure waveform format
write(scope, "FORM:BORD LSBF" + newline);
write(scope, "FORM:DATA REAL,32" + newline);

% Query header
write(scope, sprintf("CHAN%d:DATA:HEAD?" + newline, channel));
headerStr = readline(scope);
headerValues = sscanf(headerStr, "%f,%f,%f,%f");

xStart  = headerValues(1);
xStop   = headerValues(2);
nPoints = headerValues(3);

% Query waveform
write(scope, sprintf("CHAN%d:DATA?" + newline, channel));

%--- Read the binary IEEE block ---
% Read the first 2 bytes: '#', and a digit telling how many bytes describe the length
prefix = read(scope, 2, "uint8");

if prefix(1) ~= '#'
    error("Invalid IEEE block format");
end

numDigits = str2double(char(prefix(2)));

% Read length string
lenStr = read(scope, numDigits, "string");
numBytes = str2double(lenStr);

% Now read the binary waveform data
raw = read(scope, numBytes, "uint8");

% Convert bytes → single precision floats
y = typecast(uint8(raw), 'single')';

x = linspace(xStart, xStop, nPoints);

end
