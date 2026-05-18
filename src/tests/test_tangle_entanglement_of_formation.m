function test_tangle_entanglement_of_formation()
% TEST_TANGLE_ENTANGLEMENT_OF_FORMATION
% Test tangle and entanglement of formation metrics.
%
% Objective:
%   Validate:
%       - τ = 1 and E_F = 1 for Bell states
%       - τ = 0 and E_F = 0 for separable states
%       - τ = C^2 consistency
%       - physical bounds 0 <= τ,E_F <= 1

    % =========================
    % Test setup
    % =========================

    tolerance = 1e-12;


    % =========================
    % Bell state test
    % =========================

    psi_plus = bell_state('psi_plus');
    rho_bell = state_to_density_matrix(psi_plus);

    C_bell = compute_concurrence(rho_bell);
    tau_bell = compute_tangle(rho_bell);
    E_F_bell = compute_entanglement_of_formation(rho_bell);

    assert(abs(C_bell - 1) < tolerance, ...
        'Bell-state concurrence must be 1.');

    assert(abs(tau_bell - 1) < tolerance, ...
        'Bell-state tangle must be 1.');

    assert(abs(E_F_bell - 1) < tolerance, ...
        'Bell-state entanglement of formation must be 1.');


    % =========================
    % Separable state test
    % =========================

    ket_00 = computational_basis('00');
    rho_sep = state_to_density_matrix(ket_00);

    C_sep = compute_concurrence(rho_sep);
    tau_sep = compute_tangle(rho_sep);
    E_F_sep = compute_entanglement_of_formation(rho_sep);

    assert(abs(C_sep) < tolerance, ...
        'Separable-state concurrence must be 0.');

    assert(abs(tau_sep) < tolerance, ...
        'Separable-state tangle must be 0.');

    assert(abs(E_F_sep) < tolerance, ...
        'Separable-state entanglement of formation must be 0.');


    % =========================
    % Partially depolarized Bell state test
    % =========================

    p = 0.30;
    rho_depol = global_depolarizing_channel(rho_bell, p);

    C_depol = compute_concurrence(rho_depol);
    tau_depol = compute_tangle(rho_depol);
    E_F_depol = compute_entanglement_of_formation(rho_depol);

    assert(abs(tau_depol - C_depol^2) < tolerance, ...
        'Tangle must satisfy tau = C^2.');

    assert(tau_depol >= -tolerance && tau_depol <= 1 + tolerance, ...
        'Tangle must lie in [0,1].');

    assert(E_F_depol >= -tolerance && E_F_depol <= 1 + tolerance, ...
        'Entanglement of formation must lie in [0,1].');


    % =========================
    % Console output
    % =========================

    fprintf('test_tangle_entanglement_of_formation passed.\n');

end