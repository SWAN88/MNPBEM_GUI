clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  


% Simulate the response for the first polarization (e.g., along x)
I_x = simulate_polarization('x'); % Replace with your simulation function or method

% Simulate the response for the second polarization (e.g., along y)
I_y = simulate_polarization('y'); % Replace with your simulation function or method

% Calculate the unpolarized response by averaging the two polarizations
I_unpolarized = (I_x + I_y) / 2;

% Plot or analyze the unpolarized response
figure;
plot(wavelength, I_unpolarized);
xlabel('Wavelength (nm)');
ylabel('Intensity');
title('Response for Unpolarized Illumination');


% Assuming near-field/far-field data from two polarizations
E_near_x = simulate_near_field('x'); % Near-field for x-polarization
E_near_y = simulate_near_field('y'); % Near-field for y-polarization

% Calculate the averaged near-field for unpolarized light
E_near_unpolarized = (E_near_x + E_near_y) / 2;

% Plot or analyze the unpolarized near-field response
figure;
plot(wavelength, E_near_unpolarized);
xlabel('Wavelength (nm)');
ylabel('Near-field Intensity');
title('Near-field Response for Unpolarized Illumination');