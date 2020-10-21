function [ x_opt, n_feval ] = nelder_mead ( x, function_handle )
% SOURCE : https://people.sc.fsu.edu/~jburkardt/m_src/nelder_mead/nelder_mead.html
%
% Some help : https://en.wikipedia.org/wiki/Nelder-Mead_method
%
% modifications :
% - "flag" input deleted
% - typo / comments refactoring
% - added a "speed" parameter, accelerating the computation of the heavy cost_function.
%   "speed" depends on the current tolerance: tolerance is ABSOLUTE, it scale depends on the cost function
%
%
% WARNING : if you want use it, the it should be preferable to use the original one, stored in src/nelder_mead.m

%% NELDER_MEAD performs the Nelder-Mead optimization search.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    19 January 2009
%
%  Author:
%
%    Jeff Borggaard
%
%  Reference:
%
%    John Nelder, Roger Mead,
%    A simplex method for function minimization,
%    Computer Journal,
%    Volume 7, Number 4, January 1965, pages 308-313.
%
%  Parameters:
%
%    Input, real X(M+1,M), contains a list of distinct points that serve as
%    initial guesses for the solution.  If the dimension of the space is M,
%    then the matrix must contain exactly M+1 points.  For instance,
%    for a 2D space, you supply 3 points.  Each row of the matrix contains
%    one point; for a 2D space, this means that X would be a
%    3x2 matrix.
%
%    Input, handle FUNCTION_HANDLE, a quoted expression for the function,
%    or the name of an M-file that defines the function, preceded by an
%    "@" sign;
%
%    Input, logical FLAG, an optional argument; if present, and set to 1,
%    it will cause the program to display a graphical image of the contours
%    and solution procedure.  Note that this option only makes sense for
%    problems in 2D, that is, with N=2.
%
%    Output, real X_OPT, the optimal value of X found by the algorithm.
%

%% Define algorithm constants

tolerance = 1.0E-06; % WARNING : tolrance is an ABSOLUTE value, and depends on the scale of the cost

rho = 1;    % rho > 0
xi  = 2;    % xi  > max(rho, 1)
gam = 0.5;  % 0 < gam < 1
sig = 0.5;  % 0 < sig < 1

max_feval = 250;

speed = 100;


%%  Initialization

[ temp, n_dim ] = size ( x );

if ( temp ~= n_dim + 1 )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'NELDER_MEAD - Fatal error!\n' );
    error('  Number of points must be = number of design variables + 1\n');
end

[f    ] = evaluate ( x, speed, function_handle );
n_feval = n_dim + 1;

[ f, index ] = sort ( f );
x = x(index,:);
prev_tolerance_x = Inf;


%% Begin the Nelder Mead iteration.

converged = 0;
diverged  = 0;

while ( ~converged && ~diverged )
    
    % Compute the midpoint of the simplex opposite the worst point.
    x_bar = sum ( x(1:n_dim,:) ) / n_dim;
    
    % Compute the reflection point.
    x_r   = ( 1 + rho ) * x_bar ...
        - rho   * x(n_dim+1,:);
    f_r   = feval(function_handle,x_r,speed);
    n_feval = n_feval + 1;
    
    if ( f(1) <= f_r && f_r <= f(n_dim) ) % Accept the point
        
        x(n_dim+1,:) = x_r;
        f(n_dim+1  ) = f_r;
        
    elseif ( f_r < f(1) )%   Test for possible expansion.
        
        x_e = ( 1 + rho * xi ) * x_bar ...
            - rho * xi   * x(n_dim+1,:);
        
        f_e = feval(function_handle,x_e,speed);
        n_feval = n_feval+1;
        
        % Can we accept the expanded point ?
        if ( f_e < f_r )
            x(n_dim+1,:) = x_e;
            f(n_dim+1  ) = f_e;
        else
            x(n_dim+1,:) = x_r;
            f(n_dim+1  ) = f_r;
        end
        
        
    elseif ( f(n_dim) <= f_r && f_r < f(n_dim+1) ) % Outside contraction.
        
        x_c = (1+rho*gam)*x_bar - rho*gam*x(n_dim+1,:);
        f_c = feval(function_handle,x_c,speed); n_feval = n_feval+1;
        
        if (f_c <= f_r) % accept the contracted point
            x(n_dim+1,:) = x_c;
            f(n_dim+1  ) = f_c;
        else
            [x,f] = shrink(x,speed,function_handle,sig); n_feval = n_feval+n_dim;
        end
        
        
    else %  F_R must be >= F(N_DIM+1), Try an inside contraction.
        
        x_c = ( 1 - gam ) * x_bar ...
            + gam   * x(n_dim+1,:);
        
        f_c = feval(function_handle,x_c,speed);
        n_feval = n_feval+1;
        
        % Can we accept the contracted point?
        if (f_c < f(n_dim+1))
            x(n_dim+1,:) = x_c;
            f(n_dim+1  ) = f_c;
        else
            [x,f] = shrink(x,speed,function_handle,sig); n_feval = n_feval+n_dim;
        end
        
    end
    
    %  Resort the points.  Note that we are not implementing the usual
    %  Nelder-Mead tie-breaking rules  (when f(1) = f(2) or f(n_dim) =
    %  f(n_dim+1)...
    [ f, index ] = sort ( f );
    x            = x(index,:);
    
    % Test for convergence
    tolerance_x = f(n_dim+1)-f(1); % absolute value
    if ~isempty(speed)
        if tolerance_x < prev_tolerance_x
            if tolerance_x > 0.1
                speed = 100;
            elseif tolerance_x > 0.001
                speed = 10;
            else
                speed = 1;
            end
            prev_tolerance_x = tolerance_x; % prev_tolerance_x can ne
        end
    end
    converged = tolerance_x < tolerance;
    
    % Test for divergence
    diverged = ( max_feval < n_feval );
    
end % while

x_opt = x(1,:);

if ( diverged )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'NELDER_MEAD - Warning!\n' );
    fprintf ( 1, '  The maximum number of function evaluations was exceeded\n')
    fprintf ( 1, '  without convergence being achieved.\n' );
end


end % function


function f = evaluate ( x, speed, function_handle )
%% EVALUATE handles the evaluation of the function at each point.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    19 January 2009
%
%  Author:
%
%    Jeff Borggaard
%
%  Reference:
%
%    John Nelder, Roger Mead,
%    A simplex method for function minimization,
%    Computer Journal,
%    Volume 7, Number 4, January 1965, pages 308-313.
%
%  Parameters:
%
%    Input, real X(N_DIM+1,N_DIM), the points.
%
%    Input, real FUNCTION_HANDLE ( X ), the handle of a MATLAB procedure
%    to evaluate the function.
%
%    Output, real F(1,NDIM+1), the value of the function at each point.
%

[ ~, n_dim ] = size ( x );

f = zeros ( 1, n_dim+1 );

for i = 1 : n_dim + 1
    f(i) = feval(function_handle,x(i,:),speed);
end

end % function


function [ x, f ] = shrink ( x, speed, function_handle, sig )
%% SHRINK shrinks the simplex towards the best point.
%
%  Discussion:
%
%    In the worst case, we need to shrink the simplex along each edge towards
%    the current "best" point.  This is quite expensive, requiring n_dim new
%    function evaluations.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    19 January 2009
%
%  Author:
%
%    Jeff Borggaard
%
%  Reference:
%
%    John Nelder, Roger Mead,
%    A simplex method for function minimization,
%    Computer Journal,
%    Volume 7, Number 4, January 1965, pages 308-313.
%
%  Parameters:
%
%    Input, real X(N_DIM+1,N_DIM), the points.
%
%    Input, real FUNCTION_HANDLE ( X ), the handle of a MATLAB procedure
%    to evaluate the function.
%
%    Input, real SIG, ?
%
%    Output, real X(N_DIM+1,N_DIM), the points after shrinking was applied.
%
%    Output, real F(1,NDIM+1), the value of the function at each point.
%

[ ~, n_dim ] = size ( x );

x1   = x(1,:);
f    = zeros ( 1, n_dim+1 );
f(1) = feval ( function_handle, x1, speed );

for i = 2 : n_dim + 1
    x(i,:) = sig * x(i,:) + ( 1.0 - sig ) * x(1,:);
    f(i) = feval ( function_handle, x(i,:), speed );
end


end % function

