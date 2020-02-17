% =========================================================================
%           ECONOMETRICS IV - SPRING 2020 - Prof. Schorfehide 
%                        STRUCTURAL VARs                     
%
% Author: Juan Castellanos Silv�n 
% Date  : 24/04/2020
% =========================================================================
%
% =========================================================================
%                             INPUTS
% =========================================================================
%   - Phi::Array =  (np+1) x n matirx of coefficients 
%   - Sigma::Array = n x n variance-covariance matrix 
%   - h::Integer = horizon of the IRFs
%
% =========================================================================
%                             OUTPUTS
% =========================================================================
%   - D_wold::Array = h x n matrix of impulse responses
%
% =========================================================================
function [D_wold]=IRF(Phi, Sigma, h)
        
    % ---------------
    % 1. Housekeeping
    % ---------------
    n = size(Phi,2);                % number of variables
    p = (size(Phi,1)-1)/n;          % number of lags
    D = zeros(n,h);
    
    % Choleski decomposition
    Sigma_tr = chol(Sigma,'lower'); 
    
    % Companion form
    Phi_aux=zeros(n, n*p);
    j=1;
    for i=1:p
        phi = Phi(j:i*p,:);
        Phi_aux(:,j:i*p)=phi;
        j = i*p+1;
    end
    BigA=[Phi_aux; eye(n*p-n) zeros(n*p-n,n)]; % np x np matrix
    
    
    % ---------------------
    % 2. Impulse responses 
    % ---------------------
    
    % initial candidate
    Z = randn(n,1);   
    Omega1 = Z/norm(Z);
    
    for ih = 1:h 
    
        if ih < 4
        
            % Acceptance sampling
            iter = 0;
            maxIter = 1000;
            while iter<maxIter

                % Wold representation 
                BigC = BigA^(ih-1);
                C = BigC(1:n,1:n);
                D_aux = C * Sigma_tr * Omega1;

                % restrictions
                if D_aux(2) < 0 && D_aux(3) > 0 && D_aux(4) < 0
                   D(:,ih) = D_aux;
                   %Omega1 = Omega1;
                   break
                end

                % update
                Z = randn(n,1);   
                Omega1 = Z/norm(Z);
                iter = iter+1;
            end
            
        end
         
        
      BigC = BigA^(ih-1);
      C = BigC(1:n,1:n);
      D(:,ih) = C * Sigma_tr * Omega1;
          
        
    end

    D_wold = D';
    
end


