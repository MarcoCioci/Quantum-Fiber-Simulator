function analytics = ...
        analytical_values_experiment_2_two_arm_pmd_spectral_correlations( ...
            dgd_values, sigma_omega, correlation_values)
% ANALYTICAL_VALUES_EXPERIMENT_2_TWO_ARM_PMD_SPECTRAL_CORRELATIONS
% Analytical predictions for two-arm PMD with correlated Gaussian spectra.
%
% Objective:
%   Compute the continuous-spectrum analytical benchmark for the propagation
%   of the Bell state |Ψ+⟩ through two frequency-dependent PMD segments.
%
%   The input polarization state is
%
%       |Ψ+⟩ = (|01⟩ + |10⟩) / sqrt(2).
%
%   Both photons experience the same physical differential group delay
%
%       τ_A = τ_B = τ,
%
%   while the PMD axes are chosen as
%
%       n_A = +z_hat,
%       n_B = -z_hat.
%
%   The two-photon angular-frequency offsets Ω_A and Ω_B are assumed to
%   follow a zero-mean symmetric Gaussian joint spectral intensity with
%
%       Var(Ω_A) = Var(Ω_B) = σ_ω^2
%
%   and spectral correlation coefficient
%
%       r = Cov(Ω_A, Ω_B) / σ_ω^2.
%
%   The corresponding widths along the sum and difference spectral
%   coordinates are
%
%       σ_sum^2        = 2 σ_ω^2 (1 + r),
%       σ_difference^2 = 2 σ_ω^2 (1 - r).
%
%   For the chosen opposite PMD axes, the frequency-dependent relative
%   phase between the two Bell-state components is proportional to
%
%       θ = τ (Ω_A + Ω_B).
%
%   Therefore
%
%       Var(θ)
%       =
%       2 σ_ω^2 τ^2 (1 + r),
%
%   and the polarization coherence remaining after tracing over frequency is
%
%       g(τ,r)
%       =
%       ⟨exp(iθ)⟩
%       =
%       exp[-σ_ω^2 τ^2 (1 + r)].
%
%   Introducing the dimensionless PMD strength
%
%       ξ = σ_ω τ,
%
%   this becomes
%
%       g(ξ,r) = exp[-(1+r) ξ^2].
%
%   The reduced polarization density operator is consequently
%
%                 [ 0    0      0    0 ]
%                 [ 0   1/2    g/2   0 ]
%       ρ_AB =    [ 0   g/2    1/2   0 ].
%                 [ 0    0      0    0 ]
%
%   From this state, the analytical purity, fidelity, concurrence, tangle,
%   entanglement of formation, maximal CHSH value, and correlation tensor
%   are evaluated.
%
% Input:
%   dgd_values         - Non-empty vector of common physical DGD values
%                        τ = τ_A = τ_B [s].
%
%                        Values must be finite and non-negative.
%
%   sigma_omega        - Positive finite scalar containing the marginal
%                        angular-frequency standard deviation σ_ω [rad/s]
%                        of each photon.
%
%   correlation_values - Non-empty vector of spectral correlation
%                        coefficients r.
%
%                        Each value must satisfy
%
%                            -1 < r < 1.
%
%                        The limiting values r = +/-1 are excluded because
%                        one of the Gaussian sum/difference widths becomes
%                        exactly zero and cannot be represented by the
%                        numerical JSI used in the experiment runner.
%
% Output:
%   analytics - Structure containing the analytical predictions:
%
%       analytics.dgd_values
%       analytics.sigma_omega
%       analytics.correlation_values
%
%       analytics.sigma_sum_values
%       analytics.sigma_difference_values
%
%       analytics.normalized_pmd_strength
%       analytics.phase_variance
%       analytics.coherence
%
%       analytics.rho_output
%
%       analytics.purity
%       analytics.purity_A
%       analytics.purity_B
%       analytics.fidelity
%       analytics.concurrence
%       analytics.tangle
%       analytics.entanglement_of_formation
%       analytics.chsh_max
%
%       analytics.correlation_tensor
%
%       analytics.correlations.xx
%       analytics.correlations.yy
%       analytics.correlations.zz
%
% Notes:
%   The returned scalar metric maps have dimensions
%
%       N_r x N_DGD,
%
%   where N_r is the number of spectral-correlation values and N_DGD is the
%   number of common DGD values.
%
%   The analytical density operators have dimensions
%
%       4 x 4 x N_r x N_DGD,
%
%   while the analytical correlation tensors have dimensions
%
%       3 x 3 x N_r x N_DGD.
%
%   For r = 0, the two photon frequencies are uncorrelated and
%
%       g = exp(-ξ^2).
%
%   For r -> -1, the spectrum becomes increasingly anticorrelated and
%
%       g -> 1,
%
%   showing the nonlocal compensation of the two PMD contributions.
%
%   For r -> +1, the two frequencies become increasingly correlated and
%   the PMD-induced loss of polarization coherence is enhanced.


    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error( ...
            ['analytical_values_experiment_2_', ...
             'two_arm_pmd_spectral_correlations:InvalidNumInputs'], ...
            ['Expected exactly 3 input arguments: dgd_values, ', ...
             'sigma_omega, correlation_values.']);
    end

    if ~isnumeric(dgd_values) || ...
            ~isreal(dgd_values) || ...
            ~isvector(dgd_values) || ...
            isempty(dgd_values)
        error( ...
            ['analytical_values_experiment_2_', ...
             'two_arm_pmd_spectral_correlations:InvalidDGDValues'], ...
            'dgd_values must be a non-empty real numeric vector.');
    end

    if any(~isfinite(dgd_values), 'all')
        error( ...
            ['analytical_values_experiment_2_', ...
             'two_arm_pmd_spectral_correlations:InvalidDGDValues'], ...
            'dgd_values must contain only finite values.');
    end

    if any(dgd_values < 0, 'all')
        error( ...
            ['analytical_values_experiment_2_', ...
             'two_arm_pmd_spectral_correlations:NegativeDGD'], ...
            'dgd_values must contain only non-negative values.');
    end

    if ~isnumeric(sigma_omega) || ...
            ~isscalar(sigma_omega) || ...
            ~isreal(sigma_omega) || ...
            ~isfinite(sigma_omega)
        error( ...
            ['analytical_values_experiment_2_', ...
             'two_arm_pmd_spectral_correlations:InvalidSigmaOmega'], ...
            'sigma_omega must be a finite real numeric scalar.');
    end

    if sigma_omega <= 0
        error( ...
            ['analytical_values_experiment_2_', ...
             'two_arm_pmd_spectral_correlations:InvalidSigmaOmegaRange'], ...
            'sigma_omega must satisfy sigma_omega > 0.');
    end

    if ~isnumeric(correlation_values) || ...
            ~isreal(correlation_values) || ...
            ~isvector(correlation_values) || ...
            isempty(correlation_values)
        error( ...
            ['analytical_values_experiment_2_', ...
             'two_arm_pmd_spectral_correlations:', ...
             'InvalidCorrelationValues'], ...
            ['correlation_values must be a non-empty real numeric ', ...
             'vector.']);
    end

    if any(~isfinite(correlation_values), 'all')
        error( ...
            ['analytical_values_experiment_2_', ...
             'two_arm_pmd_spectral_correlations:', ...
             'InvalidCorrelationValues'], ...
            'correlation_values must contain only finite values.');
    end

    if any(correlation_values <= -1, 'all') || ...
            any(correlation_values >= 1, 'all')
        error( ...
            ['analytical_values_experiment_2_', ...
             'two_arm_pmd_spectral_correlations:', ...
             'InvalidCorrelationRange'], ...
            'correlation_values must satisfy -1 < r < 1.');
    end


    % =========================
    % Input normalization
    % =========================

    % DGD values define the horizontal dimension of all analytical maps.
    dgd_values = dgd_values(:).';

    % Spectral-correlation values define the vertical dimension.
    correlation_values = correlation_values(:);

    num_dgd_values = numel(dgd_values);
    num_correlation_values = numel(correlation_values);


    % =========================
    % Spectral parameters
    % =========================

    % For equal marginal standard deviations sigma_omega,
    %
    %   Var(Omega_A + Omega_B)
    %       = 2 sigma_omega^2 (1 + r),
    %
    %   Var(Omega_A - Omega_B)
    %       = 2 sigma_omega^2 (1 - r).
    %
    % The corresponding standard deviations are therefore:

    sigma_sum_values = ...
        sqrt(2) * sigma_omega .* sqrt(1 + correlation_values);

    sigma_difference_values = ...
        sqrt(2) * sigma_omega .* sqrt(1 - correlation_values);


    % =========================
    % Dimensionless PMD strength
    % =========================

    normalized_pmd_strength = ...
        sigma_omega * dgd_values;


    % =========================
    % Effective phase variance
    % =========================

    % With tau_A = tau_B = tau and opposite PMD axes, the Bell-state
    % relative phase is
    %
    %   theta = tau (Omega_A + Omega_B).
    %
    % Hence
    %
    %   Var(theta)
    %       = 2 (1+r) (sigma_omega tau)^2
    %       = 2 (1+r) xi^2.
    %
    % correlation_values is N_r x 1 and normalized_pmd_strength is
    % 1 x N_DGD, so implicit expansion constructs the N_r x N_DGD map.

    phase_variance = ...
        2 * (1 + correlation_values) .* ...
        normalized_pmd_strength.^2;


    % =========================
    % Polarization coherence
    % =========================

    % The characteristic function of a zero-mean Gaussian variable gives
    %
    %   <exp(i theta)> = exp[-Var(theta)/2].

    coherence = ...
        exp(-0.5 * phase_variance);


    % =========================
    % Analytical density matrix
    % =========================

    rho_output = complex(zeros( ...
        4, 4, num_correlation_values, num_dgd_values));

    for i_correlation = 1:num_correlation_values

        for i_dgd = 1:num_dgd_values

            g = coherence(i_correlation, i_dgd);

            rho_output(:, :, i_correlation, i_dgd) = ...
                [ ...
                    0,   0,       0,   0; ...
                    0, 1/2,     g/2,   0; ...
                    0, g/2,     1/2,   0; ...
                    0,   0,       0,   0 ...
                ];

        end

    end


    % =========================
    % Purity
    % =========================

    % The eigenvalues of the non-zero 2x2 block are
    %
    %   lambda_+ = (1+g)/2,
    %   lambda_- = (1-g)/2.
    %
    % Therefore
    %
    %   gamma_AB = Tr(rho_AB^2) = (1+g^2)/2.

    purity = ...
        (1 + coherence.^2) / 2;

    % The reduced states remain maximally mixed for every value of g:
    %
    %   rho_A = rho_B = I_2 / 2.

    purity_A = ...
        0.5 * ones(num_correlation_values, num_dgd_values);

    purity_B = ...
        0.5 * ones(num_correlation_values, num_dgd_values);


    % =========================
    % Bell-state fidelity
    % =========================

    % Fidelity with respect to the original |Psi+> state is
    %
    %   F_Psi+ = (1+g)/2.

    fidelity = ...
        (1 + coherence) / 2;


    % =========================
    % Concurrence and tangle
    % =========================

    % For this Bell-dephased X-state,
    %
    %   C = g.

    concurrence = ...
        coherence;

    tangle = ...
        concurrence.^2;


    % =========================
    % Entanglement of formation
    % =========================

    % For two qubits,
    %
    %   E_F(C)
    %   =
    %   h_2[
    %       (1 + sqrt(1-C^2)) / 2
    %   ],
    %
    % where h_2 is the binary entropy.

    eof_probability = ...
        (1 + sqrt(max(0, 1 - concurrence.^2))) / 2;

    eof_complement = ...
        1 - eof_probability;

    entanglement_of_formation = ...
        zeros(size(eof_probability));

    nonzero_probability = ...
        eof_probability > 0;

    nonzero_complement = ...
        eof_complement > 0;

    entanglement_of_formation(nonzero_probability) = ...
        entanglement_of_formation(nonzero_probability) ...
        - eof_probability(nonzero_probability) .* ...
        log2(eof_probability(nonzero_probability));

    entanglement_of_formation(nonzero_complement) = ...
        entanglement_of_formation(nonzero_complement) ...
        - eof_complement(nonzero_complement) .* ...
        log2(eof_complement(nonzero_complement));


    % =========================
    % Correlation tensor
    % =========================

    % For the averaged state,
    %
    %           [ g   0   0 ]
    %   T   =   [ 0   g   0 ].
    %           [ 0   0  -1 ]
    %
    % Therefore the transverse correlations decay with the residual
    % spectral coherence while the longitudinal anticorrelation remains
    % ideal.

    correlation_tensor = zeros( ...
        3, 3, num_correlation_values, num_dgd_values);

    for i_correlation = 1:num_correlation_values

        for i_dgd = 1:num_dgd_values

            g = coherence(i_correlation, i_dgd);

            correlation_tensor(:, :, i_correlation, i_dgd) = ...
                [ ...
                    g, 0,  0; ...
                    0, g,  0; ...
                    0, 0, -1 ...
                ];

        end

    end

    correlation_xx = ...
        coherence;

    correlation_yy = ...
        coherence;

    correlation_zz = ...
        -ones(num_correlation_values, num_dgd_values);


    % =========================
    % Maximal CHSH value
    % =========================

    % The eigenvalues of T^T T are
    %
    %   {g^2, g^2, 1}.
    %
    % Since 0 <= g <= 1, the two largest are 1 and g^2. Therefore,
    %
    %   S_max = 2 sqrt(1 + g^2).

    chsh_max = ...
        2 * sqrt(1 + coherence.^2);


    % =========================
    % Output structure
    % =========================

    analytics = struct();


    % -------------------------
    % Parameters
    % -------------------------

    analytics.dgd_values = ...
        dgd_values;

    analytics.sigma_omega = ...
        sigma_omega;

    analytics.correlation_values = ...
        correlation_values;

    analytics.sigma_sum_values = ...
        sigma_sum_values;

    analytics.sigma_difference_values = ...
        sigma_difference_values;

    analytics.normalized_pmd_strength = ...
        normalized_pmd_strength;


    % -------------------------
    % PMD coherence quantities
    % -------------------------

    analytics.phase_variance = ...
        phase_variance;

    analytics.coherence = ...
        coherence;


    % -------------------------
    % Density operators
    % -------------------------

    analytics.rho_output = ...
        rho_output;


    % -------------------------
    % State metrics
    % -------------------------

    analytics.purity = ...
        purity;

    analytics.purity_A = ...
        purity_A;

    analytics.purity_B = ...
        purity_B;

    analytics.fidelity = ...
        fidelity;

    analytics.concurrence = ...
        concurrence;

    analytics.tangle = ...
        tangle;

    analytics.entanglement_of_formation = ...
        entanglement_of_formation;

    analytics.chsh_max = ...
        chsh_max;


    % -------------------------
    % Correlation observables
    % -------------------------

    analytics.correlation_tensor = ...
        correlation_tensor;

    analytics.correlations = struct();

    analytics.correlations.xx = ...
        correlation_xx;

    analytics.correlations.yy = ...
        correlation_yy;

    analytics.correlations.zz = ...
        correlation_zz;

end