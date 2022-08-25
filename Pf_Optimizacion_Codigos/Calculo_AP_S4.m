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
suma = [];
cordenada = [];
contador = 0;
% Coordenadas Ap
for yAP = 85:5:174 % No se considera el borde del plano
    for xAP = 101:5:264
        y1 = yAP; % Eje y
        x1 = xAP; % Eje x
        p1 = [x1,y1]; % Punto Ap

        %figure
        %image(Norm)
        %hold on
        %plot([p1(1),p1(1)],[p1(2),p1(2)],'o','Color','r','LineWidth',3)
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
         Sum_p = 0;   
        for yp = 85:5:174 % No se considera el borde del plano
            for xp = 101:5:264
                if (xAP ~= xp && yAP ~= yp) || (xAP == xp && yAP ~= yp) 
                    if Norm([yp],[xp]) > 0.95 % Condición para no tener en cuenta los muros
                        pp = [xp,yp]; % Coordenadas
                        j = j+1; 
                        %pp = Norm([xp],[yp])
                        %hold on
                        %plot([pp(1),pp(1)],[pp(2),pp(2)],'o','Color','b','LineWidth',1)

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

                        Sum_p = Sum_p + sum(sum(PR));
                    end
                end % End de la condicion para que no tome los muros
            end % End del ciclo for de coordenadas
        end
        contador = contador + 1;
        suma(contador)= Sum_p;
        cordenada(1,contador)=xAP;
        cordenada(2,contador)=yAP;
    end
end
[m,U]=max(suma);
cordenada(1,U)
cordenada(2,U)