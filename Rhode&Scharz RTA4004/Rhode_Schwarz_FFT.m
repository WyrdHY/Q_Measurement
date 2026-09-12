ch = 2;
[t,y] = Rhode_Read_Waveform(ch);

%% Original Signal
figure;
plot(t,y)

% FFT
N = length(y);
fs = 1/mean(diff(t));
Y = fft(y)/N;

% Double-sided FFT
f2 = (-floor(N/2):ceil(N/2)-1) * fs/N;
figure;
plot(f2, abs(fftshift(Y)))

% Single-sided FFT
Y1 = Y(1:floor(N/2)+1);
Y1(2:end-1) = 2*Y1(2:end-1);
f1 = (0:floor(N/2)) * fs/N;
figure;
plot(f1, abs(Y1))