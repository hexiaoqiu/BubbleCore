function [RaStr] = dnsGetLatexRaBubble(dns)

exp = floor(log10(dns.Ra));
expStr = num2str(exp,'%d');
real = dns.Ra/(10^(exp));
realStr = sprintf('%.2f', real);
realStr = regexprep(realStr, '\.?0+$', '');
RaStr = ['$Ra=',realStr,'\times 10^{',expStr,'}$'];

end