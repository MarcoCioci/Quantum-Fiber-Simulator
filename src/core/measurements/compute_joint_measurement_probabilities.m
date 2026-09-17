function probabilities = compute_joint_measurement_probabilities(state, basis_A, basis_B)
% COMPUTE_JOINT_MEASUREMENT_PROBABILITIES
% Compute the four joint probabilities for local projective measurements.
%
% Inputs:
%   state   - Two-qubit pure state vector (4x1) or density matrix (4x4).
%   basis_A - 2x2 matrix whose columns are the measurement basis states
%             of subsystem A.
%   basis_B - 2x2 matrix whose columns are the measurement basis states
%             of subsystem B.
%
% Output:
%   probabilities - 2x2 matrix of joint probabilities, where
%                   probabilities(i,j) corresponds to outcome i on A
%                   and outcome j on B.

    if isvector(state)

        state = state(:);

        if numel(state) ~= 4
            error( ...
                'compute_joint_measurement_probabilities:InvalidState', ...
                'A two-qubit pure state must contain four amplitudes.');
        end

        rho = state_to_density_matrix(state);

    elseif isequal(size(state), [4, 4])

        rho = state;

    else

        error( ...
            'compute_joint_measurement_probabilities:InvalidState', ...
            'State must be a 4-element vector or a 4x4 density matrix.');

    end

    if ~isequal(size(basis_A), [2, 2]) || ~isequal(size(basis_B), [2, 2])

        error( ...
            'compute_joint_measurement_probabilities:InvalidBasis', ...
            'Each local measurement basis must be a 2x2 matrix.');

    end

    tolerance = 1e-12;

    if norm(basis_A' * basis_A - eye(2), 'fro') > tolerance || ...
       norm(basis_B' * basis_B - eye(2), 'fro') > tolerance

        error( ...
            'compute_joint_measurement_probabilities:NonOrthonormalBasis', ...
            'Measurement basis vectors must form orthonormal bases.');

    end

    probabilities = zeros(2, 2);

    for i = 1:2

        ket_A = basis_A(:, i);
        projector_A = ket_A * ket_A';

        for j = 1:2

            ket_B = basis_B(:, j);
            projector_B = ket_B * ket_B';

            joint_projector = tensor_product(projector_A, projector_B);

            probabilities(i, j) = real(trace(rho * joint_projector));

        end

    end

    probabilities(abs(probabilities) < tolerance) = 0;

    if any(probabilities(:) < -tolerance)

        error( ...
            'compute_joint_measurement_probabilities:NegativeProbability', ...
            'Computed measurement probabilities contain negative values.');

    end

    probabilities = max(probabilities, 0);

    normalization = sum(probabilities, 'all');

    if normalization <= tolerance

        error( ...
            'compute_joint_measurement_probabilities:InvalidNormalization', ...
            'Joint measurement probabilities have zero total weight.');

    end

    probabilities = probabilities / normalization;

end