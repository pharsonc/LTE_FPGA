classdef transmitter
    %TX Class creates a transmitter object
    %  Methods include setup and broadcast.
    
    properties
        RRC = struct(...       %Root Raised Cosine Filter
            'sampsPerSymb', 8,... %Upsampling factor
            'beta', 0.2,...       %Rolloff factor
            'Nsym', 2)            %Filter span in symbol dutrations
        M                      %Modulation Order
        H_pskMod               %Modulator Object
        H_RRC                  %RRC filtering object
    end
    
    methods
        function obj = transmitter(M)
            if nargin == 0
                disp ' nargin 0'
                obj.M = 2         %use default of  BPSK
            end
            obj.M = M;
            %if (gpuDeviceCount)
            
            obj.H_pskMod = comm.PSKModulator('ModulationOrder',obj.M,'PhaseOffset',pi);
            
            obj.H_RRC = comm.RaisedCosineTransmitFilter(...
                'Shape',                  'Normal', ...
                'RolloffFactor',          obj.RRC.beta, ...
                'FilterSpanInSymbols',    obj.RRC.Nsym, ...
                'OutputSamplesPerSymbol', obj.RRC.sampsPerSymb);
            
            % Normalize to obtain maximum filter tap value of 1
            obj.RRC.b      = coeffs(obj.H_RRC);
            obj.H_RRC.Gain = 1/max(obj.RRC.b.Numerator);
        end
        function out = broadcast(obj,bitInput,parameters)  %Code, Moudlate, and Pulseshape
            codedBits = bitInput;  %Apply an Error Correction Code TO DO
            modulated = step(obj.H_pskMod,codedBits); %Modulate Bits
            pad = [modulated; zeros(2*obj.RRC.Nsym,1)]; %Padd with zeros at the end
            out = step(obj.H_RRC,pad); %Filter padded vector
            RRCwindowed = out(obj.RRC.Nsym/2*obj.RRC.sampsPerSymb+1:...
                obj.RRC.Nsym/2*obj.RRC.sampsPerSymb+1 + length(parameters.timeVectorUp)-1);
            if parameters.plots
                figure(2)
                plot(parameters.timeVectorUp,real(RRCwindowed));
                xlabel('time (s)'); ylabel('Amplitude');
                grid on; hold on;
                stem(parameters.timeVectorDown,real(modulated),'k');
                legend('Pulseshaped Signal','Modulated data');
            end
        end
    end
end
