classdef channel
    %Channel Make a channel that a signal can be sent through
    
    properties
        type = 'AWGN'
        H_chan      %Object will contain the comm toolbox channel
    end
    
    methods
        function obj = channel
            %if (gpuDeviceCount)
            
            obj.H_chan = comm.AWGNChannel(...    %Setup AWGN channel
                'NoiseMethod','Signal to noise ratio (SNR)',...
                'SNR',10,...   %Default SNR
                'SignalPower',1);
            
            %should pass the type and then set it up properly
            %right now, just assume it'll be AWGN.
        end
        function output = transmit_over_channel(obj, snr, input,parameters)
            obj.H_chan.SNR = snr;  %update snr
            output = step(obj.H_chan, input);
        end
        
        %RX.z   = RX.data.channel - TX.data.filteredPad;   %Calculate the noise signal
        %RX.snr = snr(TX.data.filteredPad, RX.z);          %Sanity check on snr
    end
end

