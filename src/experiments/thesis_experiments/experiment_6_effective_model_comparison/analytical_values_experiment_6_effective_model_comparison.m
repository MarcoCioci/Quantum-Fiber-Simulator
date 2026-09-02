function analytics = ...
        analytical_values_experiment_6_effective_model_comparison( ...
            xi_values, dgd_values, sigma_omega, concurrence_threshold)
% ANALYTICAL_VALUES_EXPERIMENT_6_EFFECTIVE_MODEL_COMPARISON
% Analytical predictions for the physical/effective PMD comparison.
%
% Objective:
%   Construct closed-form predictions for:
%
%       1) canonical one-arm Gaussian PMD,
%       2) the exactly coherence-matched dephasing model,
%       3) an isotropic local-depolarizing model calibrated to the same
%          transverse correlation-survival factor.
%
%   The physical PMD coherence is
%
%       g(ξ) = exp(-ξ^2/2),
%
%   with ξ = σ_ω τ.
%
%   For physical PMD and matched dephasing:
%
%       C       = g,
%       γ       = (1 + g^2)/2,
%       F       = (1 + g)/2,
%       S_max   = 2 sqrt(1 + g^2),
%       T       = diag(g, g, -1).
%
%   The isotropic local-depolarizing model is calibrated through
%
%       η = (1-p_A)(1-p_B) = g,
%
%   using p_A = p_B = 1-sqrt(g). For the Bell-state input this gives
%
%       C       = max[0, (3g-1)/2],
%       γ       = (1 + 3g^2)/4,
%       F       = (1 + 3g)/4,
%       S_max   = 2 sqrt(2) g,
%       T       = diag(g, g, -g).
%
% Input:
%   xi_values              - Dimensionless PMD strengths ξ >= 0
%   dgd_values             - Physical DGD values [s]
%   sigma_omega            - Marginal angular-frequency standard deviation
%                            [rad/s]
%   concurrence_threshold  - Operational threshold C_th with 0 < C_th < 1
%
% Output:
%   analytics - Structure containing coherence, model predictions, and
%               analytical concurrence-quality threshold crossings
%
% Notes:
%   The concurrence threshold is an operational quality criterion. It must
%   not be confused with the exact entanglement/separability boundary C=0.


    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 4
        error( ...
            ['analytical_values_experiment_6_effective_model_comparison:', ...
             'InvalidNumInputs'], ...
            ['Expected 4 inputs: xi_values, dgd_values, sigma_omega, ', ...
             'concurrence_threshold.']);
    end

    if ~isnumeric(xi_values) || ~isreal(xi_values) || ...
            isempty(xi_values) || any(~isfinite(xi_values), 'all')
        error( ...
            ['analytical_values_experiment_6_effective_model_comparison:', ...
             'InvalidXiValues'], ...
            'xi_values must contain finite real numeric values.');
    end

    if any(xi_values < 0, 'all')
        error( ...
            ['analytical_values_experiment_6_effective_model_comparison:', ...
             'NegativeXiValues'], ...
            'xi_values must be non-negative.');
    end

    if ~isnumeric(dgd_values) || ~isreal(dgd_values) || ...
            isempty(dgd_values) || any(~isfinite(dgd_values), 'all')
        error( ...
            ['analytical_values_experiment_6_effective_model_comparison:', ...
             'InvalidDGDValues'], ...
            'dgd_values must contain finite real numeric values.');
    end

    if any(dgd_values < 0, 'all')
        error( ...
            ['analytical_values_experiment_6_effective_model_comparison:', ...
             'NegativeDGDValues'], ...
            'dgd_values must be non-negative.');
    end

    if numel(xi_values) ~= numel(dgd_values)
        error( ...
            ['analytical_values_experiment_6_effective_model_comparison:', ...
             'InconsistentGridSizes'], ...
            'xi_values and dgd_values must contain the same number of points.');
    end

    if ~isnumeric(sigma_omega) || ~isscalar(sigma_omega) || ...
            ~isreal(sigma_omega) || ~isfinite(sigma_omega) || ...
            sigma_omega <= 0
        error( ...
            ['analytical_values_experiment_6_effective_model_comparison:', ...
             'InvalidSigmaOmega'], ...
            'sigma_omega must be a positive finite real scalar.');
    end

    if ~isnumeric(concurrence_threshold) || ...
            ~isscalar(concurrence_threshold) || ...
            ~isreal(concurrence_threshold) || ...
            ~isfinite(concurrence_threshold) || ...
            concurrence_threshold <= 0 || ...
            concurrence_threshold >= 1
        error( ...
            ['analytical_values_experiment_6_effective_model_comparison:', ...
             'InvalidConcurrenceThreshold'], ...
            'concurrence_threshold must satisfy 0 < C_th < 1.');
    end


    % =========================
    % Normalization
    % =========================

    xi_values = ...
        xi_values(:).';

    dgd_values = ...
        dgd_values(:).';


    % =========================
    % Gaussian PMD coherence
    % =========================

    coherence = ...
        exp(-0.5 * xi_values.^2);


    % =========================
    % Physical PMD
    % =========================

    physical_pmd = struct();

    physical_pmd.purity = ...
        (1 + coherence.^2) / 2;

    physical_pmd.fidelity = ...
        (1 + coherence) / 2;

    physical_pmd.concurrence = ...
        coherence;

    physical_pmd.tangle = ...
        coherence.^2;

    physical_pmd.entanglement_of_formation = ...
        eof_from_concurrence(coherence);

    physical_pmd.chsh_max = ...
        2 * sqrt(1 + coherence.^2);

    physical_pmd.c_xx = ...
        coherence;

    physical_pmd.c_yy = ...
        coherence;

    physical_pmd.c_zz = ...
        -ones(size(coherence));


    % =========================
    % Matched effective dephasing
    % =========================

    effective_dephasing = ...
        physical_pmd;


    % =========================
    % Matched isotropic depolarization
    % =========================

    p_symmetric = ...
        1 - sqrt(coherence);

    effective_depolarizing = struct();

    effective_depolarizing.p_symmetric = ...
        p_symmetric;

    effective_depolarizing.eta = ...
        coherence;

    effective_depolarizing.purity = ...
        (1 + 3 * coherence.^2) / 4;

    effective_depolarizing.fidelity = ...
        (1 + 3 * coherence) / 4;

    effective_depolarizing.concurrence = ...
        max( ...
            0, ...
            (3 * coherence - 1) / 2);

    effective_depolarizing.tangle = ...
        effective_depolarizing.concurrence.^2;

    effective_depolarizing.entanglement_of_formation = ...
        eof_from_concurrence( ...
            effective_depolarizing.concurrence);

    effective_depolarizing.chsh_max = ...
        2 * sqrt(2) * coherence;

    effective_depolarizing.c_xx = ...
        coherence;

    effective_depolarizing.c_yy = ...
        coherence;

    effective_depolarizing.c_zz = ...
        -coherence;


    % =========================
    % Concurrence-quality thresholds
    % =========================

    thresholds = struct();

    % Physical PMD / dephasing:
    %
    %   exp(-xi^2/2) = C_th.

    thresholds.xi_physical = ...
        sqrt( ...
            -2 * log(concurrence_threshold));

    thresholds.xi_dephasing = ...
        thresholds.xi_physical;

    thresholds.dgd_physical = ...
        thresholds.xi_physical / sigma_omega;

    thresholds.dgd_dephasing = ...
        thresholds.dgd_physical;

    % Isotropic depolarization:
    %
    %   (3g - 1)/2 = C_th
    %
    %   -> g = (2 C_th + 1)/3.

    coherence_threshold_depolarizing = ...
        (2 * concurrence_threshold + 1) / 3;

    thresholds.xi_depolarizing = ...
        sqrt( ...
            -2 * log(coherence_threshold_depolarizing));

    thresholds.dgd_depolarizing = ...
        thresholds.xi_depolarizing / sigma_omega;

    % Isotropic depolarization becomes separable when
    %
    %   (3g - 1)/2 = 0  ->  g = 1/3.

    thresholds.xi_entanglement_death_depolarizing = ...
        sqrt(2 * log(3));

    thresholds.dgd_entanglement_death_depolarizing = ...
        thresholds.xi_entanglement_death_depolarizing ...
        / sigma_omega;


    % =========================
    % Output structure
    % =========================

    analytics = struct();

    analytics.xi_values = ...
        xi_values;

    analytics.dgd_values = ...
        dgd_values;

    analytics.sigma_omega = ...
        sigma_omega;

    analytics.concurrence_threshold = ...
        concurrence_threshold;

    analytics.coherence = ...
        coherence;

    analytics.physical_pmd = ...
        physical_pmd;

    analytics.effective_dephasing = ...
        effective_dephasing;

    analytics.effective_depolarizing = ...
        effective_depolarizing;

    analytics.thresholds = ...
        thresholds;

end


% ========================================================
% Local helper: entanglement of formation
% ========================================================

function eof = eof_from_concurrence(concurrence)
% EOF_FROM_CONCURRENCE  Evaluate two-qubit entanglement of formation.

    concurrence = ...
        min(max(concurrence, 0), 1);

    argument = ...
        (1 + sqrt(max(0, 1 - concurrence.^2))) / 2;

    eof = ...
        zeros(size(argument));

    positive_mask = ...
        argument > 0 & argument < 1;

    eof(positive_mask) = ...
        -argument(positive_mask) ...
            .* log2(argument(positive_mask)) ...
        -(1 - argument(positive_mask)) ...
            .* log2(1 - argument(positive_mask));

end
