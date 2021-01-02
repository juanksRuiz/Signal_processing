function Xf = remove_OL_NAN(X,t)
    % Esta funcion reemplaza todos los outliers en y NaN en la matriz X
    % X: matriz de dimension nx3 de las señales
    % t: vector del tiempo
    Xf = X;
    sum(isoutlier(Xf));
    %1) cambiamos las filas donde haya outliers por [nan,nan,nan].
    
    % numero de NaNs en toda la matriz Xf (incluidos los que estan en misma fila)
    numOL = sum(sum(isoutlier(Xf)));
    % Lista con los indices donde hay NaN en columnas 1,2 y 3
    OL_indexes = zeros(numOL,1);
    c = 1;
    for i = 1:3
        % Buscamos cuales son outliers en la i-ésima columna
        isOL = isoutlier(Xf(:,i));
        if sum(isOL) > 0
            % Entonces en esta columna hay NaN
            % Indices de las posiciones donde hay NaN
            outliers = find(isOL==1);
            % Cantidad de outliers
            numOL = length(outliers);
            OL_indexes(c:c+numOL-1) = outliers;
            c = c+numOL;
        end
    end
    OL_indexes = unique(OL_indexes);
    for i =1:length(OL_indexes)
        Xf(OL_indexes(i),:) = [nan,nan,nan];
    end
    
    %======================================================================
    % 2) interpolamos cada columna
    % Verificamos si hay valores nan (en la primera columna)
    if sum(isnan(Xf(:,1)))> 0
        %indices de filas donde hay NaN
        NaN_idx = find(isnan(Xf(:,1)))
        %indices de filas donde no hay NaN
        NotNaN_idx = find(isnan(Xf(:,1))==0)
        
        %Buscamos si hay que extrapolar valores
        if ismember(1,NaN_idx) || ismember(length(Xf),NaN_idx)
            % En este caso primero interpolamos, luego extrapolamos
            
            % 2.1) Interpolacion
            % limites del rango para encontrar los NaN en el rango de
            % interpolacion
            lim_izq = NotNaN_idx(1)
            lim_der = NotNaN_idx(end)            
            % Puntos (indices) iniciales de la interpolacion
            x_interp = NotNaN_idx
            t_interp = t(x_interp)
            % imagenes de los nodos iniciales
            v_interp = Xf(x_interp,:)            
            % Puntos (indices) en el rango de interpolacion donde hay nan (que se van a interpolar)
            xq_interp = NaN_idx(NaN_idx >=lim_izq & NaN_idx <= lim_der)
            tq_interp = t(xq_interp);
            % Valores interpolados
            vq_interp = interp1(t_interp,v_interp,tq_interp,'pchip')            
            % Reemplazamos los valores interpolados
            Xf(xq_interp,:) = vq_interp
            
           
            % 2.2) Extrapolacion
            % Puntos (indices) iniciales para extrapolación
            x_extrap = [lim_izq:lim_der]
            t_extrap = t(x_extrap)
            % Imagenes de puntos iniciales
            v_extrap = Xf(x_extrap,:)
            % Puntos (indices) donde hay nan(que se va a extrapolar)
            xq_extrap = NaN_idx(NaN_idx < lim_izq | NaN_idx > lim_der)
            tq_extrap = t(xq_extrap)
            % Valores extrapolados
            vq_extrap = interp1(t_extrap, v_extrap, tq_extrap,'pchip','extrap')
            % Reemplazamos los valores extrapolados
            Xf(xq_extrap,:) = vq_extrap;    
        else
            % En este caso solo es necesario interpolar
            % Puntos(indices) iniciales
            x = NotNaN_idx
            tx = t(NotNaN_idx)
            % Imagenes de los puntos iniciales
            v = Xf(x,:)
            % Puntos (indices) donde hay nan (que se van a interpolar)
            xq = NaN_idx
            tq = t(NaN_idx)
            % Valores interpolados
            vq = interp1(tx,v,tq,'pchip')
            % Reemplazamos los valroes interpolados
            Xf(xq,:) = vq
        end
    end
end