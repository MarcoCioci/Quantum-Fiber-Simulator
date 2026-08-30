function analytics = analytical_values_experiment_7( ...
        dgd_values_A, dgd_values_B, sigma_sum, sigma_difference)
% ANALYTICAL_VALUES_EXPERIMENT_7
% Analytical benchmark for two-arm PMD nonlocal compensation.
%
% Objective:
%   Compute the closed-form predictions for |Psi+> propagated through two
%   aligned first-order PMD elements and traced over a Gaussian joint
%   spectrum. The benchmark is used to validate Experiment 7, where PMD in
%   arm B is tuned to compensate PMD-induced decoherence from arm A.
%
% Input:
%   dgd_values_A    - real non-negative vector of DGD values tau_A [s].
%   dgd_values_B    - real non-negative vector of DGD values tau_B [s].
%   sigma_sum       - JSA width along Omega_A + Omega_B [rad/s].
%   sigma_difference - JSA width along Omega_A - Omega_B [rad/s].
%
% Output:
%   analytics       - structure containing analytical kappa, states,
%                     correlation tensors, metrics, and spectral moments.
%
% Notes:
%   The joint spectrum is assumed proportional to
%
%       exp[-(Omega_A + Omega_B)^2 / (2 sigma_sum^2)]
%       exp[-(Omega_A - Omega_B)^2 / (2 sigma_difference^2)].
%
%   Therefore
%
%       sigma_A^2 = sigma_B^2 =
%           (sigma_sum^2 + sigma_difference^2) / 4,
%
%       covariance_AB =
%           (sigma_sum^2 - sigma_difference^2) / 4.
%
%   With the PMD axes chosen as z in arm A and -z in arm B, the coherence
%   factor is
%
%       kappa(tau_A, tau_B) =
%       exp[-1/2 * Var(Omega_A tau_A + Omega_B tau_B)].

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 4
        error('analytical_values_experiment_7:InvalidNumInputs', ...
            ['Expected exactly 4 input arguments: dgd_values_A, ', ...
             'dgd_values_B, sigma_sum, sigma_difference.']);
    end

    if ~isnumeric(dgd_values_A) || ~isreal(dgd_values_A) || ...
            ~isvector(dgd_values_A) || isempty(dgd_values_A)
        error('analytical_values_experiment_7:InvalidDGDValuesA', ...
            'dgd_values_A must be a non-empty real numeric vector.');
    end

    if any(~isfinite(dgd_values_A), 'all') || ...
            any(dgd_values_A < 0, 'all')
        error('analytical_values_experiment_7:InvalidDGDValuesA', ...
            'dgd_values_A must contain finite non-negative values.');
    end

    if ~isnumeric(dgd_values_B) || ~isreal(dgd_values_B) || ...
            ~isvector(dgd_values_B) || isempty(dgd_values_B)
        error('analytical_values_experiment_7:InvalidDGDValuesB', ...
            'dgd_values_B must be a non-empty real numeric vector.');
    end

    if any(~isfinite(dgd_values_B), 'all') || ...
            any(dgd_values_B < 0, 'all')
        error('analytical_values_experiment_7:InvalidDGDValuesB', ...
            'dgd_values_B must contain finite non-negative values.');
    end

    if ~isnumeric(sigma_sum) || ~isscalar(sigma_sum) || ...
            ~isreal(sigma_sum) || ~isfinite(sigma_sum) || sigma_sum <= 0
        error('analytical_values_experiment_7:InvalidSigmaSum', ...
            'sigma_sum must be a positive finite real scalar.');
    end

    if ~isnumeric(sigma_difference) || ~isscalar(sigma_difference) || ...
            ~isreal(sigma_difference) || ~isfinite(sigma_difference) || ...
            sigma_difference <= 0
        error('analytical_values_experiment_7:InvalidSigmaDifference', ...
            'sigma_difference must be a positive finite real scalar.');
    end


    % =========================
    % Spectral moments
    % =========================

    dgd_values_A = dgd_values_A(:).';
    dgd_values_B = dgd_values_B(:).';

    num_dgd_values_A = numel(dgd_values_A);
    num_dgd_values_B = numel(dgd_values_B);

    sigma_A = sqrt((sigma_sum^2 + sigma_difference^2) / 4);
    sigma_B = sigma_A;

    covariance_AB = (sigma_sum^2 - sigma_difference^2) / 4;
    correlation_AB = covariance_AB / (sigma_A * sigma_B);


    % =========================
    % Main computation
    % =========================

    [tau_A_grid, tau_B_grid] = ndgrid(dgd_values_A, dgd_values_B);

    coherence_variance = ...
        sigma_A^2 * tau_A_grid.^2 + ...
        sigma_B^2 * tau_B_grid.^2 + ...
        2 * covariance_AB .* tau_A_grid .* tau_B_grid;

    kappa = exp(-0.5 * coherence_variance);

    analytics = struct();

    analytics.model_name = 'two_arm_pmd_nonlocal_compensation';
    analytics.reference_state_label = 'psi_plus';

    analytics.dgd_values_A = dgd_values_A;
    analytics.dgd_values_B = dgd_values_B;

    analytics.sigma_sum = sigma_sum;
    analytics.sigma_difference = sigma_difference;
    analytics.sigma_A = sigma_A;
    analytics.sigma_B = sigma_B;
    analytics.covariance_AB = covariance_AB;
    analytics.correlation_AB = correlation_AB;

    analytics.coherence_variance = coherence_variance;
    analytics.kappa = kappa;

    analytics.rho = cell(num_dgd_values_A, num_dgd_values_B);
    analytics.rho_A = cell(num_dgd_values_A, num_dgd_values_B);
    analytics.rho_B = cell(num_dgd_values_A, num_dgd_values_B);

    analytics.correlation_tensor = zeros( ...
        3, 3, num_dgd_values_A, num_dgd_values_B);

    analytics.c_xx = kappa;
    analytics.c_yy = kappa;
    analytics.c_zz = -ones(num_dgd_values_A, num_dgd_values_B);

    analytics.purity_global = (1 + kappa.^2) / 2;
    analytics.purity_A = 0.5 * ones(num_dgd_values_A, num_dgd_values_B);
    analytics.purity_B = 0.5 * ones(num_dgd_values_A, num_dgd_values_B);

    analytics.fidelity_psi_plus = (1 + kappa) / 2;
    analytics.concurrence = kappa;
    analytics.S_max = 2 * sqrt(1 + kappa.^2);

    for idx_A = 1:num_dgd_values_A
        for idx_B = 1:num_dgd_values_B

            kappa_value = kappa(idx_A, idx_B);

            rho_value = zeros(4, 4);
            rho_value(2, 2) = 0.5;
            rho_value(3, 3) = 0.5;
            rho_value(2, 3) = 0.5 * kappa_value;
            rho_value(3, 2) = 0.5 * kappa_value;

            analytics.rho{idx_A, idx_B} = rho_value;
            analytics.rho_A{idx_A, idx_B} = 0.5 * eye(2);
            analytics.rho_B{idx_A, idx_B} = 0.5 * eye(2);

            analytics.correlation_tensor(:, :, idx_A, idx_B) = diag( ...
                [kappa_value, kappa_value, -1]);

        end
    end

end
