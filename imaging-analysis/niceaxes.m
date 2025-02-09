% niceaxes.m
%
% makes current axes have nice formatting
%
function niceaxes()

set(gca,'fontname','times','fontsize',14);
ax=findall(gca,'Type','line');
for i=1:length(ax)
    set(ax(i),'linewidth',2);
end
ax=findall(gcf,'Type','text');
for i=1:length(ax)
    set(ax(i),'fontname','times','fontsize',14);
end