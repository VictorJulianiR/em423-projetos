clear;
clc;
disp("#####################################################################");
disp("REFERENCIAIS/CONVENÇÕES:");
disp("1a. Forças verticais são positivas no sentido positivo do eixo Y (de baixo para cima).");
disp("1b. Forças horizontais são positivas no sentido positivo do eixo X (da esquerda para direita).");
disp("Por exemplo, para marcar forças pontuais que são: verticais para cima: usa-se angulo 90; verticais para baixo: usa-se angulo 270; horizontais para direita: usa-se angulo 0; horizontais para esquerda: usa-se angulo 180")
disp("1c. Torques são positivos no sentido positivo do eixo X (para a direita).");
disp("1d. Momentos são positivos no sentido horário.");
disp("1e. Caso forças de carregamento estejam sobrepostas, cabe ao usário fazer a devida soma das funções, separando-o em mais de um carregamento caso seja necessário")
disp("1f. Como adotamos refencial de forças de cima pra baixo como negativo, carregamentos que atuem em cima da barra devem ter valor de sua função negativa")
disp("");
disp("2. Os referencias são adotados todos a partir do início da viga, ou seja, posição (0,0)");
disp("");
disp("3. Todas as unidades devem estar no SI menos os ângulos que estão em graus");
disp("#####################################################################\n");

function forcaCarregamento = calcForcaCarregamento(carregamento)
  ini = carregamento(1);
  fim = carregamento(2);
  coefs = transpose(carregamento(3:end));
  integral = polyint(coefs);
  forcaCarregamento = polyval(integral, fim) - polyval(integral, ini);
endfunction

function momentoCarregamento = calcMomentoCarregamento(carregamento)
  ini = carregamento(1);
  fim = carregamento(2);
  coefs = (carregamento(3:end));
  coefs = [coefs, 0];
  integral = polyint(coefs);
  momentoCarregamento = (polyval(integral, fim) - polyval(integral, ini));
endfunction

function momentos = getMomentos()
  numMomentos = input("Quantos momentos estao sendo aplicados na viga: ");

  momentos = zeros(numMomentos,2); # [x, intensidade]

  if (numMomentos > 0)
    disp("");
    disp("Para cada momento, digite sua posição e sua intensidade - lembrando que se a intensidade é negativa, o momento é tido no sentido horário.");
    for i = 1:numMomentos
      disp(sprintf("Momento %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      
      momentos(i, :) = [pos;intensidade];
      
      disp("Momento computado com sucesso!\n");
    endfor
  endif
endfunction


function forcasExternas = getForcas()
  numForcasPontuais = input("Quantas forças pontuais estão sendo aplicadas na viga: ");

  forcasExternas = zeros(numForcasPontuais,2); # [x, fy]

  if (numForcasPontuais > 0)
    disp("");
    disp("Para cada força, digite sua posição na viga e sua intensidade"); 
    disp(" ** Obrigatoriamente a resultante das forças externas verticais deve ser de cima para baixo e deve estar entre a posição dos dois roletes.");
    disp(" ** Se a intensidade é negativa, a força é aplicada verticalmente de baixo para cima");
    disp(" ** Para este problema, torques e forças no eixo x tem resultante 0.");
    disp("");
    for i = 1:numForcasPontuais
      disp(sprintf("Força %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      
      fy = intensidade;
      
      forcasExternas(i,:) = [pos;fy]
      
      disp("Força computada com sucesso!");
    endfor
  endif
endfunction


function carregamentos = getCarregamentos()
  numCarregamentos = input("Quantos carregamentos distribuídos estão sendo aplicados na viga: ");
  n = input("Digite o grau máximo 'n' da função de carregamento: ")
  
  carregamentos = zeros(numCarregamentos, n+3); # [posIni, posFim, coefs]

  if (numCarregamentos > 0)
    disp("");
    disp("Para cada carregamento, digite as suas posições inicial e final e sua função polinomial (em N/m)");
    for i = 1:numCarregamentos
      disp(sprintf("Carregamento %d\n", i));
      posIni = input("Posição inicial: ");
      posFim = input("Posição final: ");
      coefs = input("Coeficientes (seguindo o padrão) [an;an-1;...;a1;a0]:");
      
      carregamentos(i, :) = [posIni;posFim;coefs];
      
      disp("Carregamento computado com sucesso.");
    endfor
  endif
endfunction



###############################################
######## ENTRADAS! ###########
###############################################
tamanhoViga = input("Digite o tamanho da viga: ");
pos_rolete_A = input ("Digite a posição do rolete 1: ");
pos_rolete_B = input ("Digite a posição do rolete 2: ");
forcas = getForcas()
momentos = getMomentos()
carregamentos = getCarregamentos()



###############################################
######## CÁLCULOS PARA O 2 ROLETES! ###########
###############################################

# 1. Equilibrio de forças na horizontal:
fx = 0.0; #Forças pontuais

printf("Fx: %f\n", fx);

# 2. Equilibrio de forças na vertical:
forcaCarregamento = 0;
for i = 1:rows(carregamentos) #Forças de carregamento distribuído
  forcaCarregamento = forcaCarregamento + calcForcaCarregamento(carregamentos(i,:))
endfor


fy = forcaCarregamento + sum(forcas(:,2)); #Forças pontuais
printf("Fy: %f\n", fy);

# 3. Equilibrio de torques:
torque = 0.0;
printf("Torque: %f\n", torque);

# 4. Equilibrio de momentos:
#Será escolhido o ponto de referencia sempre o rolete mais a esquerda.
if (pos_rolete_A < pos_rolete_B)
  pontoReferenciaMomento = pos_rolete_A;
else
  pontoReferenciaMomento = pos_rolete_B;
endif

# Momentos externos
momentoExterno = sum(momentos(:,2));

# Momento Carregamento
momentoCarregamento = 0;
colunaCarregamento = rows(carregamentos);
for i = 1:rows(carregamentos) #Momento do carregamento distribuído
  momentoTeste = calcMomentoCarregamento(carregamentos(i,:));
  xResultante = calcMomentoCarregamento(carregamentos(i,:))/calcForcaCarregamento(carregamentos(i,:)) ;
  if xResultante < pontoReferenciaMomento
    momentoCarregamento = momentoCarregamento + abs(pontoReferenciaMomento-xResultante)*calcForcaCarregamento(carregamentos(i,:));
  else
    momentoCarregamento = momentoCarregamento - abs(pontoReferenciaMomento-xResultante)*calcForcaCarregamento(carregamentos(i,:));
  endif
endfor

# Momento Forcas
momentoForcas = 0;
for i = 1:rows(forcas) #Momento do carregamento distribuído
  if forcas(i,1) < pontoReferenciaMomento
    momentoForcas = momentoForcas + forcas(i,2)*abs(forcas(i,1)-pontoReferenciaMomento);
  elseif forcas(i,1) > pontoReferenciaMomento
    momentoForcas = momentoForcas - forcas(i,2)*abs(forcas(i,1)-pontoReferenciaMomento);
  endif
endfor



momentoTotal = momentoForcas + momentoCarregamento + momentoExterno;


#Forças de apoio
if (pos_rolete_A < pos_rolete_B)
  Fyb = (momentoTotal)/(pos_rolete_B-pos_rolete_A);
  Fya = -1*(Fyb + fy) ;
else
  Fya = (momentoTotal) / (pos_rolete_A-pos_rolete_B);
  Fyb = -1*(Fya + fy);
endif

printf("Força de apoio para o relote 1: %f\n", Fya);
printf("Força de apoio para o rolete 2: %f\n", Fyb);

######################################
# DIAGRAMA DE ESFORÇOS SOLICITANTES
######################################
# Pontos de interesse
# Sempre escolhemos o lado esquerdo da secção para encontar as forças solicitantes,
# pois ele tem o ponto considerado o nosso referencial 0.

PontosDeInteresse = [unique(vertcat(pos_rolete_A,pos_rolete_B,forcas(:,1),momentos(:,1),carregamentos(:,1),carregamentos(:,2)))]
forcas = [forcas; pos_rolete_A, Fya];
forcas = [forcas; pos_rolete_B, Fyb]; 
g = figure ();
for i = 2:rows(PontosDeInteresse) # começa em 2 pois o primeiro ponto de interesse sempre sera 0.0
  printf("Ponto de interesse: %d\n", i)
  ####################################################################################
  # Calculo V interno 
  ####################################################################################
  F_externas = sum(forcas(forcas(:,1) < PontosDeInteresse(i),:)(:,2)); #foças precisam estar no intervalo (0.0,pontoDeINnteresse(i))
  CarregamentosIntegraveis = carregamentos(carregamentos(:,2)<= PontosDeInteresse(i-1),:);
  ForcaCarregamento = 0;
  for j = 1:rows(CarregamentosIntegraveis)
    ForcaCarregamento = ForcaCarregamento + calcForcaCarregamento(CarregamentosIntegraveis(j,:));
  endfor
  # V interior será calculado posteriormente quando tivermos os valores de x para a integral
  # caso exista carregamento.
  V_interior_parcial = [F_externas + ForcaCarregamento];
  # Esta parte só serve caso exista um carregamento entre os pontos
  # de interesse, pois dessa forma desconheceremos o limite da integral
  V_interior_carregamento_em_x =  carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),:);
  
  ########################################################################################
  # Calculo M interno 
  ########################################################################################
  MomentoPontual = sum(momentos(momentos(:,1) < PontosDeInteresse(i),:)(:,2)); # momentos precisam estar no intervalo (0.0,pontoAtual)
  MomentoCarregamentos = 0;
  for j = 1:rows(CarregamentosIntegraveis) #Momento do carregamento distribuído
    MomentoCarregamentos = MomentoCarregamentos + calcMomentoCarregamento(CarregamentosIntegraveis(j,:));
  endfor
  


  ForcasExistentes = forcas(forcas(:,1) < PontosDeInteresse(i),:);
  MomentoForcasExternas = 0;
  for j = 1:rows(ForcasExistentes)
  
    MomentoForcasExternas = MomentoForcasExternas - ForcasExistentes(j,2)*ForcasExistentes(j,1);
  
  endfor
  

  # M interior será calculado posteriormente quando tivermos os valores de x para a integral.
  # Este momento interno ainda não considera o momento gerado pelo V interno
  # Este MomentoCarregamento são aqueles gerados por carregamentos anteriores ao ponto de interesse anterior. 
  M_interior_parcial = MomentoPontual + MomentoCarregamentos + MomentoForcasExternas;
  # Esta parte só serve caso exista um carregamento entre os pontos
  # de interesse, pois dessa forma desconheceremos o limite da integral
  M_interior_carregamento_em_x = carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),:);
  
  ####################################################################
  # Calculo dos valores da tabela necessario para montar o diagrama
  ####################################################################
  
  # Criando valores de x no intervalo de dois pontos de interesse

  X = transpose(linspace(PontosDeInteresse(i-1),PontosDeInteresse(i),(PontosDeInteresse(i)-PontosDeInteresse(i-1))*4));  
  DadosDoDiagrama_V_x = zeros(rows(X), 1);
  DadosDoDiagrama_M_x = zeros(rows(X), 1);
  for j = 1:rows(X)

    # Se existir carregamento entre os pontos de interesse a integral sera entre o ponto anterior e o x
    if (sum(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i))==1)
      V_interior_carregamento_em_x(1) = carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),1); # posIni
      V_interior_carregamento_em_x(2) = X(j);  # posFim
  
      
      V_x = -1*(V_interior_parcial + calcForcaCarregamento(V_interior_carregamento_em_x));
      M_interior_carregamento_em_x(1) = carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),1); # posIni
      M_interior_carregamento_em_x(2) = X(j) ; # posFim
      M_x = (-1*M_interior_parcial + calcMomentoCarregamento(M_interior_carregamento_em_x) + (V_x * X(j)));
    else
      V_x = -1*V_interior_parcial; 
      M_x = -1*(M_interior_parcial - (V_x * X(j)));
    endif

    
    #printf(DadosDoDiagrama_V_x(j));
    DadosDoDiagrama_V_x(j) = [V_x];
    DadosDoDiagrama_M_x(j) = [M_x];
  endfor   
  # plot da função para cada intervalo dos pontos de interesse
  

  subplot(2,1,1);
  hold on;
  xlabel ("x");
  ylabel ("V(x)");
  title ("Esforço cortante");
  plot(X,DadosDoDiagrama_V_x);
  hold off;     
  
  subplot(2,1,2);
  hold on;
  xlabel ("x");
  ylabel ("M(x)");
  title ("Momento Fletor");
  plot(X,DadosDoDiagrama_M_x);
  hold off;
endfor
print diagramaForcasSolicitantes.pdf;
open diagramaForcasSolicitantes.pdf