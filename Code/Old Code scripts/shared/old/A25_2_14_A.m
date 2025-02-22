%% Construyendo los nodos en los larguerillos

    id_nodo_local_larguerillo_costilla = zeros(numero_larguerillos_total*numero_costillas,3);

    for index_larguerillo_counter = 1:numero_larguerillos_costilla_final % El bucle para cada larguerillo
        temp_size_nodos = size(nodos_larguerillos,2);
        % Hay que unir el primer nodo del larguerillo con el encastre
        % (línea vertical). 
        temp_intersect = cortes_de_dos_funciones_lineales_v3([Lf 1],inf,[intersecciones_costillas_larguerillos(index_larguerillo_counter,index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+1,:)], pendiente_larguero_posterior,index_larguerillo_counter,-1);

        nodos_larguerillos = [nodos_larguerillos temp_intersect intersecciones_costillas_larguerillos(index_larguerillo_counter,index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo_counter)+1:index_larguerillos_anterior(index_larguerillo_counter),:)];

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

            temp = cortes_de_dos_funciones_lineales_v3(larguerillos(index_larguerillo_counter,:,1), pendiente_larguero_posterior, [Lf c1*Distancia_larguero_anterior_cuerda_porcentaje], pendiente_larguero_anterior,index_larguerillo_counter,-2);
            nodos_larguerillos = [nodos_larguerillos temp];
            threshold_distance = distancia_entre_costillas*.07;
            
            % nodos_larguerillos = insert_perpendicular_node_v3(nodos_larguerillos, pendiente_larguero_posterior, [x2 y2], numero_costillas*2-1,threshold_distance);
            slope = pendiente_larguero_posterior;
            perpendicular_slope = pendiente_perpendicular_larguero_posterior;    
            
            [nodos_larguerillos inserted_nodes_temp]= adjust_nodos_larguerillos_v2(nodos_larguerillos, slope, perpendicular_slope, numero_costillas*2-1, distancia_entre_larguerillo_vertical, alfa_larguero_posterior_radianes, threshold_distance);
            inserted_nodes = [inserted_nodes inserted_nodes_temp];
            Numero_nodos_elementos_ala(index_larguerillo_counter+2,1) = size(nodos_larguerillos,2) - temp_size_nodos;

        else
            disp('Se quitó un larguerillo: Cambia el numero de larguerillo total en el ala -1')
            quitar_larguerillo = quitar_larguerillo + 1;
        end
    end
    
    numero_larguerillos_total = numero_larguerillos_total - quitar_larguerillo;
    