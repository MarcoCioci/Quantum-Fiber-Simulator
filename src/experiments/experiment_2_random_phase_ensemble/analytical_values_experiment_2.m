function analytics = analytical_values_experiment_2(theta_samples)
% ANALYTICAL_VALUES_EXPERIMENT_2
% Analytical predictions for the random-phase ensemble experiment.
%
% Objective:
%   Return the analytical quantities associated with the ensemble-averaged
%   phase-noise model used in Experiment 2.
%
% Input:
%   theta_samples - real numeric vector containing sampled phase values
%
% Output:
%   analytics - structure containing analytical predictions:
%
%       analytics.mu
%       analytics.mu_real
%       analytics.mu_imag
%       analytics.mu_abs
%
%       analytics.c_xx
%       analytics.c_yy
%       analytics.c_zz
%       analytics.c_xy
%       analytics.c_yx
%
%       analytics.gamma_AB
%       analytics.gamma_A
%       analytics.gamma_B
%
%       analytics.F_psi_plus
%       analytics.C
%
%       analytics.T
%
% Notes:
%   The ensemble coherence parameter is
%
%       μ = <exp(iθ)>
%
%   and determines the transverse correlation structure.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('analytical_values_experiment_2:InvalidNumInputs', ...
              'Expected 1 input argument: theta_samples.');
    end

    if ~isnumeric(theta_samples) || ~isvector(theta_samples) || ~isreal(theta_samples)
        error('analytical_values_experiment_2:InvalidThetaSamples', ...
              'theta_samples must be a real numeric vector.');
    end

    if isempty(theta_samples)
        error('analytical_values_experiment_2:EmptyThetaSamples', ...
              'theta_samples cannot be empty.');
    end

    if any(~isfinite(theta_samples))
        error('analytical_values_experiment_2:NonFiniteThetaSamples', ...
              'theta_samples must contain only finite values.');
    end


    % =========================
    % Main computation
    % =========================

    theta_samples = theta_samples(:).';

    % ---------------------------------
    % Ensemble coherence parameter
    % ---------------------------------

    mu = mean(exp(1i * theta_samples));

    mu_real = real(mu);
    mu_imag = imag(mu);
    mu_abs  = abs(mu);

    analytics.mu      = mu;
    analytics.mu_real = mu_real;
    analytics.mu_imag = mu_imag;
    analytics.mu_abs  = mu_abs;


    % ---------------------------------
    % Correlations
    % ---------------------------------

    analytics.c_xx = mu_real;
    analytics.c_yy = mu_real;
    analytics.c_zz = -1;

    analytics.c_xy = -mu_imag;
    analytics.c_yx =  mu_imag;


    % ---------------------------------
    % State metrics
    % ---------------------------------

    analytics.gamma_AB = (1 + mu_abs^2) / 2;

    analytics.gamma_A = 0.5;
    analytics.gamma_B = 0.5;

    analytics.F_psi_plus = (1 + mu_real) / 2;

    analytics.C = mu_abs;


    % ---------------------------------
    % Correlation tensor
    % ---------------------------------

    analytics.T = ...
        [ mu_real, -mu_imag, 0; ...
          mu_imag,  mu_real, 0; ...
          0,        0,      -1 ];

end