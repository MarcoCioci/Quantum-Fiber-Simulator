function analytics = analytical_values_experiment_4(theta_values, p_values)
% ANALYTICAL_VALUES_EXPERIMENT_4
% Analytical CHSH predictions for Experiment 4.
%
% Objective:
%   Return analytical maximal-CHSH predictions for:
%
%       1. phase-evolved Bell states
%       2. globally depolarized Bell states
%
% Input:
%   theta_values - real numeric vector of phase values
%   p_values     - real numeric vector of depolarization parameters in [0,1]
%
% Output:
%   analytics - structure containing:
%
%       analytics.phase.S_max
%       analytics.phase.S_classical_bound
%       analytics.phase.S_tsirelson_bound
%
%       analytics.depolarization.S_max
%       analytics.depolarization.p_chsh_threshold
%       analytics.depolarization.S_classical_bound
%       analytics.depolarization.S_tsirelson_bound
%
% Notes:
%   Deterministic local phase evolution is unitary and preserves maximal
%   CHSH violation:
%
%       S_max = 2 sqrt(2)
%
%   Global depolarization contracts the Bell-state tensor by (1-p), hence:
%
%       S_max(p) = 2 sqrt(2) (1-p)

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('analytical_values_experiment_4:InvalidNumInputs', ...
              'Expected 2 input arguments: theta_values and p_values.');
    end

    if ~isnumeric(theta_values) || ~isvector(theta_values) || ~isreal(theta_values)
        error('analytical_values_experiment_4:InvalidThetaValues', ...
              'theta_values must be a real numeric vector.');
    end

    if any(~isfinite(theta_values))
        error('analytical_values_experiment_4:NonFiniteThetaValues', ...
              'theta_values must contain only finite values.');
    end

    if ~isnumeric(p_values) || ~isvector(p_values) || ~isreal(p_values)
        error('analytical_values_experiment_4:InvalidPValues', ...
              'p_values must be a real numeric vector.');
    end

    if any(~isfinite(p_values))
        error('analytical_values_experiment_4:NonFinitePValues', ...
              'p_values must contain only finite values.');
    end

    if any(p_values < 0) || any(p_values > 1)
        error('analytical_values_experiment_4:PValuesOutOfRange', ...
              'All p_values entries must satisfy 0 <= p <= 1.');
    end


    % =========================
    % Main computation
    % =========================

    theta_values = theta_values(:).';
    p_values = p_values(:).';

    S_classical_bound = 2;
    S_tsirelson_bound = 2 * sqrt(2);

    analytics.phase.theta_values = theta_values;
    analytics.phase.S_max = S_tsirelson_bound * ones(size(theta_values));
    analytics.phase.S_classical_bound = S_classical_bound;
    analytics.phase.S_tsirelson_bound = S_tsirelson_bound;

    analytics.depolarization.p_values = p_values;
    analytics.depolarization.S_max = S_tsirelson_bound * (1 - p_values);
    analytics.depolarization.p_chsh_threshold = 1 - 1 / sqrt(2);
    analytics.depolarization.S_classical_bound = S_classical_bound;
    analytics.depolarization.S_tsirelson_bound = S_tsirelson_bound;

end