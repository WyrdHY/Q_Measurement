function [y, x, yunit, xunit] = Tektronix3014_readwaveform(obj, source)
    % If this is a group function, OBJ is the group object.
    % If it is a base device function, OBJ is the device object.
    if (nargout == 0)
        return;
    end
    scale = true;
    y = [];
    x = [];
    yunit = 'unknown';
    xunit = 'unknown';
    validValues = {'channel1', 'channel2', 'channel3', 'channel4', 'referenceA', 'referenceB', 'referenceC', 'referenceD', 'math'};
    scopeValues = {'ch1', 'ch2', 'ch3', 'ch4', 'refa', 'refb', 'refc', 'refd', 'math'};
    idx = strmatch(lower(source), validValues, 'exact');
    if (isempty(idx))
        error('Invalid SOURCE. CHANNEL must be one of: channel1, channel2, channel3, channel4, referenceA, referenceB, referenceC, referenceD, math');
    end
    trueSource = scopeValues{idx};
    % Get interface
    interface = get(get(obj, 'parent'), 'interface');
    oldPrecision = get(obj, 'Precision');
    oldByteOrder = get(obj, 'ByteOrder');
    set(obj, 'Precision', 'int16');
    set(obj, 'ByteOrder', 'littleEndian');
    fprintf(interface, 'CURVE?');
    try
        % Specify source
        fprintf(interface, ['DATA:SOURCE ' trueSource]);
        % Issue the curve transfer command.
        fprintf(interface, 'CURVE?');
        raw = binblockread(interface, 'int16');
        % Tektronix scopes send an extra terminator after the binblock.
        fread(interface, 1);
    catch
        set(obj, 'Precision', oldPrecision);
        set(obj, 'ByteOrder', oldByteOrder);
        error(lasterr);
    end
    if (isempty(raw))
        set(obj, 'Precision', oldPrecision);
        set(obj, 'ByteOrder', oldByteOrder);
        error('An error occurred while reading the waveform.');
    end
    if (scale == false)
        y = raw;
        if (nargout < 2)
            set(obj, 'Precision', oldPrecision);
            set(obj, 'ByteOrder', oldByteOrder);
            return;
        end
        ptcnt = str2num(query(interface, 'WFMPRE:NR_PT?'));
        x = 1:ptcnt;
        if (nargout > 2)
            xunit = query(interface, 'WFMPRE:XUnit?');
            xunit(xunit == '"') = [];
            yunit = query(interface, 'WFMPRE:YUnit?');
            yunit(yunit == '"') = [];
        end
    else
        yoffs = str2num(query(interface, 'WFMPRE:YOFF?'));
        ymult = str2num(query(interface, 'WFMPRE:YMULT?'));
        yzero = str2num(query(interface, 'WFMPRE:YZERO?'));
        y = ((raw - yoffs) .* ymult) + yzero;
        if (nargout < 2)
            set(obj, 'Precision', oldPrecision);
            set(obj, 'ByteOrder', oldByteOrder);
            return;
        end
        xzero = str2num(query(interface, 'WFMPRE:XZERO?'));
        xincr = str2num(query(interface, 'WFMPRE:XINCR?'));
        ptcnt = str2num(query(interface, 'WFMPRE:NR_PT?'));
        x = (((0:(ptcnt-1)) .* xincr) + xzero);
        if (nargout > 2)
            xunit = query(interface, 'WFMPRE:XUnit?');
            xunit(xunit == '"') = [];
            yunit = query(interface, 'WFMPRE:YUnit?');
            yunit(yunit == '"') = [];
        end
    end
    y = y';
    set(obj, 'Precision', oldPrecision);
    set(obj, 'ByteOrder', oldByteOrder);
end
