function flag = is_unitary(U, tolerance)
% IS_UNITARY  Check whether a matrix is unitary within a tolerance.
%
% Objective:
%   Verify whether a matrix U satisfies:
%
%       U' * U = I   and   U * U' = I
%
%   within a specified numerical tolerance.
%
% Input:
%   U   - square numeric matrix
%   tolerance - numerical tolerance (optional, default = 1e-12)
%
% Output:
%   flag - logical value (true if U is unitary)
%
% Notes:
%   This function is intended for validation and diagnostics.
%
%   The check is performed using matrix norms:
%
%       ||U'*U - I||  and  ||U*U' - I||
%
%   Both conditions are tested to ensure numerical robustness.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1
        error('is_unitary:InvalidNumInputs', ...
            'At least one input argument (U) is required.');
    end

    if nargin < 2
        tolerance = 1e-12;
    end

    if ~isnumeric(U) || ~ismatrix(U)
        error('is_unitary:InvalidType', ...
            'U must be a numeric 2-D matrix.');
    end

    [m, n] = size(U);

    if m ~= n
        flag = false;
        return;
    end

    
    % =========================
    % Main computation
    % =========================

    I = eye(m);

    err1 = norm(U' * U - I, 'fro');
    err2 = norm(U * U' - I, 'fro');

    flag = (err1 < tolerance) && (err2 < tolerance);

end