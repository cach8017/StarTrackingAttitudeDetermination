function poly = convPoly(terms)

poly = terms(1,:);
if length(terms(:,1))>1
    for i=2:length(terms(:,1))
        poly = conv(poly, terms(i,:));
    end
end

end