clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%%  initialization
%  options for BEM simulation
op = bemoptions('sim', 'stat', 'waitbar', 0, 'interp', 'curv');

%  table of dielectric functions
epstab = {epsconst(1.0), epstable('gold_olmon.dat')};
radius = 14.5;
enei = 400:1:1000;
mie = miesolver(epstab{2}, epstab{1}, radius*2, op);

%% final plots
particle_name = ['radius_' num2str(radius)];

fig1 = figure('visible','on');
plot(enei, mie.abs(enei), '-','LineWidth', 1);  
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Absorption cross section (nm^2)', 'FontSize', 20);

fig2 = figure('visible','on');
plot(enei, mie.sca(enei), '-', 'LineWidth', 1);  
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Scattering cross section (nm^2)', 'FontSize', 20);

%% save data
filepath = "C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17\Examples";

spec_file = [enei', mie.sca(enei)'*1e-18, mie.abs(enei)'*1e-18];

% Define file paths with the desired directory and filenames
spec_filepath = fullfile(filepath, [particle_name '_mie_spec.csv']);

% Open the file for writing
fid = fopen(spec_filepath, 'w');

% Write the header
fprintf(fid, 'wav,scat,abs');

% Close and save data
fclose(fid);

% Save data as a CSV file
writematrix(spec_file, spec_filepath, 'WriteMode', 'append');
