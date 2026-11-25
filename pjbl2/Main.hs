{-# OPTIONS_GHC -Wall #-}

module Main where

import Data.Char (isSpace)
import Data.Either (partitionEithers)
import Data.List (group, nub, sort, sortBy)
import Data.Maybe (fromMaybe, mapMaybe)
import Data.Ord (Down (..), comparing)
import Text.Read (readMaybe)


-- CAMADA 1: TIPOS E DADOS DO CAMPEONATO


type Time = String

data Resultado
  = Vitoria
  | Empate
  | Derrota
  deriving (Show, Eq)

data Partida = Partida
  { rodada :: Int
  , mandante :: Time
  , golsMandante :: Int
  , golsVisitante :: Int
  , visitante :: Time
  }
  deriving (Show, Eq)

data Linha = Linha
  { time :: Time
  , jogos :: Int
  , vitorias :: Int
  , empates :: Int
  , derrotas :: Int
  , golsPro :: Int
  , golsContra :: Int
  }
  deriving (Show, Eq)

participou :: Time -> Partida -> Bool
participou nomeTime partida =
  nomeTime == mandante partida || nomeTime == visitante partida

resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara nomeTime partida
  | nomeTime == mandante partida =
      Just (compararPlacar (golsMandante partida) (golsVisitante partida))
  | nomeTime == visitante partida =
      Just (compararPlacar (golsVisitante partida) (golsMandante partida))
  | otherwise = Nothing
  where
    compararPlacar golsTime golsAdversario =
      case compare golsTime golsAdversario of
        GT -> Vitoria
        EQ -> Empate
        LT -> Derrota

times :: [Partida] -> [Time]
times = sort . nub . concatMap (\partida -> [mandante partida, visitante partida])


-- CAMADA 2: CLASSIFICACAO


pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate = 1
pontos Derrota = 0

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas nomeTime = foldl atualizarLinha linhaInicial partidas
  where
    linhaInicial = Linha nomeTime 0 0 0 0 0 0
    atualizarLinha linhaAtual partida =
      case resultadoPara nomeTime partida of
        Nothing -> linhaAtual
        Just res ->
          let (gp, gc) =
                if nomeTime == mandante partida
                  then (golsMandante partida, golsVisitante partida)
                  else (golsVisitante partida, golsMandante partida)
          in linhaAtual
               { jogos = jogos linhaAtual + 1
               , vitorias = vitorias linhaAtual + if res == Vitoria then 1 else 0
               , empates = empates linhaAtual + if res == Empate then 1 else 0
               , derrotas = derrotas linhaAtual + if res == Derrota then 1 else 0
               , golsPro = golsPro linhaAtual + gp
               , golsContra = golsContra linhaAtual + gc
               }

pontosLinha :: Linha -> Int
pontosLinha linha =
  vitorias linha * pontos Vitoria + empates linha * pontos Empate

saldo :: Linha -> Int
saldo linha = golsPro linha - golsContra linha

aproveitamento :: Linha -> Double
aproveitamento linha
  | jogos linha == 0 = 0.0
  | otherwise =
      (fromIntegral (pontosLinha linha) / fromIntegral (jogos linha * 3)) * 100.0

-- Criterios de desempate:
-- 1) Pontos (desc) -> 2) Vitorias (desc) -> 3) Saldo de gols (desc)
-- -> 4) Gols pro (desc) -> 5) Nome do time (ordem alfabetica)
compararLinhas :: Linha -> Linha -> Ordering
compararLinhas =
  comparing (Down . pontosLinha)
    <> comparing (Down . vitorias)
    <> comparing (Down . saldo)
    <> comparing (Down . golsPro)
    <> comparing time

classificacao :: [Partida] -> [Linha]
classificacao partidas =
  sortBy compararLinhas (map (linhaDoTime partidas) (times partidas))

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada limite = filter ((<= limite) . rodada)

diferencaGols :: Partida -> Int
diferencaGols partida = abs (golsMandante partida - golsVisitante partida)

maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada = foldl escolherMaior Nothing
  where
    escolherMaior Nothing atual = Just atual
    escolherMaior (Just melhor) atual
      | diferencaGols atual > diferencaGols melhor = Just atual
      | otherwise = Just melhor

mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols partidas =
  Just (fromIntegral totalGols / fromIntegral (length partidas))
  where
    totalGols = sum (map (\p -> golsMandante p + golsVisitante p) partidas)


-- CAMADA 3: LEITURA, VALIDACAO E FORMATACAO


data Erro
  = CamposInvalidos Int String
  | NumeroInvalido Int String
  | PlacarNegativo Int Int
  | MesmoTime Int Time
  | TimeRepetidoNaRodada Int Time
  deriving (Show, Eq)

separar :: Char -> String -> [String]
separar delimitador = foldr passo [""]
  where
    passo caractere acc
      | caractere == delimitador = "" : acc
      | otherwise = case acc of
          [] -> [[caractere]]
          (cabeca : cauda) -> (caractere : cabeca) : cauda

removerEspacos :: String -> String
removerEspacos = reverse . dropWhile isSpace . reverse . dropWhile isSpace

ehLinhaIgnorada :: String -> Bool
ehLinhaIgnorada linhaTexto =
  let limpa = removerEspacos linhaTexto
  in null limpa || case limpa of
       ('#' : _) -> True
       _ -> False

linhasRelevantes :: String -> [(Int, String)]
linhasRelevantes texto =
  filter (not . ehLinhaIgnorada . snd) (zip [1 :: Int ..] (lines texto))

lerInteiro :: Int -> String -> Either Erro Int
lerInteiro numLinha texto =
  maybe (Left (NumeroInvalido numLinha texto)) Right (readMaybe texto)

lerInteiroPositivo :: Int -> String -> Either Erro Int
lerInteiroPositivo numLinha texto =
  maybe
    (Left (NumeroInvalido numLinha texto))
    Right
    (readMaybe texto >>= \n -> if n > 0 then Just n else Nothing)

validarPlacar :: Int -> Int -> Either Erro ()
validarPlacar numLinha gols
  | gols < 0 = Left (PlacarNegativo numLinha gols)
  | otherwise = Right ()

lerPartida :: Int -> String -> Either Erro Partida
lerPartida numLinha linhaBruta = do
  let campos = map removerEspacos (separar ';' linhaBruta)
  (strRodada, mand, strGolsM, strGolsV, visit) <-
    case campos of
      [r, m, gm, gv, v] | not (null m) && not (null v) -> Right (r, m, gm, gv, v)
      _ -> Left (CamposInvalidos numLinha linhaBruta)
  numRodada <- lerInteiroPositivo numLinha strRodada
  golsM <- lerInteiro numLinha strGolsM
  golsV <- lerInteiro numLinha strGolsV
  validarPlacar numLinha golsM
  validarPlacar numLinha golsV
  if mand == visit
    then Left (MesmoTime numLinha mand)
    else Right (Partida numRodada mand golsM golsV visit)

timesRepetidosNaRodada :: Int -> [Partida] -> [Erro]
timesRepetidosNaRodada numRodada partidas =
  let partidasDaRodada = filter ((== numRodada) . rodada) partidas
      aparicoes = concatMap (\p -> [mandante p, visitante p]) partidasDaRodada
      grupos = group (sort aparicoes)
  in mapMaybe extrairRepetido grupos
  where
    extrairRepetido (nomeTime : _ : _) = Just (TimeRepetidoNaRodada numRodada nomeTime)
    extrairRepetido _ = Nothing

verificarRodadas :: [Partida] -> [Erro]
verificarRodadas partidas =
  let rodadasUnicas = sort (nub (map rodada partidas))
  in concatMap (`timesRepetidosNaRodada` partidas) rodadasUnicas

lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (uncurry lerPartida) (linhasRelevantes texto)
  case verificarRodadas partidas of
    [] -> Right partidas
    (primeiroErro : _) -> Left primeiroErro

todosOsErros :: String -> [Erro]
todosOsErros texto =
  let resultados = map (uncurry lerPartida) (linhasRelevantes texto)
      (errosLinhas, partidasValidas) = partitionEithers resultados
      errosDeRodada = verificarRodadas partidasValidas
  in errosLinhas ++ errosDeRodada

formatarErro :: Erro -> String
formatarErro (CamposInvalidos numLinha conteudo) =
  "Linha " ++ show numLinha ++ ": quantidade de campos invalida ou time vazio -> " ++ show conteudo
formatarErro (NumeroInvalido numLinha conteudo) =
  "Linha " ++ show numLinha ++ ": numero invalido -> " ++ show conteudo
formatarErro (PlacarNegativo numLinha gols) =
  "Linha " ++ show numLinha ++ ": placar negativo nao permitido -> " ++ show gols
formatarErro (MesmoTime numLinha nomeTime) =
  "Linha " ++ show numLinha ++ ": time nao pode jogar contra si mesmo -> " ++ nomeTime
formatarErro (TimeRepetidoNaRodada numRodada nomeTime) =
  "Rodada " ++ show numRodada ++ ": time escalado mais de uma vez -> " ++ nomeTime

alinharEsquerda :: Int -> String -> String
alinharEsquerda largura texto =
  texto ++ replicate (max 0 (largura - length texto)) ' '

alinharDireita :: Int -> String -> String
alinharDireita largura texto =
  replicate (max 0 (largura - length texto)) ' ' ++ texto

formatarSaldo :: Int -> String
formatarSaldo valor
  | valor > 0 = '+' : show valor
  | otherwise = show valor

formatarDuasCasas :: Double -> String
formatarDuasCasas valor =
  let centesimos :: Int
      centesimos = round (valor * 100)
      (parteInteira, parteDecimal) = abs centesimos `divMod` 100
      sinal = if centesimos < 0 then "-" else ""
      decimalTexto =
        if parteDecimal < 10
          then '0' : show parteDecimal
          else show parteDecimal
  in sinal ++ show parteInteira ++ "." ++ decimalTexto

formatarPartida :: Partida -> String
formatarPartida partida =
  "Rodada "
    ++ show (rodada partida)
    ++ ": "
    ++ mandante partida
    ++ " "
    ++ show (golsMandante partida)
    ++ " x "
    ++ show (golsVisitante partida)
    ++ " "
    ++ visitante partida

tabelaFormatada :: [Linha] -> String
tabelaFormatada [] = "Nenhuma partida registrada no campeonato."
tabelaFormatada linhas = unlines (cabecalho : separador : corpo)
  where
    cabecalho =
      alinharDireita 3 "Pos" ++ " | "
        ++ alinharEsquerda 14 "Time" ++ " | "
        ++ alinharDireita 3 "Pts" ++ " | "
        ++ alinharDireita 2 "J" ++ " | "
        ++ alinharDireita 2 "V" ++ " | "
        ++ alinharDireita 2 "E" ++ " | "
        ++ alinharDireita 2 "D" ++ " | "
        ++ alinharDireita 3 "GP" ++ " | "
        ++ alinharDireita 3 "GC" ++ " | "
        ++ alinharDireita 3 "SG"
    separador = replicate (length cabecalho) '-'
    corpo = zipWith formatarLinha [1 :: Int ..] linhas
    formatarLinha posicao linha =
      alinharDireita 3 (show posicao) ++ " | "
        ++ alinharEsquerda 14 (time linha) ++ " | "
        ++ alinharDireita 3 (show (pontosLinha linha)) ++ " | "
        ++ alinharDireita 2 (show (jogos linha)) ++ " | "
        ++ alinharDireita 2 (show (vitorias linha)) ++ " | "
        ++ alinharDireita 2 (show (empates linha)) ++ " | "
        ++ alinharDireita 2 (show (derrotas linha)) ++ " | "
        ++ alinharDireita 3 (show (golsPro linha)) ++ " | "
        ++ alinharDireita 3 (show (golsContra linha)) ++ " | "
        ++ alinharDireita 3 (formatarSaldo (saldo linha))


-- DADOS DE TESTE
-- 6 times, 5 rodadas (turno unico), empate 0x0, goleadas >= 3 gols,
-- empate em pontos na classificacao final decidido por saldo de gols.


dadosCampeonato :: String
dadosCampeonato =
  unlines
    [ "# rodada; mandante; gols mandante; gols visitante; visitante"
    , "# Rodada 1"
    , "1; Athletico; 2; 0; Operario"
    , "1; Cascavel; 0; 3; Maringa"
    , "1; Coritiba; 0; 0; Londrina"
    , ""
    , "# Rodada 2"
    , "2; Operario; 1; 1; Londrina"
    , "2; Maringa; 1; 2; Coritiba"
    , "2; Athletico; 4; 0; Cascavel"
    , ""
    , "# Rodada 3"
    , "3; Cascavel; 1; 0; Operario"
    , "3; Coritiba; 2; 1; Athletico"
    , "3; Londrina; 2; 0; Maringa"
    , ""
    , "# Rodada 4"
    , "4; Operario; 2; 1; Maringa"
    , "4; Athletico; 1; 1; Londrina"
    , "4; Cascavel; 0; 1; Coritiba"
    , ""
    , "# Rodada 5"
    , "5; Coritiba; 1; 2; Operario"
    , "5; Londrina; 2; 0; Cascavel"
    , "5; Maringa; 0; 2; Athletico"
    ]

dadosComErros :: String
dadosComErros =
  unlines
    [ "# Entrada propositalmente invalida para testar todos os erros"
    , "1; Coritiba; 2; 1"
    , "1; Coritiba; dois; 1; Athletico"
    , "1; Londrina; -1; 2; Operario"
    , "2; Maringa; 1; 1; Maringa"
    , "3; Coritiba; 2; 0; Cascavel"
    , "3; Coritiba; 1; 1; Operario"
    ]


-- PROGRAMA PRINCIPAL


main :: IO ()
main = do
  putStrLn "=== DEMONSTRACAO DO CAMPEONATO ==="
  case lerCampeonato dadosCampeonato of
    Left erro -> putStrLn ("Erro inesperado na leitura: " ++ formatarErro erro)
    Right partidas -> do
      let tabelaFinal = classificacao partidas
          tabelaR3 = classificacao (ateRodada 3 partidas)

      putStrLn ("\nTimes participantes: " ++ show (times partidas))

      putStrLn "\n--- Classificacao Final (apos 5 rodadas) ---"
      putStrLn (tabelaFormatada tabelaFinal)

      putStrLn "--- Classificacao Intermediaria (apos 3a rodada) ---"
      putStrLn (tabelaFormatada tabelaR3)

      putStrLn "--- Estatisticas da Camada 2 ---"
      putStrLn
        ( "Maior goleada: "
            ++ fromMaybe "Nenhuma partida." (formatarPartida <$> maiorGoleada partidas)
        )
      putStrLn
        ( "Media de gols por partida: "
            ++ fromMaybe "Indisponivel." (formatarDuasCasas <$> mediaGols partidas)
        )
      putStrLn "Aproveitamento dos times:"
      mapM_
        ( \linha ->
            putStrLn
              ( "  - "
                  ++ alinharEsquerda 10 (time linha)
                  ++ ": "
                  ++ formatarDuasCasas (aproveitamento linha)
                  ++ "%"
              )
        )
        tabelaFinal

  putStrLn "\n=== TRATAMENTO DE ENTRADA COM ERROS ==="
  putStrLn "1) lerCampeonato (para no primeiro erro):"
  case lerCampeonato dadosComErros of
    Left erro -> putStrLn ("  " ++ formatarErro erro)
    Right _ -> putStrLn "  Nenhum erro encontrado."

  putStrLn "\n2) todosOsErros (relatorio completo):"
  mapM_ (\erro -> putStrLn ("  - " ++ formatarErro erro)) (todosOsErros dadosComErros)

   -- ghc -Wall Main.hs -o main; .\main.exe