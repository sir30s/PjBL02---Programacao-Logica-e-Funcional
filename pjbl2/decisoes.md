# Decisões de Modelagem e Limitações Conhecidas

Este documento apresenta as principais escolhas de implementação realizadas pelo grupo no projeto **PjBL2 — Tabela de Classificação de Campeonato em Haskell**, justificando as decisões de modelagem e registrando as limitações da versão desenvolvida.

## 1. Representação dos Dados

As estruturas `Partida` e `Linha` foram implementadas como registros (*records*), com campos nomeados. Essa escolha facilita o acesso às informações e torna o código mais legível, evitando confusões entre valores de tipos semelhantes.

O tipo `Time` utiliza `String` para representar os nomes das equipes, sem a necessidade de identificadores numéricos.

A lista de times participantes é obtida diretamente das partidas, utilizando `nub` para remover duplicações e `sort` para ordenar os nomes. Assim, não é necessário manter um cadastro separado de equipes.

## 2. Cálculo da Classificação

A função `linhaDoTime` utiliza `foldl` para percorrer as partidas e acumular as estatísticas de cada equipe, atualizando jogos, vitórias, empates, derrotas, gols pró e gols contra.

A função `compararLinhas` reúne os critérios de desempate em uma única comparação, utilizando `comparing`, `Down` e o operador `<>`. Dessa forma, os critérios são aplicados em sequência, sem a necessidade de múltiplas ordenações.

## 3. Representação de Resultados

A função `resultadoPara` utiliza `Maybe Resultado` para representar o resultado de uma equipe em uma partida. Quando o time não participa, retorna `Nothing`.

O mesmo princípio é aplicado às funções `maiorGoleada` e `mediaGols`, que retornam `Nothing` quando não existem partidas.

Para equipes sem jogos, o aproveitamento é definido como `0.0`, evitando divisão por zero.

## 4. Estatísticas Complementares

A maior goleada é identificada pela diferença absoluta entre os gols das equipes. Em caso de empate na maior diferença, a primeira partida encontrada é mantida.

A média de gols utiliza `fromIntegral` para permitir a divisão em `Double`, evitando truncamento de valores.

A função `ateRodada` filtra as partidas até a rodada informada e reutiliza a função de classificação, evitando duplicação de lógica.

## 5. Leitura e Validação

As partidas são separadas pelo caractere `;`, e os campos passam por `removerEspacos` para eliminar espaços nas extremidades.

Linhas vazias e comentários iniciados por `#` são ignorados. A numeração original das linhas é preservada para facilitar a identificação de erros.

A conversão dos valores numéricos utiliza `readMaybe`, evitando falhas durante a leitura. Já a função `lerPartida` utiliza `Either` e um bloco `do` para encadear as conversões e validações, propagando os erros encontrados.

## 6. Tratamento de Erros

As funções `lerCampeonato` e `todosOsErros` possuem comportamentos diferentes:

- `lerCampeonato` interrompe o processamento no primeiro erro encontrado.
- `todosOsErros` reúne os erros individuais e verifica a repetição de times nas rodadas, considerando as partidas válidas.

A identificação de times repetidos utiliza ordenação e agrupamento com `sort` e `group`.

## 7. Limitações Conhecidas

- Os times são identificados exclusivamente pelas partidas cadastradas. Equipes sem jogos não aparecem na classificação.
- Os nomes são comparados literalmente, portanto diferenças de maiúsculas, minúsculas ou acentuação podem representar equipes distintas.
- A validação não verifica a consistência completa do calendário, como a quantidade de partidas por equipe ou a sequência das rodadas.
- A função `ateRodada` não verifica se a rodada informada realmente existe.
- Em caso de empate na maior goleada, somente a primeira partida encontrada é retornada.
- `todosOsErros` não considera partidas inválidas na verificação de repetição de times.
- Os dados de demonstração estão definidos diretamente no código, sem leitura de arquivos externos.
- A tabela utiliza larguras fixas, podendo apresentar problemas de alinhamento com nomes de equipes muito extensos.

=)