function spectral_weights = pmd_joint_spectral_weights( ...
        omega_offsets_A, omega_offsets_B, ...
        sigma_sum, sigma_difference)
% PMD_JOINT_SPECTRAL_WEIGHTS  Construct normalized Gaussian two-photon
%                             joint spectral weights.
%
% Objective:
%   Construct a Gaussian joint spectral intensity (JSI) on the discrete
%   angular-frequency-offset grids of photons A and B:
%
%       J(Ω_A, Ω_B) ∝
%       exp[
%           -(Ω_A + Ω_B)^2 / (2 σ_Σ^2)
%           -(Ω_A - Ω_B)^2 / (2 σ_Δ^2)
%       ].
%
%   The continuous JSI is converted into normalized discrete probabilities
%   using quadrature weights:
%
%       Q(k,l) =
%       a_k b_l J(Ω_A,k, Ω_B,l)
%       ----------------------------------- ,
%       Σ_k' Σ_l' a_k' b_l' J(Ω_A,k', Ω_B,l')
%
%   so that
%
%       Q(k,l) >= 0,
%       Σ_k Σ_l Q(k,l) = 1.
%
% Input:
%   omega_offsets_A - Non-empty vector of angular-frequency offsets
%
%                         Ω_A = ω_A - ω_0,A
%
%                     for photon A [rad/s].
%
%   omega_offsets_B - Non-empty vector of angular-frequency offsets
%
%                         Ω_B = ω_B - ω_0,B
%
%                     for photon B [rad/s].
%
%   sigma_sum       - Standard deviation σ_Σ of the sum-frequency-offset
%                     variable
%
%                         Ω_A + Ω_B
%
%                     [rad/s]. Positive finite real numeric scalar.
%
%   sigma_difference - Standard deviation σ_Δ of the
%                      difference-frequency-offset variable
%
%                          Ω_A - Ω_B
%
%                      [rad/s]. Positive finite real numeric scalar.
%
% Output:
%   spectral_weights - N_A-by-N_B real non-negative matrix containing the
%                      normalized discrete joint spectral probabilities
%                      Q(k,l).
%
% Notes:
%   Row k corresponds to omega_offsets_A(k), while column l corresponds to
%   omega_offsets_B(l).
%
%   The Gaussian model describes the joint spectral intensity J = |F|^2,
%   rather than the joint spectral amplitude F itself.
%
%   The corresponding spectral correlation coefficient is
%
%       r =
%       (sigma_sum^2 - sigma_difference^2) /
%       (sigma_sum^2 + sigma_difference^2).
%
%   Consequently:
%
%       sigma_sum < sigma_difference  -> spectral anticorrelation,
%       sigma_sum = sigma_difference  -> uncorrelated Gaussian spectrum,
%       sigma_sum > sigma_difference  -> positive spectral correlation.
%
%   Composite-trapezoidal quadrature weights are constructed directly from
%   the supplied frequency grids before normalization.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 4
        error('pmd_joint_spectral_weights:InvalidNumInputs', ...
            ['Expected exactly 4 input arguments: omega_offsets_A, ', ...
             'omega_offsets_B, sigma_sum, sigma_difference.']);
    end

    if ~isnumeric(omega_offsets_A) || ~isreal(omega_offsets_A) || ...
            ~isvector(omega_offsets_A) || isempty(omega_offsets_A)
        error('pmd_joint_spectral_weights:InvalidOmegaOffsetsA', ...
            'omega_offsets_A must be a non-empty real numeric vector.');
    end

    if any(~isfinite(omega_offsets_A), 'all')
        error('pmd_joint_spectral_weights:InvalidOmegaOffsetValuesA', ...
            'omega_offsets_A must contain only finite values.');
    end

    if ~isnumeric(omega_offsets_B) || ~isreal(omega_offsets_B) || ...
            ~isvector(omega_offsets_B) || isempty(omega_offsets_B)
        error('pmd_joint_spectral_weights:InvalidOmegaOffsetsB', ...
            'omega_offsets_B must be a non-empty real numeric vector.');
    end

    if any(~isfinite(omega_offsets_B), 'all')
        error('pmd_joint_spectral_weights:InvalidOmegaOffsetValuesB', ...
            'omega_offsets_B must contain only finite values.');
    end

    if ~isnumeric(sigma_sum) || ~isscalar(sigma_sum) || ...
            ~isreal(sigma_sum) || ~isfinite(sigma_sum)
        error('pmd_joint_spectral_weights:InvalidSigmaSum', ...
            'sigma_sum must be a finite real numeric scalar.');
    end

    if sigma_sum <= 0
        error('pmd_joint_spectral_weights:InvalidSigmaSumRange', ...
            'sigma_sum must satisfy sigma_sum > 0.');
    end

    if ~isnumeric(sigma_difference) || ~isscalar(sigma_difference) || ...
            ~isreal(sigma_difference) || ~isfinite(sigma_difference)
        error('pmd_joint_spectral_weights:InvalidSigmaDifference', ...
            'sigma_difference must be a finite real numeric scalar.');
    end

    if sigma_difference <= 0
        error('pmd_joint_spectral_weights:InvalidSigmaDifferenceRange', ...
            'sigma_difference must satisfy sigma_difference > 0.');
    end

    omega_offsets_A = omega_offsets_A(:);
    omega_offsets_B = omega_offsets_B(:);

    num_frequencies_A = numel(omega_offsets_A);
    num_frequencies_B = numel(omega_offsets_B);

    if num_frequencies_A > 1 && any(diff(omega_offsets_A) <= 0)
        error('pmd_joint_spectral_weights:NonIncreasingGridA', ...
            'omega_offsets_A must be strictly increasing.');
    end

    if num_frequencies_B > 1 && any(diff(omega_offsets_B) <= 0)
        error('pmd_joint_spectral_weights:NonIncreasingGridB', ...
            'omega_offsets_B must be strictly increasing.');
    end


    % =========================
    % Quadrature weights
    % =========================

    % Composite-trapezoidal weights for arm A.

    quadrature_weights_A = ones(num_frequencies_A, 1);

    if num_frequencies_A > 1

        quadrature_weights_A(1) = ...
            (omega_offsets_A(2) - omega_offsets_A(1)) / 2;

        quadrature_weights_A(end) = ...
            (omega_offsets_A(end) - omega_offsets_A(end - 1)) / 2;

        if num_frequencies_A > 2
            quadrature_weights_A(2:end-1) = ...
                (omega_offsets_A(3:end) - ...
                 omega_offsets_A(1:end-2)) / 2;
        end

    end

    % Composite-trapezoidal weights for arm B.

    quadrature_weights_B = ones(num_frequencies_B, 1);

    if num_frequencies_B > 1

        quadrature_weights_B(1) = ...
            (omega_offsets_B(2) - omega_offsets_B(1)) / 2;

        quadrature_weights_B(end) = ...
            (omega_offsets_B(end) - omega_offsets_B(end - 1)) / 2;

        if num_frequencies_B > 2
            quadrature_weights_B(2:end-1) = ...
                (omega_offsets_B(3:end) - ...
                 omega_offsets_B(1:end-2)) / 2;
        end

    end


    % =========================
    % Gaussian joint spectrum
    % =========================

    omega_sum = ...
        omega_offsets_A + omega_offsets_B.';

    omega_difference = ...
        omega_offsets_A - omega_offsets_B.';

    % Evaluate the logarithm of the JSI first to improve numerical
    % stability for large spectral intervals.

    log_joint_spectral_intensity = ...
        -0.5 * (omega_sum / sigma_sum).^2 ...
        -0.5 * (omega_difference / sigma_difference).^2;


    % =========================
    % Discrete spectral weights
    % =========================

    % Include the two-dimensional quadrature measure.

    log_unnormalized_weights = ...
        log_joint_spectral_intensity ...
        + log(quadrature_weights_A) ...
        + log(quadrature_weights_B.');

    % Subtracting the maximum leaves normalized probabilities unchanged
    % while preventing avoidable numerical underflow.

    maximum_log_weight = max(log_unnormalized_weights, [], 'all');

    if ~isfinite(maximum_log_weight)
        error('pmd_joint_spectral_weights:InvalidSpectralSupport', ...
            ['The supplied grid and spectral widths do not produce ', ...
             'numerically resolvable spectral weights.']);
    end

    unnormalized_weights = ...
        exp(log_unnormalized_weights - maximum_log_weight);

    normalization = sum(unnormalized_weights, 'all');

    if ~isfinite(normalization) || normalization <= 0
        error('pmd_joint_spectral_weights:InvalidNormalization', ...
            'Unable to normalize the joint spectral distribution.');
    end

    spectral_weights = ...
        unnormalized_weights / normalization;

end