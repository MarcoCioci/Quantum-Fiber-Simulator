function analytics = analytical_values_experiment_5(theta_input, p_A, p_B, mode)
% ANALYTICAL_VALUES_EXPERIMENT_5
% Analytical predictions for the composite fiber-channel experiment.
%
% Objective:
%   Return analytical quantities associated with the composite
%   phase--depolarization model:
%
%       ρ_out =
%       (D_pA ⊗ D_pB)
%       [ U_θ ρ_in U_θ† ]
%
%   Two modes are supported:
%
%       mode = 'pure'
%           theta_input is interpreted as a vector of exact phase
%           values θ.
%
%       mode = 'ensemble'
%           theta_input is interpreted as a vector of phase samples used to
%           construct an ensemble-averaged state.
%
% Input:
%   theta_input - real numeric vector of phase values or phase samples
%   p_A         - depolarization parameter on subsystem A
%   p_B         - depolarization parameter on subsystem B
%   mode        - 'pure' or 'ensemble'
%
% Output:
%   analytics - structure containing analytical predictions.
%
% Notes:
%   The common depolarization contraction factor is
%
%       η = (1-p_A) * (1-p_B)

    % =========================
    % Default input handling
    % =========================

    if nargin < 4 || isempty(mode)
        mode = 'pure';
    end


    % =========================
    % Robustness checks
    % =========================

    if nargin < 3 || nargin > 4
        error('analytical_values_experiment_5:InvalidNumInputs', ...
              'Expected 3 or 4 input arguments: theta_input, p_A, p_B, mode.');
    end

    if ~isnumeric(theta_input) || ~isvector(theta_input) || ~isreal(theta_input)
        error('analytical_values_experiment_5:InvalidThetaInput', ...
              'theta_input must be a real numeric vector.');
    end

    if isempty(theta_input)
        error('analytical_values_experiment_5:EmptyThetaInput', ...
              'theta_input cannot be empty.');
    end

    if any(~isfinite(theta_input))
        error('analytical_values_experiment_5:NonFiniteThetaInput', ...
              'theta_input must contain only finite values.');
    end

    if ~isnumeric(p_A) || ~isscalar(p_A) || ~isreal(p_A) || ~isfinite(p_A)
        error('analytical_values_experiment_5:InvalidParameterA', ...
              'p_A must be a finite real numeric scalar.');
    end

    if ~isnumeric(p_B) || ~isscalar(p_B) || ~isreal(p_B) || ~isfinite(p_B)
        error('analytical_values_experiment_5:InvalidParameterB', ...
              'p_B must be a finite real numeric scalar.');
    end

    if p_A < 0 || p_A > 1
        error('analytical_values_experiment_5:InvalidRangeA', ...
              'p_A must satisfy 0 <= p_A <= 1.');
    end

    if p_B < 0 || p_B > 1
        error('analytical_values_experiment_5:InvalidRangeB', ...
              'p_B must satisfy 0 <= p_B <= 1.');
    end

    if ~(ischar(mode) || isstring(mode))
        error('analytical_values_experiment_5:InvalidModeType', ...
              'mode must be either ''pure'' or ''ensemble''.');
    end

    mode = lower(string(mode));

    if mode ~= "pure" && mode ~= "ensemble"
        error('analytical_values_experiment_5:InvalidModeValue', ...
              'mode must be either ''pure'' or ''ensemble''.');
    end


    % =========================compute_fidelity
    % Common initialization
    % =========================

    theta_input = theta_input(:).';

    analytics = struct();

    analytics.mode = char(mode);
    analytics.p_A = p_A;
    analytics.p_B = p_B;
    analytics.eta = (1 - p_A) * (1 - p_B);

    eta = analytics.eta;


    % =========================
    % Mode-specific computation
    % =========================

    switch mode

        case "pure"

            N = numel(theta_input);

            analytics.theta_values = theta_input;

            analytics.correlation_tensor = zeros(3, 3, N);

            analytics.c_xx = zeros(1, N);
            analytics.c_yy = zeros(1, N);
            analytics.c_zz = zeros(1, N);
            analytics.c_xy = zeros(1, N);
            analytics.c_yx = zeros(1, N);

            analytics.purity_global = ...
                ((1 + 3 * eta^2) / 4) * ones(1, N);

            analytics.purity_A = 0.5 * ones(1, N);
            analytics.purity_B = 0.5 * ones(1, N);

            analytics.fidelity_psi_plus = zeros(1, N);

            analytics.concurrence = ...
                max(0, (3 * eta - 1) / 2) * ones(1, N);

            analytics.S_max = ...
                2 * sqrt(2) * eta * ones(1, N);

            for idx = 1:N

                theta = theta_input(idx);

                T = eta * ...
                    [ cos(theta), -sin(theta), 0; ...
                      sin(theta),  cos(theta), 0; ...
                      0,           0,         -1 ];

                analytics.correlation_tensor(:, :, idx) = T;

                analytics.c_xx(idx) = T(1, 1);
                analytics.c_yy(idx) = T(2, 2);
                analytics.c_zz(idx) = T(3, 3);
                analytics.c_xy(idx) = T(1, 2);
                analytics.c_yx(idx) = T(2, 1);

                analytics.fidelity_psi_plus(idx) = ...
                    (1 - eta) / 4 + eta * (1 + cos(theta)) / 2;

            end


        case "ensemble"

            theta_samples = theta_input;

            mu = mean(exp(1i * theta_samples));

            analytics.theta_samples = theta_samples;

            analytics.mu = mu;
            analytics.mu_real = real(mu);
            analytics.mu_imag = imag(mu);
            analytics.mu_abs = abs(mu);

            analytics.correlation_tensor = eta * ...
                [ analytics.mu_real, -analytics.mu_imag, 0; ...
                  analytics.mu_imag,  analytics.mu_real, 0; ...
                  0,                  0,                 -1 ];

            analytics.c_xx = analytics.correlation_tensor(1, 1);
            analytics.c_yy = analytics.correlation_tensor(2, 2);
            analytics.c_zz = analytics.correlation_tensor(3, 3);
            analytics.c_xy = analytics.correlation_tensor(1, 2);
            analytics.c_yx = analytics.correlation_tensor(2, 1);

            analytics.purity_global = ...
                (1 + eta^2 * (1 + 2 * analytics.mu_abs^2)) / 4;

            analytics.purity_A = 0.5;
            analytics.purity_B = 0.5;

            analytics.fidelity_psi_plus = ...
                (1 - eta) / 4 ...
                + eta * (1 + analytics.mu_real) / 2;

            analytics.concurrence = ...
                max(0, eta * analytics.mu_abs - (1 - eta) / 2);

            analytics.S_max = ...
                2 * eta * sqrt(1 + analytics.mu_abs^2);

    end

end