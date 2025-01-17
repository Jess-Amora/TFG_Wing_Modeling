function [results] = construir_fuselaje_v2(avion,datosEstructural)

% Parámetros de entrada:
    %   - wingParams: Estructura con los siguientes campos:
    %       * Lf: Longitud del fuselaje en la unión del ala
    %       * c1: Cuerda en el encastre
    %       * c2: Cuerda en la punta
    %       * x_local_ala: Coordenadas locales de la envergadura
    %       * y_global_punta_ala_borde_ataque: Coordenada Y del borde de ataque en la punta
    %       * Distancia_larguero_anterior_cuerda_porcentaje: Porcentaje de la cuerda para el larguero anterior
    %       * Distancia_larguero_posterior_cuerda_porcentaje: Porcentaje de la cuerda para el larguero posterior
    %       * numero_de_puntos_en_las_lineas: Resolución de las líneas
    %       * distancia_centro_aerodinamico: Posición del centro aerodinámico
    %       * distancia_eje_de_referencia_estructural_cuerda: Posición del eje estructural
    %       * flecha_radianes: Ángulo de flecha en radianes
    %       * Lw: Longitud del ala (semienvergadura)

    
            
    % Extraer parámetros
    % Geometría
    Lf = avion.geometria.Lf;
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    b = avion.geometria.b;
    MTOW = avion.MTOW;

    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha.radian;
    % Datos estructural
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    distancia_entre_larguerillo = datosEstructural.distancia_entre_larguerillo;
    n = datosEstructural.n;

    numero_costillas_fuselaje = floor(Lf/distancia_entre_costillas);


    costillas_fuselaje = zeros(numero_costillas_fuselaje,2,numero_de_puntos_en_las_lineas); % Dimension (Desde y=0 hacia Lf, (x,y), Desde posterior a anterior)

    costillas_fuselaje(1,:,:) = [zeros(numero_de_puntos_en_las_lineas,1), linspace(Distancia_larguero_posterior_cuerda_porcentaje*c1,Distancia_larguero_anterior_cuerda_porcentaje*c1,numero_de_puntos_en_las_lineas)']';


    for i = 2:numero_costillas_fuselaje
        costillas_fuselaje(i,:,:) = [(Lf-distancia_entre_costillas*(numero_costillas_fuselaje-i+1))*ones(numero_de_puntos_en_las_lineas,1), linspace(Distancia_larguero_posterior_cuerda_porcentaje*c1,Distancia_larguero_anterior_cuerda_porcentaje*c1,numero_de_puntos_en_las_lineas)']';
    end
    
    % Larguerillos
    longitud_porcentaje_cuerda_largueros = Distancia_larguero_posterior_cuerda_porcentaje - Distancia_larguero_anterior_cuerda_porcentaje; % Es la longitud entre los largueros anterior y posterior
    numero_larguerillos_total = floor(c1*longitud_porcentaje_cuerda_largueros/distancia_entre_larguerillo);
    larguerillos_fuselaje = zeros (numero_larguerillos_total,2,numero_de_puntos_en_las_lineas); % Dimensión: (Desde y=0 hacia Lf, (x,y), Desde posterior a anterior)

    % size(larguerillos_fuselaje)
    % numero_larguerillos_total
    for i = 1:numero_larguerillos_total
        size(larguerillos_fuselaje(i,:,:))
        size(linspace(0,Lf,numero_de_puntos_en_las_lineas))
        size(ones(numero_de_puntos_en_las_lineas,1)'*(c1*Distancia_larguero_posterior_cuerda_porcentaje-(i*distancia_entre_larguerillo)))
        size([linspace(0,Lf,numero_de_puntos_en_las_lineas);ones(numero_de_puntos_en_las_lineas,1)'*(c1*Distancia_larguero_posterior_cuerda_porcentaje-(i*distancia_entre_larguerillo))])
        larguerillos_fuselaje(i,:,:) =[linspace(0,Lf,numero_de_puntos_en_las_lineas);ones(numero_de_puntos_en_las_lineas,1)'*(c1*Distancia_larguero_posterior_cuerda_porcentaje-(i*distancia_entre_larguerillo))];
    end

  

    % puntos medio
    puntos_medio_larguero_posterior= zeros(numero_costillas_fuselaje,2);
    puntos_medio_larguero_anterior = zeros(numero_costillas_fuselaje,2);
    puntos_medio_larguerillos = zeros(numero_larguerillos_total,2);
    

    for i = 2:numero_costillas_fuselaje
        puntos_medio_larguero_posterior_fuselaje(i-1,:) = (costillas_fuselaje(i,:,1)+costillas_fuselaje(i-1,:,1))/2;
        puntos_medio_larguero_anterior_fuselaje(i-1,:) = (costillas_fuselaje(i,:,end)+costillas_fuselaje(i-1,:,end))/2;
    end

    
    nodos_posterior_fuselaje = interleave_matrices(costillas_fuselaje(:,:,1)', puntos_medio_larguero_posterior_fuselaje');
    nodos_anterior_fuselaje = interleave_matrices(costillas_fuselaje(:,:,end)', puntos_medio_larguero_anterior_fuselaje');

    % Cambiar las dimensiones de 2x num costillas a 1 x num_costillas*2 ((x,y;x,y)->(x y x y))
    nodos_posterior_fuselaje = reshape(nodos_posterior_fuselaje, 1, []);
    nodos_anterior_fuselaje = reshape(nodos_anterior_fuselaje, 1, []);
    
    % La ultima costilla (La más cerca del encastre)
    costilla_final = [costillas_fuselaje(i,:,1) costillas_fuselaje(i,:,end)]; 
    % Encastre (x_top,y,top,x_bot,y_bot)
    Encastre = [Lf c1*Distancia_larguero_posterior_cuerda_porcentaje Lf c1*Distancia_larguero_anterior_cuerda_porcentaje];

    % Poner los nodos entre el encastre y la costilla final 
    nodos_posterior_fuselaje = [nodos_posterior_fuselaje (costilla_final(1)+Encastre(1))/2 (costilla_final(2)+Encastre(2))/2];
    nodos_anterior_fuselaje = [nodos_anterior_fuselaje (costilla_final(3)+Encastre(3))/2 (costilla_final(4)+Encastre(4))/2];

    % Poner los nodos en el encastre
    nodos_posterior_fuselaje = [nodos_posterior_fuselaje Encastre(1) Encastre(2)];
    nodos_anterior_fuselaje = [nodos_anterior_fuselaje Encastre(3) Encastre(4)];
    
    % Construir ribs_ribs_medio
    % ribs: Mx4 matrix [x1, y1, x2, y2] for each rib
    costilla_costilla_medio_fuselaje = zeros((numero_costillas_fuselaje * 2)+1,4); %num_costilla*2 -1 ,(x,y),(start,end)
    j=1;
    for i= 1 : numero_costillas_fuselaje-1
        costilla_costilla_medio_fuselaje(j,:) = [costillas_fuselaje(i,:,1) costillas_fuselaje(i,:,end)]; % x_r y_r x_t y_t
        j=j+1;
        costilla_costilla_medio_fuselaje(j,:) = [(costillas_fuselaje(i+1,:,1)+costillas_fuselaje(i,:,1))/2 (costillas_fuselaje(i+1,:,end)+costillas_fuselaje(i,:,end))/2];
        j=j+1;
    end
    
    % Hay que añadir la costilla final y el punto medio de la costilla
    % final y el encastre
    costilla_costilla_medio_fuselaje(j,:) = [costillas_fuselaje(end,:,1) costillas_fuselaje(end,:,end)];
    costilla_costilla_medio_fuselaje(j+1,:) = [(costillas_fuselaje(end,:,1)+Encastre(1:2))/2 (costillas_fuselaje(end,:,end)+Encastre(3:4))/2];

    %Encastre
    costilla_costilla_medio_fuselaje(end,:) = Encastre; % x_r y_r x_t y_t
    size(costilla_costilla_medio_fuselaje)
    costilla_costilla_medio_fuselaje
    
    % disp('costilla medio')
    % costilla_costilla_medio_fuselaje(end,:)
    % size(costilla_costilla_medio_fuselaje)

    % Nodos larguerillos

    %larguerillo 1
    nodos_larguerillos_fuselaje =[];
    

    for j=1:numero_larguerillos_total % El bucle para cada larguerillo

       
        larguerillos_i = [larguerillos_fuselaje(j,:,1) larguerillos_fuselaje(j,:,end)]; % x_r y_r x_t y_t

        for i = 1:size(costilla_costilla_medio_fuselaje,1) % El bucle para las intersecciones del larguerillo y las costillas y sus puntos medios
            costillas_i = costilla_costilla_medio_fuselaje(i,:);
            nodos_larguerillos_fuselaje = [nodos_larguerillos_fuselaje generate_stringer_nodes(larguerillos_i, costillas_i)];
        end

        % En esta línea, se hace el nodo que es una intersección
        % entre el punto medio de la costilla final y el encastre, y el larguerillo
        nodos_larguerillos_fuselaje = [nodos_larguerillos_fuselaje generate_stringer_nodes(larguerillos_i, (costilla_costilla_medio_fuselaje(end,:) + Encastre)/2)];

        % En esta línea, se hace el nodo final que es una intersección
        % entre el encastre y el larguerillo
        nodos_larguerillos_fuselaje = [nodos_larguerillos_fuselaje generate_stringer_nodes(larguerillos_i,Encastre )];

    end

    results.larguerillos_fuselaje = larguerillos_fuselaje;
    results.costillas_fuselaje = costillas_fuselaje;
    results.numero_costillas_fuselaje = numero_costillas_fuselaje;
    
    % Nodos y elementos
    
    results.mesh.nodos_larguerillos_fuselaje = nodos_larguerillos_fuselaje; % larguerillos
    results.mesh.nodos_posterior_fuselaje = nodos_posterior_fuselaje; % Los nodos en el larguero posterior.
    results.mesh.nodos_anterior_fuselaje = nodos_anterior_fuselaje; % Los nodos en el larguero posterior.


end