function analytics = ...
        analytical_values_experiment_5_pmd_compensation_robustness( ...
            dgd_A, dgd_values_B, sigma_sum, sigma_difference)
% ANALYTICAL_VALUES_EXPERIMENT_5_PMD_COMPENSATION_ROBUSTNESS
% Return the continuous-Gaussian benchmark for aligned PMD compensation.
%
% Objective:
%   Evaluate the analytical polarization-coherence factor for the aligned
%   configuration used as the reference section of Experiment 5.
%
%   The PMD axes are
%
%       n_A = +z,
%       n_B = -z.
%
%   For |Psi+>, the relative spectral phase is
%
%       Phi = Omega_A tau_A + Omega_B tau_B.
%
%   If (Omega_A, Omega_B) are jointly Gaussian with zero mean, then
%
%       R = <exp(i Phi)>
%         = exp[-Var(Phi) / 2].
%
%   With equal marginal variance sigma_omega^2 and covariance sigma_AB,
%
%       Var(Phi)
%       =
%       sigma_omega^2 tau_A^2
%       + sigma_omega^2 tau_B^2
%       + 2 sigma_AB tau_A tau_B.
%
%   The corresponding reduced polarization state has
%
%       C        = R,
%       purity   = (1 + R^2) / 2,
%       F_Psi+   = (1 + R) / 2,
%       S_max    = 2 sqrt(1 + R^2).
%
% Input:
%   dgd_A           - Fixed arm-A DGD tau_A [s].
%   dgd_values_B    - Vector of arm-B DGD values tau_B [s].
%   sigma_sum       - Gaussian width along Omega_A + Omega_B [rad/s].
%   sigma_difference - Gaussian width along Omega_A - Omega_B [rad/s].
%
% Output:
%   analytics - Structure containing:
%       .sigma_omega
%       .covariance_AB
%       .correlation_AB
%       .dgd_B_optimal
%       .phase_variance
%       .coherence
%       .concurrence
%       .purity
%       .fidelity
%       .chsh_max
%
% Notes:
%   The optimum is obtained by minimizing Var(Phi) with respect to tau_B:
%
%       tau_B,opt = -(sigma_AB / sigma_omega^2) tau_A
%                 = -r tau_A.
%
%   This benchmark is valid for the aligned-axis section alpha = 0.
%   It is not used as an analytical model for arbitrary axis misalignment.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 4
        error( ...
            ['analytical_values_experiment_5_pmd_compensation_robustness:', ...
             'InvalidNumInputs'], ...
            ['Expected exactly 4 input arguments: dgd_A, dgd_values_B, ', ...
             'sigma_sum, sigma_difference.']);
    end

    if ~isnumeric(dgd_A) || ...
            ~isscalar(dgd_A) || ...
            ~isreal(dgd_A) || ...
            ~isfinite(dgd_A) || ...
            dgd_A < 0
        error( ...
            ['analytical_values_experiment_5_pmd_compensation_robustness:', ...
             'InvalidDGDA'], ...
            'dgd_A must be a finite non-negative real scalar.');
    end

    if ~isnumeric(dgd_values_B) || ...
            ~isreal(dgd_values_B) || ...
            ~isvector(dgd_values_B) || ...
            isempty(dgd_values_B)
        error( ...
            ['analytical_values_experiment_5_pmd_compensation_robustness:', ...
             'InvalidDGDB'], ...
            'dgd_values_B must be a non-empty real numeric vector.');
    end

    if any(~isfinite(dgd_values_B), 'all') || ...
            any(dgd_values_B < 0, 'all')
        error( ...
            ['analytical_values_experiment_5_pmd_compensation_robustness:', ...
             'InvalidDGDBValues'], ...
            'dgd_values_B must contain finite non-negative values.');
    end

    if ~isnumeric(sigma_sum) || ...
            ~isscalar(sigma_sum) || ...
            ~isreal(sigma_sum) || ...
            ~isfinite(sigma_sum) || ...
            sigma_sum <= 0
        error( ...
            ['analytical_values_experiment_5_pmd_compensation_robustness:', ...
             'InvalidSigmaSum'], ...
            'sigma_sum must be a positive finite real scalar.');
    end

    if ~isnumeric(sigma_difference) || ...
            ~isscalar(sigma_difference) || ...
            ~isreal(sigma_difference) || ...
            ~isfinite(sigma_difference) || ...
            sigma_difference <= 0
        error( ...
            ['analytical_values_experiment_5_pmd_compensation_robustness:', ...
             'InvalidSigmaDifference'], ...
            'sigma_difference must be a positive finite real scalar.');
    end


    % =========================
    % Gaussian spectral moments
    % =========================

    dgd_values_B = ...
        dgd_values_B(:).';

    sigma_omega = ...
        sqrt((sigma_sum^2 + sigma_difference^2) / 4);

    covariance_AB = ...
        (sigma_sum^2 - sigma_difference^2) / 4;

    correlation_AB = ...
        covariance_AB / sigma_omega^2;


    % =========================
    % Optimal compensation DGD
    % =========================

    dgd_B_optimal_unconstrained = ...
        -correlation_AB * dgd_A;

    dgd_B_optimal = ...
        max(0, dgd_B_optimal_unconstrained);


    % =========================
    % Coherence factor
    % =========================

    phase_variance = ...
        sigma_omega^2 * dgd_A^2 + ...
        sigma_omega^2 * dgd_values_B.^2 + ...
        2 * covariance_AB * dgd_A .* dgd_values_B;

    % Remove negative roundoff at the level of machine precision.
    phase_variance = ...
        max(real(phase_variance), 0);

    coherence = ...
        exp(-0.5 * phase_variance);


    % =========================
    % State metrics
    % =========================

    concurrence = ...
        coherence;

    purity = ...
        0.5 * (1 + coherence.^2);

    fidelity = ...
        0.5 * (1 + coherence);

    chsh_max = ...
        2 * sqrt(1 + coherence.^2);


    % =========================
    % Output
    % =========================

    analytics = struct();

    analytics.sigma_omega = ...
        sigma_omega;

    analytics.covariance_AB = ...
        covariance_AB;

    analytics.correlation_AB = ...
        correlation_AB;

    analytics.dgd_B_optimal = ...
        dgd_B_optimal;

    analytics.phase_variance = ...
        phase_variance;

    analytics.coherence = ...
        coherence;

    analytics.concurrence = ...
        concurrence;

    analytics.purity = ...
        purity;

    analytics.fidelity = ...
        fidelity;

    analytics.chsh_max = ...
        chsh_max;

end
