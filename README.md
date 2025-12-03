1. Overview 
The DSP Block is a specialized digital signal processing module designed to handle real-time 
streaming data with a Moving Average Filter. It processes data from an 8-bit Analog-to-Digital 
Converter (ADC) and a Transmit (Tx) FIFO, applying a 4-tap Moving Average Filter before 
sending the processed data to an 8-bit Digital-to-Analog Converter (DAC) or storing it in a 
Receive (Rx) FIFO for CPU retrieval. The block integrates an AHB-Lite Slave interface for CPU 
control and data transfer, supporting efficient data flow between high-speed (up to 400 MHz) 
AHB and low-speed (up to 40 MHz) ADC/DAC clock domains. 
Operational Flow 
1. CPU-to-DAC Path (Tx FIFO Streaming): 
o The CPU writes raw data into the Tx FIFO via the AHB-Lite interface. 
o The DSP applies a 4-tap Moving Average Filter to the data. 
o Filtered data is streamed to the DAC at 40 MHz for continuous output. 
2. ADC-to-CPU Path (Rx FIFO Streaming): 
o The ADC samples data at 40 MHz and feeds it to the DSP. 
o The DSP applies a 4-tap Moving Average Filter. 
o Filtered data is stored in the Rx FIFO, with an interrupt (IRQ) triggered to notify 
the CPU when data is available. 
The DSP block ensures low-latency processing, efficient buffering, and seamless clock domain 
crossing (CDC) to support real-time signal processing in AMBA-based systems. 
2. Features 
• AHB-Lite Slave Interface: Enables CPU configuration, FIFO access, and status 
monitoring. 
• 8-bit ADC Input Interface: Supports real-time signal acquisition at up to 40 MHz. 
• 8-bit DAC Output Interface: Provides continuous filtered signal output at up to 40 
MHz. 
• Dual FIFOs: 
o Tx FIFO: Buffers CPU data for DAC output. 
o Rx FIFO: Stores filtered ADC data for CPU retrieval. 
• 4-Tap Moving Average Filter: Smooths data for both Tx and Rx paths
• Interrupt Mechanism: Notifies the CPU when Rx FIFO contains data, reducing polling 
overhead. 
• Clock Domain Crossing (CDC) Logic: Handles synchronization between 400 MHz 
AHB and 40 MHz ADC/DAC clocks. 
• Configurable Control: Supports start/stop, mode selection, and FIFO status monitoring. 
