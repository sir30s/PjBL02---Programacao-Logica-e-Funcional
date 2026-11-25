# PjBL2 — Tabela de Classificação de Campeonato em Haskell

Projeto desenvolvido para a disciplina de Programação Lógica e Funcional, implementando o cálculo e a validação de uma tabela de classificação de campeonato de futebol em três camadas funcionais.

## Integrantes do Grupo

- Murilo Serra
- Matteo Dias
- Eduardo dos Reis

## Projeto

O desenvolvimento foi realizado inicialmente no Haskell Playground e posteriormente estruturado no VS Code para organizar a entrega em dois arquivos distintos (`Main.hs` e `Testes.hs`), além de um arquivo `.txt` contendo a junção de ambos para execução direta no playground.

O projeto foi organizado em três camadas funcionais, como requisitado:

### Camada 1 — Tipos e Dados

- Definição dos tipos de dados do campeonato.
- Representação dos times e das partidas.
- Identificação dos resultados de cada equipe.
- Organização dos times participantes.

### Camada 2 — Classificação

- Cálculo dos pontos de cada time.
- Contagem de vitórias, empates e derrotas.
- Cálculo de gols pró, gols contra e saldo de gols.
- Ordenação da tabela de classificação.
- Aplicação dos critérios de desempate.
- Cálculo do aproveitamento dos times.
- Identificação da maior goleada e da média de gols.
- Consulta da classificação até uma rodada específica.

### Camada 3 — Leitura, Validação e Formatação

- Leitura dos dados das partidas.
- Separação e tratamento dos campos informados.
- Validação dos resultados e das rodadas.
- Identificação de entradas inválidas.
- Exibição de mensagens de erro.
- Formatação da tabela de classificação.

## Critérios de Classificação

A classificação dos times utiliza os seguintes critérios de desempate:

1. Maior número de pontos.
2. Maior número de vitórias.
3. Melhor saldo de gols.
4. Maior número de gols pró.
5. Ordem alfabética do nome do time.

A pontuação utilizada é:

- Vitória: 3 pontos.
- Empate: 1 ponto.
- Derrota: 0 pontos.

## Dados de Teste

O projeto utiliza um campeonato de exemplo contendo:

- 6 times participantes.
- 5 rodadas.
- 15 partidas.
- Partidas com empate e goleadas.
- Empate na pontuação final para testar os critérios de desempate.

Também foram criados dados inválidos para testar o funcionamento das validações e o tratamento de erros.

## Testes

Foram implementados testes em `Testes.hs` para verificar as três camadas do projeto.

Os testes verificam:

- Identificação dos times participantes.
- Resultado das partidas.
- Cálculo da classificação.
- Aplicação dos critérios de desempate.
- Cálculo da média de gols.
- Identificação da maior goleada.
- Leitura de partidas válidas.
- Identificação de campos e números inválidos.
- Identificação de placares negativos.
- Identificação de times repetidos na mesma rodada.
- Captura de todos os erros encontrados.

## Tecnologias Utilizadas

- Haskell
- GHC (Glasgow Haskell Compiler)
- Visual Studio Code (VS Code)
- Haskell Playground

## Estrutura dos Arquivos

- `Main.hs` — Implementação das três camadas, dados de teste e demonstração principal.
- `Testes.hs` — Suíte de testes automatizados das três camadas.
- `docs/decisoes.md` — Decisões de modelagem e limitações conhecidas.
- `README.md` — Documentação geral e instruções de execução.
- Arquivo `.txt` anexo — Versão unificada (`Main.hs` + `Testes.hs`) pronta para uso no Haskell Playground.

## Como Executar

Existem duas abordagens recomendadas para executar o projeto:

### Abordagem 1 — Via IDE VS Code / GHC Local

Abordagem utilizada para a entrega.

1. Instale o GHC (Glasgow Haskell Compiler) via GHCup.
2. Abra a pasta do projeto no VS Code.
3. Abra o terminal integrado (PowerShell no Windows).

Para compilar e executar o programa principal (`Main.hs`):

```powershell
ghc -Wall Main.hs -o main; .\main.exe
```

Para compilar e executar a suíte de testes (`Testes.hs`):

```powershell
ghc -Wall -main-is Testes Testes.hs -o testes; .\testes.exe
```

*Linux ou macOS*: substitua:

`; .\main.exe` por `&& ./main`
`; .\testes.exe` por `&& ./testes`.

### Abordagem 2 — Via Haskell Playground (Online)

1. Acesse o Haskell Playground.
2. Abra o arquivo `PJBL 2.txt` anexo, contendo a junção de `Main.hs` e `Testes.hs`.
3. Copie todo o conteúdo do arquivo e cole no editor do playground.
4. Clique em **Run** para executar tanto a demonstração das três camadas quanto os testes obrigatórios em uma única execução.

## Considerações Finais

O projeto demonstra a aplicação dos conceitos de programação funcional em Haskell, utilizando funções de ordem superior, tipos algébricos, listas, composição de funções e tratamento de erros com `Maybe` e `Either`.

A implementação foi dividida em três camadas funcionais, permitindo separar a representação dos dados, o processamento da classificação e a leitura, validação e formatação das entradas.

Além disso, a suíte de testes automatizados permite verificar o funcionamento das funcionalidades implementadas, incluindo os critérios de classificação e o tratamento de entradas inválidas.

Dessa forma, o projeto reúne os principais conceitos estudados na disciplina de Programação Lógica e Funcional em uma aplicação prática, demonstrando como Haskell pode ser utilizado para desenvolver soluções organizadas, modulares e confiáveis =) .