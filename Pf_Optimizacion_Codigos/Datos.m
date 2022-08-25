%For reproducibility
% Cargar una imagen del plano
clc
clear all
close all

img = imread('Plano_1.jpeg');
img = imresize(img,[270,250]); % Escala: 1m = 10px;  1px = 10cm
Norm = rescale(img); % Normalizar los valores de cada pixel entre 0 y 1

%r = a + (b-a).*rand(N,1)
a = 5;
b = 260;
d = 240;
X = [(d-a).*rand(200,1) + a,(b-a).*rand(200,1) + a];
%X = [(90-1).*(rand(100,2)*0.75+ones(100,2))+1;(180-90).*(rand(100,2)*0.75+ones(100,2))+90;(270-180).*(rand(100,2)*0.75+ones(100,2))+180];
%X = [(randn(100,2)*0.75+ones(100,2));     randn(100,2)*0.5-ones(100,2);     randn(100,2)*0.75];

[idx,C] = kmeans(X,5);
vu=unique(idx,'stable');
for i=1:length(vu)
    m=vu(i);
    nv(i)=length( find(idx==vu(i)));
end
figure
image(Norm)
hold on
gscatter(X(:,1),X(:,2),idx,'bgmyc') 
hold on 
plot(C(:,1),C(:,2),'rx','MarkerSize',15,'LineWidth',3)  % Valor medio mas cercano
legend('Usuarios AP 1','Usuarios AP 2','Usuarios AP 3','Usuarios AP 4','Usuarios AP 5','Ubicacion de AP')
save('Data.mat')