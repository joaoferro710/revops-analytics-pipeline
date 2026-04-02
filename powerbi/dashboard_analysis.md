# Dashboard Analysis

Este documento consolida a leitura analítica da empresa fictícia com base nas abas efetivamente construídas no dashboard em Power BI.

As páginas analisadas são:

- Funnel
- Revenue
- Churn & Retention
- Cohort Analysis

## Resumo executivo

O dashboard mostra uma operação SaaS B2B com bom volume de geração de pipeline, conversão consistente nas etapas comerciais, crescimento líquido de receita e sinais positivos de expansão dentro da base. Ao mesmo tempo, a empresa ainda convive com churn relevante em partes específicas do portfólio, principalmente no plano Growth, além de concentração importante de receita em contas de maior ticket.

Os principais sinais de negócio são:

- 600 deals no pipeline total
- 155 negócios ganhos
- win rate de 25,8%
- ticket médio de R$ 23,8 mil
- ciclo médio de 95,54 dias
- MRR total de R$ 91,9 mil no recorte de 2024
- ARR de R$ 1,1 mi
- Expansion MRR de R$ 42,0 mil
- churn rate de 26,5%
- retenção de 100% em M3, 99% em M6 e 94% em M12

Em conjunto, os visuais contam a história de uma empresa que cresce com boa tração comercial e boa retenção inicial, mas que ainda precisa melhorar a sustentabilidade da base em segmentos e planos específicos.

## Funnel

### Estrutura da página

A aba de Funnel foi desenhada para responder quatro perguntas principais:

- qual é o tamanho do pipeline
- quanto desse pipeline converte em vendas
- como a conversão cai entre etapas
- como o resultado varia por segmento e por tempo

Os principais KPIs do topo são:

- Total Deals: 600
- Won Deals: 155
- Win Rate: 25,8%
- Ticket Médio: R$ 23,8 mil
- Ciclo Médio: 95,54 dias

### Leitura do funil

O gráfico de negociações por estágio mostra um pipeline com boa massa de oportunidades no topo e queda progressiva até o fechamento:

- Prospecting: 600
- Qualified: 526
- Proposal: 399
- Negotiation: 265
- Closed Won: 155

Essa distribuição é saudável do ponto de vista visual porque não há uma ruptura abrupta logo no início do funil. As perdas acontecem ao longo da jornada, com maior redução a partir da metade do processo comercial.

O gráfico de taxa de conversão por etapa reforça esse ponto:

- Prospecting -> Qualified: 87,67%
- Qualified -> Proposal: 75,86%
- Proposal -> Negotiation: 66,42%
- Negotiation -> Closed Won: 58,49%

### Interpretação de negócio

A operação comercial consegue mover oportunidades com boa eficiência nas primeiras etapas. O maior atrito está da proposta para frente, especialmente no trecho final até o fechamento. Isso sugere que o time comercial consegue gerar interesse e qualificar demanda, mas ainda encontra dificuldades maiores no momento de defender proposta, negociar condições e capturar decisão final.

O ticket médio de R$ 23,8 mil, combinado com ciclo médio próximo de 96 dias, é coerente com uma venda B2B de perfil consultivo. Não parece um processo simples ou transacional, o que ajuda a explicar a duração do ciclo.

### Receita por segmento

A tabela de receita por segmento mostra um recorte importante:

- SMB concentra a maior receita absoluta
- Mid-Market aparece com ticket médio mais alto
- o win rate de Mid-Market é inferior ao de SMB

Isso sugere uma operação com bom volume em SMB, mas com maior dificuldade de eficiência comercial em Mid-Market. Em contrapartida, quando Mid-Market converte, tende a carregar tickets mais elevados.

### Negociações fechadas por trimestre

O gráfico trimestral mostra variação moderada ao longo do tempo, com pico em Q4 2022 e volumes ainda consistentes em 2023 e 2024. Há desaceleração visível em meados de 2024, seguida de alguma recuperação no fim do período.

### Síntese da aba

A empresa tem um funil comercial funcional, com forte entrada de oportunidades e boa progressão inicial. O principal espaço de melhoria está na eficiência das etapas finais de fechamento e na conversão de segmentos mais complexos.

## Revenue

### Estrutura da página

A aba de Revenue foi montada para mostrar:

- tamanho atual da receita
- composição do crescimento
- peso da expansão
- evolução mensal do MRR
- diferenças de valor por segmento

No filtro aplicado no print, o ano selecionado é 2024.

Os KPIs mostrados são:

- MRR Total: R$ 91,9 mil
- ARR: R$ 1,1 mi
- Net New MRR: R$ 91,9 mil
- Expansion MRR: R$ 42,0 mil

### Waterfall de MRR

O waterfall é um dos visuais mais fortes da página porque resume bem a dinâmica da receita:

- New: R$ 87,1 mil
- Expansion: R$ 42,0 mil
- Contraction: -R$ 11,0 mil
- Churned: -R$ 26,2 mil
- Total: R$ 91,9 mil

### Interpretação de negócio

A empresa cresceu de forma líquida no período porque a soma entre nova receita e expansão superou as perdas por contraction e churn. O peso de Expansion MRR é especialmente positivo, pois mostra que o crescimento não depende apenas de aquisição. Existe capacidade de capturar valor adicional dentro da própria base.

Ao mesmo tempo, o churned MRR de R$ 26,2 mil mostra que parte do crescimento está sendo consumida por perda de receita existente. Isso não invalida a trajetória positiva, mas sinaliza que a empresa ainda precisa amadurecer retenção e defesa de base.

### LTV médio por segmento

O visual de LTV médio por segmento mostra diferenças claras entre perfis de cliente. Mid-Market aparece com LTV mais alto em uma das séries principais, enquanto SMB e Enterprise também apresentam valores relevantes.

A leitura mais útil aqui é que nem sempre o segmento que mais vende é o que mais gera valor ao longo do tempo. Esse tipo de contraste é importante para decisões de foco comercial e priorização de contas.

### MRR acumulado mês a mês

O gráfico mensal deixa claro o protagonismo do plano Enterprise sobre os demais. A curva de Enterprise está muito acima das linhas de Growth, Pro e Starter durante todo o período.

Isso confirma que a empresa tem concentração de receita em planos maiores. Essa característica pode ser positiva para crescimento mais rápido de MRR, mas aumenta exposição a perdas mais severas quando uma conta relevante sai.

### Síntese da aba

A empresa apresenta crescimento líquido saudável, sustentado por nova receita e expansão. O maior ponto de atenção não é ausência de crescimento, e sim a dependência de contas mais valiosas e o impacto potencial do churn sobre essa base.

## Churn & Retention

### Estrutura da página

A aba de Churn & Retention mostra:

- tamanho da base
- churn rate
- MRR perdido
- LTV médio
- churn por segmento
- churn por plano
- tempo médio de vida
- evolução mensal do churned MRR

Os KPIs exibidos são:

- Total Assinaturas: 155
- Churn Rate: 26,5%
- MRR Churned: -R$ 64,9 mil
- LTV Médio: R$ 28,4 mil

### Churn por segmento

O gráfico de churn por segmento mostra:

- SMB: 70 ativos e 28 churned
- Mid-Market: 29 ativos e 6 churned
- Enterprise: 15 ativos e 7 churned

### Churn rate por plano

O gráfico por plano é um dos mais acionáveis da página:

- Growth: 36,7%
- Pro: 29,7%
- Enterprise: 21,7%
- Starter: 21,4%

### Interpretação de negócio

O plano Growth é claramente o principal ponto de alerta da base. Ele tem o maior churn rate entre todos os planos, o que pode indicar desalinhamento entre proposta de valor e expectativa do cliente, dificuldade de adoção, ou transição ruim entre faixas de uso.

SMB é o segmento com maior volume absoluto de churn, o que é esperado por ter mais clientes. Já Enterprise chama atenção porque, mesmo com base menor, acumula perda relevante. Em uma operação com concentração de receita em tickets altos, isso merece monitoramento próximo.

Mid-Market aparece como o segmento mais estável nesta página. Isso é interessante porque contrasta com a leitura do Funnel, onde Mid-Market era menos eficiente na aquisição. Em outras palavras, parece mais difícil vender para Mid-Market, mas quando entra, esse cliente tende a ficar mais tempo.

### Tempo médio de vida

O visual de tempo médio de vida reforça essa leitura:

- Mid-Market: 18
- Enterprise: 15
- SMB: 14

Mesmo sem unidade explicitada no visual, a lógica relativa é clara: Mid-Market apresenta maior permanência média, enquanto SMB tem permanência inferior.

### MRR churned mês a mês

O gráfico de evolução do churned MRR mostra uma piora gradual ao longo do tempo, saindo de um patamar próximo de zero para perdas mais relevantes no fim do período.

Isso sugere que a empresa não enfrenta um único evento isolado de churn, mas sim uma erosão contínua da base. Em termos executivos, isso indica necessidade de estruturar iniciativas mais consistentes de retenção, e não apenas correções pontuais.

### Síntese da aba

A empresa ainda perde receita de forma material. O principal foco de atuação deveria ser reduzir churn no plano Growth e aprofundar o entendimento de quais perfis de clientes SMB e Enterprise estão abandonando a base.

## Cohort Analysis

### Estrutura da página

A aba de Cohort Analysis foi desenhada com:

- cards de retenção em M3, M6 e M12
- indicador de cohort médio
- quantidade de cohorts
- heatmap de retenção por cohort
- gráfico de retenção média mês a mês

Os KPIs mostrados são:

- Retenção M3: 100%
- Retenção M6: 99%
- Retenção M12: 94%
- Cohort Médio: 4,08
- Cohorts: 38

### Heatmap de cohorts

O heatmap mostra um padrão muito positivo nos primeiros meses. Boa parte dos cohorts mantém retenção total ou quase total no curto prazo. A deterioração aparece de maneira mais evidente apenas em meses posteriores e não de forma uniforme para todos os grupos.

Há cohorts muito fortes, que permanecem em 100% por vários períodos, e outros que caem para 80%, 75%, 60% ou 50% em horizontes mais longos.

### Retenção média ao longo do tempo

O gráfico de retenção média mês a mês confirma essa leitura:

- M0 a M4 praticamente em 100%
- queda gradual ao longo do tempo
- redução mais perceptível a partir da região de M12 a M20
- estabilização em patamar ainda relativamente saudável nos meses mais avançados

### Interpretação de negócio

A principal mensagem da aba é que o problema da empresa não está na ativação inicial do cliente. O início da jornada parece muito sólido. O desgaste vem depois, em uma fase de manutenção de valor e continuidade do relacionamento.

Isso sugere algumas hipóteses de negócio:

- onboarding e venda inicial funcionam bem
- parte dos clientes perde percepção de valor no médio prazo
- determinados cohorts podem estar associados a perfis de plano ou segmento menos aderentes
- há espaço para cruzar cohort com plano e segmento para isolar causas de deterioração

### Síntese da aba

A retenção da empresa é forte no curto prazo e razoável no médio prazo, o que é um ótimo sinal estrutural. O desafio está menos em entrada de clientes e mais em sustentar valor nos cohorts que começam a perder força depois de vários meses.

## Leitura integrada da empresa

Quando as quatro abas são lidas em conjunto, a narrativa da empresa fica bem clara.

### O que funciona bem

- geração de pipeline com bom volume
- conversão consistente nas primeiras etapas do funil
- ticket médio compatível com operação B2B consultiva
- crescimento líquido de receita
- expansão relevante dentro da base
- retenção muito forte nos primeiros meses

### Onde estão os principais riscos

- perda de eficiência nas etapas finais do funil
- churn elevado no plano Growth
- erosão gradual do churned MRR ao longo do tempo
- dependência importante de receita em contas Enterprise

### Síntese executiva final

A empresa fictícia retratada no dashboard está em trajetória de crescimento, com operação comercial funcional, boa capacidade de gerar receita nova e sinais concretos de expansão dentro da base. A saúde dos cohorts mostra que os clientes entram bem e permanecem por um período relevante. O principal desafio não está em aquisição, mas em sustentação de valor no médio prazo e em redução de churn nas faixas mais sensíveis do portfólio.

## Observações sobre o dashboard como peça de portfólio

O dashboard está forte para portfólio por quatro motivos:

- cada aba responde uma pergunta de negócio clara
- os cards do topo resumem bem o contexto
- os visuais se complementam sem redundância excessiva
- a aba de cohort eleva o nível analítico do projeto

Os aprimoramentos mais naturais para a publicação final seriam:

- incluir uma página inicial executiva com visão geral do negócio
- padronizar ainda mais a exibição de unidades monetárias e casas decimais
- adicionar uma breve legenda metodológica para explicar alguns KPIs mais técnicos

## Texto curto para usar no GitHub

O dashboard em Power BI foi estruturado para analisar a operação de Revenue Operations de uma empresa SaaS B2B fictícia a partir de quatro frentes: Funnel, Revenue, Churn & Retention e Cohort Analysis. A leitura dos visuais mostra uma empresa com pipeline robusto, boa capacidade de conversão inicial, crescimento líquido de receita e expansão relevante dentro da base, mas ainda com churn expressivo em planos específicos e concentração de receita em contas de maior ticket. A análise de cohorts reforça que a retenção inicial é forte, enquanto a principal oportunidade de melhoria está na sustentação de valor no médio prazo.
