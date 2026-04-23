function test_fidelity()
% TEST_FIDELITY  Validate fidelity computations for pure and mixed quantum states.
%
% Objective:
%   Verify that compute_fidelity correctly reproduces the expected fidelity
%   values for the main cases relevant to Section 4.3 of the thesis guide.
%
%   The following cases are tested:
%
%       1. Pure Bell state with itself:
%          F = 1
%
%       2. Orthogonal Bell states:
%          F = 0
%
%       3. Phase-evolved Bell-like state with respect to |Psi+>:
%          F(theta) = (1 + cos(theta)) / 2
%
%       4. Density matrix of |Psi+> with pure target |Psi+>:
%          F = 1
%
%       5. Symmetry check for pure-density mixed input order:
%          F(|psi>, rho) = F(rho, |psi>)
%
%       6. Separable mixed state:
%          rho_sep = 1/2 |01><01| + 1/2 |10><10|
%          F_{Psi+}(rho_sep) = 1/2
%
% Input:
%   None
%
% Output:
%   None
%
% Notes:
%   The test raises an error if any expected value is not matched within
%   numerical tolerance. If all checks pass, a success message is printed.

    % =========================
    % Test configuration
    % =========================

    tolerance = 1e-12;

    fprintf('Running test_fidelity...\n');


    % =========================
    % Common reference states
    % =========================

    psi_plus  = (computational_basis('01') + computational_basis('10')) / sqrt(2);   % |Psi+>
    psi_minus = (computational_basis('01') - computational_basis('10'))  / sqrt(2);  % |Psi->

    rho_psi_plus = state_to_density_matrix(psi_plus);


    % =========================
    % Test 1: Pure Bell state with itself
    % =========================

    fidelity_self = compute_fidelity(psi_plus, psi_plus);

    assert(abs(fidelity_self - 1.0) < tolerance, ...
        'test_fidelity:SelfFidelityFailed', ...
        'Fidelity of a pure state with itself should be 1.');


    % =========================
    % Test 2: Orthogonal Bell states
    % =========================

    fidelity_orthogonal = compute_fidelity(psi_plus, psi_minus);

    assert(abs(fidelity_orthogonal - 0.0) < tolerance, ...
        'test_fidelity:OrthogonalBellStatesFailed', ...
        'Fidelity of orthogonal Bell states should be 0.');


    % =========================
    % Test 3: Phase-evolved Bell-like state
    % =========================

    theta = pi / 3;

    psi_theta = [0; 1; exp(1i * theta); 0] / sqrt(2);

    fidelity_phase = compute_fidelity(psi_theta, psi_plus);
    fidelity_expected = (1 + cos(theta)) / 2;

    assert(abs(fidelity_phase - fidelity_expected) < tolerance, ...
        'test_fidelity:PhaseEvolvedStateFailed', ...
        'Phase-evolved Bell-like fidelity does not match analytical prediction.');


    % =========================
    % Test 4: Density matrix vs pure target
    % =========================

    fidelity_density_pure = compute_fidelity(rho_psi_plus, psi_plus);

    assert(abs(fidelity_density_pure - 1.0) < tolerance, ...
        'test_fidelity:DensityVsPureFailed', ...
        'Fidelity of Bell density matrix with Bell pure target should be 1.');


    % =========================
    % Test 5: Symmetry check for pure-density ordering
    % =========================

    fidelity_pure_density = compute_fidelity(psi_plus, rho_psi_plus);

    assert(abs(fidelity_pure_density - 1.0) < tolerance, ...
        'test_fidelity:PureVsDensityFailed', ...
        'Fidelity of Bell pure state with Bell density matrix should be 1.');

    assert(abs(fidelity_density_pure - fidelity_pure_density) < tolerance, ...
        'test_fidelity:MixedOrderSymmetryFailed', ...
        'Fidelity should agree when swapping pure and density inputs in this case.');


    % =========================
    % Test 6: Separable mixed state
    % =========================

    ket_01 = computational_basis('01');
    ket_10 = computational_basis('10');

    rho_sep = 0.5 * (ket_01 * ket_01') + 0.5 * (ket_10 * ket_10');

    fidelity_sep = compute_fidelity(rho_sep, psi_plus);

    assert(abs(fidelity_sep - 0.5) < tolerance, ...
        'test_fidelity:SeparableMixedStateFailed', ...
        'Fidelity of the separable mixed state with |Psi+> should be 1/2.');


    % =========================
    % Success message
    % =========================

    fprintf('test_fidelity passed.\n');

end