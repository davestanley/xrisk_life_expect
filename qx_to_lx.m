

function lx = qx_to_lx(qx,radix,ca)

    if nargin < 3
        ca = 0;         % Current age. zero = just born
    end
    
    cai = ca+1;        % Current age index (assuming age starts at zero)

    lx = ones(size(qx));
    
    lx(ca+1,:)= 1;             % 100% survival at currrent age
    lx(ca+2:end,:) = [ lx(cai+1,:) .* cumprod(1-qx(ca+1:end-1,:))];  % Disregard end data point, since that is "termination" - 100% death rate!
    
    lx = lx * radix;
end