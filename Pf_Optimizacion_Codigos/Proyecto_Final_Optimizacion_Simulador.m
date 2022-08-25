clc
clear all
close all

% Cargar una imagen del plano

img = imread('Plano_1.jpeg');
img = imresize(img,[270,250]); % Escala: 1m = 10px;  1px = 10cm
figure
image(img)

Norm = rescale(img); % Normalizar los valores de cada pixel entre 0 y 1

%% Establecer un punto de acceso AP

% Coordenadas Ap

x1 = 131; % Eje x
y1 = 185; % Eje y
p1 = [x1,y1]; % Punto Ap

figure
image(Norm)
hold on
plot([p1(1),p1(1)],[p1(2),p1(2)],'o','Color','r','LineWidth',3)
%legend('Access Point ');

%% Coordenadas de prueba

% Parámetros para el modelo de propagación
Pt = 0; % Pt = Potencia transmitida [dBm]
Gt = 3; % Gt = Ganancia transmitica [dBi]
Gr = 3; % Gr = Ganancia recibida [dBi]
f = 2.4e9; % Frecuencia
c = 3e8; % Velocidad de la luz
n = 2; % Exponente de pérdidas, Espacio libre = 2, Rural = 2.5, Urbano = 4,6.
wp = 11.5; % Wp = factor de perdidas por muro [En cemento normal 8- 12 dB]

% Vectores y matrices de almacenamiento de variables
PR = zeros(270,250);% Matriz para almacenar las potencias en los pixeles analizados
VPR = []; % Vector de potencias recibidas
VX = []; % Vector de coordenadas x
VY = []; % Vector de coordenadas y
j = 0;

for yp = 175:3:268 % No se considera el borde del plano
   for xp = 101:3:264
        if Norm([yp],[xp]) > 0.95 % Condición para no tener en cuenta los muros
            pp = [xp,yp]; % Coordenadas
            j = j+1; 
            %pp = Norm([xp],[yp])
            hold on
            plot([pp(1),pp(1)],[pp(2),pp(2)],'o','Color','b','LineWidth',1)
            
            % Trayectoria
            %hold on
            %plot([p1(1),pp(1)],[p1(2),pp(2)],'Color','g','LineWidth',3)
            
            % Distancia de la trayectoria y pendiente
            d = norm(p1-pp); % Distancia en Pixeles
            dm = d/10; % Distancia en Metros
            m = (pp(2)-p1(2))/(pp(1)-p1(1)); % Pendiene de la recta
            
            % Ecuacion de la recta
            h=0; % Variable de identificacion horizontal
            v=0; % Variable de identificacion vertical
            % xi,xd limites izquierdo y derecho del eje x
            if abs(p1(1)-pp(1))>=30 || abs(pp(1)-p1(1))>=30 % Realizar de manera horizontal para distancia mayor a 30 pixeles
                if p1(1)< pp(1)
                    xi = p1(1);
                    xd = pp(1);
                end
                if p1(1)> pp(1)
                    xi = pp(1);
                    xd = p1(1);
                end
                x = [xi:1:xd]; % Variable x de la ecuacion de la recta
                y= m*(x - p1(1))+ p1(2); % Ecuacion de la recta horizontal
                %plot(x,y,'g','linewidth',3)
                h=1;

            else % Realizar de manera vertical para distancia menor a 30 pixeles
                m2 = (p1(2)-pp(2))/(p1(1)-pp(1)); % Pendiene de la recta vertical
                if pp(2)< p1(2)
                    yi = pp(2);
                    yd = p1(2);       
                end
                if pp(2)> p1(2)
                    yi = p1(2);
                    yd = pp(2);
                end
                y2 = [yi:1:yd]; % Variable x de la ecuacion de la recta
                x2= ((y2 - p1(2))/m2)+ p1(1); % Ecuacion de la recta vertical
                %plot(x2,y2,'g','linewidth',3)
                v=1;
            end
            
            % Ciclo for para evaluar toda la recta

            if h==1 % Para evaluar de manera horizontal
                xin = round(xi);
                xdn = round(xd);

                wr = 0;
                for i = xin:1:xdn

                    y= round(m*(i - p1(1))+ p1(2));
                    fr = Norm([y],[i]); % Inspeccion del valor que tiene la coordenada [fila,columna]

                    if fr <= 0.1 && Norm([y-1],[i-1])>0.1
                        if fr <= 0.1
                            wr = wr+1;
                        end
                    end
                end
            end

            if v==1 % Para evaluar de manera vertical
                xin = round(yi);
                xdn = round(yd);

                wr = 0;
                for i = xin:1:xdn
                    x2= round(((y2 - p1(2))/m2)+ p1(1));
                    fr = Norm([i],[x2]); % Inspeccion del valor que tiene la coordenada [fila,columna]

                    if fr <= 0.1
                        if Norm([i-1],[x2-1])>0.1
                            if fr <= 0.1
                                wr = wr+1;
                            end
                        end
                    end
                end % End del ciclo for de analisis de muros vertical
            end
            
            % Potencia recibida [dB] - Formula de Friis - Tx - Rx
            Lfs = 10*n*log10(dm) + 20*log10(f) - 20*log10(c/(4*pi)); % Lp = Perdidas de propagración en el espacio libre 
            Lobs = wr*wp; % Perdidas de obstaculos, Wr = Número de paredes
            Pr = Pt + Gt + Gr - Lfs - Lobs; % Potencia recibida teniendo en cuenta las paredes
            PR(yp,xp)= Pr; % Aqui se va almacenando las potencias de los pixeles analizazdos
            VPR(j) = Pr; % Vector de potencias recibidas
            VX(j) = yp; % Vectorde coordenadas y
            VY(j) = xp; % Vector de coordenadas x
            
        end % End de la condicion para que no tome los muros
    end % End del ciclo for de coordenadas
end

%% Mapas de Propagación

%% Trayectoria
wd = 1;
figure
image(Norm)
hold on

for k = 1:1:length(VPR)
    if VPR(k) <= -100
        %plot([p1(1),VY(k)],[p1(2),VX(k)],'Color','b','LineWidth',3)
        ppm = [VY(k),VX(k)]; % Coordenadas
        plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'*','Color','[0 0 1]','Linewidth',wd)
    end
end
for k = 1:1:length(VPR)
    if VPR(k) <= -90 && VPR(k) > -100
        %plot([p1(1),VY(k)],[p1(2),VX(k)],'Color','g','LineWidth',3)
        ppm = [VY(k),VX(k)]; % Coordenadas
        plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'*','Color','[0 0.3922 1]','Linewidth',wd)
    end
end
for k = 1:1:length(VPR)
    if VPR(k) <= -80 && VPR(k) > -90
        %plot([p1(1),VY(k)],[p1(2),VX(k)],'Color','y','LineWidth',3)
        ppm = [VY(k),VX(k)]; % Coordenadas
        plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'*','Color','[0 1 0.7843]','Linewidth',wd)
    end
end
for k = 1:1:length(VPR)
    if VPR(k) <= -70 && VPR(k) > -80
        %plot([p1(1),VY(k)],[p1(2),VX(k)],'Color','c','LineWidth',3)
        ppm = [VY(k),VX(k)]; % Coordenadas
        plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'*','Color','[0.3922 1 0]','Linewidth',wd)
    end
end
for k = 1:1:length(VPR)
    if VPR(k) <= -60 && VPR(k) > -70
        %plot([p1(1),VY(k)],[p1(2),VX(k)],'Color','[1 0 0]','LineWidth',3)
        ppm = [VY(k),VX(k)]; % Coordenadas
        plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'*','Color','[1 0.7843 0]','Linewidth',wd)
    end
end
for k = 1:1:length(VPR)
    if VPR(k) <= -50 && VPR(k) > -60
        %plot([p1(1),VY(k)],[p1(2),VX(k)],'Color','[0.74 0 0]','LineWidth',3)
        ppm = [VY(k),VX(k)]; % Coordenadas
        plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'*','Color','[1 0.3922 0]','Linewidth',wd)
    end
end
for k = 1:1:length(VPR)
    if VPR(k) <= -40 && VPR(k) > -50
        %plot([p1(1),VY(k)],[p1(2),VX(k)],'Color','[0.74 0 0]','LineWidth',3)
        ppm = [VY(k),VX(k)]; % Coordenadas
        plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'*','Color','[1 0 0]','Linewidth',wd)
    end
end
for k = 1:1:length(VPR)
    if VPR(k) <= -30 && VPR(k) > -40
        %plot([p1(1),VY(k)],[p1(2),VX(k)],'Color','[0.74 0 0]','LineWidth',3)
        ppm = [VY(k),VX(k)]; % Coordenadas
        plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'*','Color','[0.8627 0 0]','Linewidth',wd)
    end
end
for k = 1:1:length(VPR)
    if VPR(k) <= -1 && VPR(k) > -30
        %plot([p1(1),VY(k)],[p1(2),VX(k)],'Color','[0.74 0 0]','LineWidth',3)
        ppm = [VY(k),VX(k)]; % Coordenadas
        plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'*','Color','[0.7255 0 0]','Linewidth',wd)
    end
end
%% Repitar los muros
jm = 0;
for ypm = 1:1:270 % No se considera el borde del plano
    for xpm = 1:1:250
        if Norm([ypm],[xpm]) < 0.05 % Condición tener en cuenta los muros
            ppm = [xpm,ypm]; % Coordenadas
            jm = jm+1; 
            %pp = Norm([xp],[yp])
            hold on
            plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'.','Color','k','Linewidth',1)
            
%              Ciclo for para evaluar toda la recta
%             PR(yp,xp)= Pr; % Aqui se va almacenando las potencias de los pixeles analizazdos
%             VPR(j) = Pr; % Vector de potencias recibidas
%             VX(j) = yp; % Vectorde coordenadas y
%             VY(j) = xp; % Vector de coordenadas x
%             
        end % End de la condicion para que no tome los muros
    end % End del ciclo for de coordenadas
end
hold on
plot([p1(1),p1(1)],[p1(2),p1(2)],'*','Color','b','LineWidth',6)
legend('AP')
%% Repitar los muros
% jm = 0;
% for ypm = 1:1:270 % No se considera el borde del plano
%     for xpm = 1:1:250
%         if Norm([ypm],[xpm]) < 0.55 % Condición tener en cuenta los muros
%             ppm = [xpm,ypm]; % Coordenadas
%             jm = jm+1; 
%             %pp = Norm([xp],[yp])
%             hold on
%             plot([ppm(1),ppm(1)],[ppm(2),ppm(2)],'.','Color','k','Linewidth',1)
%             
% %              Ciclo for para evaluar toda la recta
% %             PR(yp,xp)= Pr; % Aqui se va almacenando las potencias de los pixeles analizazdos
% %             VPR(j) = Pr; % Vector de potencias recibidas
% %             VX(j) = yp; % Vectorde coordenadas y
% %             VY(j) = xp; % Vector de coordenadas x
% %             
%         end % End de la condicion para que no tome los muros
%     end % End del ciclo for de coordenadas
% end

%% Coordenadas Receptor
%x2 = 181; % Eje x
%y2 = 250; % Eje y
%p2 = [x2,y2]; % Punto Recpetor

%figure
%image(Norm)
%hold on
%plot([p2(1),p2(1)],[p2(2),p2(2)],'o','Color','b','LineWidth',3)
%legend('Receptor ');

%% Grafica del AP y receptor

%figure
%image(Norm)
%hold on
%plot([p1(1),p1(1)],[p1(2),p1(2)],'o','Color','r','LineWidth',3)
%hold on
%plot([p2(1),p2(1)],[p2(2),p2(2)],'o','Color','b','LineWidth',3)
%hold on
%legend('Access Point ','Receptor ')

%% Trayectoria
% figure
% image(Norm)
% hold on
% plot([p1(1),p1(1)],[p1(2),p1(2)],'o','Color','r','LineWidth',3)
% hold on
% plot([p2(1),p2(1)],[p2(2),p2(2)],'o','Color','b','LineWidth',3)
% hold on
% plot([p1(1),p2(1)],[p1(2),p2(2)],'Color','g','LineWidth',3)
% legend('Access Point ','Receptor ','Trayectoria ')

% %% Distancia de la trayectoria
%  
% d = norm(p1-p2); % Distancia en Pixeles
% dm = d/10; % Distancia en Metros

%% Pendiente

%m = (p2(2)-p1(2))/(p2(1)-p1(1)); % Pendiene de la recta

% %% Ecuacion de la recta
% h=0; % Variable de identificacion horizontal
% v=0; % Variable de identificacion vertical
% % xi,xd limites izquierdo y derecho del eje x
% if abs(p1(1)-p2(1))>=30 || abs(p2(1)-p1(1))>=30 % Realizar de manera horizontal para distancia mayor a 30 pixeles
%     if p1(1)< p2(1)
%         xi = p1(1);
%         xd = p2(1);
%     end
%     if p1(1)> p2(1)
%         xi = p2(1);
%         xd = p1(1);
%     end
%     x = [xi:1:xd]; % Variable x de la ecuacion de la recta
%     y= m*(x - p1(1))+ p1(2); % Ecuacion de la recta horizontal
%     plot(x,y,'g','linewidth',3)
%     h=1;
%     
% else % Realizar de manera vertical para distancia menor a 30 pixeles
%     m2 = (p1(2)-p2(2))/(p1(1)-p2(1)); % Pendiene de la recta vertical
%     if p2(2)< p1(2)
%         yi = p2(2);
%         yd = p1(2);       
%     end
%     if p2(2)> p1(2)
%         yi = p1(2);
%         yd = p2(2);
%     end
%     y2 = [yi:1:yd]; % Variable x de la ecuacion de la recta
%     x2= ((y2 - p1(2))/m2)+ p1(1); % Ecuacion de la recta vertical
%     plot(x2,y2,'g','linewidth',3)
%     v=1;
% end

%% Ciclo for para evaluar toda la recta

% if h==1 % Para evaluar de manera horizontal
%     xin = round(xi);
%     xdn = round(xd);
%     
%     wr = 0;
%     for i = xin:1:xdn
%         
%         y= round(m*(i - p1(1))+ p1(2));
%         fr = Norm([y],[i]); % Inspeccion del valor que tiene la coordenada [fila,columna]
%         
%         if fr <= 0.1 && Norm([y-1],[i-1])>0.1
%             if fr <= 0.1
%                 wr = wr+1 
%             end
%         end
%     end
% end
% 
% if v==1 % Para evaluar de manera vertical
%     xin = round(yi);
%     xdn = round(yd);
%     
%     wr = 0;
%     for i = xin:1:xdn
%         x2= round(((y2 - p1(2))/m2)+ p1(1));
%         fr = Norm([i],[x2]); % Inspeccion del valor que tiene la coordenada [fila,columna]
%         
%         if fr <= 0.1
%             if Norm([i-1],[x2-1])>0.1
%                 if fr <= 0.1
%                     wr = wr+1
%                 end
%             end
%         end
%     end
% end

%% Potencia recibida [dB] - Formula de Friis - Tx - Rx

% Parámetros
% Pt = 0; % Pt = Potencia transmitida [dBm]
% Gt = 3; % Gt = Ganancia transmitica [dBi]
% Gr = 3; % Gr = Ganancia recibida [dBi]
% f = 2.4e9; % Frecuencia
% c = 3e8; % Velocidad de la luz
% n = 2; % Exponente de pérdidas, Espacio libre = 2, Rural = 2.5, Urbano = 4,6.


%Lfs = 10*n*log10(dm) + 20*log10(f) - 20*log10(c/(4*pi)); % Lp = Perdidas de propagración en el espacio libre 
%Prfs = Pt + Gt + Gr - Lfs; % Pr = Potencia recibida en el espacio libre

% Corrección de la formula de friis para considerar obstaculos

%wp = 11.5; % Wp = factor de perdidas por muro [En cemento normal 8- 12 dB]
%Lobs = wr*wp; % Perdidas de obstaculos, Wr = Número de paredes
%Pr = Pt + Gt + Gr - Lfs - Lobs; % Potencia recibida teniendo en cuenta las paredes

%% Asignar colores alos pixeles
% figure
% R = Norm(:,:,1);
% G = Norm(:,:,2);
% B = Norm(:,:,3);
% 
% R = 0/255;
% G = 0/255;
% B = 200/255;
% 
% Norm(:,:,1) = R;
% Norm(:,:,2) = G;
% Norm(:,:,3) = B;
% 
% image(Norm)

