function [results] = construirAla(avion,datosEstructural,cargas)

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
    distancia_entre_larguerillo = datosEstructural.distancia_entre_larguerillo;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    n = datosEstructural.n;

    % Coordenadas
    x_local_ala = avion.coordenadas.x_local_ala;

    % Cargas
    schrenk = cargas.schrenk;

    % La línea del larguero anterior
    linea_larguero_anterior=linspace(c1*Distancia_larguero_anterior_cuerda_porcentaje,y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,numero_de_puntos_en_las_lineas);
    
    % La línea del larguero posterior
    linea_larguero_posterior=linspace(c1*Distancia_larguero_posterior_cuerda_porcentaje,y_global_punta_ala_borde_ataque+Distancia_larguero_posterior_cuerda_porcentaje*c2,numero_de_puntos_en_las_lineas);
    
    % La línea de los centros aerodinámicos
    linea_centro_aerodinamico=linspace(c1*distancia_centro_aerodinamico,c1*distancia_centro_aerodinamico+Lw*sin(flecha_radianes),numero_de_puntos_en_las_lineas);
    
    % % La línea del eje de referencia estructural
    linea_eje_estructural=linspace(c1*distancia_eje_de_referencia_estructural_cuerda,c2*distancia_eje_de_referencia_estructural_cuerda+y_global_punta_ala_borde_ataque,numero_de_puntos_en_las_lineas);

    %% ETAPA 2: Discretizaciçon
    % Nomenclatura
    % Los valores con constante_... son los valores de la constante/la ordenada
    % al origen (y_0 o y(x=0) de la ecuación lineal y = y_0 + m * x. En esos
    % puntos, se dibujan las líneas.
    % 
    % Los variables coord_..._..._ son las coordenadas de las dos líneas. 
    % l es el vector que contiene la distribución de sustentación. x_l y y_l
    %   son sus coordenadas (punto medio linea aerodinamico)
    % coord_aerodinamica_costillas_punto_medio - las coordenadas de todos los
    %   puntos medio en la linea aerodinamica
    % coord_aerodinamica_costillas - las coordenadas de todos los
    %   puntos de intersección aerodinamica-costillas
    % costillas - es la matriz que contiene todas las lineas de las costillas
    %   que tiene un tamaño de (numero de costillas, (x,y), numero de puntos en
    %   las lineas)
    
    
    %cálculos previos
    
    % En esta parte se calculan los pendientes de las líneas.
    pendiente_larguero_anterior = (linea_larguero_anterior(end) - linea_larguero_anterior(1)) / (Lw);
    pendiente_larguero_posterior = (linea_larguero_posterior(end) - linea_larguero_posterior(1)) / (Lw);
    pendiente_eje_estructural = (linea_eje_estructural(end) - linea_eje_estructural(1)) / (Lw);
    % pendiente_centro_aerodinamico = tan(flecha_radianes);
    pendiente_perpendicular_larguero_posterior = -1 / pendiente_larguero_posterior;
    
    % Cálculos de los valores de los cortes de las líneas en el eje y vertical (x=0).
    % A(x=0) = A(Lf) - pendiente * Lf
    constante_linea_larguero_anterior = linea_larguero_anterior(1) - pendiente_larguero_anterior * Lf;
    constante_linea_larguero_posterior = linea_larguero_posterior(1) - pendiente_larguero_posterior * Lf;
    constante_linea_eje_estructural = linea_eje_estructural(1) - pendiente_eje_estructural * Lf;
    % constante_linea_centro_aerodinamico = linea_centro_aerodinamico(1) - pendiente_centro_aerodinamico * Lf;
    
    % % Para verificación: Esta línea es para cálcular la longitud del larguero posterior total
    % % Esta línea es para calcular el promedio del número de costillas que es lacoord_interseccion_aerod_cost
    % % longitud/distancia_entre_costillas
    longitud_larguero_posterior=norm([Lw+Lf y_global_punta_ala_borde_ataque+c2*Distancia_larguero_posterior_cuerda_porcentaje]-[Lf c1*Distancia_larguero_posterior_cuerda_porcentaje]);
    promedio_num_costillas = longitud_larguero_posterior/distancia_entre_costillas;
    numero_costillas=floor(promedio_num_costillas);
    
    % Dimensiones costillas (encastre-punta, (x,y), posterior-anterior)
    costillas = zeros(numero_costillas,2,numero_de_puntos_en_las_lineas);
    
    % intersección centro aerodinámico
    coord_aerodinamico_costillas = zeros(numero_costillas,2);
    coord_aerodinamica_costillas_punto_medio= zeros(numero_costillas-1,2);
        
    % Sustentación
    l=zeros(numero_costillas-1,1);
    
    % El ángulo de la línea del larguero posterior
    alfa_larguero_posterior_radianes=atan(pendiente_larguero_posterior);
    distancia_entre_larguerillo_vertical = distancia_entre_larguerillo/cos(alfa_larguero_posterior_radianes);
    
    % Esta parte es para generar los puntos en la linea larguero posterior para
    % construir las costillas
    %costillas datos

    % Está línea está construyendo las coordenadas en el larguero posterior
    coord_costillas_larguero_posterior_x = Lf:distancia_entre_costillas*cos(alfa_larguero_posterior_radianes):(numero_costillas-1)*distancia_entre_costillas*cos(alfa_larguero_posterior_radianes)+Lf;
    coord_costillas_larguero_posterior_y = spline(x_local_ala,linea_larguero_posterior,coord_costillas_larguero_posterior_x);
    
    % Esta parte es para ver si este bien colocado los origen de las costillas
    % plot(coord_costillas_larguero_posterior_x,coord_costillas_larguero_posterior_y, 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'k')
    % norm([coord_costillas_larguero_posterior_x(2) coord_costillas_larguero_posterior_y(2)]-[coord_costillas_larguero_posterior_x(1) coord_costillas_larguero_posterior_y(2)])
    % numero_costillas
    % distancia_entre_costillas
    
    % Es un valor para hallar la intersección de la costilla al larguero
    % anterior siendo la costilla es una linea perpendicular al larguero
    % posterior
    constante_perpendicular_larguero_posterior = coord_costillas_larguero_posterior_y - pendiente_perpendicular_larguero_posterior * coord_costillas_larguero_posterior_x;
    
    %% Costilla
    for i = 1:numero_costillas
        
        % Está coordenada coord_costillas_larguero_anterior es la coordenada de
        % las intersecciones entre la costilla y el larguero anterior
        coord_costillas_larguero_anterior_x = -(constante_linea_larguero_anterior - constante_perpendicular_larguero_posterior(i)) / (pendiente_larguero_anterior - pendiente_perpendicular_larguero_posterior);
        coord_costillas_larguero_anterior_y = pendiente_larguero_anterior * coord_costillas_larguero_anterior_x + constante_linea_larguero_anterior;
    
        % plot(coord_costillas_larguero_anterior_y,coord_costillas_larguero_anterior_x,'d')
        costillas(i,1,:)=linspace(coord_costillas_larguero_posterior_x(i),coord_costillas_larguero_anterior_x,numero_de_puntos_en_las_lineas);
        costillas(i,2,:)=linspace(coord_costillas_larguero_posterior_y(i),coord_costillas_larguero_anterior_y,numero_de_puntos_en_las_lineas);
    
    
        % Estos plot es para verificar que esten calculados bien.
        % plot(coord_costillas_larguero_anterior_x,coord_costillas_larguero_anterior_y,'o');
        % plot(squeeze (costillas(i,1,:)),squeeze (costillas(i,2,:)));
    
    
        % Las intersecciones de las costillas con la línea de los centros aerodinámicos
        [coord_aerodinamico_costillas(i,1),coord_aerodinamico_costillas(i,2),~] = polyxpoly(costillas(i,1,:),costillas(i,2,:),x_local_ala,linea_centro_aerodinamico);
    
    
        %punto medio
        if i~=1
            
            % Se guardan los puntos medio entre costillas de la línea de los centros
            % aerodinámicos.
            coord_aerodinamica_costillas_punto_medio(i-1,1)= (coord_aerodinamico_costillas(i-1,1)+coord_aerodinamico_costillas(i,1))/2;
            coord_aerodinamica_costillas_punto_medio(i-1,2) = (coord_aerodinamico_costillas(i-1,2)+coord_aerodinamico_costillas(i,2))/2;
            %plot(coord_aerodinamica_costillas_punto_medio(i-1,1),coord_aerodinamica_costillas_punto_medio(i-1,2),'d')
    
            % Se aplican las cargas aerodinámicas en ese punto medio. Más
            % información ver chatgpt notes
            %Sustentación
            l(i-1) = spline (x_local_ala,schrenk,coord_aerodinamica_costillas_punto_medio(i-1,1));
            l(i-1) = l(i-1) * n * MTOW * 2 / Lw^2;
    
        end
    
    
    end
    
    % Verificación perpendicularidad costilla-larg_post
    x1=costillas(1,1,1);
    y1=costillas(1,2,1);
    x2=costillas(1,1,2);
    y2=costillas(1,2,2);
    x3=x_local_ala(1);
    y3=linea_larguero_posterior(1);
    x4=x_local_ala(2);
    y4=linea_larguero_posterior(2);
    % m1 = (y2 - y1) / (x2 - x1); % Slope of Line 1
    % m2 = (y4 - y3) / (x4 - x3); % Slope of Line 2
    
    
    
    % Añadiendo el resto de las costillas
    % el trianglo que está formado por los vértices (Lf,c1*distancia larguero
    % posterior), (Lf,c1*distancia larguero anterior), (x_cotilla1,y_costilla1)
    % linea_interseccion_costilla_fuselaje=linspace(c1*Distancia_larguero_posterior_cuerda_porcentaje,0,numero)
    % [0.25*c1 linea_centro_aerodinamico(1)]
    
    % numero_costillas_triangulo=floor((c1*Distancia_larguero_posterior_cuerda_porcentaje)/(.4/sin(alfa_larguero_posterior_radianes)))-1;
    % numero_costillas_triangulo = 0;
    % Sólo cojo a partir de la línea de los centros aerodinámicos hacia arriba
    coord_costillas_larguero_posterior_y_triangulo = c1*Distancia_larguero_posterior_cuerda_porcentaje:-distancia_entre_costillas/sin(alfa_larguero_posterior_radianes):c1*.25;
    numero_costillas_triangulo = size(squeeze(coord_costillas_larguero_posterior_y_triangulo),2)-1;
    coord_costillas_larguero_posterior_x_triangulo = Lf*ones(numero_costillas_triangulo,1);
    coord_costillas_larguero_posterior_y_triangulo(1) = [];
    
    
    % plot(coord_costillas_larguero_posterior_x_triangulo,coord_costillas_larguero_posterior_y_triangulo,'o')
    
    costillas_triangulo = zeros(numero_costillas_triangulo,2,numero_de_puntos_en_las_lineas);
    
    % %intersección centro aerodinámico
    coord_aerodinamica_costillas_triangulo=zeros(numero_costillas_triangulo,2);
    coord_aerodinamica_costillas_punto_medio_triangulo=zeros(numero_costillas_triangulo-1,2);
    
    % Las constantes/ordenada de origen de las líneas de las costillas dentro
    % del triangulo. Se necesitan estos, porque para calcular las
    % intersecciones costillas-larguero anterior, se requieren estos puntos.
    constante_perpendicular_larguero_posterior_triangulo = coord_costillas_larguero_posterior_y_triangulo - pendiente_perpendicular_larguero_posterior * coord_costillas_larguero_posterior_x_triangulo';
    size(constante_perpendicular_larguero_posterior_triangulo);
    size(constante_perpendicular_larguero_posterior);
    constante_perpendicular_larguero_posterior = [constante_perpendicular_larguero_posterior_triangulo';constante_perpendicular_larguero_posterior'];
    
    %% Sustentación
    l_triangulo=zeros(numero_costillas_triangulo-1,1);
    
    for i = 1:numero_costillas_triangulo
    
    
        coord_costillas_larguero_anterior_x_triangulo = (constante_perpendicular_larguero_posterior_triangulo(i) - constante_linea_larguero_anterior) / (pendiente_larguero_anterior - pendiente_perpendicular_larguero_posterior);
        coord_costillas_larguero_anterior_y_triangulo = pendiente_larguero_anterior * coord_costillas_larguero_anterior_x_triangulo + constante_linea_larguero_anterior;
    
        % plot(coord_costillas_larguero_anterior_x_triangulo,coord_costillas_larguero_anterior_y_triangulo,'d')
    
        % plot(coord_costillas_larguero_anterior_y,coord_costillas_larguero_anterior_x,'d')
        costillas_triangulo(i,1,:)=linspace(coord_costillas_larguero_posterior_x_triangulo(i),coord_costillas_larguero_anterior_x_triangulo,numero_de_puntos_en_las_lineas);
        costillas_triangulo(i,2,:)=linspace(coord_costillas_larguero_posterior_y_triangulo(i),coord_costillas_larguero_anterior_y_triangulo,numero_de_puntos_en_las_lineas);
    
        % plot(squeeze(costillas_triangulo(i,1,:)),squeeze(costillas_triangulo(i,2,:)))
    
        %%% intersección costillas x centro aerodinámico
        [coord_aerodinamica_costillas_triangulo(i,1),coord_aerodinamica_costillas_triangulo(i,2),~] = polyxpoly(costillas_triangulo(i,1,:),costillas_triangulo(i,2,:),x_local_ala,linea_centro_aerodinamico);
    
    
        %punto medio
        if i~=1
    
            coord_aerodinamica_costillas_punto_medio_triangulo(i-1,1)= (coord_aerodinamica_costillas_triangulo(i-1,1)+coord_aerodinamica_costillas_triangulo(i,1))/2;
            coord_aerodinamica_costillas_punto_medio_triangulo(i-1,2) = (coord_aerodinamica_costillas_triangulo(i-1,2)+coord_aerodinamica_costillas_triangulo(i,2))/2;
            % plot(coord_aerodinamica_costillas_punto_medio_triangulo(i-1,1),coord_aerodinamica_costillas_punto_medio_triangulo(i-1,2),'d')
    
            % Sustentación
            l_triangulo(i-1)=spline(x_local_ala,schrenk,coord_aerodinamica_costillas_punto_medio_triangulo(i-1,1));
            l_triangulo(i-1)=l_triangulo(i-1)*n*MTOW*2/Lw^2;
            % f5=stem3(coord_aerodinamica_costillas_punto_medio_triangulo(i-1,1),coord_aerodinamica_costillas_punto_medio_triangulo(i-1,2),l(i-1),'b');
            % view(3)
    
        end
     
    end
    
    
    %% Sustentación triangulo
    %
    x_union_triangulo_resto = (coord_aerodinamica_costillas_triangulo(1,1)+coord_aerodinamico_costillas(1,1))/2;
    y_union_triangulo_resto = (coord_aerodinamica_costillas_triangulo(1,2)+coord_aerodinamico_costillas(1,2))/2;
    %plot(x_union_triangulo_resto,y_union_triangulo_resto,'d')
    l_union=spline(x_local_ala,schrenk,x_union_triangulo_resto);
    l_union=l_union*n*MTOW*2/Lw^2;
    
    % Sustentación de la distribución continua (l(x)) 
    l_triangulo=flip(l_triangulo);
    l = [l_triangulo; l_union; l ];
    x_l = [flip(coord_aerodinamica_costillas_punto_medio_triangulo(:,1)) ;x_union_triangulo_resto; coord_aerodinamica_costillas_punto_medio(:,1)];
    y_l = [flip(coord_aerodinamica_costillas_punto_medio_triangulo(:,2)) ;y_union_triangulo_resto; coord_aerodinamica_costillas_punto_medio(:,2)];
    % stem3(x_l,y_l,l,'b')
    % view(3)
    % Juntando todo
    coord_aerodinamica_costillas_punto_medio = [flip(coord_aerodinamica_costillas_punto_medio_triangulo)' [x_union_triangulo_resto y_union_triangulo_resto]'  coord_aerodinamica_costillas_punto_medio']';
    coord_aerodinamico_costillas = [flip(coord_aerodinamica_costillas_triangulo)' coord_aerodinamico_costillas'];
    
    % Dimension costillas 
    % Dim 1(numero de costillas) orden de costillas de izquierda a derecha, es decir,  desde fuselaje hast la punta
    % Dim 2 (X,Y)
    % Dim 3 (desde posterior hasta anterior)
    costillas = cat(1,flip(costillas_triangulo),costillas);
        
    % Para encontrar la k constante de la sustentación
    
    numero_costillas = numero_costillas_triangulo+numero_costillas;
    
    
    % Sustentación de la distribución continua (L_ala)
    L = zeros(numero_costillas-3,1);
    % x_L = zeros(size(L,1),1);
    x_L = x_l(2:end-1);
    % y_L = zeros(size(L,1),1);
    y_L = y_l(2:end-1);
    for i = 2:numero_costillas-2
        L(i-1)=(1/6) *(x_l(i+1)-x_l(i)) * (2*l(i)+l(i+1)) + (1/6)*(x_l(i)-x_l(i-1)) * (l(i)+2*l(i-1));
    end
    
    cociente_L_W_inicial=2*sum(L)/n/MTOW;
    % cociente_L_W_inicial
    

    

    %% Larguerillos y mesh

    % Rehacer costilla
    % new_dimension = zeros(size(costilla,1), 1, (size(costilla,3)); % Create a 46x1x1000 matrix of zeros
    % costilla = cat(2, costilla, new_dimension); % 46x3x1000
    % H = 0;


    longitud_porcentaje_cuerda_largueros = Distancia_larguero_posterior_cuerda_porcentaje - Distancia_larguero_anterior_cuerda_porcentaje; % Es la longitud entre los largueros anterior y posterior
    numero_larguerillos_total = floor(c1*longitud_porcentaje_cuerda_largueros/distancia_entre_larguerillo_vertical);
    numero_larguerillos_costilla_final = floor(norm(costillas(end,:,1)-costillas(end,:,end))/distancia_entre_larguerillo_vertical);
    larguerillos = zeros (numero_larguerillos_total,2,numero_de_puntos_en_las_lineas); % Dimension (De larguero posterior a anterior,(x,y), encastre a punta/larguero_anterior)

    coord_encastre_larguerillo_x = Lf * ones(numero_larguerillos_total,1);
    coord_encastre_larguerillo_y = c1*Distancia_larguero_posterior_cuerda_porcentaje-(distancia_entre_larguerillo_vertical*linspace(1,numero_larguerillos_total,numero_larguerillos_total));
    constante_encastre_larguerillo = (coord_encastre_larguerillo_y' - pendiente_larguero_posterior * coord_encastre_larguerillo_x);


    for i=1:numero_larguerillos_costilla_final
        larguerillos(i,:,:) = [linspace(Lf,Lf+Lw,numero_de_puntos_en_las_lineas) ... 
            ;linspace(c1*Distancia_larguero_posterior_cuerda_porcentaje-(i*distancia_entre_larguerillo_vertical) , y_global_punta_ala_borde_ataque+ c2*Distancia_larguero_posterior_cuerda_porcentaje-(i*distancia_entre_larguerillo_vertical), numero_de_puntos_en_las_lineas)];

    end


    for i=(numero_larguerillos_costilla_final+1):numero_larguerillos_total

        coord_larguerillo_larguero_anterior_x = -(constante_linea_larguero_anterior - constante_encastre_larguerillo(i)) / (pendiente_larguero_anterior - pendiente_larguero_posterior);
        coord_larguerillo_larguero_anterior_y = pendiente_larguero_anterior * coord_larguerillo_larguero_anterior_x + constante_linea_larguero_anterior;


        larguerillos(i,:,:) = [linspace(Lf,coord_larguerillo_larguero_anterior_x,numero_de_puntos_en_las_lineas) ... 
            ;linspace(c1*Distancia_larguero_posterior_cuerda_porcentaje-(i*distancia_entre_larguerillo_vertical) , coord_larguerillo_larguero_anterior_y, numero_de_puntos_en_las_lineas)];

    end
    
    
    

    % % Counter
    % counter_borde_de_salida_ala = 0;
    % counter_borde_de_ataque_ala = 0;

    % % Creando las líneas en los larguer
    % puntos medio
    puntos_medio_larguero_posterior_ala = zeros(numero_costillas-1,2);
    puntos_medio_larguero_anterior_ala = zeros(numero_costillas-1,2);

    for i = 2:numero_costillas
        puntos_medio_larguero_posterior_ala(i-1,:) = (costillas(i,:,1)+costillas(i-1,:,1))/2;
        puntos_medio_larguero_anterior_ala(i-1,:) = (costillas(i,:,end)+costillas(i-1,:,end))/2;
    end

     %% Construir costilla_costilla_medio: es la matriz que contiene toda las
    % costillas incluyendo la "costilla intermedia".
    % costilla_costilla_medio: Mx4 matriz de (num_costilla*2 -1 ,[(x,y)_start,(x,y)_end])
    costilla_costilla_medio = zeros((numero_costillas * 2)-1,4); 
    j=1;
    for i= 1 : numero_costillas-1
        costilla_costilla_medio(j,:) = [costillas(i,:,1) costillas(i,:,end)]; % x_r y_r x_t y_t
        j=j+1;
        costilla_costilla_medio(j,:) = [(costillas(i+1,:,1)+costillas(i,:,1))/2 (costillas(i+1,:,end)+costillas(i,:,end))/2];
        j=j+1;
    end
    costilla_costilla_medio(end,:) = [costillas(end,:,1) costillas(end,:,end)]; % x_r y_r x_t y_t

    %% Construcción de los nodos
    counter_nodo_ala = 0;
    counter_elemento_ala = 0;
    counter_elemento_ala = 0;
    counter_nodo_larguerillo_ala = 0;
    counter_nodos = 0;
    counter_barras = 0;
    nodos_ala = [];
    barras_ala = [];
    nodos_larguerillos =[];
    % Matriz que contiene el número de nodos y elementos en las partes de
    % larguero posterior y anterior y en los larguerillos (N x 2)
    %  donde N = (2 + numero de larguerillos). El dos es por los largueros
    Numero_nodos_elementos_ala = zeros(2 + numero_larguerillos_total,2);

    %% Creando los nodos en los largueros anterior y posterior
    % Nodos largueros
    nodos_posterior = zeros(3,(numero_costillas*2)-1); % Los nodos en el borde de salida que son numero_costillas (costillas) + numero_costillas-1 (punto medio)
    nodos_anterior = zeros(3,(numero_costillas*2)-1);
    nodos_posterior = interleave_matrices(costillas(:,:,1)', puntos_medio_larguero_posterior_ala');
    nodos_anterior = interleave_matrices(costillas(:,:,end)', puntos_medio_larguero_anterior_ala');
    
    % Contando la cantidad de nodos para cada larguero
    numero_nodos_larguero_posterior_ala = size(nodos_posterior,2);
    numero_nodos_larguero_anterior_ala = size(nodos_anterior,2);

    Numero_nodos_elementos_ala(1,1) = numero_nodos_larguero_posterior_ala;
    Numero_nodos_elementos_ala(2,1) = numero_nodos_larguero_anterior_ala;
    Numero_nodos_dos_largueros = numero_nodos_larguero_posterior_ala+numero_nodos_larguero_anterior_ala;
    %% % Buscando los número de cortes que corten los larguerillos incluyendo
    % % el punto medio entre costillas (index_larguerillos_anterior)
    index_larguerillos_anterior = size(nodos_posterior,2)*ones(1, numero_larguerillos_total); % Initialize
    
    for i = numero_larguerillos_costilla_final+1:numero_larguerillos_total
        % counter_i = counter_i + 1;
        
        % Find the last node in nodos_anterior that is less than or equal to the stringer's endpoint
        endpoint = larguerillos(i, :, end)'; % Stringer endpoint (2x1 vector)
        indices = find(nodos_anterior(1, :) <= endpoint(1) & nodos_anterior(2, :) <= endpoint(2)); % Check x and y
        
        % Take the maximum index satisfying the condition
        if ~isempty(indices)
            index_larguerillos_anterior(i) = max(indices);
        else
            index_larguerillos_anterior(i) = -1; % No valid connection
        end
    end
    %% Creando un index en donde se cuentan el número de nodos que no cuentan
    % Debido a que la función cortes_de_dos_funciones_lineales calcula
    % todas las intersecciones.
    % Matriz "intersecciones_costillas_larguerillos" de las coordenadas de las intersecciones de los
    % larguerillos-costilla_costilla_medio de dimension
    % (num_larguerillo,num_cost_cost_med,(x,y))
    intersecciones_costillas_larguerillos = cortes_de_dos_funciones_lineales_v3(squeeze(larguerillos(:,:,1)),pendiente_larguero_posterior,costilla_costilla_medio(:,1:2),pendiente_perpendicular_larguero_posterior);
    counter_quitar_nodos_larguerillos_menor_Lf = 0;
    index_counter_quitar_nodos_larguerillos_menor_Lf = zeros(numero_larguerillos_total,1);

    for index_larguerillo_counter = 1:numero_larguerillos_total % El bucle para cada larguerillo
        counter_quitar_nodos_larguerillos_menor_Lf = 0;
        for index_costilla_counter = 1 : numero_costillas
            if intersecciones_costillas_larguerillos(index_larguerillo_counter,index_costilla_counter,1)<Lf
                counter_quitar_nodos_larguerillos_menor_Lf = counter_quitar_nodos_larguerillos_menor_Lf + 1;
            end
        end
        index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter) = counter_quitar_nodos_larguerillos_menor_Lf;
    end

     %% Construyendo los nodos en los larguerillos
    % Creando un matriz que contiene el id local del nodo junto con el
    % index del larguerillo y de la costilla. De dimensión 
    % (id_local, Lf + index_costilla, index_larguerillo)
    % -1 encastre, -2 larguero anterior, -3 quitado
    id_nodo_local_larguerillo_costilla = zeros(numero_larguerillos_total*numero_costillas,3);

    % counter_nodo_larguerillo_ala = numero_nodos_larguero_posterior_ala+numero_nodos_larguero_anterior_ala;
    

    for index_larguerillo_counter = 1:numero_larguerillos_costilla_final % El bucle para cada larguerillo
        temp_size_nodos = size(nodos_larguerillos,2);
        % Hay que unir el primer nodo del larguerillo con el encastre
        % (línea vertical). 
        temp_intersect = cortes_de_dos_funciones_lineales_v3([Lf 1],inf,[intersecciones_costillas_larguerillos(index_larguerillo_counter,index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+1,:)], pendiente_larguero_posterior,index_larguerillo_counter,-1);

        nodos_larguerillos = [nodos_larguerillos temp_intersect intersecciones_costillas_larguerillos(index_larguerillo_counter,index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+1:index_larguerillos_anterior(index_larguerillo_counter),:)];
        
        % Actualizando el id_nodo_local_larguerillo_costilla
        % for index_costilla 
        % for index_costilla = index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+1:index_larguerillos_anterior(index_larguerillo_counter)
        %     id_nodo_local_larguerillo_costilla()
        % end
        id_nodo_local_larguerillo_costilla(temp_size_nodos+1,1) = temp_size_nodos+1;
        id_nodo_local_larguerillo_costilla(temp_size_nodos+1,2) = -1;
        id_nodo_local_larguerillo_costilla(temp_size_nodos+1,3) = index_larguerillo_counter;
        counter_nodos_id = 1;
        for index_id = temp_size_nodos+2:size(nodos_larguerillos,2)
            id_nodo_local_larguerillo_costilla(index_id,1) = index_id;
            id_nodo_local_larguerillo_costilla(index_id,2) = index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+counter_nodos_id;
            id_nodo_local_larguerillo_costilla(index_id,3) = index_larguerillo_counter;
            counter_nodos_id = counter_nodos_id + 1;
        end



        Numero_nodos_elementos_ala(index_larguerillo_counter+2,1) = size(nodos_larguerillos,2) - temp_size_nodos;
        % counter_nodo_larguerillo_ala = counter_nodo_larguerillo_ala + index_larguerillos_anterior(index_larguerillo_counter) - index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter) + 1;

    end
    
    inserted_nodes =[];
    quitar_larguerillo = 0;
    for index_larguerillo_counter = numero_larguerillos_costilla_final+1:numero_larguerillos_total % El bucle para cada larguerillo

        % Se hace esta condición, para quitar un larguerillo que no tenga
        % corte. Es mayor que uno, porque hay que poner una barra.
        if index_larguerillos_anterior(index_larguerillo_counter)>1
            temp_size_nodos = size(nodos_larguerillos,2);

            % Hay que unir el primer nodo del larguerillo con el encastre
            % (línea vertical). 
            temp_intersect = cortes_de_dos_funciones_lineales_v3([Lf 1],inf,[intersecciones_costillas_larguerillos(index_larguerillo_counter,index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+1,:)], pendiente_larguero_posterior,index_larguerillo_counter,-1);


            % La construcción del larguerillo
            nodos_larguerillos = [nodos_larguerillos temp_intersect intersecciones_costillas_larguerillos(index_larguerillo_counter,index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+1:(index_larguerillos_anterior(index_larguerillo_counter)),:)];
            
            
            % Actualizando el id_nodo_local_larguerillo_costilla
            % for index_costilla 
            % for index_costilla = index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+1:index_larguerillos_anterior(index_larguerillo_counter)
            %     id_nodo_local_larguerillo_costilla()
            % end
            id_nodo_local_larguerillo_costilla(temp_size_nodos+1,1) = temp_size_nodos+1;
            id_nodo_local_larguerillo_costilla(temp_size_nodos+1,2) = -1;
            id_nodo_local_larguerillo_costilla(temp_size_nodos+1,3) = index_larguerillo_counter;
            counter_nodos_id = 1;

            for index_id = temp_size_nodos+2:size(nodos_larguerillos,2)
                id_nodo_local_larguerillo_costilla(index_id,1) = index_id;
                id_nodo_local_larguerillo_costilla(index_id,2) = index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+counter_nodos_id;
                id_nodo_local_larguerillo_costilla(index_id,3) = index_larguerillo_counter;
                counter_nodos_id = counter_nodos_id + 1;
            end
            
           

            % Se añade el ultimo nodo del corte del larguerillo y el
            % larguero anterior.
            temp = cortes_de_dos_funciones_lineales_v3(larguerillos(index_larguerillo_counter,:,1), pendiente_larguero_posterior, [Lf c1*Distancia_larguero_anterior_cuerda_porcentaje], pendiente_larguero_anterior,index_larguerillo_counter,-2);
            nodos_larguerillos = [nodos_larguerillos temp];
            threshold_distance = distancia_entre_costillas*.07;
            
            % nodos_larguerillos = insert_perpendicular_node_v3(nodos_larguerillos, pendiente_larguero_posterior, [x2 y2], numero_costillas*2-1,threshold_distance);
            slope = pendiente_larguero_posterior;
            perpendicular_slope = pendiente_perpendicular_larguero_posterior;    
            
            [nodos_larguerillos inserted_nodes_temp]= adjust_nodos_larguerillos_v2(nodos_larguerillos, slope, perpendicular_slope, numero_costillas*2-1, distancia_entre_larguerillo_vertical, alfa_larguero_posterior_radianes, threshold_distance);
            inserted_nodes = [inserted_nodes inserted_nodes_temp];
            Numero_nodos_elementos_ala(index_larguerillo_counter+2,1) = size(nodos_larguerillos,2) - temp_size_nodos;
            % counter_nodo_larguerillo_ala = counter_nodo_larguerillo_ala + index_larguerillos_anterior(index_larguerillo_counter);

        else
            disp('Se quitó un larguerillo: Cambia el numero de larguerillo total en el ala -1')
            quitar_larguerillo = quitar_larguerillo + 1;
        end
    end
    
    numero_larguerillos_total = numero_larguerillos_total - quitar_larguerillo;
    
    % Datos Generales
    results.costillas = costillas; %
    results.numero_costillas = numero_costillas;
    results.numero_costillas_triangulo = numero_costillas_triangulo;
    results.cociente_L_W_inicial = cociente_L_W_inicial;
    % results.mom_flector = flip(mom_flector);
    % results.torsion = flip(torsion);
    % results.H_caja = H_caja;
    results.costilla_costilla_medio = costilla_costilla_medio;

    % Larguerillo
    results.numero_larguerillos_total = numero_larguerillos_total;
    results.numero_larguerillos_costilla_final = numero_larguerillos_costilla_final;
    results.larguerillos = larguerillos;

    % Coordenadas
    % l(y)
    results.x_l = x_l;
    results.y_l = y_l;
    results.l = l;    
    % L(y)
    results.x_L = x_L;
    results.y_L = y_L;
    results.L = L;
    results.coord_aerodinamica_costillas_punto_medio = coord_aerodinamica_costillas_punto_medio; %(x,y)
    results.coord_aerodinamico_costillas = coord_aerodinamico_costillas; %(x,y)
    % results.coord_aerodinamica_costillas_pasa_por_A = coord_aerodinamica_costillas_pasa_por_A;
    % results.coord_interseccion_paralela_costillas_pasa_por_A = coord_interseccion_paralela_costillas_pasa_por_A; % dimension es num_costillas y (X,Y) y (larguero anterior;larguero posterior,eje estructural)
    % results.y_L = y_L; 
    
    % Geometria
    results.geometria.linea_larguero_anterior = linea_larguero_anterior; % (x_local_ala,linea)
    results.geometria.linea_larguero_posterior = linea_larguero_posterior; % (x_local_ala,linea)
    results.geometria.linea_centro_aerodinamico = linea_centro_aerodinamico; % (x_local_ala,linea)
    results.geometria.linea_eje_estructural = linea_eje_estructural; % (x_local_ala,linea)
    results.geometria.pendiente_larguero_anterior = pendiente_larguero_anterior;
    results.geometria.pendiente_larguero_posterior = pendiente_larguero_posterior;
    results.geometria.pendiente_eje_estructural = pendiente_eje_estructural;
    results.geometria.pendiente_perpendicular_larguero_posterior = pendiente_perpendicular_larguero_posterior;
    results.geometria.constante_linea_larguero_anterior = constante_linea_larguero_anterior; 
    results.geometria.linea_larguero_anterior = linea_larguero_anterior; 
    results.geometria.constante_linea_larguero_posterior = constante_linea_larguero_posterior;
    results.geometria.constante_linea_eje_estructural = constante_linea_eje_estructural; 
    results.geometria.alfa_larguero_posterior_radianes = alfa_larguero_posterior_radianes; 
    results.geometria.constante_perpendicular_larguero_posterior = constante_perpendicular_larguero_posterior; 
    results.geometria.coord_costillas_larguero_anterior_x = coord_costillas_larguero_anterior_x;
    results.geometria.coord_costillas_larguero_anterior_y = coord_costillas_larguero_anterior_y; 
    results.geometria.constante_perpendicular_larguero_posterior_triangulo = constante_perpendicular_larguero_posterior_triangulo; 
  
    %% Nodos y elementos
    % mesh
    results.mesh.intersecciones_costillas_larguerillos = intersecciones_costillas_larguerillos;
    results.mesh.index_counter_quitar_nodos_larguerillos_menor_Lf = index_counter_quitar_nodos_larguerillos_menor_Lf;
    results.mesh.Numero_nodos_elementos_ala = Numero_nodos_elementos_ala;
    results.mesh.id_nodo_local_larguerillo_costilla = id_nodo_local_larguerillo_costilla;
    results.mesh.inserted_nodes = inserted_nodes;
    % nodos
    results.mesh.nodos_larguerillos = nodos_larguerillos; % larguerillos
    results.mesh.index_larguerillos_anterior = index_larguerillos_anterior; % Número de intersección que hace el larguerillo con la costillas y su punto medio (Punto medio entre costillas).
    results.mesh.nodos_posterior = nodos_posterior; % Los nodos en el larguero posterior.
    results.mesh.nodos_anterior = nodos_anterior; % Los nodos en el larguero posterior.
    
    %% Standardization
    % addpath('./conversion');
    % Convert nodes to tables
    nodos_larguerillos = squeeze(nodos_larguerillos);
    nodos_larguerillos(:, [3, 4]) = nodos_larguerillos(:, [4, 3]); % Swap rib/stringer if needed
    nodos_larguerillos_table = convert_nodes_to_table_v2(nodos_larguerillos);
    
    nodos_anterior_ala_table = convert_nodes_front_spars_to_table_v2(nodos_anterior');
    nodos_posterior_ala_table = convert_nodes_rear_spars_to_table_v2(nodos_posterior');
    
    % Create the Combined Node Table
    combined_nodes = create_combined_node_table_v2(nodos_larguerillos_table, nodos_anterior_ala_table, nodos_posterior_ala_table);

    results.mesh.combined_nodes = combined_nodes;
end