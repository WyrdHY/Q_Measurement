%[x,y] = Read_DOSX_2024A(1);
 [x2, y2, x3, y3] = Read_Rigol_23();
figure;
plot(x2,y2,'o-');hold on
%plot(x3,y3,'o-');

function [t, V] = Read_Rigol(channel)

addr = "USB0::0x1AB1::0x0515::MS5A255207375::0::INSTR";

scope = visadev(addr);
scope.Timeout = 20;

% Check connection
idn = writeread(scope, "*IDN?");
disp(idn)

% Stop acquisition before RAW waveform read
writeline(scope, ":STOP");

% Waveform setup
writeline(scope, sprintf(":WAV:SOUR CHAN%d", channel));
writeline(scope, ":WAV:MODE RAW");
writeline(scope, ":WAV:FORM BYTE");

% Read preamble
p = str2double(split(strtrim(writeread(scope, ":WAV:PRE?")), ","));

format     = p(1);
type       = p(2);
points     = p(3);
count      = p(4);

xIncrement = p(5);
xOrigin    = p(6);
xReference = p(7);

yIncrement = p(8);
yOrigin    = p(9);
yReference = p(10);

fprintf('Waveform points: %d\n', points);

% Read waveform in chunks

chunkSize = 200000;      % points per transfer
raw = zeros(points, 1, 'uint8');

idx = 1;

while idx <= points

    idx_end = min(idx + chunkSize - 1, points);

    writeline(scope, sprintf(":WAV:STAR %d", idx));
    writeline(scope, sprintf(":WAV:STOP %d", idx_end));

    writeline(scope, ":WAV:DATA?");

    temp = readbinblock(scope, "uint8");

    % Sometimes there may be a remaining terminator
    flush(scope, "input");

    nRead = length(temp);

    raw(idx:idx+nRead-1) = temp(:);

    fprintf('Read %d / %d points\n', idx+nRead-1, points);

    idx = idx + nRead;

end

% Convert waveform code to voltage

V = (double(raw) - yOrigin - yReference) .* yIncrement;
% Generate time axis

N = length(raw);

t = ((0:N-1) - xReference) .* xIncrement + xOrigin;

t = t(:);
V = V(:);

% Resume acquisition

writeline(scope, ":RUN");

end

function [x2, y2, x3, y3] = Read_Rigol_23()

addr = "USB0::0x1AB1::0x0515::MS5A255207375::0::INSTR";

scope = visadev(addr);
scope.Timeout = 20;

% Check connection
idn = writeread(scope, "*IDN?");
disp(idn)

% Stop acquisition
writeline(scope, ":STOP");

% Get actual acquisition memory depth
points = str2double(writeread(scope, ":ACQ:MDEP?"));

fprintf('Acquisition memory depth: %d points\n', points);

% Read CH2
[x2, y2] = read_channel(scope, 2, points);

% Read CH3
[x3, y3] = read_channel(scope, 3, points);

% Resume acquisition
writeline(scope, ":RUN");

end


function [t, V] = read_channel(scope, channel, points)

% Waveform setup
writeline(scope, sprintf(":WAV:SOUR CHAN%d", channel));
writeline(scope, ":WAV:MODE RAW");
writeline(scope, ":WAV:FORM BYTE");

% Explicitly reset waveform range
writeline(scope, ":WAV:STAR 1");
writeline(scope, sprintf(":WAV:STOP %d", points));

% Read preamble
p = str2double(split(strtrim(writeread(scope, ":WAV:PRE?")), ","));

xIncrement = p(5);
xOrigin    = p(6);
xReference = p(7);

yIncrement = p(8);
yOrigin    = p(9);
yReference = p(10);

fprintf('CH%d: reading %d points\n', channel, points);

% Read waveform in chunks
chunkSize = 200000;

raw = zeros(points, 1, 'uint8');

idx = 1;

while idx <= points

    idx_end = min(idx + chunkSize - 1, points);

    writeline(scope, sprintf(":WAV:STAR %d", idx));
    writeline(scope, sprintf(":WAV:STOP %d", idx_end));

    writeline(scope, ":WAV:DATA?");

    temp = readbinblock(scope, "uint8");

    flush(scope, "input");

    nRead = length(temp);

    raw(idx:idx+nRead-1) = temp(:);

    fprintf('CH%d: Read %d / %d points\n', ...
        channel, idx+nRead-1, points);

    idx = idx + nRead;

end

%% Convert ADC code -> voltage
V = (double(raw) - yOrigin - yReference) .* yIncrement;
%% Time axis
N = length(raw);

t = ((0:N-1) - xReference) .* xIncrement + xOrigin;

t = t(:);
V = V(:);

end