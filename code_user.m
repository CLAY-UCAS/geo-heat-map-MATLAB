%% 1. ==================  数据准备（原脚本不变）  ==================
load('D:\EXIOBASE\matlab_code\data_D_cba.mat')
load('D:\EXIOBASE\matlab_code\data_D_pba.mat')
load('D:\EXIOBASE\matlab_code\data_U_cba.mat')
load('D:\EXIOBASE\matlab_code\data_U_pba.mat')

% 将进入经济系统的和未进入经济系统的金属开采量进行相加，得到data_cba
data_cba = data_D_cba;
vals_D = data_D_cba{:, 3:14};   
vals_U = data_U_cba{:, 3:14};   
vals_sum = vals_D + vals_U;
data_cba{:, 3:14} = vals_sum;

% 将进入经济系统的和未进入经济系统的金属开采量进行相加，得到data_pba
data_pba = data_D_pba;
vals_D = data_D_pba{:, 3:14};   
vals_U = data_U_pba{:, 3:14};   
vals_sum = vals_D + vals_U;
data_pba{:, 3:14} = vals_sum;

% 将data_cba减去data_pba
data_minus = data_D_pba;
value_cba = data_cba{:,3:14};
value_pba = data_pba{:,3:14};
value_minus = value_cba - value_pba;
data_minus{:,3:14} = value_minus;

% 对data_minus中的region进行补齐
regions = data_minus{:,1};
currentRegion = regions{1};
for k = 1:numel(regions)
    if ~isempty(regions{k})
        currentRegion = regions{k};
    else
        regions{k} = currentRegion;
    end
end
data_minus{:,1} = regions;

%% 2. ==================  交互 1：行业多选  ==================
% 先列出所有行业
allIndustries = unique(data_minus{:,2});
fprintf('\n==========  行业列表  ==========\n');
for k = 1:numel(allIndustries)
    fprintf('%2d  %s\n', k, allIndustries{k});
end
fprintf('\n请输入你要选择的行业编号（用空格分隔），输入 continue 继续：\n');

selectedInd = {};
while true
    userInput = strtrim(input('行业编号 > ', 's'));
    if strcmpi(userInput, 'continue')
        if ~isempty(selectedInd); break; else disp('至少选一个行业！'); end
    else
        idx = str2double(regexp(userInput, '\s+', 'split'));
        idx = idx(~isnan(idx));
        if any(idx < 1 | idx > numel(allIndustries))
            disp('编号超出范围，请重新输入');
            continue;
        end
        selectedInd = unique([selectedInd, allIndustries(idx)]);
    end
end

% 根据所选行业做筛选
idxInd = ismember(data_minus{:,2}, selectedInd);
subT   = data_minus(idxInd,:);

%% 3. ==================  交互 2：选择要画图的数值列（第3列起）  ==================
cols = 3:width(subT);               % 第3列到最后一列
colNames = subT.Properties.VariableNames(cols);

fprintf('\n==========  可选数值列  ==========\n');
for k = 1:numel(colNames)
    fprintf('%2d  %s\n', k, colNames{k});
end
fprintf('\n请输入你要画图的数值列编号，输入 continue 继续：\n');

colNum = [];
while true
    userInput = strtrim(input('数值列编号 > ', 's'));
    if strcmpi(userInput, 'continue')
        if ~isempty(colNum); break; else disp('至少选一列！'); end
    else
        tmp = str2double(userInput);
        if isnan(tmp) || tmp < 1 || tmp > numel(cols)
            disp('编号超出范围，请重新输入');
            continue;
        end
        colNum = cols(tmp);   % 对应到真实列号
    end
end

% 求和：按 region 累加所选列
[regionList,~,idxR] = unique(subT{:,1}, 'stable');
sums = accumarray(idxR, subT{:,colNum}, [], @sum);
values = table(regionList, sums, 'VariableNames', {'region', 'total'});
values = values{:,2};    % 只保留数值向量

fprintf('\n==========  画图设置  ==========\n');

% 1) 是否删除极值
clipMode = 0;
clipOpt  = lower(strtrim(input('删除极值？(none/max/min/both) > ', 's')));
switch clipOpt
    case 'max',  clipMode = 1;
    case 'min',  clipMode = 2;
    case 'both', clipMode = 3;
    otherwise,   clipMode = 0;
end

% 2) 设置 parula 的颜色级数
N = input('颜色级数 N (默认 256) > ');
if isempty(N) || ~isnumeric(N) || N<2
    N = 256;
end
myCmap = parula(N);  
%% 5. ==================  读 shapefile（原脚本不变）  ==================
%%
shpFile = 'ne_110m_admin_0_countries.shp';
if ~isfile(shpFile)
    websave('ne.zip', ne);
    unzip('ne.zip');
end
S = shaperead(shpFile, 'UseGeoCoords', true);

%对需要画图的国家进行映射
iso2 = string({S.ISO_A2_EH})';
iso2 = replace(iso2, " ", "");
iso2 = strtrim(iso2);  
iso2 = erase(iso2, " ");
iso2 = regexprep(iso2, "\s+$", "");
iso2 = extractBefore(iso2, 3);
iso3=string({S.ISO_A3_EH});
name=string({S.NAME});
codes = {'AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GR', ...
         'HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO', ...
         'SE','SI','SK','GB','US','JP','CN','CA','KR','BR','IN','MX', ...
         'RU','AU','CH','TR','TW','NO','ID','ZA','WA','WL','WE','WF','WM'};
codes=string(codes);
disp(codes(1))
disp(iso2(115))

if codes(8)==iso2(121)
    disp(codes(8))
else
    disp(iso2(1))
end
% 先给每个区域一个 NaN，找不到就留空
countryValue = NaN(height(S),1);
idx_country=zeros(177,1);
for i=1:49
    disp(codes(i))
    for j=1:177
        %disp(iso2(j))
        if codes(i)==iso2(j)
            idx_country(j)=i;
        else
        end
    end
end


for i=1:177
    if idx_country(i)>0
        countryValue(i)=values((idx_country(i)));
    else
        countryValue(i)=0;
    end
end
%% 6. ==================  开始画图（根据交互参数调整）  ==================
figure
worldmap('World')     % 画世界底图
load coastlines
plotm(coastlat, coastlon, 'k', 'LineWidth', 0.5)  % 海岸线




% 2) 计算 >0 的数值范围
validIdx = countryValue ~= 0;
% 1) 先对正负分别取 log
logVal = sign(countryValue) .* log10(max(abs(countryValue), eps));

% 2) 把结果线性映射到 [0,1]
%logVal = rescale(logVal, 0, 1);

% 3) 替换原变量
countryValue = logVal;

switch clipMode
    case 1,  countryValue(countryValue==max(countryValue)) = [];   % 去最大
    case 2,  countryValue(countryValue==min(countryValue)) = [];   % 去最小
    case 3,  countryValue(countryValue==max(countryValue)) = []; countryValue(countryValue==min(countryValue)) = []; % 去最大+最小
end
cmin = min(countryValue(validIdx));
cmax = max(countryValue(validIdx));
if cmin==cmax
    cmin = cmin - 1;
    cmax = cmax + 1;
end

% 3) 先统一画成浅灰色底图（可改成白色）
for i = 1:numel(S)
    patchm(S(i).Lat, S(i).Lon, ...
           'FaceColor', [0.9 0.9 0.9], ...   % 浅灰底图
           'EdgeColor', [0.5 0.5 0.5], ...
           'LineWidth', 0.3);
end

% 4) 再单独给 >0 的国家上色
for i = 1:numel(S)
    if validIdx(i)
        % 计算颜色索引
        idx   = max(1, min(N, round((countryValue(i)-cmin)/(cmax-cmin)*N)+1));
        color = myCmap(idx,:);
        patchm(S(i).Lat, S(i).Lon, ...
               'FaceColor', color, ...
               'EdgeColor', [0.5 0.5 0.5], ...
               'LineWidth', 0.3);
    end
end

% 5) 颜色条


colormap(myCmap)
caxis([cmin cmax])
ticks  = linspace(cmin,cmax,5);
labels = compose("%.2f", ticks);   % 或 "%g"
colorbar('Ticks', ticks, 'TickLabels', labels);

%% 7. ==================  结束  ==================
fprintf('\n画图完成！\n');