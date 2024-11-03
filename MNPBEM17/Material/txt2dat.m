% Convert dielectric data (txt) to .dat file for BEM simulaitons. 

clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17\Material'))  

% Load data from CSV file
data = readmatrix('Au_dielectric_function_olmon_2012.txt'); % Replace 'input.csv' with your actual CSV file name

% Extract wavelength (wl), n, and k columns
wl = data(:, 1); % Wavelength in micrometers
n = data(:, 2);  % Refractive index
k = data(:, 3);  % Extinction coefficient

% Combine enei, n, and k to remove duplicates
[unique_wl, unique_indices] = unique(wl);
n = n(unique_indices);
k = k(unique_indices);

% Sort by energy (enei) if not already sorted
[unique_wl, sort_indices] = sort(unique_wl);
n = n(sort_indices);
k = k(sort_indices);

% Convert wavelength to energy (eV) using Energy = 1240 / wl (nm)
energy_eV = 1240 ./ (unique_wl * 1e3); % Convert wl from micrometers to nm and calculate energy

% Combine the data into a new matrix
output_data = [energy_eV, n, k];

% Reverse the order of rows
output_data = flipud(output_data);

% Define the file path for the new .dat file
new_filepath = 'gold_olmon.dat';

% Define headers and data
header1 = '% Gold dielectric function from Olmon';
header2 = '%  Energy (eV)  n   k';

% Open file for writing
fid = fopen(new_filepath, 'w');

% Write headers
fprintf(fid, '%s\n', header1);
fprintf(fid, '%s\n', header2);

% Write data to the file
for i = 1:size(output_data, 1)
    fprintf(fid, '%.6f\t%.6f\t%.6f\n', output_data(i, 1), output_data(i, 2), output_data(i, 3));
end

% Close the file
fclose(fid);