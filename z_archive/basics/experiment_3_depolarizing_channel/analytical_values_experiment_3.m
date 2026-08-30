function analytics = analytical_values_experiment_3(p_values)
% ANALYTICAL_VALUES_EXPERIMENT_3
% Analytical predictions for the global depolarizing-channel experiment.
%
% Objective:
%   Return the analytical quantities associated with the global two-qubit
%   depolarizing channel applied to |Ψ⁺⟩:
%
%       ρ(p) = (1-p)ρ_0 + p I_4/4
%
% Input:
%   p_values - real scalar or vector, with 0 <= p <= 1
%
% Output:
%   analytics - structure containing analytical predictions:
%
%       analytics.p_values
%       analytics.gamma_AB
%       analytics.gamma_A
%       analytics.gamma_B
%       analytics.F_psi_plus
%       analytics.C
%       analytics.c_xx
%       analytics.c_yy
%       analytics.c_zz
%       analytics.T
%
% Notes:
%   If p_values contains N values, analytics.T is returned as a 3x3xN array.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('analytical_values_experiment_3:InvalidNumInputs', ...
              'Expected 1 input argument: p_values.');
    end

    if ~isnumeric(p_values) || ~isreal(p_values)
        error('analytical_values_experiment_3:InvalidPValuesType', ...
              'p_values must be real numeric.');
    end

    if any(~isfinite(p_values), 'all')
        error('analytical_values_experiment_3:InvalidPValues', ...
              'p_values must contain only finite values.');
    end

    if any(p_values < 0, 'all') || any(p_values > 1, 'all')
        error('analytical_values_experiment_3:InvalidPValuesRange', ...
              'All entries of p_values must satisfy 0 <= p <= 1.');
    end


    % =========================
    % Main computation
    % =========================

    p_values = p_values(:).';
    N = numel(p_values);

    analytics.p_values = p_values;

    analytics.gamma_AB = 1 - (3/2) * p_values + (3/4) * p_values.^2;
    analytics.gamma_A  = 0.5 * ones(size(p_values));
    analytics.gamma_B  = 0.5 * ones(size(p_values));

    analytics.F_psi_plus = 1 - (3/4) * p_values;

    analytics.C = max(0, 1 - (3/2) * p_values);

    analytics.c_xx = 1 - p_values;
    analytics.c_yy = 1 - p_values;
    analytics.c_zz = -(1 - p_values);

    analytics.T = zeros(3, 3, N);

    for k = 1:N
        p = p_values(k);

        analytics.T(:, :, k) = ...
            [ 1-p, 0,   0; ...
              0,   1-p, 0; ...
              0,   0,  -(1-p) ];
    end

end