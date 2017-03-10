

function pdf = lx_to_pdf(lx,radix)
    pdf = diff(1-lx/radix);
end