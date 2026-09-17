function qber = compute_bbm92_qber(state)
% COMPUTE_BBM92_QBER
% Compute BBM92 basis-dependent QBERs for the |Psi+> reference convention.
%
% The adopted polarization bases are
%
%   Z basis: |H>, |V>
%   X basis: |D>, |A>
%
% with
%
%   |D> = (|H> + |V>) / sqrt(2)
%   |A> = (|H> - |V>) / sqrt(2).
%
% For the reference Bell state
%
%   |Psi+> = (|HV> + |VH>) / sqrt(2),
%
% the expected outcomes are
%
%   Z basis: anticorrelated
%   X basis: correlated.
%
% Therefore
%
%   Q_Z = P(H,H) + P(V,V)
%   Q_X = P(D,A) + P(A,D).
%
% Input:
%   state - Two-qubit pure state vector (4x1) or density matrix (4x4).
%
% Output:
%   qber - Structure containing:
%          .Q_Z
%          .Q_X
%          .Q_mean
%          .probabilities_Z
%          .probabilities_X

    H = computational_basis('0');
    V = computational_basis('1');

    D = (H + V) / sqrt(2);
    A = (H - V) / sqrt(2);

    basis_Z = [H, V];
    basis_X = [D, A];

    probabilities_Z = compute_joint_measurement_probabilities( ...
        state, ...
        basis_Z, ...
        basis_Z);

    probabilities_X = compute_joint_measurement_probabilities( ...
        state, ...
        basis_X, ...
        basis_X);

    Q_Z = ...
        probabilities_Z(1, 1) + ...
        probabilities_Z(2, 2);

    Q_X = ...
        probabilities_X(1, 2) + ...
        probabilities_X(2, 1);

    qber = struct();

    qber.Q_Z = Q_Z;
    qber.Q_X = Q_X;
    qber.Q_mean = 0.5 * (Q_Z + Q_X);

    qber.probabilities_Z = probabilities_Z;
    qber.probabilities_X = probabilities_X;

end