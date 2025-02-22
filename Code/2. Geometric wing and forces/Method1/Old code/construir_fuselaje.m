function [results] = construir_fuselaje(avion,datosEstructural, ala)

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
    flecha_radianes = avion.geometria.flecha_radian;

    % Datos estructural
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    distancia_entre_larguerillo = datosEstructural.distancia_entre_larguerillo;
    n = datosEstructural.n;
    
    % Ala
    % [numero_larguerillos_total, lengths, data] = extract_larguerillos_info(ala);
    numero_larguerillos_total = size(ala.larguerillos,1);
    alfa_larguero_posterior_radianes = ala.geometria.alfa_larguero_posterior_radianes;

    flecha_posterior_radian = alfa_larguero_posterior_radianes;
    % [N, lengths, data] = extract_larguerillos_info(ala.mesh);

    %% Cálculo previo costilla
    numero_costillas_fuselaje = floor(Lf/distancia_entre_costillas);
    costillas_fuselaje = zeros(numero_costillas_fuselaje,2,numero_de_puntos_en_las_lineas); % Dimension (Desde y=0 hacia Lf, (x,y), Desde posterior a anterior)

    %% Construyendo la primer costilla en el medio del avion (y=0).
    costillas_fuselaje(1,:,:) = [zeros(numero_de_puntos_en_las_lineas,1), linspace(Distancia_larguero_posterior_cuerda_porcentaje*c1,Distancia_larguero_anterior_cuerda_porcentaje*c1,numero_de_puntos_en_las_lineas)']';

    %% Construtendo el resto de las costillas
    for i = 2:numero_costillas_fuselaje
        costillas_fuselaje(i,:,:) = [(Lf-distancia_entre_costillas*(numero_costillas_fuselaje-i+1))*ones(numero_de_puntos_en_las_lineas,1), linspace(Distancia_larguero_posterior_cuerda_porcentaje*c1,Distancia_larguero_anterior_cuerda_porcentaje*c1,numero_de_puntos_en_las_lineas)']';
    end
    
    %% Cálculo previo Larguerillos
    longitud_porcentaje_cuerda_largueros = Distancia_larguero_posterior_cuerda_porcentaje - Distancia_larguero_anterior_cuerda_porcentaje; % Es la longitud entre los largueros anterior y posterior
    larguerillos_fuselaje = zeros (numero_larguerillos_total,2,numero_de_puntos_en_las_lineas); % Dimensión: (Desde posterior a anterior, (x,y), Desde el origin hacia Lf)

    %% Construyendo los larguerillos
    for i = 1:numero_larguerillos_total
        larguerillos_fuselaje(i,:,:) =[linspace(0,Lf,numero_de_puntos_en_las_lineas);ones(numero_de_puntos_en_las_lineas,1)'*(c1*Distancia_larguero_posterior_cuerda_porcentaje-(i*distancia_entre_larguerillo/cos(flecha_posterior_radian)))];
    end
  
    %% Cálculos los puntos medios
    puntos_medio_larguero_posterior= zeros(numero_costillas_fuselaje,2);
    puntos_medio_larguero_anterior = zeros(numero_costillas_fuselaje,2);
    puntos_medio_larguerillos = zeros(numero_larguerillos_total,2);
    

    for i = 2:numero_costillas_fuselaje
        puntos_medio_larguero_posterior_fuselaje(i-1,:) = (costillas_fuselaje(i,:,1)+costillas_fuselaje(i-1,:,1))/2;
        puntos_medio_larguero_anterior_fuselaje(i-1,:) = (costillas_fuselaje(i,:,end)+costillas_fuselaje(i-1,:,end))/2;
    end
    
    % La ultima costilla (La más cerca del encastre)
    costilla_final = [costillas_fuselaje(end,:,1) costillas_fuselaje(end,:,end)]; 

    % Encastre (x_top,y,top,x_bot,y_bot)
    Encastre = [Lf c1*Distancia_larguero_posterior_cuerda_porcentaje Lf c1*Distancia_larguero_anterior_cuerda_porcentaje];
    
    %% Cálculos las costillas-costillas media (costilla_costilla_medio_fuselaje)
    % ribs: Mx4 matrix [x1, y1, x2, y2] for each rib
    costilla_costilla_medio_fuselaje = zeros(((numero_costillas_fuselaje * 2)+1),4); %num_costilla*2 + 1(de izquierda a derecha) ,(x,y),(start,end)
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
    % size(costilla_costilla_medio_fuselaje)
    % costilla_costilla_medio_fuselaje
    
    % disp('costilla medio')
    % costilla_costilla_medio_fuselaje(end,:)
    % size(costilla_costilla_medio_fuselaje)
    
    %% Construcción de los nodos en los largueros
    Numero_nodos_elementos_fuselaje = zeros(2+numero_larguerillos_total,2);
    nodos_posterior_fuselaje = [];
    nodos_anterior_fuselaje = [];
    temp_nodos_posterior = 0;
    
    % size(nodos_posterior_fuselaje)
    % size(nodos_anterior_fuselaje)
    nodos_posterior_fuselaje = interleave_matrices(costillas_fuselaje(:,:,1)', puntos_medio_larguero_posterior_fuselaje')';
    nodos_anterior_fuselaje = interleave_matrices(costillas_fuselaje(:,:,end)', puntos_medio_larguero_anterior_fuselaje')';
    % size(nodos_posterior_fuselaje)
    % size(nodos_anterior_fuselaje)
    % Poner los nodos entre el encastre y la costilla final 
    % size([(costilla_final(1)+Encastre(1))/2 ; (costilla_final(2)+Encastre(2))/2])
    % size([(costilla_final(1)+Encastre(1))/2 ; (costilla_final(2)+Encastre(2))/2]')
    % size(nodos_posterior_fuselaje)
    nodos_posterior_fuselaje = [nodos_posterior_fuselaje; [(costilla_final(1)+Encastre(1))/2 ; (costilla_final(2)+Encastre(2))/2]'];
    % size(nodos_posterior_fuselaje)
    nodos_anterior_fuselaje = [nodos_anterior_fuselaje; [(costilla_final(3)+Encastre(3))/2 ; (costilla_final(4)+Encastre(4))/2]'];
    % size(nodos_posterior_fuselaje)
    % size(nodos_anterior_fuselaje)
    nodos_posterior_fuselaje = [nodos_posterior_fuselaje; Encastre(1:2)];
    nodos_anterior_fuselaje = [nodos_anterior_fuselaje; Encastre(3:4)];
    % size(nodos_posterior_fuselaje)
    % size(nodos_anterior_fuselaje)
    % Nodos larguerillos
    Numero_nodos_elementos_fuselaje(1,1) = size(nodos_posterior_fuselaje,1);
    Numero_nodos_elementos_fuselaje(2,1) = size(nodos_anterior_fuselaje,1);
    % Numero_nodos_elementos_fuselaje = Numero_nodos_elementos_fuselaje(1,1) + Numero_nodos_elementos_fuselaje(2,1);

    %% Construcción de los nodos en los larguerillos
    nodos_larguerillos_fuselaje =[];
    intersecciones_costillas_larguerillos = cortes_de_dos_funciones_lineales_v3(squeeze(costilla_costilla_medio_fuselaje(:,:,1)),inf,squeeze(larguerillos_fuselaje(:,:,1)),0);

    % size(costilla_costilla_medio_fuselaje,1)
    % numero_larguerillos_total
    % size(cortes_fuselaje)

    for index_larguerillo_counter = 1:numero_larguerillos_total % El bucle para cada larguerillo
        temp_size_nodos = size(nodos_larguerillos_fuselaje,2);
        
        for index_costilla = 1:size(costilla_costilla_medio_fuselaje,1) % El bucle para las intersecciones del larguerillo y las costillas y sus puntos medios
            nodos_larguerillos_fuselaje = [nodos_larguerillos_fuselaje intersecciones_costillas_larguerillos(index_costilla,index_larguerillo_counter,:)];
        end
        
        Numero_nodos_elementos_fuselaje(index_larguerillo_counter+2,1) = size(nodos_larguerillos_fuselaje,2) - temp_size_nodos;

    end
    % 
    % %% Construcción de las barras
    % % % Creando las barras en los largueros posterior y anterior
    % barras_fuselaje_larguero_posterior = [];
    % barras_fuselaje_larguero_anterior = [];
    % barras_fuselaje_larguerillos = [];
    % 
    % 
    % %% Creando los primeros elementos en el larguero posterior
    % for i = 1 : Numero_nodos_elementos_fuselaje(1,1)-1
    %     barras_fuselaje_larguero_posterior = [barras_fuselaje_larguero_posterior [i;i+1]];
    % end
    % 
    % numero_elementos_larguero_posterior_fuselaje = size(barras_fuselaje_larguero_posterior,2);
    % if output_command
    %     fprintf('Numero de elementos en el larguero posterior = %d\n', numero_elementos_larguero_posterior_fuselaje);
    %     fprintf('Elementos 1 : %d\n', numero_elementos_larguero_posterior_fuselaje);
    % end
    % 
    % % counter_nodos_larguero_posterior_ala = Numero_nodos_elementos_fuselaje(1,1);
    % 
    % %% Creando Los elementos en el larguero anterior
    % % Numero_nodos_elementos_fuselaje(2,1)
    % for i = 1 : Numero_nodos_elementos_fuselaje(2,1)-1
    %     % Numero_nodos_elementos_fuselaje(2,1)
    %     barras_fuselaje_larguero_anterior = [barras_fuselaje_larguero_anterior [i;i+1]];
    % end
    % numero_elementos_larguero_anterior_fuselaje = size(barras_fuselaje_larguero_anterior,2);
    % 
    % if output_command
    %     fprintf('Numero de elementos en el larguero anterior = %d\n', numero_elementos_larguero_anterior_fuselaje);
    %     fprintf('Elementos %d : %d\n', numero_elementos_larguero_posterior_fuselaje+1,numero_elementos_larguero_posterior_fuselaje+numero_elementos_larguero_anterior_fuselaje);
    % end
    % 
    % % % Es el número de barra en donde empieza los elementos de los
    % % % larguerillos;
    % % counter_barras = numero_elementos_larguero_posterior_fuselaje+numero_elementos_larguero_anterior_fuselaje;
    % % % Está counter es donde empezó el nodo de los larguerillos.
    % % counter_barras_nodos = numero_nodos_larguero_posterior_fuselaje+numero_nodos_larguero_anterior_ala;
    % 
    % Numero_nodos_elementos_fuselaje(1,2) = numero_elementos_larguero_posterior_fuselaje;
    % Numero_nodos_elementos_fuselaje(2,2) = numero_elementos_larguero_anterior_fuselaje;
    % Numero_nodos_elementos_fuselaje_temp = Numero_nodos_elementos_fuselaje(3:end,:)
    % 
    % temp_node = 0;
    % %% Creando Los elementos en los larguerillos
    % for index_larguerillo_counter = 1:numero_larguerillos_total % El bucle para cada larguerillo
    %     temp_size_barras = size(barras_fuselaje_larguerillos,2);
    % 
    %     % Construyendo la barra en larguerillo numero = index_larguerillo_counter  
    % 
    %     for index_nodos = 1:Numero_nodos_elementos_fuselaje(index_larguerillo_counter+2,1)-1
    %         barras_fuselaje_larguerillos = [barras_fuselaje_larguerillos [temp_node + index_nodos; temp_node + index_nodos + 1]];
    %     end
    % 
    % 
    %     temp_node = sum(Numero_nodos_elementos_fuselaje_temp(1:index_larguerillo_counter,1));
    % 
    %     Numero_nodos_elementos_fuselaje(2+index_larguerillo_counter,2) = size(barras_fuselaje_larguerillos,2) - temp_size_barras;
    % 
    %     % counter_barras_nodos = counter_barras_nodos + index_larguerillos_anterior(index_larguerillo_counter);
    %     % numeros_elementos_larguerillos_index = counter_barras-counter_barra_minus_i;
    %     if output_command
    %         fprintf('---Numero de barras en el larguerillo numero %d = %d\n',index_larguerillo_counter, Numero_nodos_elementos_fuselaje(2+index_larguerillo_counter,2));
    %         fprintf('Elements %d : %d\n', temp_size_barras+1,size(barras_fuselaje_larguerillos,2));
    %         fprintf('nodos %d : %d\n', temp_node + 1,temp_node + Numero_nodos_elementos_fuselaje(index_larguerillo_counter+2,1));
    %     end
    % end

    %% Guardando los resultados
    results.larguerillos_fuselaje = larguerillos_fuselaje;
    results.costillas_fuselaje = costillas_fuselaje;
    results.numero_costillas_fuselaje = numero_costillas_fuselaje;
    
    % Nodos y elementos
    
    results.mesh.nodos_larguerillos_fuselaje = nodos_larguerillos_fuselaje; % larguerillos
    results.mesh.nodos_posterior_fuselaje = nodos_posterior_fuselaje; % Los nodos en el larguero posterior.
    results.mesh.nodos_anterior_fuselaje = nodos_anterior_fuselaje; % Los nodos en el larguero posterior.
    results.mesh.intersecciones_costillas_larguerillos = intersecciones_costillas_larguerillos;
    results.mesh.Numero_nodos_elementos_fuselaje = Numero_nodos_elementos_fuselaje;
    % results.mesh.barras_fuselaje_larguero_posterior = barras_fuselaje_larguero_posterior;
    % results.mesh.barras_fuselaje_larguero_anterior = barras_fuselaje_larguero_anterior;
    % results.mesh.barras_fuselaje_larguerillos = barras_fuselaje_larguerillos;
end