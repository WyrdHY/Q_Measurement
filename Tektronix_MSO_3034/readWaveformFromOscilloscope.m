function [Y, X, YUnit, XUnit] = readWaveformFromOscilloscope(resourceString, channel)
    % Define the driver path
    driverMDD = 'C:\Experiment\Tek_Oscilloscope_Driver\tektronix_tds3034B\tektronix_tds3034B.mdd';

    % Connect to the oscilloscope using VISA
    oscivisaObj = visa('agilent', resourceString);
    oscideviceObj = icdevice(driverMDD, oscivisaObj);
    oscigroupObj = get(oscideviceObj, 'Waveform');

    % Open the connection
    connect(oscideviceObj);

    % Read waveform data
    channelStr = ['channel', num2str(channel)];
    [Y, X, YUnit, XUnit] = Tektronix3014_readwaveform(oscigroupObj, channelStr);

    % Disconnect and clean up
    disconnect(oscideviceObj);
    delete(oscideviceObj);
    delete(oscivisaObj);
end
