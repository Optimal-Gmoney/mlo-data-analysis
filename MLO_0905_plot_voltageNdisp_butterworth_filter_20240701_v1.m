% PURPOSE: This MATLAB script will intake the data files generated by the 
% NI LABView DAQ (1) and the MTS 858 Mini BIONIX II (2) and will plot the
% voltage and displacement with respect to time. The data file for (1) is a
% .csv file while the data file for (2) is a .dat file. The script will
% plot the voltage with respect to the left y-axis and displacement with
% respect to the right y-axis. It is important to have this MATLAB file in
% the same folder where the data is located or else it will not work. The
% path may need to be changed depending on your folder setup. This script
% is setup such that the ouput files will be saved to a user specified
% folder.
% Author: Geronimo Macias 

% MATLAB Script to Plot Data from a CSV File

clc; clear all; close all;

%--------------------------------------------------------------------------
%                           $- USER INPUT-$
%--------------------------------------------------------------------------
%-% Data analysis for NI LabVIEW DAQ RAW data 
% Specify the path to your CSV file (sampling rate is 250 Hz)

csvFile1 = 'T:\NMT-R&D-engineer\Data\20240903_bike-test_TO-DO\CSV-Files\20240903_MLO-Y_trial3_broke_dcv.csv'; %DCV
csvFile2 = 'T:\NMT-R&D-engineer\Data\20240903_bike-test_TO-DO\CSV-Files\20240903_MLO-Y_trial2_dci.csv'; %DCI


% MLO7
% csvFile1 = 'T:\NMT-R&D-engineer\Data\20240328_sensor-validation\NI LabVIEW DAQ\CSV-Files\20240328_MLO-strip7_12ps_trial2_fs_dcv.csv'; % DCV file
% csvFile2 = 'T:\NMT-R&D-engineer\Data\20240328_sensor-validation\NI LabVIEW DAQ\CSV-Files\20240328_MLO-strip7_12ps_trial2_fs_dci.csv'; % DCI file

% MLO6
%csvFile1 = 'T:\NMT-R&D-engineer\Data\20240301_sensor-validation\NI LabVIEW DAQ\CSV-files\20240301_MLO-strip6_12ps_trial2_fs_dcv.csv'; % DCV file
%csvFile2 = 'T:\NMT-R&D-engineer\Data\20240301_sensor-validation\NI LabVIEW DAQ\CSV-files\20240301_MLO-strip6_12ps_trial2_fs_dci.csv'; % DCI file

% MLO5
% csvFile1 = 'T:\NMT-R&D-engineer\Data\20240228_sensor-validation\NI LabVIEW DAQ\CSV-files\20240228_MLO-strip5_10ps_trial2_fs_dcv.csv';
% csvFile2 = 'T:\NMT-R&D-engineer\Data\20240228_sensor-validation\NI LabVIEW DAQ\CSV-files\20240228_MLO-strip5_10ps_trial2_fs_dci.csv';

% MLO4
% csvFile1 = 'T:\NMT-R&D-engineer\Data\20240201_sensor-validation\NI DAQexpress\CSV-files\MLO4_dcv_5ps.csv';
% csvFile2 = 'T:\NMT-R&D-engineer\Data\20240201_sensor-validation\NI DAQexpress\CSV-files\MLO4_dci_5ps.csv';

% MLO3
% csvFile1 = 'T:\NMT-R&D-engineer\Data\20240201_sensor-validation\NI DAQexpress\CSV-files\MLO3_dcv_15ps.csv';
% csvFile2 = 'T:\NMT-R&D-engineer\Data\20240201_sensor-validation\NI DAQexpress\CSV-files\MLO3_dci_15ps.csv';

% MLO2
% csvFile1 = 'T:\NMT-R&D-engineer\Data\20240110_sensor-validation\DAQexpress\CSV-files\MLO2_DCV_test3.csv';

% MLO1
% csvFile1 = 'T:\NMT-R&D-engineer\Data\20240110_sensor-validation\DAQexpress\CSV-files\MLO1_manual-strain-DCV_test2.csv';


%20240404_TO-DO: 
% -change back to _norm for voltage and current on option 3 and option 1!!!
% -change ylabels as well back to normalized voltage and current 

%csvFile1 = 'NI LabVIEW DAQ\CSV-files\20240228_ML-strip_15ps_fs.csv';

% this is where the files that are generated will be saved to (needs to be
% adjusted)
%outputdir = 'NI LabVIEW DAQ\Figures\20240402_MLO7-power-plots';
outputdir = 'T:\NMT-R&D-engineer\Data\20240903_bike-test_TO-DO\Figures';

file_date = 20240905;
strain_perc = 15;
file_save_opt = '.fig'; % chose from .png or .fig

% Gauge Length of Specimen
Gauge_length = 1; % mm
% to determine the strain divide the displacemetn data by the guage length

% Switch will allow for switching between plotting DCV, DCI, or both with
% the displacement (or strain) applied (1: DCV, 2: DCI, 3: BOTH). The 
% naming convention of files is extremely important!
switch_analysis = 3; 

% automatically naming and saving the file 
MLO_name = 'MLO-Y-0826Strip-ML';
%MLO_name = 'initial-disp2';
node_name_A = append(MLO_name,'');
node_name_B = append(MLO_name,'-B');
node_name_C = append(MLO_name,'-C');

% save files into outputdir folder (change to 1 to save)
save_files = 0;


%code below can be used to extract certain loading frequencies 
%Range of values from total array; Define time lower and upper limit
x1 = 1;
x2 = 120;
%Time lower and upper limits multiplied by sample rate 250 samples/s
x1s = 250*x1;
x2s = 250*x2;
% time vector
T = linspace(x1,x2,(x2s-x1s)+1);
%-------

SampFreq = 250; cutoffFreq = 12;
%--------------------------------------------------------------------------

loading_freq = [1 2 3]; % for naming plots 

switch switch_analysis

    case 1 % DCV only
        % Read the data from the file
        data1 = readmatrix(csvFile1);
        
        % Remove rows with NaN as the first element
        cleanedData1 = data1(~isnan(data1(:,1)), :);
        
        % Remove columns with NaN as the first element
        cleanedData1(:, any(isnan(cleanedData1), 1)) = [];
        
        % Extract x and y data (DCV)
        x1Data_dcv = cleanedData1(:,1);
        % Note: MTS displacement in terms of voltage (collected using the BNC cable
        % connected to the back of the controller box on MTS) needs to multiplied
        % by a factor of 10 to convert to displacement in terms of mm. 
        y1Data_mm = cleanedData1(:,2); y1Data_mm = 10*y1Data_mm;

        y1Data_strain = y1Data_mm/Gauge_length - min(y1Data_mm)/Gauge_length;

        y2Data = cleanedData1(:,3);
        y3Data = cleanedData1(:,4);
        y4Data = cleanedData1(:,5);
        
        % getting the averge of the first 5 seconds of data for the nodal voltages
        % (this is when the sample is at rest)
        y2Mean5sec = mean(y2Data(1:1251));
        y3Mean5sec = mean(y3Data(1:1251));
        y4Mean5sec = mean(y4Data(1:1251));
        
        % calculating normalized nodal voltages (unitless)
        y2Data_norm = (y2Data-y2Mean5sec)/y2Mean5sec;
        y3Data_norm = (y3Data-y3Mean5sec)/y3Mean5sec;
        y4Data_norm = (y4Data-y4Mean5sec)/y4Mean5sec;
        


    case 2 % DCI only
        % Read the data from the file
        data2 = readmatrix(csvFile2);
        
        % Remove rows with NaN as the first element
        cleanedData2 = data2(~isnan(data2(:,1)), :);
        
        % Remove columns with NaN as the first element
        cleanedData2(:, any(isnan(cleanedData2), 1)) = [];
        
        % Extract x and z data (DCI)
        x1Data_dci = cleanedData2(:,1);
        % Note: MTS displacement in terms of voltage (collected using the BNC cable
        % connected to the back of the controller box on MTS) needs to multiplied
        % by a factor of 10 to convert to displacement in terms of mm. 
        z1Data_mm = cleanedData2(:,2); z1Data_mm = 10*z1Data_mm;
        
        z1Data_strain = z1Data_mm/Gauge_length - min(z1Data_mm)/Gauge_length;
    
        z2Data = cleanedData2(:,3);
        z3Data = cleanedData2(:,4);
        z4Data = cleanedData2(:,5);
        
        % getting the averge of the first 5 seconds of data for the nodal voltages
        % (this is when the sample is at rest)
        z2Mean5sec = mean(z2Data(1:1251));
        z3Mean5sec = mean(z3Data(1:1251));
        z4Mean5sec = mean(z4Data(1:1251));
        
        % calculating normalized nodal voltages (unitless)
        z2Data_norm = (z2Data-z2Mean5sec)/z2Mean5sec;
        z3Data_norm = (z3Data-z3Mean5sec)/z3Mean5sec;
        z4Data_norm = (z4Data-z4Mean5sec)/z4Mean5sec;

    case 3 % Both DCI and DCV
        % Read the data from the file
        data1 = readmatrix(csvFile1);
        data2 = readmatrix(csvFile2);
        
        % Remove rows with NaN as the first element
        cleanedData1 = data1(~isnan(data1(:,1)), :);
        cleanedData2 = data2(~isnan(data2(:,1)), :);
        
        % Remove columns with NaN as the first element
        cleanedData1(:, any(isnan(cleanedData1), 1)) = [];
        cleanedData2(:, any(isnan(cleanedData2), 1)) = [];
        
        % Extract x and y data (DCV)
        x1Data_dcv = cleanedData1(:,1);
        % Note: MTS displacement in terms of voltage (collected using the BNC cable
        % connected to the back of the controller box on MTS) needs to multiplied
        % by a factor of 10 to convert to displacement in terms of mm. 
        y1Data_mm = cleanedData1(:,2); y1Data_mm = 10*y1Data_mm;

        y1Data_strain = y1Data_mm/Gauge_length - min(y1Data_mm)/Gauge_length;

        y2Data = cleanedData1(:,3);
        y3Data = cleanedData1(:,4);
        y4Data = cleanedData1(:,5);
        
        % Extract x and z data (DCI)
        x1Data_dci = cleanedData2(:,1);
        % Note: MTS displacement in terms of voltage (collected using the BNC cable
        % connected to the back of the controller box on MTS) needs to multiplied
        % by a factor of 10 to convert to displacement in terms of mm. 
        z1Data_mm = cleanedData2(:,2); z1Data_mm = 10*z1Data_mm;
        
        z1Data_strain = z1Data_mm/Gauge_length - min(z1Data_mm)/Gauge_length;

        z2Data = cleanedData2(:,3);
        z3Data = cleanedData2(:,4);
        z4Data = cleanedData2(:,5);
        
        % getting the averge of the first 5 seconds of data for the nodal voltages
        % (this is when the sample is at rest)
        y2Mean5sec = mean(y2Data(1:1251));
        y3Mean5sec = mean(y3Data(1:1251));
        y4Mean5sec = mean(y4Data(1:1251));
        z2Mean5sec = mean(z2Data(1:1251));
        z3Mean5sec = mean(z3Data(1:1251));  
        z4Mean5sec = mean(z4Data(1:1251));
        
        % calculating normalized nodal voltages (unitless)
        y2Data_norm = (y2Data-y2Mean5sec)/y2Mean5sec;
        y3Data_norm = (y3Data-y3Mean5sec)/y3Mean5sec;
        y4Data_norm = (y4Data-y4Mean5sec)/y4Mean5sec;

        z2Data_norm = (z2Data-z2Mean5sec)/z2Mean5sec;
        z3Data_norm = (z3Data-z3Mean5sec)/z3Mean5sec;
        z4Data_norm = (z4Data-z4Mean5sec)/z4Mean5sec;
end

%--------------------------------------------------------------------------
% % % create a new pair of axes inside current figure
% % axes('position',[.155 .6 .25 .25])
% % box on % put box around new pair of axes
% % indexOfInterest = (xData < 5) & (xData > 0); % range of t near perturbation
% % % make sure to change the y-vector and color when plotting!!!
% % plot(xData(indexOfInterest),y3Data(indexOfInterest),'Color' , '#EDB120') % plot on new axes
% % axis tight
%--------------------------------------------------------------------------


%$-$% Data analysis for MTS Tensile Tester RAW data %$-$% 

% Note: This file (if obtained from the MTS) will show the programmed
% output, not the actual ouput, which is obtained by establishing a BNC
% conncection on the back of the MTS controller. It is not necessary to
% conduct the data analysis. 

% % Specify the path to your CSV file (sampling rate is 250 Hz)
% csvFile3 = 'MTS Tensile Tester\20240228_ml-strip_15ps_fs.dat';
% 
% % Read the data from the file
% data3 = readmatrix(csvFile3);
% 
% % Remove rows with NaN as the first element
% cleanedData3 = data3(~isnan(data3(:,1)), :);
% 
% % Remove columns with NaN as the first element
% cleanedData3(:, any(isnan(cleanedData3), 1)) = [];
% 
% %disp(cleanedData)
% 
% % --KEY--
% % Note: needs to be udpated for each data analysis, since the data
% % extracted from the MTS might be different.
% %x2Data = Time; y5Data = Axial Displacement
% %y6Data = Axial Displacement Abs. Error; y7Data = Readout 1 
% 
% % Extract x and y data
% x2Data = cleanedData3(:,1);
% y5Data = cleanedData3(:,2);
% y6Data = cleanedData3(:,3);
% y7Data = cleanedData3(:,4);
% %y4Data = cleanedData(:,5);

%-$-% Plot using yyplot()

Pix_SS = get(0,'screensize'); % get the screen dimensions 

switch switch_analysis
    
    case 1 %plot DCV data
        % Plot data on both y-axes
        figure('position', [0, 500, Pix_SS(3), Pix_SS(4)/4]) 
        % plot voltage data on the left y-axis
        yyaxis left; hold on; grid on;
        %plot(x1Data_dcv, y1Data,'Color','#000000','LineWidth',1.2, 'LineStyle','-.', ...
        %    'DisplayName', 'MTS Displacement Readout');


       % SampFreq = 250; cutoffFreq = 8;
        [B,A] = butter(2,cutoffFreq/(SampFreq/2)); % 2nd order, fc/(fs/2)
        DCV_output = y2Data;
        DCV_Fil = filter(B,A,DCV_output);

        plot(x1Data_dcv, DCV_Fil,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-.', ...
            'DisplayName', node_name_A );



%         plot(x1Data_dcv, y3Data,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-.', ...
%             'DisplayName', node_name_B );
%         plot(x1Data_dcv, y4Data,'Color','#77AC30','LineWidth',1.2, 'LineStyle','-.', ...
%             'DisplayName',node_name_C );
        ylabel("Voltage (V)",'FontWeight', 'bold');


         %ylabel("Voltage Output (V)",'FontWeight', 'bold');

        % plot displacemetn data on the right y-axis
        yyaxis right;
        % delay between NI DAQexpress start and MTS start (in seconds)
        % (1) add dealy to x-axis to shift the displacement plot to the right
        % (2) find delay by comparing same peak in y1Data (MTS voltage output collected 
        % using NI LabVIEW DAQexpress) and y5Data (MTS displacement ouput from MTS
        % RAW data file). Use (1) when Dr. Majumdar's MTS is used. Use (2) when
        % another MTS that does not allow for displacement in terms of voltage
        % readout.
        
        %Note: The MTS voltage readout converted to displacement is being used for
        %this plot 
        
%         DAQ_time_delay = 5.1731; % option (2)
%         plot(x2Data+DAQ_time_delay, y5Data,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-', ...
%             'DisplayName','Axial Disp.');
        
        % note: min value is negative, so a negative sign is needed in
        % front of the added constant to shift the plot up (double-check
        % for each different test)

       plot(x1Data_dcv, y1Data_strain,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
            'DisplayName', 'MTS Strain Applied ');

        %plot(x2Data, y6Data, 'Color','#A2142F','LineWidth',1.2, 'LineStyle','none', ...
        %    'DisplayName','Axial Disp. Abs. Error');
        %plot(x2Data, y7Data, 'Color' , '#77AC30' ,'LineWidth',1.2, 'LineStyle','none', ...
        %    'DisplayName','test')

        ylabel("Strain",'FontWeight', 'bold');
        
        xlabel("Time (s)",'FontWeight', 'bold');
        title([MLO_name,' Strip Strain & Filtered Node Voltage Ouput (',num2str(strain_perc),'%)'],'FontWeight','bold')      
        legend('show', 'Location', 'best');   
        
        if save_files ==1
            fname = [num2str(file_date),'_',MLO_name,'_filtered_dcv_',num2str(strain_perc),'ps_AllHz',file_save_opt];
            saveas(gcf,fullfile(outputdir,fname));
        end
        %xlim([5 15])

    case 2 %plot DCI data 
        % Plot data on both y-axes
        figure('position', [0, 500, Pix_SS(3), Pix_SS(4)/4]) 
        % plot current data on the left y-axis
        yyaxis left; hold on; grid on;
        %plot(x1Data_dci, y1Data,'Color','#000000','LineWidth',1.2, 'LineStyle','-.', ...
        %    'DisplayName', 'MTS Displacement Readout');


        %SampFreq = 250; cutoffFreq = 8;
        [B,A] = butter(2,cutoffFreq/(SampFreq/2)); % 2nd order, fc/(fs/2)
        DCI_output = z2Data;
        DCI_Fil = filter(B,A,DCI_output);

        plot(x1Data_dci, DCI_Fil,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-.', ...
            'DisplayName', node_name_A );

%         plot(x1Data_dci, z3Data,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-.', ...
%             'DisplayName', node_name_B );
%         plot(x1Data_dci, z4Data,'Color','#77AC30','LineWidth',1.2, 'LineStyle','-.', ...
%             'DisplayName', node_name_C );


        ylabel("Current (A)",'FontWeight', 'bold');

        % plot displacemetn data on the right y-axis
        yyaxis right;
        % delay between NI DAQexpress start and MTS start (in seconds)
        % (1) add dealy to x-axis to shift the displacement plot to the right
        % (2) find delay by comparing same peak in y1Data (MTS voltage output collected 
        % using NI LabVIEW DAQexpress) and y5Data (MTS displacement ouput from MTS
        % RAW data file). Use (1) when Dr. Majumdar's MTS is used. Use (2) when
        % another MTS that does not allow for displacement in terms of voltage
        % readout.
        
        %Note: The MTS voltage readout converted to displacement is being used for
        %this plot 
        
        %DAQ_time_delay = 6.8073; % option (2)
        %plot(x2Data+DAQ_time_delay, y5Data,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
        %    'DisplayName','Axial Disp.');
        
        plot(x1Data_dci, z1Data_strain ,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
            'DisplayName', 'MTS Strain Applied ');
        %plot(x2Data, y6Data, 'Color','#A2142F','LineWidth',1.2, 'LineStyle','none', ...
        %    'DisplayName','Axial Disp. Abs. Error');
        %plot(x2Data, y7Data, 'Color' , '#77AC30' ,'LineWidth',1.2, 'LineStyle','none', ...
        %    'DisplayName','test')
        ylabel("Strain",'FontWeight', 'bold');
        
        xlabel("Time (s)",'FontWeight', 'bold');
        title([MLO_name,' Strip Strain & Filtered Node Current Ouput (',num2str(strain_perc),'%)'],'FontWeight','bold')
        legend('show', 'Location', 'best');
        
        if save_files ==1
            fname = [num2str(file_date),'_',MLO_name,'_filtered_dci_',num2str(strain_perc),'ps_AllHz',file_save_opt];
            saveas(gcf,fullfile(outputdir,fname));
        end

    case 3 %plot both DCV and DCI on seperate plots
        % Plot data on both y-axes (DCV)
        figure('position', [0, 500, Pix_SS(3), Pix_SS(4)/4]) 
        % plot voltage data on the left y-axis
        yyaxis left; hold on; grid on;
        %plot(x1Data_dcv, y1Data,'Color','#000000','LineWidth',1.2, 'LineStyle','-.', ...
        %    'DisplayName', 'MTS Displacement Readout');

        
        % applying low-pass filter to raw DCV data
        [B,A] = butter(2,cutoffFreq/(SampFreq/2)); % 2nd order, fc/(fs/2)
        DCV_output = y2Data;%((250*x1):(250*x2));
        DCV_Fil = filter(B,A,DCV_output);
        
        
        plot(x1Data_dcv, DCV_Fil,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-.', ...
            'DisplayName', node_name_A );

        %plot(x1Data_dcv, y3Data_norm,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-.', ...
        %    'DisplayName', node_name_B );
        %plot(x1Data_dcv, y4Data_norm,'Color','#77AC30','LineWidth',1.2, 'LineStyle','-.', ...
        %    'DisplayName',node_name_C );
        %ylabel("Normalized Voltage",'FontWeight', 'bold');
         ylabel("Voltage Output (V)",'FontWeight', 'bold');

        % plot displacemetn data on the right y-axis
        yyaxis right;
        % delay between NI DAQexpress start and MTS start (in seconds)
        % (1) add dealy to x-axis to shift the displacement plot to the right
        % (2) find delay by comparing same peak in y1Data (MTS voltage output collected 
        % using NI LabVIEW DAQexpress) and y5Data (MTS displacement ouput from MTS
        % RAW data file). Use (1) when Dr. Majumdar's MTS is used. Use (2) when
        % another MTS that does not allow for displacement in terms of voltage
        % readout.
        
        %Note: The MTS voltage readout converted to displacement is being used for
        %this plot 
        
        %DAQ_time_delay = 6.8073; % option (2)
        %plot(x2Data+DAQ_time_delay, y5Data,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
        %    'DisplayName','Axial Disp.');

        plot(x1Data_dcv, y1Data_strain,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
            'DisplayName', 'MTS Strain Applied ');

        %plot(x2Data, y6Data, 'Color','#A2142F','LineWidth',1.2, 'LineStyle','none', ...
        %    'DisplayName','Axial Disp. Abs. Error');
        %plot(x2Data, y7Data, 'Color' , '#77AC30' ,'LineWidth',1.2, 'LineStyle','none', ...
        %    'DisplayName','test')
        ylabel("Strain",'FontWeight', 'bold');        
        xlabel("Time (s)",'FontWeight', 'bold');
        title([MLO_name,' Strain & Filtered Node Voltage Ouput (',num2str(strain_perc),'%)'],'FontWeight','bold')
        legend('show', 'Location', 'best');
        
        %ps_trial2_AllHz; ps_AllHz
        if save_files ==1
            fname = [num2str(file_date),'_',MLO_name,'_filtered_dcv_',num2str(strain_perc),'ps_AllHz',file_save_opt];
            saveas(gcf,fullfile(outputdir,fname));
        end
         
        % Plot data on both y-axes (DCI)
        figure('position', [0, 500, Pix_SS(3), Pix_SS(4)/4]) 
        % plot current data on the left y-axis
        yyaxis left; hold on; grid on;
        %plot(x1Data_dci, y1Data,'Color','#000000','LineWidth',1.2, 'LineStyle','-.', ...
        %    'DisplayName', 'MTS Displacement Readout');


        % applying low-pass filter to raw DCI data
        [B,A] = butter(2,cutoffFreq/(SampFreq/2)); % 2nd order, fc/(fs/2)
        DCI_output = z2Data;%((250*x1):(250*x2));
        DCI_Fil = filter(B,A,DCI_output);

    
        %y-value changed from z2Data (DCI_output) to DCI_fil.; xvalue
        %changed from x1Data_dci
        plot(x1Data_dci, DCI_Fil,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-.', ...
            'DisplayName', node_name_A );

        %plot(x1Data_dci, z3Data_norm,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-.', ...
        %    'DisplayName', node_name_B );
        %plot(x1Data_dci, z4Data_norm,'Color','#77AC30','LineWidth',1.2, 'LineStyle','-.', ...
        %    'DisplayName', node_name_C );
        %ylabel("Normalized Current",'FontWeight', 'bold');
         ylabel("Current Output (A)",'FontWeight', 'bold');

        % plot displacemetn data on the right y-axis
        yyaxis right;
        % delay between NI DAQexpress start and MTS start (in seconds)
        % (1) add dealy to x-axis to shift the displacement plot to the right
        % (2) find delay by comparing same peak in y1Data (MTS voltage output collected 
        % using NI LabVIEW DAQexpress) and y5Data (MTS displacement ouput from MTS
        % RAW data file). Use (1) when Dr. Majumdar's MTS is used. Use (2) when
        % another MTS that does not allow for displacement in terms of voltage
        % readout.
        
        %Note: The MTS voltage readout converted to displacement is being used for
        %this plot 
        
        %DAQ_time_delay = 6.8073; % option (2)
        %plot(x2Data+DAQ_time_delay, y5Data,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
        %    'DisplayName','Axial Disp.');
        
        plot(x1Data_dci, z1Data_strain,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
            'DisplayName', 'MTS Strain Applied ');
        %plot(x2Data, y6Data, 'Color','#A2142F','LineWidth',1.2, 'LineStyle','none', ...
        %    'DisplayName','Axial Disp. Abs. Error');
        %plot(x2Data, y7Data, 'Color' , '#77AC30' ,'LineWidth',1.2, 'LineStyle','none', ...
        %    'DisplayName','test')
        ylabel("Strain",'FontWeight', 'bold');
        
        xlabel("Time (s)",'FontWeight', 'bold');
        title([MLO_name,' Strain & Filtered Node Current Ouput (',num2str(strain_perc),'%)'],'FontWeight','bold')

        legend('show', 'Location', 'best');
        
        %ps_trial2_AllHz; ps_AllHz
        if save_files ==1
            fname = [num2str(file_date),'_',MLO_name,'_filtered_dci_',num2str(strain_perc),'ps_AllHz',file_save_opt];
            saveas(gcf,fullfile(outputdir,fname));
        end
end





%% ML Strip Data Analysis

% clc; clear all; close all;
%--------------------------------------------------------------------------
%                           $- USER INPUT-$
%--------------------------------------------------------------------------
csvFile1 = 'T:\NMT-R&D-engineer\Data\20240506_sensor-validation\NI LabVIEW DAQ\CSV-Files\20240501_sensor-fabrication\20240506_S3_10ps_fs_dcv.csv';

% Note: This file (if obtained from the MTS) will show the programmed
% output, not the actual ouput, which is obtained by establishing a BNC
% conncection on the back of the MTS controller. It is not necessary to
% conduct the data analysis. However, it serves as a check to make sure
% both options are giving the same reading.

% Specify the path to your CSV file (sampling rate is 250 Hz)
csvFile3 = 'T:\NMT-R&D-engineer\Data\20240506_sensor-validation\MTS Tensile Tester\20240501_sensor-fabrication\20240506_s3a-10ps_fs_dcv_readme.dat';


% this is where the files that are generated will be saved to (needs to be
% adjusted)
outputdir = 'NI LabVIEW DAQ\Figures\20240402_MLO7-power-plots';
file_date = 20240508;
strain_perc = 10;
file_save_opt = '.fig'; % chose from .png or .fig

% Gauge Length of Specimen
Gauge_length = 55; % mm
% to determine the strain divide the displacemetn data by the guage length

% automatically naming and saving the file 
MLO_name = 'MLO-sensor-0501S3';

% save files into outputdir folder (change to 1 to save)
save_files = 0;

% leave to have plots configured for strain. Change to 0 for displacement.
plot_strain = 0;
%--------------------------------------------------------------------------

% Read the data from the file
data1 = readmatrix(csvFile1);

% Remove rows with NaN as the first element
cleanedData1 = data1(~isnan(data1(:,1)), :);

% Remove columns with NaN as the first element
cleanedData1(:, any(isnan(cleanedData1), 1)) = [];

% Extract x and y data (DCV)
x1Data_dcv = cleanedData1(:,1);
% Note: MTS displacement in terms of voltage (collected using the BNC cable
% connected to the back of the controller box on MTS) needs to multiplied
% by a factor of 10 to convert to displacement in terms of mm. 
y1Data_mm = cleanedData1(:,2); y1Data_mm = 10*y1Data_mm;

y1Data_strain = y1Data_mm/Gauge_length - min(y1Data_mm)/Gauge_length;

y2Data = cleanedData1(:,3);
y3Data = cleanedData1(:,4);
y4Data = cleanedData1(:,5);

% getting the averge of the first 5 seconds of data for the nodal voltages
% (this is when the sample is at rest)
y2Mean5sec = mean(y2Data(1:1251));
y3Mean5sec = mean(y3Data(1:1251));
y4Mean5sec = mean(y4Data(1:1251));

% calculating normalized nodal voltages (unitless)

% notes: 
% - min value is negative, so a negative sign is needed in
%   front of the added constant to shift the plot up (double-check
%   for each different test)

y2Data_norm = (y2Data-y2Mean5sec)/y2Mean5sec;
y3Data_norm = (y3Data-y3Mean5sec)/y3Mean5sec;
y4Data_norm = (y4Data-y4Mean5sec)/y4Mean5sec;

%$-$% Data analysis for MTS Tensile Tester RAW data %$-$% 


% Read the data from the file
data3 = readmatrix(csvFile3);

% Remove rows with NaN as the first element
cleanedData3 = data3(~isnan(data3(:,1)), :);

% Remove columns with NaN as the first element
cleanedData3(:, any(isnan(cleanedData3), 1)) = [];

%disp(cleanedData)

% --KEY--
% Note: needs to be udpated for each data analysis, since the data
% extracted from the MTS might be different.
% x2Data = Time; y5Data = Axial Displacement
% y6Data = Axial Displacement Abs. Error; y7Data = Readout 1 

% Extract x and y data
x2Data = cleanedData3(:,1);
y5Data = cleanedData3(:,2);
y6Data = cleanedData3(:,3);
y7Data = cleanedData3(:,4);
%y4Data = cleanedData(:,5);

%-$-% Plot data

Pix_SS = get(0,'screensize'); % get the screen dimensions 

% Plot data on both y-axes
figure('position', [0, 500, Pix_SS(3), Pix_SS(4)/4])
hold on;
% plot voltage data on the left y-axis

% delay between NI DAQexpress start and MTS start (in seconds)
% (1) add dealy to x-axis to shift the displacement plot to the right
% (2) find delay by comparing same peak in y1Data (MTS voltage output collected 
% using NI LabVIEW DAQexpress) and y5Data (MTS displacement ouput from MTS
% RAW data file). Use (1) when Dr. Majumdar's MTS is used. Use (2) when
% another MTS that does not allow for displacement in terms of voltage
% readout.

%Note: The MTS voltage readout converted to displacement is being used for
%this plot 



% DAQ_time_delay = 4.45206; % option (2)
% plot(x2Data+DAQ_time_delay, y5Data,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-', ...
%     'DisplayName','MTS Readout');


% notes: 
% - obtain the DAQ_time_delay by plotting the MTS and NI LabVIEW data and
%   synchronizing them
% - comment the three code lines above when plotting strain


if plot_strain == 1
    plot(x1Data_dcv, y1Data_strain,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', 'MTS Applied Strain');
    %plot(x2Data, y6Data, 'Color','#A2142F','LineWidth',1.2, 'LineStyle','none', ...
    %    'DisplayName','Axial Disp. Abs. Error');
    %plot(x2Data, y7Data, 'Color' , '#77AC30' ,'LineWidth',1.2, 'LineStyle','none', ...
    %    'DisplayName','test')
    hold off;

    ylabel("Strain",'FontWeight', 'bold');
    xlabel("Time (s)",'FontWeight', 'bold');
    title([MLO_name,' Strip Strain (',num2str(strain_perc),'%)'],'FontWeight','bold')      
    legend('show', 'Location', 'best');   
else
    plot(x1Data_dcv, y1Data_mm,'Color','#FF0000','LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', 'NI LabVIEW Readout ');
    plot(x2Data+8.1273, y5Data, 'Color','#0000FF','LineWidth',1.2, 'LineStyle','-', ...
        'DisplayName','MTS Program Readout');
    %plot(x2Data, y7Data, 'Color' , '#77AC30' ,'LineWidth',1.2, 'LineStyle','none', ...
    %    'DisplayName','test')
    hold off;
    ylabel("Displacement (mm)",'FontWeight', 'bold');
    xlabel("Time (s)",'FontWeight', 'bold');
    title([MLO_name,' Strip Displacement Comparison (',num2str(strain_perc),'%)'],'FontWeight','bold')      
    legend('show', 'Location', 'best');  

end


if save_files ==1 && plot_strain == 0
    fname = [num2str(file_date),'_',MLO_name,'_dcv_displacement-comparison_',num2str(strain_perc),'ps_AllHz',file_save_opt];
    saveas(gcf,fullfile(outputdir,fname));
end

if save_files ==1 && plot_strain == 1
    fname = [num2str(file_date),'_',MLO_name,'_dcv_',num2str(strain_perc),'ps_AllHz',file_save_opt];
    saveas(gcf,fullfile(outputdir,fname));
end

