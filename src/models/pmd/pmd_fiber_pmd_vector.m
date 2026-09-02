function [pmd_vector, total_dgd, generator] = pmd_fiber_pmd_vector( ...
        omega_offset, derivative_step, phases, dgds, axes)
% PMD_FIBER_PMD_VECTOR  Extract the input-side PMD vector of a segmented fiber.
%
% Objective:
%   Numerically evaluate the first-order polarization-mode-dispersion
%   generator of the complete segmented-fiber operator
%
%       U(Omega) = U_N(Omega) ... U_2(Omega) U_1(Omega)
%
%   through the centered finite difference
%
%       dU/dOmega
%       approximately
%       [U(Omega + h) - U(Omega - h)] / (2 h).
%
%   The input-side PMD generator is
%
%       G_in = -i U(Omega)^dagger dU/dOmega,
%
%   and its traceless Hermitian part is expanded as
%
%       G_in = 1/2 tau_vector . sigma.
%
%   The total first-order differential group delay is therefore
%
%       DGD = ||tau_vector||.
%
% Input:
%   omega_offset    - Angular-frequency offset Omega [rad/s] at which the
%                     PMD vector is evaluated.
%
%   derivative_step - Positive centered finite-difference step h [rad/s].
%
%   phases          - Segment differential phases at the carrier [rad].
%
%   dgds            - Segment differential group delays [s].
%
%   axes            - N-by-3 matrix containing the segment birefringence
%                     axes.
%
% Output:
%   pmd_vector      - 1-by-3 real PMD vector [s].
%
%   total_dgd       - Non-negative total first-order DGD [s].
%
%   generator       - 2-by-2 Hermitian traceless PMD generator [s].
%
% Notes:
%   Validation of phases, dgds, and axes is delegated to
%   pmd_fiber_unitary, which is the authoritative segmented-fiber
%   constructor.
%
%   The sign of pmd_vector depends on the sign convention adopted in the
%   segment unitary. The physically invariant total DGD is its Euclidean
%   norm.
%
%   derivative_step must be tested for convergence. Too large a step
%   introduces truncation error, while too small a step amplifies
%   floating-point cancellation.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 5
        error( ...
            'pmd_fiber_pmd_vector:InvalidNumInputs', ...
            ['Expected exactly 5 input arguments: omega_offset, ', ...
             'derivative_step, phases, dgds, axes.']);
    end

    if ~isnumeric(omega_offset) || ...
            ~isscalar(omega_offset) || ...
            ~isreal(omega_offset) || ...
            ~isfinite(omega_offset)
        error( ...
            'pmd_fiber_pmd_vector:InvalidOmegaOffset', ...
            'omega_offset must be a finite real numeric scalar.');
    end

    if ~isnumeric(derivative_step) || ...
            ~isscalar(derivative_step) || ...
            ~isreal(derivative_step) || ...
            ~isfinite(derivative_step) || ...
            derivative_step <= 0
        error( ...
            'pmd_fiber_pmd_vector:InvalidDerivativeStep', ...
            'derivative_step must be a positive finite real scalar.');
    end


    % =========================
    % Fiber operators
    % =========================

    U_0 = pmd_fiber_unitary( ...
        omega_offset, ...
        phases, ...
        dgds, ...
        axes);

    U_plus = pmd_fiber_unitary( ...
        omega_offset + derivative_step, ...
        phases, ...
        dgds, ...
        axes);

    U_minus = pmd_fiber_unitary( ...
        omega_offset - derivative_step, ...
        phases, ...
        dgds, ...
        axes);


    % =========================
    % Frequency derivative
    % =========================

    dU_domega = ...
        (U_plus - U_minus) / (2 * derivative_step);


    % =========================
    % PMD generator
    % =========================

    generator = -1i * U_0' * dU_domega;

    % Remove roundoff-level anti-Hermitian contributions.
    generator = (generator + generator') / 2;

    % Remove any roundoff-level identity contribution.
    generator = ...
        generator - ...
        trace(generator) / 2 * eye(2);


    % =========================
    % Pauli decomposition
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();

    pmd_vector = real([ ...
        trace(generator * sigma_x), ...
        trace(generator * sigma_y), ...
        trace(generator * sigma_z) ...
    ]);

    total_dgd = norm(pmd_vector, 2);

end