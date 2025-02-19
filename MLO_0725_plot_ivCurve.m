% PURPOSE: This MATLAB script will plot the dark and light IV curves for an
% MLO strip. The data extraction is dependent on the days that the IV
% curves were collected. So it is necessary to adjust the code accordingly.

%-% Clear Plots %-%
clc; clear all; close all;



% save files into outputdir folder (change to 1 to save)
save_files = 1;

% dark IV data extraction
csvFile_d1 = 'T:\NMT-R&D-engineer\Data\20240801_sensor-validation_TODO\2450 Keithley DMM\20240801\20240724_MLO_G_D.csv';
csvFile_d2 = 'T:\NMT-R&D-engineer\Data\20240801_sensor-validation_TODO\2450 Keithley DMM\20240801\20240724_MLO_O_D.csv';
csvFile_d3 = 'T:\NMT-R&D-engineer\Data\20240801_sensor-validation_TODO\2450 Keithley DMM\20240801\20240724_MLO_P_D.csv';
csvFile_d4 = 'T:\NMT-R&D-engineer\Data\20240801_sensor-validation_TODO\2450 Keithley DMM\20240801\20240724_MLO_Y_D.csv';

data_d1 = readmatrix(csvFile_d1);
data_d2 = readmatrix(csvFile_d2);
data_d3 = readmatrix(csvFile_d3);
data_d4 = readmatrix(csvFile_d4);

% light IV data extraction
csvFile_l1 = 'T:\NMT-R&D-engineer\Data\20240801_sensor-validation_TODO\2450 Keithley DMM\20240801\20240724_MLO_G_L.csv';
csvFile_l2 = 'T:\NMT-R&D-engineer\Data\20240801_sensor-validation_TODO\2450 Keithley DMM\20240801\20240724_MLO_O_L.csv';
csvFile_l3 = 'T:\NMT-R&D-engineer\Data\20240801_sensor-validation_TODO\2450 Keithley DMM\20240801\20240724_MLO_P_L.csv';
csvFile_l4 = 'T:\NMT-R&D-engineer\Data\20240801_sensor-validation_TODO\2450 Keithley DMM\20240801\20240724_MLO_Y_L.csv';

data_l1 = readmatrix(csvFile_l1);
data_l2 = readmatrix(csvFile_l2);
data_l3 = readmatrix(csvFile_l3);
data_l4 = readmatrix(csvFile_l4);

outputdir = 'T:\NMT-R&D-engineer\Data\20240801_sensor-validation_TODO\2450 Keithley DMM\Figures';
file_date = 20240805;
MLO_name = 'Short-MLO-Strips';
file_save_opt = '.fig'; % chose from .png or .fig


%-% PLot Dark IV Curve %-%

DCV_output_d1 = data_d1(:,4)*1000;
DCI_output_d1 = data_d1(:,2)*1000;

DCV_output_d2 = data_d2(:,4)*1000;
DCI_output_d2 = data_d2(:,2)*1000;

DCV_output_d3 = data_d3(:,4)*1000;
DCI_output_d3 = data_d3(:,2)*1000;

DCV_output_d4 = data_d4(:,4)*1000;
DCI_output_d4 = data_d4(:,2)*1000;



figure; hold on;
plot(DCV_output_d1,DCI_output_d1,'LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', '20240724-MLO-G (20%)');
plot(DCV_output_d2,DCI_output_d2,'LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', '20240724-MLO-O (20%)');
plot(DCV_output_d3,DCI_output_d3,'LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', '20240724-MLO-P (20%)');
plot(DCV_output_d4,DCI_output_d4,'LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', '20240724-MLO-Y (20%)');
hold off;

xlabel("Voltage (mV)",'FontWeight', 'bold');
ylabel("Current (mA)",'FontWeight', 'bold')
title([MLO_name,' Dark IV Curve'],'FontWeight','bold')


legend('show', 'Location', 'best');

if save_files == 1
    fname = [num2str(file_date),'_',MLO_name,'_dark-iv-curve',file_save_opt];
    saveas(gcf,fullfile(outputdir,fname));
end

%-% Plot Light IV Curve %-%


DCV_output_l1 = data_l1(:,4)*1000;
DCI_output_l1 = data_l1(:,2)*1000;

DCV_output_l2 = data_l2(:,4)*1000;
DCI_output_l2 = data_l2(:,2)*1000;

DCV_output_l3 = data_l3(:,4)*1000;
DCI_output_l3 = data_l3(:,2)*1000;

DCV_output_l4 = data_l4(:,4)*1000;
DCI_output_l4 = data_l4(:,2)*1000;


figure; hold on;
plot(DCV_output_l1,DCI_output_l1,'LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', '20240724-MLO-G (20%)');
plot(DCV_output_l2,DCI_output_l2,'LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', '20240724-MLO-O (20%)');
plot(DCV_output_l3,DCI_output_l3,'LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', '20240724-MLO-P (20%)');
plot(DCV_output_l4,DCI_output_l4,'LineWidth',1.2, 'LineStyle','-', ...
    'DisplayName', '20240724-MLO-Y (20%)');
hold off;


xlabel("Voltage (mV)",'FontWeight', 'bold');
ylabel("Current (mA)",'FontWeight', 'bold')
title([MLO_name,' Light IV Curve'],'FontWeight','bold')

legend('show', 'Location', 'best');

if save_files == 1
    fname = [num2str(file_date),'_',MLO_name,'_light-iv-curve',file_save_opt];
    saveas(gcf,fullfile(outputdir,fname));
end
