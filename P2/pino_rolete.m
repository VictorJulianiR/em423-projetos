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


function moduloElasticidade = getModuloElasticidade()
    moduloElasticidade = input("Insira o modulo de elasticidade: ");
endfunction

function moduloCisalhamento = getModuloCisalhamento()
    moduloCisalhamento = input("Insira o modulo de cisalhamento: ");
endfunction

function coeficiente_de_Poisson = getCoeficiente_de_Poisson()
    coeficiente_de_Poisson = input("Insira o Coeficiente de Poisson: ");
endfunction

function limite_de_escoamento = getLimite_de_Escoamento()
    limite_de_escoamento = input("Insira o Limite de Escoamento do material(MPa): ");
endfunction

function infoFormato = getFormato()
    formato = input("Insira o numero correspondente ao formato da barra. 1 - Circulo. 2 - Coroa circular: ");
    if(formato == 1)
      d_e = input("Insira o valor do diametro em metros: ");
      d_i = 0
      momentoInerciaEmZ = (3.14 * (power(d,4)))/64;
      momentoInerciaPolar = (2 * momentoInerciaEmZ);
      areaTransversal = 3.14*(power(d/2,2));
    else
      d_e = input("Insira o valor do diametro externo em metros: ");
      d_i = input("Insira o valor do diametro interno em metros: ");
      momentoInerciaEmZ = (3.14 * ((power(d_e,4))-(power(d_i,4))))/64;
      momentoInerciaPolar = (2 * momentoInerciaEmZ);
      areaTransversal = 3.14*(power(d_e/2,2)) - 3.14*(power(d_i/2,2));
    endif

    infoFormato = [momentoInerciaEmZ,momentoInerciaPolar,areaTransversal, d_e, d_i, formato];
endfunction



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
  coefs = carregamento(3:end);
  coefs = [coefs, 0];
  integral = polyint(coefs);
  momentoCarregamento = -1*(polyval(integral, fim) - polyval(integral, ini));
endfunction

function forcasExternas = getForcas()
  numForcasPontuais = input("Quantas forças pontuais estão sendo aplicadas na viga: ");

  forcasExternas = zeros(numForcasPontuais,3); # [x, fx, fy]

  if (numForcasPontuais > 0)
    disp("");
    disp("Para cada força, digite sua posição na viga, intensidade, ângulo em graus");
    for i = 1:numForcasPontuais
      disp(sprintf("Força %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      angulo = input("Ângulo: ");
      
      fx = intensidade*cos(deg2rad(angulo));
      fy = intensidade*sin(deg2rad(angulo));
      
      forcasExternas(i,:) = [pos;fx;fy]
      
      disp("Força computada com sucesso!");
    endfor
  endif
endfunction


function torques = getTorques()
  numTorques = input("Quantos torques estao sendo aplicados na viga: ");

  torques = zeros(numTorques,2); # [x, intensidade]

  if (numTorques > 0)
    disp("");
    disp("Para cada torque, digite sua posição e sua intensidade - lembrando que se a intensidade é negativa, o torque � tido no sentido oposto do eixo X.");
    for i = 1:numTorques
      disp(sprintf("Torque %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      
      torques(i, :) = [pos;intensidade]
      
      disp("Torque computado com sucesso!");
    endfor
  endif
endfunction

function momentos = getMomentos()
  numMomentos = input("Quantos momentos estão sendo aplicados na viga: ");

  momentos = zeros(numMomentos,2); # [x, intensidade]

  if (numMomentos > 0)
    disp("");
    disp("Para cada momento, digite sua posição e sua intensidade - lembrando que se a intensidade é negativa, o momento � tido no sentido hor�rio.");
    for i = 1:numMomentos
      disp(sprintf("Momento %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      
      momentos(i, :) = [pos;intensidade]
      
      disp("Momento computado com sucesso!");
    endfor
  endif
endfunction


function carregamentos = getCarregamentos()
  numCarregamentos = input("Quantos carregamentos distribuídos estão sendo aplicados na viga: ");
  
  if (numCarregamentos > 0)
    n = input("Digite o grau máximo 'n' da função de carregamento: ")
    carregamentos = zeros(numCarregamentos, n+3); # [posIni, posFim, coefs]

    disp("");
    disp("Para cada carregamento, digite as suas posições inicial e final e sua função polinomial (em N/m)");
    for i = 1:numCarregamentos
      disp(sprintf("Carregamento %d\n", i));
      posIni = input("Posição inicial: ");
      posFim = input("Posição final: ");
      coefs = input("Coeficientes (seguindo o padrão) [an;an-1;...;a1;a0], lembrando que deve-se preencher completamente mesmo quando o coeficiente for 0:");
      
      carregamentos(i, :) = [posIni;posFim;coefs];
      
      disp("Carregamento computado com sucesso.");
    endfor
  else
    carregamentos = zeros(0, 3); # [posIni, posFim, coefs]
  endif
endfunction

###############################################
######## ENTRADAS! ###########
###############################################

tamanhoViga = input("Digite o tamanho da viga: ");
posicaoRolete = input("Digite o ponto aonde está o apoio do tipo rolete : ");
posicaoPino = input("Digite o ponto aonde está o apoio do tipo pino : ");
forcas = getForcas();
torques = getTorques();
momentos = getMomentos();
carregamentos = getCarregamentos();
moduloCisalhamento = getModuloCisalhamento();
moduloElasticidade = getModuloElasticidade();
infoFormato = getFormato();
coeficiente_de_Poisson = getCoeficiente_de_Poisson();
limite_de_escoamento = getLimite_de_Escoamento();

%{ 
EXEMPLOS DA AULA 4
tamanhoViga = 9;
posicaoRolete = 9;
posicaoPino = 0;
forcas = zeros(0,3); # [x, fx, fy]
torques = zeros(0,2); # [x, intensidade]
momentos = zeros(0,2); # [x, intensidade
carregamentos = [0,4.5,-1111.11111111,0;4.5,9.0,-1111.11111111,5000];
infoFormato = [1,1,1];
moduloCisalhamento = 1;
moduloElasticidade = 1;
%}
%{
EXEMPLOS DA AULA 4
tamanhoViga = 6;
posicaoRolete = 6;
posicaoPino = 0;
forcas = [1.5,0,-10000;4.5,0,-15000]; # [x, fx, fy]
torques = zeros(0,2); # [x, intensidade]
momentos = zeros(0,2); # [x, intensidade
carregamentos = zeros(0,3);
#carregamentos = [0,9,160,0];
%}
###############################################
######## CALCULOS PARA O PINO e ROLETE! ###########
###############################################

# 1. Equilibrio de forças na horizontal:
fx = sum(forcas(:,2)); #Forças pontuais
fx_pino = -fx;
printf("-----> Fx do apoio tipo pino: %.2f\n", fx_pino);

# 2. Equilibrio de forças na vertical:
fy=sum(forcas(:,3))

forcasCarregamento = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Forças de carregamento distribuído
  forcasCarregamentos(i) = calcForcaCarregamento(carregamentos(i,:));
  fy = fy + forcasCarregamentos(i);
endfor

fy = -fy

# 3. Equilibrio de momentos usando 0 como referencial:
momento = sum(momentos(:,2)); #soma dos momentos externos

momentoForcasExternas = -1*dot(forcas(:,1), forcas(:, 3));

momento = momento + sum(momentoForcasExternas);

momentosCarregamentos = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Momento do carregamento distribuido
  momentosCarregamentos(i) = calcMomentoCarregamento(carregamentos(i,:));
  momento = momento + momentosCarregamentos(i);
endfor

momento = -momento 



#4.Achando Fy do rolete e Fy do pino com a equacao de equlibrio dos momento e equilibrio das focas na vertical
resultado_sistema= [ 1 , 1 ; -posicaoRolete , -posicaoPino] \ [fy ; momento]  ;

fy_rolete = resultado_sistema(1);
fy_pino = resultado_sistema(2);
printf("-------->Fy do apoio tipo pino: %.2f\n", fy_pino);
printf("-------->Fy do apoio tipo rolete: %.2f\n", fy_rolete);

# 4. Equilibrio de torques:

torque = sum(torques(:,2));
torque = -torque;
printf("------->Torque de reacao do apoio tipo pino: %.2f\n", torque);


######################################
# DIAGRAMA DE ESFORÇOS SOLICITANTES
######################################
# Pontos de interesse
# Sempre escolhemos o lado esquerdo da secção para encontar as forças solicitantes,
# pois ele tem o ponto considerado o nosso referencial 0.
if (fy_pino)
  forcas = [forcas;[posicaoPino,0,fy_pino]];
endif
if (fy_rolete)
  forcas = [forcas;[posicaoRolete,0,fy_rolete]];
endif
if (fx_pino)
  forcas = [forcas;[posicaoPino,fx_pino,0]];
endif
if (torque)
  torques = [torques;[posicaoRolete,torque]];
endif

# Forma de representar e implementar a integral de singularidade
function f_final = integral_de_singularidade(f)
  f_final = f;
  for i = 1:rows(f)
    if f_final(i,3) < 1
      f_final(i,3) = f_final(i,3) + 1;
    else
      f_final(i,3) = f_final(i,3) + 1;
      f_final(i,1) = f_final(i,1)/f_final(i,3);
    endif
  endfor
endfunction

# Dado a representaçao da função de singularidade e um ponto retorna o valor da função no ponto
function resultado = resolve_equacao(f,x)
  resultado = 0;
  for i = 1:rows(f)
    if f(i,3) <= -1
      continue;
    elseif x < f(i,2) 
      continue;
    else
      resultado = resultado + (f(i,1)*((x - f(i,2))^f(i,3)));
    endif
  endfor
endfunction

# sigma_1,sigma_2, teta, sinal
function resultado_tensao_p = tensao_principal(sigma_1,sigma_2, teta, sinal)
  resultado_tensao_p = 0;
  if (sigma_1 == 0) && (sigma_2 == 0)
    if teta == 0
      resultado_tensao_p = 0;
    else
      if sinal == 0
        resultado_tensao_p = teta;
      else
        resultado_tensao_p = -1 * teta;
      endif
    endif
  elseif sinal == 0
    resultado_tensao_p = ((sigma_1 + sigma_2)/2) + sqrt(power((sigma_1 + sigma_2)/2,2) + power(teta,2));
  else
    resultado_tensao_p = ((sigma_1 + sigma_2)/2) - sqrt(power((sigma_1 + sigma_2)/2,2) + power(teta,2));
  endif
endfunction



PontosDeInteresse = [unique(vertcat(0.0,forcas(:,1),momentos(:,1),carregamentos(:,1),carregamentos(:,2),torques(:,1),tamanhoViga))]


# representação do q
# q(x) = [intensidade, inicio, expoente; ...]
q = [];
for i = 1:rows(forcas)
  if forcas(i,3) != 0
    q = [q;[forcas(i,3),forcas(i,1),-1]];
  endif
endfor
for i = 1:rows(momentos)
  q = [q;[momentos(i,2),momentos(i,1),-2]];
endfor
for i = 1:rows(carregamentos)
  coefs = carregamentos(i,3:end);
  for j = 1:columns(coefs)
    if coefs(j) != 0
      q = [q;[coefs(j),carregamentos(i,1),columns(coefs)-j]];
      q = [q;[-1*coefs(j),carregamentos(i,2),columns(coefs)-j]];
    endif
  endfor
endfor

# f_x = [intensidade, inicio, expoente; ...]
f_x = [];
for i = 1:rows(forcas)
  if forcas(i,2) != 0
    f_x = [f_x;[forcas(i,2),forcas(i,1),-1]];
  endif
endfor

#t(x) = [intensidade, inicio, expoente; ...]
t = [];
for i = 1:rows(torques)
  t = [t;[torques(i,2),torques(i,1),-1]];
endfor


#V(x) = integral_de_singularidade(q) = [intensidade, inicio, expoente; ...]
V_x = integral_de_singularidade(q);

#M(x) = integral_de_singularidade(V) = [intensidade, inicio, expoente; ...]
M_x = integral_de_singularidade(V_x);

#Teta(x) = integral_de_singularidade(M) sem a constante = [intensidade, inicio, expoente; ...]
Teta_x = integral_de_singularidade(M_x);

#v(x) = integral_de_singularidade(Teta) sem a constante = [intensidade, inicio, expoente; ...]
v_x = integral_de_singularidade(Teta_x);

#N(x) = integral_de_singularidade(f_x) sem a constante = [intensidade, inicio, expoente; ...]
N_x = integral_de_singularidade(f_x);

#L(x) = integral_de_singularidade(N_x) sem a constante = [intensidade, inicio, expoente; ...]
L_x = integral_de_singularidade(N_x);

#T(x) = integral_de_singularidade(t) sem a constante = [intensidade, inicio, expoente; ...]
T_x = integral_de_singularidade(t);

#TORCAO(x) = integral_de_singularidade(T_x) sem a constante = [intensidade, inicio, expoente; ...]
TORCAO_x = integral_de_singularidade(T_x);


# CALCULO DAS CONSTANTES

# Assumimos a origem com Inclinação igual a 0
constanteTETA = -(resolve_equacao(Teta_x,0+0.000000000000001));

# Utilizamos a posicao do pino para determinar a condicao de contorno e obter a constante de integracao da deflexao
constantev = -(resolve_equacao(v_x,posicaoPino+0.000000000000001) + constanteTETA*posicaoPino);

# Utilizamos a posicao do pino para determinar a condicao de contorno e obter a constante do alongamento
constanteL = -(resolve_equacao(L_x,posicaoPino+0.000000000000001));

# Utilizamos a posicao do pino para determinar a condicao de contorno e obter a constante do angulo de torcao
constanteTORCAO = -(resolve_equacao(TORCAO_x,posicaoPino+0.000000000000001));

# As constantes são utilizadas para o cálculo de cada ponto no gráfico.


####################################################################
# Calculo dos valores da tabela necessario para montar o diagrama
####################################################################
for i = 2:rows(PontosDeInteresse)  
  # Criando valores de x no intervalo de dois pontos de interesse
  X = transpose(linspace(PontosDeInteresse(i-1),PontosDeInteresse(i),max((PontosDeInteresse(i)-PontosDeInteresse(i-1))*4,2)));
  DadosDoDiagrama_V_x = zeros(rows(X), 1);
  DadosDoDiagrama_M_x = zeros(rows(X), 1);
  DadosDoDiagrama_N_x = zeros(rows(X), 1);
  DadosDoDiagrama_T_x = zeros(rows(X), 1);
  DadosDoDiagrama_TETA_x = zeros(rows(X), 1);
  DadosDoDiagrama_v_x = zeros(rows(X), 1);
  DadosDoDiagrama_L_x = zeros(rows(X), 1);
  DadosDoDiagrama_TORCAO_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_NORMAL_A_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_NORMAL_B_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_NORMAL_C_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_NORMAL_D_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_CISALHAMENTO_A_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_CISALHAMENTO_B_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_CISALHAMENTO_C_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_CISALHAMENTO_D_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSOES_PRINCIPAIS_A_x = zeros(rows(X), 3);
  DadosDoDiagrama_TENSOES_PRINCIPAIS_B_x = zeros(rows(X), 3);
  DadosDoDiagrama_TENSOES_PRINCIPAIS_C_x = zeros(rows(X), 3);
  DadosDoDiagrama_TENSOES_PRINCIPAIS_D_x = zeros(rows(X), 3);
  DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_A_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_B_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_C_x = zeros(rows(X), 1);
  DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_D_x = zeros(rows(X), 1);
  DadosDoDiagrama_DEFORMACAO_E_A_x = zeros(rows(X), 3);
  DadosDoDiagrama_DEFORMACAO_E_B_x = zeros(rows(X), 3);
  DadosDoDiagrama_DEFORMACAO_E_C_x = zeros(rows(X), 3);
  DadosDoDiagrama_DEFORMACAO_E_D_x = zeros(rows(X), 3);
  DadosDoDiagrama_DEFORMACAO_Y_A_x = zeros(rows(X), 3);
  DadosDoDiagrama_DEFORMACAO_Y_B_x = zeros(rows(X), 3);
  DadosDoDiagrama_DEFORMACAO_Y_C_x = zeros(rows(X), 3);
  DadosDoDiagrama_DEFORMACAO_Y_D_x = zeros(rows(X), 3);
  DadosDoDiagrama_TRESCA_AND_VON_MISES_A_x = zeros(rows(X), 2);
  DadosDoDiagrama_TRESCA_AND_VON_MISES_B_x = zeros(rows(X), 2);
  DadosDoDiagrama_TRESCA_AND_VON_MISES_C_x = zeros(rows(X), 2);
  DadosDoDiagrama_TRESCA_AND_VON_MISES_D_x = zeros(rows(X), 2);


 # infoFormato = [momentoInerciaEmZ,momentoInerciaPolar,areaTransversal, d_e, d_i, formato]
  
  for j = 1:rows(X)
    x = X(j);
    if j == 1
      V = resolve_equacao(V_x, X(j)+0.000000000000001);
      M = resolve_equacao(M_x, X(j)+0.000000000000001);
      N = resolve_equacao(N_x, X(j)+0.000000000000001);
      T = resolve_equacao(T_x, X(j)+0.000000000000001);
      TETA = ((resolve_equacao(Teta_x,X(j)+0.000000000000001))+constanteTETA) * (1/(moduloElasticidade*infoFormato(1)));
      v = ((resolve_equacao(v_x,X(j)+0.000000000000001))+ constantev + constanteTETA*X(j)) * (1/(moduloElasticidade*infoFormato(1)));
      L = ((resolve_equacao(L_x,X(j)+0.000000000000001)) + constanteL) * (1/(moduloElasticidade*infoFormato(3)));
      TORCAO = ((resolve_equacao(TORCAO_x,X(j)+0.000000000000001)) + constanteTORCAO) * (1/(moduloCisalhamento*infoFormato(2)));
      if (infoFormato(6) == 1)
        TENSAO_NORMAL_A = N/infoFormato(3) + 0;
        TENSAO_NORMAL_B = N/infoFormato(3) + (M * infoFormato(4))/infoFormato(1);
        TENSAO_NORMAL_C = N/infoFormato(3) + 0;
        TENSAO_NORMAL_D = N/infoFormato(3) + (-1*(M  *infoFormato(4))/infoFormato(1));
        TENSAO_CISALHAMENTO_A = (-1 * ((V*4)/(infoFormato(3)*3))) + T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_B = 0 + T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_C = (-1 * ((V*4)/(infoFormato(3)*3))) - T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_D = 0 - T*infoFormato(4)/infoFormato(2); 
      else
        TENSAO_NORMAL_A = N/infoFormato(3) + 0;
        TENSAO_NORMAL_B = N/infoFormato(3) + (M * infoFormato(4))/infoFormato(1);
        TENSAO_NORMAL_C = N/infoFormato(3) + 0;
        TENSAO_NORMAL_D = N/infoFormato(3) + (-1*(M  *infoFormato(4))/infoFormato(1));

        multCisalhamento = (power(infoFormato(4),2) + infoFormato(4)*infoFormato(5) + power(infoFormato(5),2))/(power(infoFormato(4),2) + power(infoFormato(5),2));
        
        TENSAO_CISALHAMENTO_A = (-1 * ((V*4)/(infoFormato(3)*3))*multCisalhamento) + T*infoFormato(4)/infoFormato(2) 
        TENSAO_CISALHAMENTO_B = 0 + T*infoFormato(4)/infoFormato(2);
        TENSAO_CISALHAMENTO_C = (-1 * ((V*4)/(infoFormato(3)*3))*multCisalhamento) - T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_D = 0 - T*infoFormato(4)/infoFormato(2); 

      endif

      
      

    elseif j == rows(X)
      V = resolve_equacao(V_x, X(j)-0.000000000000001);
      M = resolve_equacao(M_x, X(j)-0.000000000000001);
      N = resolve_equacao(N_x, X(j)-0.000000000000001);
      T = resolve_equacao(T_x, X(j)-0.000000000000001);
      TETA = (resolve_equacao(Teta_x,X(j)-0.000000000000001)+constanteTETA) * (1/(moduloElasticidade*infoFormato(1))) ; 
      v = (resolve_equacao(v_x,X(j)-0.000000000000001)+constantev + constanteTETA*X(j)) * (1/(moduloElasticidade*infoFormato(1)));
      L = (resolve_equacao(L_x,X(j)-0.000000000000001)+constanteL) * (1/(moduloElasticidade*infoFormato(3)));
      TORCAO = (resolve_equacao(TORCAO_x,X(j)-0.000000000000001)+constanteTORCAO) * (1/(moduloCisalhamento*infoFormato(2)));
      if (infoFormato(6) == 1)
        TENSAO_NORMAL_A = N/infoFormato(3) + 0;
        TENSAO_NORMAL_B = N/infoFormato(3) + (M * infoFormato(4))/infoFormato(1);
        TENSAO_NORMAL_C = N/infoFormato(3) + 0;
        TENSAO_NORMAL_D = N/infoFormato(3) + (-1*(M  *infoFormato(4))/infoFormato(1));
        TENSAO_CISALHAMENTO_A = (-1 * ((V*4)/(infoFormato(3)*3))) + T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_B = 0 + T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_C = (-1 * ((V*4)/(infoFormato(3)*3))) - T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_D = 0 - T*infoFormato(4)/infoFormato(2); 
      else
        TENSAO_NORMAL_A = N/infoFormato(3) + 0;
        TENSAO_NORMAL_B = N/infoFormato(3) + (M * infoFormato(4))/infoFormato(1);
        TENSAO_NORMAL_C = N/infoFormato(3) + 0;
        TENSAO_NORMAL_D = N/infoFormato(3) + (-1*(M  *infoFormato(4))/infoFormato(1));

        multCisalhamento = (power(infoFormato(4),2) + infoFormato(4)*infoFormato(5) + power(infoFormato(5),2))/(power(infoFormato(4),2) + power(infoFormato(5),2));
        
        TENSAO_CISALHAMENTO_A = (-1 * ((V*4)/(infoFormato(3)*3))*multCisalhamento) + T*infoFormato(4)/infoFormato(2) 
        TENSAO_CISALHAMENTO_B = 0 + T*infoFormato(4)/infoFormato(2);
        TENSAO_CISALHAMENTO_C = (-1 * ((V*4)/(infoFormato(3)*3))*multCisalhamento) - T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_D = 0 - T*infoFormato(4)/infoFormato(2); 


      endif

    else
      V = resolve_equacao(V_x, X(j));
      M = resolve_equacao(M_x, X(j));
      N = resolve_equacao(N_x, X(j));
      T = resolve_equacao(T_x, X(j));
      TETA = (resolve_equacao(Teta_x,X(j))+constanteTETA) * (1/(moduloElasticidade*infoFormato(1)));
      v = (resolve_equacao(v_x,X(j))+constantev + constanteTETA*X(j)) * (1/(moduloElasticidade*infoFormato(1)));
      L = (resolve_equacao(L_x,X(j))+constanteL) * (1/(moduloElasticidade*infoFormato(3)));
      TORCAO = (resolve_equacao(TORCAO_x,X(j))+constanteTORCAO) * (1/(moduloCisalhamento*infoFormato(2)));
      if (infoFormato(6) == 1)
        TENSAO_NORMAL_A = N/infoFormato(3) + 0;
        TENSAO_NORMAL_B = N/infoFormato(3) + (M * infoFormato(4))/infoFormato(1);
        TENSAO_NORMAL_C = N/infoFormato(3) + 0;
        TENSAO_NORMAL_D = N/infoFormato(3) + (-1*(M  *infoFormato(4))/infoFormato(1));
        TENSAO_CISALHAMENTO_A = (-1 * ((V*4)/(infoFormato(3)*3))) + T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_B = 0 + T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_C = (-1 * ((V*4)/(infoFormato(3)*3))) - T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_D = 0 - T*infoFormato(4)/infoFormato(2); 
      else
        TENSAO_NORMAL_A = N/infoFormato(3) + 0;
        TENSAO_NORMAL_B = N/infoFormato(3) + (M * infoFormato(4))/infoFormato(1);
        TENSAO_NORMAL_C = N/infoFormato(3) + 0;
        TENSAO_NORMAL_D = N/infoFormato(3) + (-1*(M  *infoFormato(4))/infoFormato(1));

        multCisalhamento = (power(infoFormato(4),2) + infoFormato(4)*infoFormato(5) + power(infoFormato(5),2))/(power(infoFormato(4),2) + power(infoFormato(5),2));
        
        TENSAO_CISALHAMENTO_A = (-1 * ((V*4)/(infoFormato(3)*3))*multCisalhamento) + T*infoFormato(4)/infoFormato(2) 
        TENSAO_CISALHAMENTO_B = 0 + T*infoFormato(4)/infoFormato(2);
        TENSAO_CISALHAMENTO_C = (-1 * ((V*4)/(infoFormato(3)*3))*multCisalhamento) - T*infoFormato(4)/infoFormato(2); 
        TENSAO_CISALHAMENTO_D = 0 - T*infoFormato(4)/infoFormato(2);

      endif
    endif
    
    # Tensoes principais
    #''' Tensoes em A '''
    # tensao_principal(sigma_1,sigma_2, teta, sinal(0 -> +, 1 -> -)
    TENSAO_P1_A = tensao_principal(TENSAO_NORMAL_A, 0, TENSAO_CISALHAMENTO_A, 0);
    TENSAO_P2_A = tensao_principal(TENSAO_NORMAL_A, 0, TENSAO_CISALHAMENTO_A, 1); 
    TENSAO_P3_A = 0;
    # Reordena tensões em tensao_1 > tensao_2 > tensao_3
    reordena = sort([TENSAO_P1_A, TENSAO_P2_A, TENSAO_P3_A]);
    TENSAO_P1_A = reordena(3);
    TENSAO_P2_A = reordena(2);
    TENSAO_P3_A = reordena(1);
    
    #''' Tensoes em B '''
    # tensao_principal(sigma_1,sigma_2, teta, sinal(0 -> +, 1 -> -)
    TENSAO_P1_B = tensao_principal(TENSAO_NORMAL_B, 0, TENSAO_CISALHAMENTO_B, 0);
    TENSAO_P2_B = tensao_principal(TENSAO_NORMAL_B, 0, TENSAO_CISALHAMENTO_B, 1); 
    TENSAO_P3_B = 0;
    # Reordena tensões em tensao_1 > tensao_2 > tensao_3
    reordena = sort([TENSAO_P1_B, TENSAO_P2_B, TENSAO_P3_B]);
    TENSAO_P1_B = reordena(3);
    TENSAO_P2_B = reordena(2);
    TENSAO_P3_B = reordena(1);
    
    #''' Tensoes em C '''
    # tensao_principal(sigma_1,sigma_2, teta, sinal(0 -> +, 1 -> -)
    TENSAO_P1_C = tensao_principal(TENSAO_NORMAL_C, 0, TENSAO_CISALHAMENTO_C, 0);
    TENSAO_P2_C = tensao_principal(TENSAO_NORMAL_C, 0, TENSAO_CISALHAMENTO_C, 1); 
    TENSAO_P3_C = 0;
    # Reordena tensões em tensao_1 > tensao_2 > tensao_3
    reordena = sort([TENSAO_P1_C, TENSAO_P2_C, TENSAO_P3_C]);
    TENSAO_P1_C = reordena(3);
    TENSAO_P2_C = reordena(2);
    TENSAO_P3_C = reordena(1);
    
    #''' Tensoes em D '''
    # tensao_principal(sigma_1,sigma_2, teta, sinal(0 -> +, 1 -> -)
    TENSAO_P1_D = tensao_principal(TENSAO_NORMAL_D, 0, TENSAO_CISALHAMENTO_D, 0);
    TENSAO_P2_D = tensao_principal(TENSAO_NORMAL_D, 0, TENSAO_CISALHAMENTO_D, 1); 
    TENSAO_P3_D = 0;
    # Reordena tensões em tensao_1 > tensao_2 > tensao_3
    reordena = sort([TENSAO_P1_D, TENSAO_P2_D, TENSAO_P3_D]);
    TENSAO_P1_D = reordena(3); 
    TENSAO_P2_D = reordena(2);
    TENSAO_P3_D = reordena(1);
    
    #Tensões de Cisalhamento Máximas Absolutas
    TENSAO_CISALHAMENTO_MAX_ABS_A = (TENSAO_P1_A - TENSAO_P3_A)/2;
    TENSAO_CISALHAMENTO_MAX_ABS_B = (TENSAO_P1_B - TENSAO_P3_B)/2;
    TENSAO_CISALHAMENTO_MAX_ABS_C = (TENSAO_P1_C - TENSAO_P3_C)/2;
    TENSAO_CISALHAMENTO_MAX_ABS_D = (TENSAO_P1_D - TENSAO_P3_D)/2;
    
    # Deformações ε x , ε y , ε z , γ xy , γ yz e γ zx
    #'''Deformacoes em A'''
    DEFORMACAO_Ex_A = (1/moduloElasticidade) * (TENSAO_NORMAL_A - coeficiente_de_Poisson*( 0 + 0 ));
    DEFORMACAO_Ey_A = (1/moduloElasticidade) * (0 - coeficiente_de_Poisson*( TENSAO_NORMAL_A + 0 ));
    DEFORMACAO_Ez_A = (1/moduloElasticidade) * (0 - coeficiente_de_Poisson*( TENSAO_NORMAL_A + 0 ));
    DEFORMACAO_Yxy_A = (1/moduloCisalhamento) * TENSAO_CISALHAMENTO_A;
    DEFORMACAO_Yyz_A = (1/moduloCisalhamento) * 0;
    DEFORMACAO_Yzx_A = (1/moduloCisalhamento) * 0;
    
    #'''Deformacoes em B'''
    DEFORMACAO_Ex_B = (1/moduloElasticidade) * (TENSAO_NORMAL_B - coeficiente_de_Poisson*( 0 + 0 ));
    DEFORMACAO_Ey_B = (1/moduloElasticidade) * (0 - coeficiente_de_Poisson*( TENSAO_NORMAL_B + 0 ));
    DEFORMACAO_Ez_B = (1/moduloElasticidade) * (0 - coeficiente_de_Poisson*( TENSAO_NORMAL_B + 0 ));
    DEFORMACAO_Yxy_B = (1/moduloCisalhamento) * 0;
    DEFORMACAO_Yyz_B = (1/moduloCisalhamento) * 0;
    DEFORMACAO_Yzx_B = (1/moduloCisalhamento) * TENSAO_CISALHAMENTO_B;
    
    #'''Deformacoes em C'''
    DEFORMACAO_Ex_C = (1/moduloElasticidade) * (TENSAO_NORMAL_C - coeficiente_de_Poisson*( 0 + 0 ));
    DEFORMACAO_Ey_C = (1/moduloElasticidade) * (0 - coeficiente_de_Poisson*( TENSAO_NORMAL_C + 0 ));
    DEFORMACAO_Ez_C = (1/moduloElasticidade) * (0 - coeficiente_de_Poisson*( TENSAO_NORMAL_C + 0 ));
    DEFORMACAO_Yxy_C = (1/moduloCisalhamento) * TENSAO_CISALHAMENTO_C;
    DEFORMACAO_Yyz_C = (1/moduloCisalhamento) * 0;
    DEFORMACAO_Yzx_C = (1/moduloCisalhamento) * 0;
    
    #'''Deformacoes em D'''
    DEFORMACAO_Ex_D = (1/moduloElasticidade) * (TENSAO_NORMAL_D - coeficiente_de_Poisson*( 0 + 0 ));
    DEFORMACAO_Ey_D = (1/moduloElasticidade) * (0 - coeficiente_de_Poisson*( TENSAO_NORMAL_D + 0 ));
    DEFORMACAO_Ez_D = (1/moduloElasticidade) * (0 - coeficiente_de_Poisson*( TENSAO_NORMAL_D + 0 ));
    DEFORMACAO_Yxy_D = (1/moduloCisalhamento) * 0;
    DEFORMACAO_Yyz_D = (1/moduloCisalhamento) * 0;
    DEFORMACAO_Yzx_D = (1/moduloCisalhamento) * TENSAO_CISALHAMENTO_D;
    
    # Coeficientes de segurança referentes ao Critério de Tresca e ao Critério de von Mises
    
    TRESCA_A = limite_de_escoamento / (TENSAO_P1_A - TENSAO_P3_A);
    TRESCA_B = limite_de_escoamento / (TENSAO_P1_B - TENSAO_P3_B);
    TRESCA_C = limite_de_escoamento / (TENSAO_P1_C - TENSAO_P3_C);
    TRESCA_D = limite_de_escoamento / (TENSAO_P1_D - TENSAO_P3_D);
    
    if TENSAO_P1_A == 0
      VON_MISES_A = limite_de_escoamento / sqrt(power(TENSAO_P2_A,2) - (TENSAO_P2_A*TENSAO_P3_A) + (power(TENSAO_P3_A,2)));
    elseif TENSAO_P2_A == 0
      VON_MISES_A = limite_de_escoamento / sqrt(power(TENSAO_P1_A,2) - (TENSAO_P1_A*TENSAO_P3_A) + (power(TENSAO_P3_A,2)));
    else  
      VON_MISES_A = limite_de_escoamento / sqrt(power(TENSAO_P1_A,2) - (TENSAO_P1_A*TENSAO_P2_A) + (power(TENSAO_P2_A,2)));
    endif
    if TENSAO_P1_B == 0
      VON_MISES_B = limite_de_escoamento / sqrt(power(TENSAO_P2_B,2) - (TENSAO_P2_B*TENSAO_P3_B) + (power(TENSAO_P3_B,2)));
    elseif TENSAO_P2_B == 0
      VON_MISES_B = limite_de_escoamento / sqrt(power(TENSAO_P1_B,2) - (TENSAO_P1_B*TENSAO_P3_B) + (power(TENSAO_P3_B,2)));
    else  
      VON_MISES_B = limite_de_escoamento / sqrt(power(TENSAO_P1_B,2) - (TENSAO_P1_B*TENSAO_P2_B) + (power(TENSAO_P2_B,2)));
    endif
    if TENSAO_P1_C == 0
      VON_MISES_C = limite_de_escoamento / sqrt(power(TENSAO_P2_C,2) - (TENSAO_P2_C*TENSAO_P3_C) + (power(TENSAO_P3_C,2)));
    elseif TENSAO_P2_C == 0
      VON_MISES_C = limite_de_escoamento / sqrt(power(TENSAO_P1_C,2) - (TENSAO_P1_C*TENSAO_P3_C) + (power(TENSAO_P3_C,2)));
    else  
      VON_MISES_C = limite_de_escoamento / sqrt(power(TENSAO_P1_C,2) - (TENSAO_P1_C*TENSAO_P2_C) + (power(TENSAO_P2_C,2)));
    endif
    if TENSAO_P1_D == 0
      VON_MISES_D = limite_de_escoamento / sqrt(power(TENSAO_P2_D,2) - (TENSAO_P2_D*TENSAO_P3_D) + (power(TENSAO_P3_D,2)));
    elseif TENSAO_P2_D == 0
      VON_MISES_D = limite_de_escoamento / sqrt(power(TENSAO_P1_D,2) - (TENSAO_P1_D*TENSAO_P3_D) + (power(TENSAO_P3_D,2)));
    else  
      VON_MISES_D = limite_de_escoamento / sqrt(power(TENSAO_P1_D,2) - (TENSAO_P1_D*TENSAO_P2_D) + (power(TENSAO_P2_D,2)));
    endif
    %}
    #printf(DadosDoDiagrama_V_x(j));
    DadosDoDiagrama_V_x(j) = [V];
    DadosDoDiagrama_M_x(j) = [M];
    DadosDoDiagrama_N_x(j) = [N];
    DadosDoDiagrama_T_x(j) = [T];
    DadosDoDiagrama_TETA_x(j) = [TETA];
    DadosDoDiagrama_v_x(j) = [v];
    DadosDoDiagrama_L_x(j) = [L];
    DadosDoDiagrama_TORCAO_x(j) = [TORCAO];
    
    DadosDoDiagrama_TENSAO_NORMAL_A_x(j) = [TENSAO_NORMAL_A];
    DadosDoDiagrama_TENSAO_NORMAL_B_x(j) = [TENSAO_NORMAL_B];
    DadosDoDiagrama_TENSAO_NORMAL_C_x(j) = [TENSAO_NORMAL_C];
    DadosDoDiagrama_TENSAO_NORMAL_D_x(j) = [TENSAO_NORMAL_D];
    DadosDoDiagrama_TENSAO_CISALHAMENTO_A_x(j) = [TENSAO_CISALHAMENTO_A];
    DadosDoDiagrama_TENSAO_CISALHAMENTO_B_x(j) = [TENSAO_CISALHAMENTO_B];
    DadosDoDiagrama_TENSAO_CISALHAMENTO_C_x(j) = [TENSAO_CISALHAMENTO_C];
    DadosDoDiagrama_TENSAO_CISALHAMENTO_D_x(j) = [TENSAO_CISALHAMENTO_D];
    DadosDoDiagrama_TENSOES_PRINCIPAIS_A_x(j,:) = [TENSAO_P1_A,TENSAO_P2_A,TENSAO_P3_A];
    DadosDoDiagrama_TENSOES_PRINCIPAIS_B_x(j,:) = [TENSAO_P1_B,TENSAO_P2_B,TENSAO_P3_B];
    DadosDoDiagrama_TENSOES_PRINCIPAIS_C_x(j,:) = [TENSAO_P1_C,TENSAO_P2_C,TENSAO_P3_C];
    DadosDoDiagrama_TENSOES_PRINCIPAIS_D_x(j,:) = [TENSAO_P1_D,TENSAO_P2_D,TENSAO_P3_D];
    DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_A_x(j) = [TENSAO_CISALHAMENTO_MAX_ABS_A];
    DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_B_x(j) = [TENSAO_CISALHAMENTO_MAX_ABS_B];
    DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_C_x(j) = [TENSAO_CISALHAMENTO_MAX_ABS_C];
    DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_D_x(j) = [TENSAO_CISALHAMENTO_MAX_ABS_D];
    DadosDoDiagrama_DEFORMACAO_E_A_x(j,:) = [DEFORMACAO_Ex_A,DEFORMACAO_Ey_A,DEFORMACAO_Ez_A];
    DadosDoDiagrama_DEFORMACAO_E_B_x(j,:) = [DEFORMACAO_Ex_B,DEFORMACAO_Ey_B,DEFORMACAO_Ez_B];
    DadosDoDiagrama_DEFORMACAO_E_C_x(j,:) = [DEFORMACAO_Ex_C,DEFORMACAO_Ey_C,DEFORMACAO_Ez_C];
    DadosDoDiagrama_DEFORMACAO_E_D_x(j,:) = [DEFORMACAO_Ex_D,DEFORMACAO_Ey_D,DEFORMACAO_Ez_D];
    DadosDoDiagrama_DEFORMACAO_Y_A_x(j,:) = [DEFORMACAO_Yxy_A,DEFORMACAO_Yyz_A,DEFORMACAO_Yzx_A];
    DadosDoDiagrama_DEFORMACAO_Y_B_x(j,:) = [DEFORMACAO_Yxy_B,DEFORMACAO_Yyz_B,DEFORMACAO_Yzx_B];
    DadosDoDiagrama_DEFORMACAO_Y_C_x(j,:) = [DEFORMACAO_Yxy_C,DEFORMACAO_Yyz_C,DEFORMACAO_Yzx_C];
    DadosDoDiagrama_DEFORMACAO_Y_D_x(j,:) = [DEFORMACAO_Yxy_D,DEFORMACAO_Yyz_D,DEFORMACAO_Yzx_D];
    DadosDoDiagrama_TRESCA_AND_VON_MISES_A_x(j,:) = [TRESCA_A*10^6, VON_MISES_A*10^6];
    DadosDoDiagrama_TRESCA_AND_VON_MISES_B_x(j,:) = [TRESCA_B*10^6, VON_MISES_B*10^6];
    DadosDoDiagrama_TRESCA_AND_VON_MISES_C_x(j,:) = [TRESCA_C*10^6, VON_MISES_C*10^6];
    DadosDoDiagrama_TRESCA_AND_VON_MISES_D_x(j,:) = [TRESCA_D*10^6, VON_MISES_D*10^6];

endfor 

  # plot da função para cada intervalo dos pontos de interesse
  figure(1)
  subplot(4,2,1);
  hold on;
  xlabel ("x");
  ylabel ("V(x)");
  title ("Esforco cortante");
  plot(X,DadosDoDiagrama_V_x);
  hold off;     
  
  subplot(4,2,2);
  hold on;
  xlabel ("x");
  ylabel ("M(x)");
  title ("Momento fletor");
  plot(X,DadosDoDiagrama_M_x);
  hold off;

  subplot(4,2,3);
  hold on;
  xlabel ("x");
  ylabel ("N(x)");
  title ("Forcas normais");
  plot(X,DadosDoDiagrama_N_x);
  hold off;

  subplot(4,2,4);
  hold on;
  xlabel ("x");
  ylabel ("T(x)");
  title ("Torques internos");
  plot(X,DadosDoDiagrama_T_x);
  hold off;

  subplot(4,2,5);
  hold on;
  xlabel ("x");
  ylabel ("0(x)");
  title ("Inclinacao");
  plot(X,DadosDoDiagrama_TETA_x);
  hold off;

  subplot(4,2,6);
  hold on;
  xlabel ("x");
  ylabel ("v(x)");
  title ("Deflexao");
  plot(X,DadosDoDiagrama_v_x);
  hold off;

  subplot(4,2,7);
  hold on;
  xlabel ("x");
  ylabel ("L(x)");
  title ("Alongamento");
  plot(X,DadosDoDiagrama_L_x);
  hold off;

  subplot(4,2,8);
  hold on;
  xlabel ("x");
  ylabel ("Torcao(x)");
  title ("Angulo de Torcao");
  plot(X,DadosDoDiagrama_TORCAO_x);
  hold off;
  saveas (1,"diagramaForcasSolicitantes.pdf");
  ############  PONTO A  ##########
  # Plot de todos os graficos relacionados ao ponto A da barra
  #################################
  figure(2)
  #figure1=figure(2,'Position', [500, 500, 1024, 1200]);
  subplot(2,2,1);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensao(Pa)");
  title ("Tensao normal em A");
  plot(X,DadosDoDiagrama_TENSAO_NORMAL_A_x);
  hold off;
  
  subplot(2,2,2);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensão de cisalhamento(Pa)");
  title ("Tensao de cisalhamento em A");
  plot(X,DadosDoDiagrama_TENSAO_CISALHAMENTO_A_x);
  hold off;
    
  subplot(2,2,3);
  hold on;
  xlabel ("x(m)");
  ylabel ("tensoes(Pa)");
  title ("Tensoes principais em A");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_A_x(:,1),"r");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_A_x(:,2),"g");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_A_x(:,3),"b");
  legend('Tensao 1','Tensao 2','Tensao 3');
  hold off;
  
  subplot(2,2,4);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensão de cisalhamento(Pa)");
  title ("Tensao de cisalhamento maxima absoluta em A");
  plot(X,DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_A_x);
  hold off;
  
  saveas (2,"DiagramasDoPontoA_1.pdf");
  
  figure(3)
  
  subplot(2,2,1);
  hold on;
  xlabel ("x(m)");
  ylabel ("Deformacoes E(Pa)");
  title ("Deformacoes Normais em A");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_A_x(:,1),"r");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_A_x(:,2),"g");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_A_x(:,3),"b");
  legend('Ex','Ey','Ez');
  hold off;
  
  subplot(2,2,2);
  hold on;
  xlabel ("x(m)");
  ylabel ("Deformacoes Y(Pa)");
  title ("Deformacoes por cisalhamento em A");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_A_x(:,1),"r");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_A_x(:,2),"g");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_A_x(:,3),"b");
  legend('Yxy','Yyz','Yzx');
  hold off;
  
  subplot(2,2,3);
  hold on;
  xlabel ("x(m)");
  ylabel ("Coeficientes (MPa)");
  title ("Coeficientes de segurança em A");
  plot(X,DadosDoDiagrama_TRESCA_AND_VON_MISES_A_x(:,1),"r");
  plot(X,DadosDoDiagrama_TRESCA_AND_VON_MISES_A_x(:,2),"g");
  legend('Tresca','Von Mises');
  hold off;
  
  saveas (3,"DiagramasDoPontoA_2.pdf");
  
    ############  PONTO B  ##########
  # Plot de todos os graficos relacionados ao ponto B da barra
  #################################
  figure(4)
  #figure1=figure(2,'Position', [500, 500, 1024, 1200]);
  subplot(2,2,1);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensao(Pa)");
  title ("Tensao normal em B ");
  plot(X,DadosDoDiagrama_TENSAO_NORMAL_B_x);
  hold off;
  
  subplot(2,2,2);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensão de cisalhamento(Pa)");
  title ("Tensao de cisalhamento em B ");
  plot(X,DadosDoDiagrama_TENSAO_CISALHAMENTO_B_x);
  hold off;
    
  subplot(2,2,3);
  hold on;
  xlabel ("x(m)");
  ylabel ("tensoes(Pa)");
  title ("Tensoes principais em B ");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_B_x(:,1),"r");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_B_x(:,2),"g");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_B_x(:,3),"b");
  legend('Tensao 1','Tensao 2','Tensao 3');
  hold off;
  
  subplot(2,2,4);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensão de cisalhamento(Pa)");
  title ("Tensao de cisalhamento maxima absoluta em B ");
  plot(X,DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_B_x);
  hold off;
  
  saveas (4,"DiagramasDoPonto_B_1.pdf");
  
  figure(5)
  
  subplot(2,2,1);
  hold on;
  xlabel ("x(m)");
  ylabel ("Deformacoes E(Pa)");
  title ("Deformacoes Normais em B ");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_B_x(:,1),"r");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_B_x(:,2),"g");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_B_x(:,3),"b");
  legend('Ex','Ey','Ez');
  hold off;
  
  subplot(2,2,2);
  hold on;
  xlabel ("x(m)");
  ylabel ("Deformacoes Y(Pa)");
  title ("Deformacoes por cisalhamento em B ");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_B_x(:,1),"r");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_B_x(:,2),"g");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_B_x(:,3),"b");
  legend('Yxy','Yyz','Yzx');
  hold off;
  
  subplot(2,2,3);
  hold on;
  xlabel ("x(m)");
  ylabel ("Coeficientes (MPa)");
  title ("Coeficientes de segurança em B ");
  plot(X,DadosDoDiagrama_TRESCA_AND_VON_MISES_B_x(:,1),"r");
  plot(X,DadosDoDiagrama_TRESCA_AND_VON_MISES_B_x(:,2),"g");
  legend('Tresca','Von Mises');
  hold off;
  
  saveas (5,"DiagramasDoPonto_B_2.pdf");
  
    ############  PONTO C  ##########
  # Plot de todos os graficos relacionados ao ponto C da barra
  #################################
  figure(6)
  #figure1=figure(2,'Position', [500, 500, 1024, 1200]);
  subplot(2,2,1);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensao(Pa)");
  title ("Tensao normal em C ");
  plot(X,DadosDoDiagrama_TENSAO_NORMAL_C_x);
  hold off;
  
  subplot(2,2,2);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensão de cisalhamento(Pa)");
  title ("Tensao de cisalhamento em C ");
  plot(X,DadosDoDiagrama_TENSAO_CISALHAMENTO_C_x);
  hold off;
    
  subplot(2,2,3);
  hold on;
  xlabel ("x(m)");
  ylabel ("tensoes(Pa)");
  title ("Tensoes principais em C ");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_C_x(:,1),"r");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_C_x(:,2),"g");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_C_x(:,3),"b");
  legend('Tensao 1','Tensao 2','Tensao 3');
  hold off;
  
  subplot(2,2,4);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensão de cisalhamento(Pa)");
  title ("Tensao de cisalhamento maxima absoluta em C ");
  plot(X,DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_C_x);
  hold off;
  
  saveas (6,"DiagramasDoPonto_C_1.pdf");
  
  figure(7)
  
  subplot(2,2,1);
  hold on;
  xlabel ("x(m)");
  ylabel ("Deformacoes E(Pa)");
  title ("Deformacoes Normais em C ");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_C_x(:,1),"r");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_C_x(:,2),"g");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_C_x(:,3),"b");
  legend('Ex','Ey','Ez');
  hold off;
  
  subplot(2,2,2);
  hold on;
  xlabel ("x(m)");
  ylabel ("Deformacoes Y(Pa)");
  title ("Deformacoes por cisalhamento em C ");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_C_x(:,1),"r");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_C_x(:,2),"g");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_C_x(:,3),"b");
  legend('Yxy','Yyz','Yzx');
  hold off;
  
  subplot(2,2,3);
  hold on;
  xlabel ("x(m)");
  ylabel ("Coeficientes (MPa)");
  title ("Coeficientes de segurança em C ");
  plot(X,DadosDoDiagrama_TRESCA_AND_VON_MISES_C_x(:,1),"r");
  plot(X,DadosDoDiagrama_TRESCA_AND_VON_MISES_C_x(:,2),"g");
  legend('Tresca','Von Mises');
  hold off;
  
  saveas (7,"DiagramasDoPonto_C_2.pdf");
  
    ############  PONTO D  ##########
  # Plot de todos os graficos relacionados ao ponto D da barra
  #################################
  figure(8)
  #figure1=figure(2,'Position', [500, 500, 1024, 1200]);
  subplot(2,2,1);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensao(Pa)");
  title ("Tensao normal em D ");
  plot(X,DadosDoDiagrama_TENSAO_NORMAL_D_x);
  hold off;
  
  subplot(2,2,2);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensão de cisalhamento(Pa)");
  title ("Tensao de cisalhamento em D ");
  plot(X,DadosDoDiagrama_TENSAO_CISALHAMENTO_D_x);
  hold off;
    
  subplot(2,2,3);
  hold on;
  xlabel ("x(m)");
  ylabel ("tensoes(Pa)");
  title ("Tensoes principais em D ");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_D_x(:,1),"r");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_D_x(:,2),"g");
  plot(X,DadosDoDiagrama_TENSOES_PRINCIPAIS_D_x(:,3),"b");
  legend('Tensao 1','Tensao 2','Tensao 3');
  hold off;
  
  subplot(2,2,4);
  hold on;
  xlabel ("x(m)");
  ylabel ("Tensão de cisalhamento(Pa)");
  title ("Tensao de cisalhamento maxima absoluta em D ");
  plot(X,DadosDoDiagrama_TENSAO_CISALHAMENTO_MAX_ABS_D_x);
  hold off;
  
  saveas (8,"DiagramasDoPonto_D_1.pdf");
  
  figure(9)
  
  subplot(2,2,1);
  hold on;
  xlabel ("x(m)");
  ylabel ("Deformacoes E(Pa)");
  title ("Deformacoes Normais em D ");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_D_x(:,1),"r");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_D_x(:,2),"g");
  plot(X,DadosDoDiagrama_DEFORMACAO_E_D_x(:,3),"b");
  legend('Ex','Ey','Ez');
  hold off;
  
  subplot(2,2,2);
  hold on;
  xlabel ("x(m)");
  ylabel ("Deformacoes Y(Pa)");
  title ("Deformacoes por cisalhamento em D ");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_D_x(:,1),"r");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_D_x(:,2),"g");
  plot(X,DadosDoDiagrama_DEFORMACAO_Y_D_x(:,3),"b");
  legend('Yxy','Yyz','Yzx');
  hold off;
  
  subplot(2,2,3);
  hold on;
  xlabel ("x(m)");
  ylabel ("Coeficientes (MPa)");
  title ("Coeficientes de segurança em D ");
  plot(X,DadosDoDiagrama_TRESCA_AND_VON_MISES_D_x(:,1),"r");
  plot(X,DadosDoDiagrama_TRESCA_AND_VON_MISES_D_x(:,2),"g");
  legend('Tresca','Von Mises');
  hold off;
  
  saveas (9,"DiagramasDoPonto_D_2.pdf");
  
endfor

open diagramaForcasSolicitantes.pdf


