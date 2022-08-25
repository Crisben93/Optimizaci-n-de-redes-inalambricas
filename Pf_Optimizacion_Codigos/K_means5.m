%For reproducibility
% Cargar una imagen del plano
clc
clear all
close all
img = imread('Plano_1.jpeg');
img = imresize(img,[270,250]); % Escala: 1m = 10px;  1px = 10cm
Norm = rescale(img); % Normalizar los valores de cada pixel entre 0 y 1
load('Data.mat')
figure
image(Norm)
hold on
gscatter(X(:,1),X(:,2),idx,'bgmyc') 
hold on 
plot(C(:,1),C(:,2),'rx','MarkerSize',15,'LineWidth',3)  % Valor medio mas cercano
legend('Usuarios AP 1','Usuarios AP 2','Usuarios AP 3','Usuarios AP 4','Usuarios AP 5','Ubicacion de AP')
X_1 = [];
contador = 0;
for j=1:200
   if idx(j) == 1
       contador = contador +1 ;
       X_1(contador,1)= X(j,1);
       X_1(contador,2)= X(j,2);
   end
end
%% Cordenadas
xCmin = min(X_1(:,1));
xCmax = max(X_1(:,1));
yCmin = min(X_1(:,2));
yCmax = max(X_1(:,2));

%%



