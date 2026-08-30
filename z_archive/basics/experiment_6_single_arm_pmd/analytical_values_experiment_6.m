function analytics = analytical_values_experiment_6( ...
        dgd_values, sigma_sum, sigma_difference)
% ANALYTICAL_VALUES_EXPERIMENT_6  Analytical predictions for single-arm PMD.
%
% Objective:
%   Return the analytical predictions for a |Psi+> photon pair when one
%   frequency-dependent PMD segment acts only on photon A. The segment has
%   a z-axis principal-state-of-polarization direction and zero static phase.
%
%   After tracing out the frequency degree of freedom, the polarization
%   coherence is
%
%       mu(tau) = exp[-sigma_A^2 * tau^2 / 2],
%
%   where
%
%       sigma_A^2 = (sigma_sum^2 + sigma_difference^2) / 4.
%
% Input:
%   dgd_values       - real non-negative vector of differential group delays
%                      tau [s].
%   sigma_sum        - Gaussian JSA width along Omega_A + Omega_B [rad/s].
%   sigma_difference - Gaussian JSA width along Omega_A - Omega_B [rad/s].
%
% Output:
%   analytics - structure containing the analytical PMD predictions.
%
% Notes:
%   The formulas refer to the continuous, unbounded Gaussian spectrum. The
%   finite frequency grid used by the numerical experiment converges to this
%   result as its range and resolution are increased.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error('analytical_values_experiment_6:InvalidNumInputs', ...
            ['Expected exactly 3 input arguments: dgd_values, ', ...
             'sigma_sum, sigma_difference.']);
    end

    if ~isnumeric(dgd_values) || ~isreal(dgd_values) || ...
            ~isvector(dgd_values) || isempty(dgd_values)
        error('analytical_values_experiment_6:InvalidDGDValues', ...
            'dgd_values must be a non-empty real numeric vector.');
    end

    if any(~isfinite(dgd_values), 'all')
        error('analytical_values_experiment_6:InvalidDGDValues', ...
            'dgd_values must contain only finite values.');
    end

    if any(dgd_values < 0, 'all')
        error('analytical_values_experiment_6:InvalidDGDRange', ...
            'dgd_values must satisfy dgd_values >= 0.');
    end

    if ~isnumeric(sigma_sum) || ~isscalar(sigma_sum) || ...
            ~isreal(sigma_sum) || ~isfinite(sigma_sum) || sigma_sum <= 0
        error('analytical_values_experiment_6:InvalidSigmaSum', ...
            'sigma_sum must be a positive finite real numeric scalar.');
    end

    if ~isnumeric(sigma_difference) || ~isscalar(sigma_difference) || ...
            ~isreal(sigma_difference) || ~isfinite(sigma_difference) || ...
            sigma_difference <= 0
        error('analytical_values_experiment_6:InvalidSigmaDifference', ...
            'sigma_difference must be a positive finite real numeric scalar.');
    end


    % =========================
    % Main computation
    % =========================

    dgd_values = dgd_values(:).';
    num_dgd_values = numel(dgd_values);

    sigma_A_squared = (sigma_sum^2 + sigma_difference^2) / 4;
    sigma_A = sqrt(sigma_A_squared);

    mu = exp(-sigma_A_squared * dgd_values.^2 / 2);

    analytics = struct();

    analytics.dgd_values = dgd_values;

    analytics.sigma_sum = sigma_sum;
    analytics.sigma_difference = sigma_difference;
    analytics.sigma_A = sigma_A;
    analytics.sigma_A_squared = sigma_A_squared;

    analytics.mu = mu;
    analytics.mu_abs = abs(mu);

    analytics.correlation_tensor = zeros(3, 3, num_dgd_values);

    analytics.c_xx = mu;
    analytics.c_yy = mu;
    analytics.c_zz = -ones(1, num_dgd_values);

    analytics.c_xy = zeros(1, num_dgd_values);
    analytics.c_yx = zeros(1, num_dgd_values);

    analytics.purity_global = (1 + mu.^2) / 2;

    analytics.purity_A = 0.5 * ones(1, num_dgd_values);
    analytics.purity_B = 0.5 * ones(1, num_dgd_values);

    analytics.fidelity_psi_plus = (1 + mu) / 2;

    analytics.concurrence = mu;

    analytics.S_max = 2 * sqrt(1 + mu.^2);

    for dgd_idx = 1:num_dgd_values

        analytics.correlation_tensor(:, :, dgd_idx) = ...
            [ mu(dgd_idx), 0,            0; ...
              0,           mu(dgd_idx),  0; ...
              0,           0,           -1 ];

    end

end