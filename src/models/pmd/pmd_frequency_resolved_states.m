function frequency_states = pmd_frequency_resolved_states( ...
        rho_input, omega_offsets_A, omega_offsets_B, ...
        delta_phases_A, delta_taus_A, axes_A, ...
        delta_phases_B, delta_taus_B, axes_B)
% PMD_FREQUENCY_RESOLVED_STATES  Propagate a two-qubit polarization state
%                                over a discrete joint spectral grid.
%
% Objective:
%   For every spectral pair (Ω_A,k, Ω_B,l), evaluate the corresponding
%   polarization density operator
%
%       ρ(k,l) = U_AB(k,l) ρ_in U_AB(k,l)†,
%
%   where
%
%       U_AB(k,l)
%       =
%       U_A(Ω_A,k) ⊗ U_B(Ω_B,l).
%
% Input:
%   rho_input       - 4x4 two-qubit polarization density matrix ρ_in.
%
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
%   delta_phases_A  - Signed differential phases Δφ_A,j at ω_0,A
%                     for the birefringent segments in arm A [rad].
%
%   delta_taus_A    - Signed differential delays Δτ_A,j of the
%                     birefringent segments in arm A [s].
%
%   axes_A          - Oriented birefringence axes of the segments in arm A.
%                     N_A,seg-by-3 real matrix.
%
%   delta_phases_B  - Signed differential phases Δφ_B,j at ω_0,B
%                     for the birefringent segments in arm B [rad].
%
%   delta_taus_B    - Signed differential delays Δτ_B,j of the
%                     birefringent segments in arm B [s].
%
%   axes_B          - Oriented birefringence axes of the segments in arm B.
%                     N_B,seg-by-3 real matrix.
%
% Output:
%   frequency_states - 4x4xN_AxN_B complex array satisfying
%
%       frequency_states(:, :, k, l) = ρ(k,l).
%
% Notes:
%   This function does not construct the complete density operator on the
%   polarization-frequency Hilbert space. Instead, it evaluates and stores
%   the polarization density operator associated with each sampled
%   frequency pair.
%
%   Under frequency-preserving propagation and an initially factorized
%   polarization-frequency state, these conditional polarization states
%   are sufficient to construct the reduced output polarization state:
%
%       ρ_out = Σ_k Σ_l Q(k,l) ρ(k,l),
%
%   where Q(k,l) are the normalized discrete joint spectral weights.
%
%   The weighted sum is performed by pmd_spectral_average_state.
%
%   The frequency-dependent segmented-fiber operators are constructed by
%   pmd_fiber_unitary.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 9
        error('pmd_frequency_resolved_states:InvalidNumInputs', ...
            'Expected exactly 9 input arguments.');
    end

    if ~isnumeric(rho_input) || ~isequal(size(rho_input), [4, 4])
        error('pmd_frequency_resolved_states:InvalidInputStateSize', ...
            'rho_input must be a 4-by-4 numeric matrix.');
    end

    if any(~isfinite(rho_input), 'all')
        error('pmd_frequency_resolved_states:InvalidInputStateValues', ...
            'rho_input must contain only finite values.');
    end

    tolerance = 1e-12;

    if norm(rho_input - rho_input', 'fro') > tolerance
        error('pmd_frequency_resolved_states:NonHermitianInputState', ...
            'rho_input must be Hermitian within numerical tolerance.');
    end

    if abs(trace(rho_input) - 1) > tolerance
        error('pmd_frequency_resolved_states:InvalidInputStateTrace', ...
            'rho_input must have unit trace within numerical tolerance.');
    end

    rho_eigenvalues = eig((rho_input + rho_input') / 2);

    if any(real(rho_eigenvalues) < -tolerance)
        error('pmd_frequency_resolved_states:NonPositiveInputState', ...
            'rho_input must be positive semidefinite within numerical tolerance.');
    end

    if ~isnumeric(omega_offsets_A) || ~isreal(omega_offsets_A) || ...
            ~isvector(omega_offsets_A) || isempty(omega_offsets_A)
        error('pmd_frequency_resolved_states:InvalidOmegaOffsetsA', ...
            'omega_offsets_A must be a non-empty real numeric vector.');
    end

    if any(~isfinite(omega_offsets_A), 'all')
        error('pmd_frequency_resolved_states:InvalidOmegaOffsetValuesA', ...
            'omega_offsets_A must contain only finite values.');
    end

    if ~isnumeric(omega_offsets_B) || ~isreal(omega_offsets_B) || ...
            ~isvector(omega_offsets_B) || isempty(omega_offsets_B)
        error('pmd_frequency_resolved_states:InvalidOmegaOffsetsB', ...
            'omega_offsets_B must be a non-empty real numeric vector.');
    end

    if any(~isfinite(omega_offsets_B), 'all')
        error('pmd_frequency_resolved_states:InvalidOmegaOffsetValuesB', ...
            'omega_offsets_B must contain only finite values.');
    end

    omega_offsets_A = omega_offsets_A(:);
    omega_offsets_B = omega_offsets_B(:);


    % =========================
    % Main computation
    % =========================

    num_frequencies_A = numel(omega_offsets_A);
    num_frequencies_B = numel(omega_offsets_B);

    % Preallocate frequency-resolved local fiber operators.

    U_A_frequency = complex(zeros(2, 2, num_frequencies_A));
    U_B_frequency = complex(zeros(2, 2, num_frequencies_B));

    % Evaluate each local fiber only once at every frequency node.

    for k = 1:num_frequencies_A

        U_A_frequency(:, :, k) = pmd_fiber_unitary( ...
            omega_offsets_A(k), ...
            delta_phases_A, ...
            delta_taus_A, ...
            axes_A);

    end

    for l = 1:num_frequencies_B

        U_B_frequency(:, :, l) = pmd_fiber_unitary( ...
            omega_offsets_B(l), ...
            delta_phases_B, ...
            delta_taus_B, ...
            axes_B);

    end

    % Preallocate the conditional polarization density matrices.

    frequency_states = complex(zeros( ...
        4, 4, num_frequencies_A, num_frequencies_B));


    % =========================
    % Frequency-pair propagation
    % =========================

    for k = 1:num_frequencies_A

        U_A = U_A_frequency(:, :, k);

        for l = 1:num_frequencies_B

            U_B = U_B_frequency(:, :, l);

            frequency_states(:, :, k, l) = ...
                apply_unitary(U_A, U_B, rho_input);

        end

    end

end