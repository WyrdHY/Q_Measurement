addpath('.')
instrreset;
osc = Infiniium('USB0::0x2A8D::0x904E::MY54200105::INSTR');
    %app.osc.Resource = 'USB0::0x2A8D::0x0396::CN61297440::0::INSTR';%UCSB
osc.connect;
CH =1;
[~,trans] = osc.readtrace(CH, 500000);
