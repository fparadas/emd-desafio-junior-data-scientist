-- Localização de chamados do 1746

---
-- Quantos chamados foram abertos no dia 01/04/2023?
select 
  count(id_chamado) as quantidade_chamados,
  cast(data_inicio as date) data_abertura
from datario.administracao_servicos_publicos.chamado_1746
where cast(data_inicio as date) = cast("01/04/2023" as date format "dd/mm/yyyy")
group by data_abertura;
---

---
-- Qual o tipo de chamado que teve mais reclamações no dia 01/04/2023?

select 
  id_tipo,
  tipo,
  count(id_chamado) as quantidade_chamados
from datario.administracao_servicos_publicos.chamado_1746
where cast(data_inicio as date) = cast("01/04/2023" as date format "dd/mm/yyyy")
group by id_tipo, tipo
order by quantidade_chamados desc
limit 1;
---

---
-- Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?

select 
  chamados.id_bairro,
  bairros.nome,
  count(chamados.id_chamado) as quantidade_chamados
from datario.administracao_servicos_publicos.chamado_1746 as chamados
left join datario.dados_mestres.bairro as bairros on
  chamados.id_bairro = bairros.id_bairro
where cast(chamados.data_inicio as date) = cast("01/04/2023" as date format "dd/mm/yyyy")
group by chamados.id_bairro, bairros.nome
order by quantidade_chamados desc
limit 3;
---

---
-- Qual o nome da subprefeitura com mais chamados abertos nesse dia?

select 
  bairros.subprefeitura, 
  count(chamados.id_chamado) as quantidade_chamados
from datario.administracao_servicos_publicos.chamado_1746 as chamados
left join datario.dados_mestres.bairro as bairros on
  chamados.id_bairro = bairros.id_bairro
where cast(chamados.data_inicio as date) = cast("01/04/2023" as date format "dd/mm/yyyy")
group by bairros.subprefeitura
order by quantidade_chamados desc
limit 1;
---

---
-- Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros? Se sim, por que isso acontece?

select 
  chamados.id_chamado,
  chamados.tipo,
  chamados.subtipo,
  chamados.id_bairro,
  bairros.nome,
  bairros.subprefeitura
from datario.administracao_servicos_publicos.chamado_1746 as chamados
left join datario.dados_mestres.bairro as bairros on
  chamados.id_bairro = bairros.id_bairro
where cast(chamados.data_inicio as date) = cast("01/04/2023" as date format "dd/mm/yyyy")
and (chamados.id_bairro is null or bairros.subprefeitura is null);

-- Existe apenas um chamado que não foi associado a um bairro ou subprefeitura
-- isso provavelmente acontece devido ao subtipo do chamado, 
-- que é uma verificação de ar condicionado em um onibus

select 
  chamados.id_tipo,
  chamados.tipo,
  chamados.id_subtipo,
  chamados.subtipo,
  string_agg(chamados.id_bairro, ", ") as lista_bairros,
  string_agg(chamados.id_chamado,", ") as lista_chamados
from datario.administracao_servicos_publicos.chamado_1746 as chamados
left join datario.dados_mestres.bairro as bairros on
  chamados.id_bairro = bairros.id_bairro
where (chamados.id_bairro is null or bairros.subprefeitura is null)
and id_tipo = "93"
group by id_tipo, id_subtipo, tipo, subtipo

-- na query acima, conseguimos ver uma lista de chamados relacionados ao tipo Onibus que não possuem nenhum bairro atrelado.
---


-- Chamados do 1746 em grandes eventos

---
-- Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?

select 
  chamados.subtipo,
  count(chamados.id_chamado) as quantidade_chamados
from datario.administracao_servicos_publicos.chamado_1746 as chamados
where chamados.subtipo = "Perturbação do sossego"
and cast(chamados.data_inicio as date) >= cast("01/01/2022" as date format "dd/mm/yyyy")
and cast(chamados.data_inicio as date) <= cast("31/12/2023" as date format "dd/mm/yyyy")
group by chamados.subtipo; 

-- Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).

select
  chamados.id_chamado,
  chamados.subtipo,
  eventos.evento,
  chamados.data_inicio
from datario.administracao_servicos_publicos.chamado_1746 as chamados
join datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos as eventos
  on chamados.data_inicio between eventos.data_inicial and eventos.data_final
where eventos.evento in ('Carnaval', 'Reveillon', 'Rock in Rio')
and chamados.subtipo = "Perturbação do sossego"

-- Quantos chamados desse subtipo foram abertos em cada evento?

select
  eventos.evento,
  count(chamados.id_chamado) as quantidade_chamados
from datario.administracao_servicos_publicos.chamado_1746 as chamados
join datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos as eventos
  on chamados.data_inicio between eventos.data_inicial and eventos.data_final
where eventos.evento in ('Carnaval', 'Reveillon', 'Rock in Rio')
and chamados.subtipo = "Perturbação do sossego"
group by eventos.evento

-- Qual evento teve a maior média diária de chamados abertos desse subtipo?

select 
  eventos.evento,
  count(chamados.id_chamado) / count(distinct cast(chamados.data_inicio as date)) as media_diaria_chamados,
  count(chamados.id_chamado) as quantidade_chamados,
  count(distinct cast(chamados.data_inicio as date)) as quantidade_dias
from 
  datario.administracao_servicos_publicos.chamado_1746 as chamados
join 
  datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos as eventos
on 
  chamados.data_inicio between eventos.data_inicial and eventos.data_final
where 
  eventos.evento in ('Carnaval', 'Reveillon', 'Rock in Rio')
  and chamados.subtipo = 'Perturbação do sossego'
group by eventos.evento
order by media_diaria_chamados desc
limit 1;

-- Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2023.

-- Médias diárias durante eventos específicos
(select 
  eventos.evento as periodo,
  count(chamados.id_chamado) / count(distinct cast(chamados.data_inicio as date)) / total.media_diaria_chamados as proporcao,
  count(chamados.id_chamado) as quantidade_chamados,
  count(distinct cast(chamados.data_inicio as date)) as quantidade_dias
from 
  datario.administracao_servicos_publicos.chamado_1746 as chamados, 
  (
    select 
      'Média Total 2022-2023' as periodo,
      count(id_chamado) / count(distinct cast(data_inicio as date)) as media_diaria_chamados,
      count(id_chamado) as quantidade_chamados,
      count(distinct cast(data_inicio as date)) as quantidade_dias
    from datario.administracao_servicos_publicos.chamado_1746
    where subtipo = 'Perturbação do sossego'
      and data_inicio between '2022-01-01' and '2023-12-31'
    ) as total
join 
  datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos as eventos
on 
  chamados.data_inicio between eventos.data_inicial and eventos.data_final
where 
  eventos.evento in ('Carnaval', 'Reveillon', 'Rock in Rio')
  and chamados.subtipo = 'Perturbação do sossego'
group by eventos.evento, total.media_diaria_chamados)

union all

-- Média diária no período total
(select 
  'Média Total 2022-2023' as periodo,
  1 as proporcao,
  count(id_chamado) as quantidade_chamados,
  count(distinct cast(data_inicio as date)) as quantidade_dias
from datario.administracao_servicos_publicos.chamado_1746
where subtipo = 'Perturbação do sossego'
  and data_inicio between '2022-01-01' and '2023-12-31')
