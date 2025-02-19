% PURPOSE: This MATLAB script will intake the data files generated by the 
% NI LABView DAQ (1) and will synchorize the voltage and current data for
% each loading frequency considered (values may need to be adjusted for
% different loading frequencies) taken by obtaining the time delay between 
% displacement data (done manually and entered into the script). 
% The script will then plot the syncrhonized displacement (strain, after 
% conversion), nodal voltage and current for each of the MLO nodes (A, B, 
% and C), and the power ouTput. It is important to have this MATLAB file in
% the same folder where the data is located or else it will not work. The
% path may need to be changed depending on your folder setup. This script
% is setup such that the ouput files will be saved to a user specified
% folder.
% Author: Geronimo Macias 

clc; clear all; close all;

%--------------------------------------------------------------------------
%                           $- USER INPUT-$
%--------------------------------------------------------------------------
%-% Data analysis for NI LabVIEW DAQ RAW data 
% Specify the path to your CSV file (sampling rate is 250 Hz)
csvFile1 = 'NI LabVIEW DAQ\CSV-files\20240301_MLO-strip6_10ps_fs_dcv.csv'; % DCV file
csvFile2 = 'NI LabVIEW DAQ\CSV-files\20240301_MLO-strip6_10ps_fs_dci.csv'; % DCI file

%this is where the files that are generated will be saved to
outputdir = 'NI LabVIEW DAQ\Figures\20240327_MLO6-power-plots';
MLO_name = 'MLO6';
file_date = 20240327;
strain_perc = 10;
file_save_opt = '.fig'; % chose from .png or .fig

% Gauge Length of Specimen
Gauge_length = 255; % mm
% to determine the strain divide the displacemetn data by the guage length

% change to 1 to display the power plots for all nodes 
disp_pwr_plot_A = 1;
disp_pwr_plot_B = 1;
disp_pwr_plot_C = 1;

% save files into outputdir folder (change to 1 to save)
save_files = 0;
%--------------------------------------------------------------------------

% TO-DO: automate the percent strain naming on the plots 
% ix=strfind(csvFile1,'_');  % get the underscore locations
% t=csvFile1(ix(2):ix(2)+2);
% percent_strain = {'5%', '10%', '15%'};

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
y2Data = cleanedData1(:,3);
y3Data = cleanedData1(:,4);
y4Data = cleanedData1(:,5);

% Extract x and z data (DCI)
x1Data_dci = cleanedData2(:,1);
% Note: MTS displacement in terms of voltage (collected using the BNC cable
% connected to the back of the controller box on MTS) needs to multiplied
% by a factor of 10 to convert to displacement in terms of mm. 
z1Data_mm = cleanedData2(:,2); z1Data_mm = 10*z1Data_mm;
z2Data = cleanedData2(:,3);
z3Data = cleanedData2(:,4);
z4Data = cleanedData2(:,5);

%comparing data sizes of the current and voltage to determine the size of
% the cell array
size_cleanedData1 = size(cleanedData1); size_cleanedData1 = size_cleanedData1(1);
size_cleanedData2 = size(cleanedData2); size_cleanedData2 = size_cleanedData2(1);

% TO-DO: Make the columns automated as well... right now there are 10
if size_cleanedData2 > size_cleanedData1
    size_diff = size_cleanedData2-size_cleanedData1;
    ALL_Data = zeros(size_cleanedData2,10);
    %sync_Data = zeros(size_cleanedData2,10);

    ALL_Data(:,1:5) = [cleanedData1(:,1:5); zeros(size_diff,5)]; 
    ALL_Data(:,2) = [y1Data_mm; zeros(size_diff,1)]; % displacement conversion (from voltage to mm)
    ALL_Data(:,6:10) = cleanedData2(:,1:5);
    ALL_Data(:,7) = z1Data_mm;
else
    size_diff = (size_cleanedData2-size_cleanedData1)*-1;
    ALL_Data = zeros(size_cleanedData1,10);
    %sync_Data = zeros(size_cleanedData1,10);
    
    ALL_Data(:,1:5) = cleanedData1(:,1:5);  
    ALL_Data(:,2) = y1Data_mm; % displacement conversion (from voltage to mm)
    ALL_Data(:,6:10) = [cleanedData2(:,1:5);zeros(size_diff,5)];
    ALL_Data(:,7) = [z1Data_mm; zeros(size_diff,1)];
end

ALL_Data_Prev = ALL_Data; 

% TO-DO: Key will have to be udpated depending on amount of data columns.

%-% KEY
% COLS 1:5 (DCV)
% [Time, MTS disp. (mm), MLO-A (V), MLO-B (V), MLO-C (V) ...
% COLS 6:10 (DCI)
% Time, MTS disp. (mm), MLO-A (A), MLO-B (A), MLO-C (A)]

%-% Need to compare the two strain signals--DCV and DCI
% Note: from this plot the time difference between the DCI and DCV strain
% plots needs to be determine, in order to synchronized the DCI and DCV
% data. 

figure; hold on;

plot(x1Data_dci, z1Data_mm,'Color','#4DBEEE','LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', 'MTS Displacement (DCI)');

plot(x1Data_dcv, y1Data_mm,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', 'MTS Displacement (DCV)');

title('MLO4 Strip Displacement Phase Difference (DCV and DCI)', ...
    'FontWeight','bold');
ylabel("Displacement (mm)",'FontWeight', 'bold');
xlabel("Time (s)",'FontWeight', 'bold');

%xlim([0 63])

legend('show', 'Location', 'best');

% These values were obtained from plot above 
deltaTime_1hz = 0; % DCI leading  
deltaTime_2hz = 0; % DCI leading
deltaTime_3hz = 0; % DCI lagging

deltaTime = [deltaTime_1hz deltaTime_2hz deltaTime_3hz];


%TO-DO 
% n: is the number of elements to extract from the data vector

n = 45*250; % (45 seconds)*(sampling frequency)
sync_Data = zeros(n,10);

%TO-DO: these ranges might need to be adjusted... 
% based on synchronized plots choose the appropriate time windows for each
% loading frequency (has to be changed for each data analysis, since the
% time ranges will most likely differ)
ranges_left = [7 13.5 20.5];
ranges_right = [13 20.05 27];


% this will add the delay to DCI data for all loading frequencies 
for i = 1:length(deltaTime) 
    % shifting the DCI time, all other DCI data remains the same
    % need to reasing original matrix at the end of the for loop
    ALL_Data(:,6) =  ALL_Data(:,6)+deltaTime(i); 

    if deltaTime(i)*(-1)>0 % deltaTime(i) is negative
        % extract 45 seconds of data   
        row_shift = find(ALL_Data(:,1)==deltaTime(i)*(-1));
        for j = 1:n
            %disp('oh')
            sync_Data(j,1:5) = ALL_Data(j,1:5); 
            sync_Data(j,6:10) = ALL_Data(j+row_shift-1,6:10);
        end

    else % deltaTime(i) is postive 
        % extract 45 seconds of data 
        row_shift = find(ALL_Data(:,1)==deltaTime(i));
        for j = 1:n
            %disp('aye')
            sync_Data(j,1:5) = ALL_Data(j+row_shift-1,1:5);
            sync_Data(j,6:10) = ALL_Data(j,6:10);
        end
    end

    % reassing synced data to previous variables 
    x1Data_dcv = sync_Data(:,1); % time data for DCV
    y1Data_mm = sync_Data(:,2); % MTS displacement for DCV
    y1Data_strain = y1Data_mm/Gauge_length - min(y1Data_mm)/Gauge_length;
    
    % Note: the *1000 converts from V to mV
    y2Data = sync_Data(:,3)*1000; % MLO-A voltage output
    y3Data = sync_Data(:,4)*1000; % MLO-B voltage ouptut
    y4Data = sync_Data(:,5)*1000; % MLO-C votlage output 
   

    x1Data_dci = sync_Data(:,6); % time data for DCI
    z1Data_mm = sync_Data(:,7); % MTS displacement for DCI
    z1Data_strain = z1Data_mm/Gauge_length - min(z1Data_mm)/Gauge_length;
    
    % Note: the *1000 converts from A to mA
    z2Data = sync_Data(:,8)*1000; % MLO-A current output
    z3Data = sync_Data(:,9)*1000; % MLO-B current output
    z4Data = sync_Data(:,10)*1000; % MLO-C current output 


    % NEW CODE 03/15/2024 (code is used to normalize the voltage)
    % getting the averge of the first 5 seconds of data for the nodal voltages
    % (this is when the sample is at rest)
    y3Mean5sec = mean(y3Data(1:1251));
    z3Mean5sec = mean(z3Data(1:1251));

    % calculating normalized nodal voltages (unitless)
    y3Data_norm = (y3Data-y3Mean5sec)/y3Mean5sec;
    z3Data_norm = (z3Data-z3Mean5sec)/z3Mean5sec;

    %-%

    powerOutputA = (y2Data.*z2Data)*1000; % converted from Watts to Milliwatts
    powerOutputB = (y3Data.*z3Data)*1000;
    powerOutputC = (y4Data.*z4Data)*1000;

    loading_freq = [1 2 3]; % for naming plots 
    
    %-% Important! Percent strain on title may need to be changed to match data

    Pix_SS = get(0,'screensize'); % get the screen dimensions 

    %-$$$$$$$$$$$$$$$$$$$$$$$- MLO-A Power Plot -$$$$$$$$$$$$$$$$$$$$$$$$-% 
    % automatically naming the plot and file generated 
    node_name_A = append(MLO_name,'-A');
    
    if disp_pwr_plot_A == 1
        figure('position', [0, 0, Pix_SS(3), Pix_SS(4)]) 
        subplot(3,1,1);
        plot(x1Data_dcv, y1Data_strain,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MTS Strain Applied (DCV)');
        hold on;
        plot(x1Data_dci,z1Data_strain,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MTS Strain Applied (DCI)');
        hold off;
        title([node_name_A,' Strip Strain Applied Comparison (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        ylabel("Strain",'FontWeight', 'bold');
        legend('show', 'Location', 'best');
    
        % 20240304: This switch statement will generate plots where only the
        % strain is synchronized for the voltage and current data. This is done
        % for each loading frequency. 
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    
        %-$-%
        subplot(3,1,2);
        yyaxis left;
        plot(x1Data_dcv, y2Data,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'Voltage Output (DCV)');
        ylabel("Voltage Output (mV)",'FontWeight', 'bold');
        hold on;
    
        yyaxis right; 
    
        plot(x1Data_dci,z2Data,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'Current Output (DCI)');
        hold off;
        title([node_name_A,' Nodal Voltage and Current Output (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        ylabel("Current Output (mA)",'FontWeight', 'bold');
        legend('show', 'Location', 'best');
    
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    
        %-$-%
        subplot(3,1,3);
        plot(x1Data_dcv, powerOutputA,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-')
        title([node_name_A,' Power Ouput (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        ylabel("Power (mW)",'FontWeight', 'bold');
        %legend('show', 'Location', 'best');  
    
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end

    end

    
    if save_files ==1
        fname = [num2str(file_date),'_',node_name_A,'_power-plot_',num2str(strain_perc),'ps_',num2str(loading_freq(i)),'Hz',file_save_opt];
        saveas(gcf,fullfile(outputdir,fname));
    end

    %-$-%

    if disp_pwr_plot_A == 1
        figure('position', [0, 500, Pix_SS(3), Pix_SS(4)/4]) 
        % Note: This is under the assumption that the same displacmeemnt (or
        % strain) is being applied for both the DCI and DCV data packets, which
        % is resonable to make since the plots only differ very slightly. 
    
        yyaxis right;
    
        plot(x1Data_dcv, y1Data_strain,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MTS Strain Applied (DCV)');
        ylabel("Strain",'FontWeight', 'bold');
        hold on;
    
        yyaxis left; 
    
        plot(x1Data_dcv,powerOutputA,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MLO-A Power Output');
        ylabel("Power Output (mW)",'FontWeight', 'bold');
        hold off;
        title([node_name_A,' Strip Power Ouput in Response to Strain Applied (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        
        legend('show', 'Location', 'best');
    
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    end
    
    if save_files ==1
        fname = [num2str(file_date),'_',node_name_A,'_power-plot2_',num2str(strain_perc),'ps_',num2str(loading_freq(i)),'Hz',file_save_opt];
        saveas(gcf,fullfile(outputdir,fname));
    end

    %-$$$$$$$$$$$$$$$$$$$$$$$- MLO-B Power Plot -$$$$$$$$$$$$$$$$$$$$$$$$-% 
    % automatically naming the plot and file generated 
    node_name_B = append(MLO_name,'-B');
    
    if disp_pwr_plot_B == 1
        figure('position', [0, 0, Pix_SS(3), Pix_SS(4)]) 
        subplot(3,1,1);
        plot(x1Data_dcv, y1Data_strain,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MTS Strain Applied (DCV)');
        hold on;
        plot(x1Data_dci,z1Data_strain,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MTS Strain Applied (DCI)');
        hold off;
        title([node_name_B,' Strip Strain Applied Comparison (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        ylabel("Strain",'FontWeight', 'bold');
        legend('show', 'Location', 'best');
    
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    
        %-$-%
        subplot(3,1,2);
        yyaxis left;
        plot(x1Data_dcv, y3Data,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'Voltage Output (DCV)');
        ylabel("Voltage Output (mV)",'FontWeight', 'bold');
        hold on;
    
        yyaxis right; 
    
        plot(x1Data_dci,z3Data,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'Current Output (DCI)');
        hold off;
        title([node_name_B,' Nodal Voltage and Current Output (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        ylabel("Current Output (mA)",'FontWeight', 'bold');
        legend('show', 'Location', 'best');
    
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    
        %-$-%
    
        subplot(3,1,3);
        plot(x1Data_dcv, powerOutputB,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-')
        title([node_name_B,' Power Ouput (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        ylabel("Power Output (mW)",'FontWeight', 'bold');
        %legend('show', 'Location', 'best');  
        
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    end
    
    if save_files ==1
        fname = [num2str(file_date),'_',node_name_B,'_power-plot_',num2str(strain_perc),'ps_',num2str(loading_freq(i)),'Hz',file_save_opt];
        saveas(gcf,fullfile(outputdir,fname));
    end

    %-$-%
    if disp_pwr_plot_B == 1
        figure('position', [0, 500, Pix_SS(3), Pix_SS(4)/4]) 
        % Note: This is under the assumption that the same displacmeemnt (or
        % strain) is being applied for both the DCI and DCV data packets, which
        % is resonable to make since the plots only differ very slightly. 
    
        yyaxis right;
    
        plot(x1Data_dcv, y1Data_strain,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MTS Strain Applied (DCV)');
        ylabel("Strain",'FontWeight', 'bold');
        hold on;
    
        yyaxis left; 
    
        plot(x1Data_dcv,powerOutputB,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MLO-B Power Output');
        ylabel("Power Output (mW)",'FontWeight', 'bold');
        hold off;
        title([node_name_B,' Strip Power Ouput in Response to Strain Applied (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        
        legend('show', 'Location', 'best');
    
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end

    end
    
    if save_files ==1
        fname = [num2str(file_date),'_',node_name_B,'_power-plot2_',num2str(strain_perc),'ps_',num2str(loading_freq(i)),'Hz',file_save_opt];
        saveas(gcf,fullfile(outputdir,fname));
    end

    %-$$$$$$$$$$$$$$$$$$$$$$$- MLO-C Power Plot -$$$$$$$$$$$$$$$$$$$$$$$$-% 
    node_name_C = append(MLO_name,'-C');
    
    if disp_pwr_plot_C == 1
        figure('position', [0, 0, Pix_SS(3), Pix_SS(4)]) 
        subplot(3,1,1);
        plot(x1Data_dcv, y1Data_strain,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MTS Strain Applied (DCV)');
        hold on;
        plot(x1Data_dci,z1Data_strain,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MTS Strain Applied (DCI)');
        hold off;
        title([node_name_C  ,' Strip Strain Applied Comparison (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        ylabel("Strain",'FontWeight', 'bold');
        legend('show', 'Location', 'best');
    
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    
        %-$-%
        subplot(3,1,2);
        yyaxis left;
        plot(x1Data_dcv, y4Data,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'Voltage Output (DCV)');
        ylabel("Voltage Output (mV)",'FontWeight', 'bold');
        hold on;
    
        yyaxis right; 
    
        plot(x1Data_dci,z4Data,'Color','#A2142F','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'Current Output (DCI)');
        hold off;
        title([node_name_C,' Nodal Voltage and Current Output (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        ylabel("Current Output (mA)",'FontWeight', 'bold');
        legend('show', 'Location', 'best');
    
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    
        %-$-%
        subplot(3,1,3);
        plot(x1Data_dcv, powerOutputC,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-')
        title([node_name_C,' Power Ouput (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        ylabel("Power Output (mW)",'FontWeight', 'bold');
        %legend('show', 'Location', 'best');
     
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    end
    
    if save_files ==1
        fname = [num2str(file_date),'_',node_name_C,'_power-plot_',num2str(strain_perc),'ps_',num2str(loading_freq(i)),'Hz',file_save_opt];
        saveas(gcf,fullfile(outputdir,fname));
    end

    %-$-%
    if disp_pwr_plot_C == 1
        figure('position', [0, 500, Pix_SS(3), Pix_SS(4)/4]) 
        % Note: This is under the assumption that the same displacmeemnt (or
        % strain) is being applied for both the DCI and DCV data packets, which
        % is resonable to make since the plots only differ very slightly. 
    
        yyaxis right;
    
        plot(x1Data_dcv, y1Data_strain,'Color','#EDB120','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MTS Strain Applied (DCV)');
        ylabel("Strain",'FontWeight', 'bold');
        hold on;
    
        yyaxis left; 
    
        plot(x1Data_dcv,powerOutputC,'Color','#0072BD','LineWidth',1.2, 'LineStyle','-', ...
                'DisplayName', 'MLO-C Power Output');
        ylabel("Power Output (mW)",'FontWeight', 'bold');
        hold off;
        title([node_name_C,' Strip Power Ouput in Response to Strain Applied (',num2str(strain_perc),'% Strain, ',num2str(loading_freq(i)),' Hz)'],'FontWeight','bold')
        xlabel("Time (s)",'FontWeight', 'bold');
        
        legend('show', 'Location', 'best');
    
        modify_x_axis = i; 
        switch modify_x_axis
            case 1
                xlim([ranges_left(i) ranges_right(i)])
            case 2
                xlim([ranges_left(i) ranges_right(i)])
            case 3
                xlim([ranges_left(i) ranges_right(i)])
        end
    end

    if save_files ==1
        fname = [num2str(file_date),'_',node_name_C,'_power-plot2_',num2str(strain_perc),'ps_',num2str(loading_freq(i)),'Hz',file_save_opt];
        saveas(gcf,fullfile(outputdir,fname));
    end

    % reasigning original data to manipulate again with different time delay 
    ALL_Data = ALL_Data_Prev; 
end


