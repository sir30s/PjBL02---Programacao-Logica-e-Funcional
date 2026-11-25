module Testes
  ( testar
  , executarTestes
  , main
  ) where

import Data.Either (isRight)
import Main
  ( Erro (..)
  , Linha (..)
  , Partida (..)
  , Resultado (..)
  , ateRodada
  , classificacao
  , dadosCampeonato
  , dadosComErros
  , lerCampeonato
  , maiorGoleada
  , mediaGols
  , participou
  , resultadoPara
  , time
  , times
  , todosOsErros
  )

-- TESTES OBRIGATORIOS

testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nomeTeste obtido esperado
  | obtido == esperado = putStrLn ("OK - " ++ nomeTeste)
  | otherwise =
      putStrLn
        ( "FALHOU - "
            ++ nomeTeste
            ++ " | obtido: "
            ++ show obtido
            ++ " | esperado: "
            ++ show esperado
        )

executarTestes :: IO ()
executarTestes = do
  putStrLn "=== TESTES ==="
  let partidaExemplo = Partida 1 "Coritiba" 2 1 "Athletico"

  -- Camada 1
  testar "C1: participou (mandante)" (participou "Coritiba" partidaExemplo) True
  testar "C1: participou (nao jogou)" (participou "Operario" partidaExemplo) False
  testar "C1: resultadoPara mandante" (resultadoPara "Coritiba" partidaExemplo) (Just Vitoria)
  testar "C1: resultadoPara visitante" (resultadoPara "Athletico" partidaExemplo) (Just Derrota)
  testar "C1: resultadoPara ausente" (resultadoPara "Operario" partidaExemplo) Nothing

  case lerCampeonato dadosCampeonato of
    Left erro -> putStrLn ("FALHOU - leitura do campeonato de teste: " ++ show erro)
    Right partidas -> do
      testar
        "C1: times sem repeticao e ordenados"
        (times partidas)
        ["Athletico", "Cascavel", "Coritiba", "Londrina", "Maringa", "Operario"]

      -- Camada 2
      let tabelaFinalEsperada =
            [ Linha "Athletico" 5 3 1 1 10 3
            , Linha "Coritiba"  5 3 1 1 6  4
            , Linha "Londrina"  5 2 3 0 6  2
            , Linha "Operario"  5 2 1 2 5  6
            , Linha "Maringa"   5 1 0 4 5  8
            , Linha "Cascavel"  5 1 0 4 1  10
            ]
          tabelaFinalObtida = classificacao partidas
          tabelaRodada3 = classificacao (ateRodada 3 partidas)

      testar "C2: classificacao final" tabelaFinalObtida tabelaFinalEsperada
      testar
        "C2: desempate por saldo (Athletico +7 vs Coritiba +2, ambos 10 pts e 3 V)"
        (map time (take 2 tabelaFinalObtida))
        ["Athletico", "Coritiba"]
      testar
        "C2: classificacao ateRodada 3 difere da final (Coritiba liderava na R3)"
        (map time tabelaRodada3)
        ["Coritiba", "Athletico", "Londrina", "Maringa", "Cascavel", "Operario"]
      testar "C2: maiorGoleada [] == Nothing" (maiorGoleada []) Nothing
      testar "C2: mediaGols [] == Nothing" (mediaGols []) Nothing
      testar
        "C2: maiorGoleada do campeonato"
        (maiorGoleada partidas)
        (Just (Partida 2 "Athletico" 4 0 "Cascavel"))
      testar "C2: mediaGols do campeonato" (mediaGols partidas) (Just 2.2)

  -- Camada 3
  testar
    "C3: lerCampeonato valido retorna Right"
    (isRight (lerCampeonato dadosCampeonato))
    True
  testar
    "C3: erro CamposInvalidos"
    (lerCampeonato "1; Coritiba; 2; 1")
    (Left (CamposInvalidos 1 "1; Coritiba; 2; 1"))
  testar
    "C3: erro NumeroInvalido"
    (lerCampeonato "1; Coritiba; dois; 1; Athletico")
    (Left (NumeroInvalido 1 "dois"))
  testar
    "C3: erro PlacarNegativo"
    (lerCampeonato "1; Londrina; -1; 2; Operario")
    (Left (PlacarNegativo 1 (-1)))
  testar
    "C3: erro MesmoTime"
    (lerCampeonato "2; Maringa; 1; 1; Maringa")
    (Left (MesmoTime 1 "Maringa"))
  testar
    "C3: erro TimeRepetidoNaRodada"
    (lerCampeonato (unlines ["3; Coritiba; 2; 0; Cascavel", "3; Coritiba; 1; 1; Operario"]))
    (Left (TimeRepetidoNaRodada 3 "Coritiba"))
  testar
    "C3: todosOsErros captura todos os 5 erros do texto invalido"
    (todosOsErros dadosComErros)
    [ CamposInvalidos 2 "1; Coritiba; 2; 1"
    , NumeroInvalido 3 "dois"
    , PlacarNegativo 4 (-1)
    , MesmoTime 5 "Maringa"
    , TimeRepetidoNaRodada 3 "Coritiba"
    ]

main :: IO ()
main = executarTestes

-- ghc -Wall -main-is Testes Testes.hs -o testes; .\testes.exe