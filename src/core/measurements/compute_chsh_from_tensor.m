function S = compute_chsh_from_tensor(T, a1, a2, b1, b2)
% COMPUTE_CHSH_FROM_TENSOR  Compute the CHSH parameter from a correlation tensor.
%
% Objective:
%   Compute the CHSH parameter
%
%       S = E(a₁,b₁) + E(a₁,b₂) + E(a₂,b₁) - E(a₂,b₂)
%
%   using the tensor expression
%
%       E(a,b) = a.' * T * b
%
%   where T is the 3x3 two-qubit correlation tensor.
%
% Input:
%   T  - 3x3 real correlation tensor with entries
%
%          T_ij = Tr[ρ_AB * (σ_i ⊗ σ_j)]
%
%   a₁ - 3x1 real unit vector defining the first measurement axis
%        for subsystem A
%
%   a₂ - 3x1 real unit vector defining the second measurement axis
%        for subsystem A
%
%   b₁ - 3x1 real unit vector defining the first measurement axis
%        for subsystem B
%
%   b₂ - 3x1 real unit vector defining the second measurement axis
%        for subsystem B
%
% Output:
%   S  - real scalar CHSH parameter associated with the selected axes
%
% Notes:
%   This function assumes that T has already been computed consistently with
%   the fixed Pauli ordering:
%
%       x, y, z
%
%   The function does not maximize over measurement settings. It only evaluates
%   S for the axes explicitly provided as input.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 5
        error('compute_chsh_from_tensor:InvalidNumInputs', ...
              'Expected 5 input arguments: T, a1, a2, b1, b2.');
    end

    if ~isnumeric(T)
        error('compute_chsh_from_tensor:InvalidTypeTensor', ...
              'T must be numeric.');
    end

    if ~isequal(size(T), [3, 3])
        error('compute_chsh_from_tensor:InvalidSizeTensor', ...
              'T must be a 3x3 correlation tensor.');
    end

    if any(~isfinite(T), 'all')
        error('compute_chsh_from_tensor:InvalidValuesTensor', ...
              'T must contain only finite values.');
    end

    tensor_real_tolerance  = 1e-12;
    tensor_range_tolerance = 1e-12;

    if any(abs(imag(T)) > tensor_real_tolerance, 'all')
        error('compute_chsh_from_tensor:ComplexTensor', ...
              'T must be real-valued within numerical tolerance.');
    end

    T = real(T);

    if any(abs(T) > 1 + tensor_range_tolerance, 'all')
        error('compute_chsh_from_tensor:TensorOutOfRange', ...
              'Tensor entries exceed physical bounds [-1, 1] beyond tolerance.');
    end

    axes = {a1, a2, b1, b2};
    axes_names = {'a1', 'a2', 'b1', 'b2'};

    axis_real_tolerance = 1e-12;
    axis_norm_tolerance = 1e-12;

    for k = 1:numel(axes)
        current_axis = axes{k};

        if ~isnumeric(current_axis)
            error('compute_chsh_from_tensor:InvalidTypeAxis', ...
                  '%s must be numeric.', axes_names{k});
        end

        if ~isequal(size(current_axis), [3, 1])
            error('compute_chsh_from_tensor:InvalidSizeAxis', ...
                  '%s must be a 3x1 vector.', axes_names{k});
        end

        if any(~isfinite(current_axis), 'all')
            error('compute_chsh_from_tensor:InvalidValuesAxis', ...
                  '%s must contain only finite values.', axes_names{k});
        end

        if any(abs(imag(current_axis)) > axis_real_tolerance)
            error('compute_chsh_from_tensor:ComplexAxis', ...
                  '%s must be real-valued within numerical tolerance.', axes_names{k});
        end

        current_axis = real(current_axis);

        if abs(norm(current_axis) - 1) > axis_norm_tolerance
            error('compute_chsh_from_tensor:NonUnitAxis', ...
                  '%s must be normalized to unit length.', axes_names{k});
        end

        axes{k} = current_axis;
    end

    a1 = axes{1};
    a2 = axes{2};
    b1 = axes{3};
    b2 = axes{4};


    % =========================
    % Main computation
    % =========================

    E11 = compute_correlation_function_from_tensor(T, a1, b1);
    E12 = compute_correlation_function_from_tensor(T, a1, b2);
    E21 = compute_correlation_function_from_tensor(T, a2, b1);
    E22 = compute_correlation_function_from_tensor(T, a2, b2);

    S = E11 + E12 + E21 - E22;

    chsh_real_tolerance = 1e-10;

    if abs(imag(S)) > chsh_real_tolerance
        error('compute_chsh_from_tensor:ComplexResult', ...
              'S must be real-valued within numerical tolerance.');
    end

    S = real(S);

    chsh_range_tolerance = 1e-10;

    if abs(S) > 4 + chsh_range_tolerance
        error('compute_chsh_from_tensor:CHSHOutOfAlgebraicRange', ...
              'S exceeds the algebraic CHSH bound |S| <= 4 beyond tolerance.');
    end

end