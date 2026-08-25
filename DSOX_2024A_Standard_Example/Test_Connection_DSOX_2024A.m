[x,y] = Read_DOSX_2024A(1);
figure;
plot(x,y);

function [t, V] = Read_DOSX_2024A(channel)
addr = "USB0::0x0957::0x1796::SG51290210::0::INSTR";
scope = visadev(addr);
scope.Timeout = 5;
idn = writeread(scope,"*IDN?");
disp(idn)
writeline(scope,sprintf(":WAV:SOUR CHAN%d",channel));
writeline(scope,":WAV:FORM WORD");
writeline(scope,":WAV:UNS 0");
writeline(scope,":WAV:BYT LSBF");
writeline(scope,":WAV:POIN:MODE NORM");
writeline(scope,":WAV:POIN MAX");
% Preamble
p = str2double(split(strtrim(writeread(scope,":WAV:PRE?")),","));
xIncrement = p(5);
xOrigin    = p(6);
xReference = p(7);
yIncrement = p(8);
yOrigin    = p(9);
yReference = p(10);
% Waveform
writeline(scope,":WAV:DATA?");
raw = readbinblock(scope,"int16");
flush(scope,"input");
V = (double(raw)-yReference).*yIncrement + yOrigin;
N = length(raw);
t = ((0:N-1)-xReference).*xIncrement + xOrigin;
t = t(:);
V = V(:);
end