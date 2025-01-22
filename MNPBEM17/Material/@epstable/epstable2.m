function [n, k] = fitMultiCoeffModel(ene, epsilon_exp)
    % ene: photon energies in eV
    % epsilon_exp: complex dielectric function (n^2 - k^2 + 2i*n*k)

    % Define initial guess for parameters
    % [eps_inf, wp, gamma, delta_eps1, omega1, gamma1, ...]
    init_params = [1, 9, 0.1, 1, 4, 0.05];

    % Define the fitting function
    fitFunc = @(params, ene) multiCoeffModel(params, ene);

    % Perform fitting using optimization
    options = optimset('Display', 'iter');
    params_fit = lsqcurvefit(fitFunc, init_params, ene, epsilon_exp, [], [], options);

    % Calculate the refractive index and extinction coefficient
    epsilon_fit = fitFunc(params_fit, ene);
    n = sqrt((real(epsilon_fit) + abs(epsilon_fit)) / 2);
    k = sqrt((-real(epsilon_fit) + abs(epsilon_fit)) / 2);
end

function epsilon = multiCoeffModel(params, ene)
    % Model parameters
    eps_inf = params(1);
    wp = params(2);
    gamma = params(3);

    % Initialize epsilon
    epsilon = eps_inf - (wp^2 ./ (ene.^2 + 1i * gamma .* ene));

    % Add Lorentz terms
    for i = 4:3:length(params)
        delta_eps = params(i);
        omega_j = params(i+1);
        gamma_j = params(i+2);

        epsilon = epsilon + ...
            (delta_eps .* omega_j.^2) ./ (omega_j.^2 - ene.^2 - 1i * gamma_j .* ene);
    end
end
