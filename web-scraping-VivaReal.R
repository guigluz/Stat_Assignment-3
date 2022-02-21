library(rvest)
library(tidyverse)
library(ggsci)

# Viva real

data = NULL
for (i in 1:30){
page_number = i
url = paste0('https://www.vivareal.com.br/aluguel/sp/sao-paulo/centro/bela-vista/?pagina=', page_number)
page = read_html(url)
nodes = html_elements(page, '.property-card__content')
a = html_text(nodes) %>% as.vector() 
data = rbind(data, data.frame(text = a))
rm(a)
}

data_tidy = separate(data, text, into = c('tipo', 'resto'), 
                     sep = ',', extra = 'merge') %>%
  separate( resto, into = c('m2', 'resto'), 
           sep = 'm²', extra = 'merge') %>%
  separate( resto, into = c('endereco', 'resto'), 
            sep = 'ver mapa', extra = 'merge') %>%
  separate( resto, into = c('drop_later', 'resto'), 
            sep = 'm²', extra = 'merge') %>%
  select(-drop_later) %>%
  separate( resto, into = c('quartos', 'resto'), 
            sep = 'Quarto', extra = 'merge') %>%
  separate( resto, into = c('banheiros', 'resto'), 
            sep = 'Banheiro', extra = 'merge') %>%
  separate( resto, into = c('vagas', 'resto'), 
            sep = 'Vaga') %>%
  separate( resto, into = c('drop_later', 'resto'), 
            sep = '\\$', extra = 'merge') %>%
  select(-drop_later) %>%
  separate( resto, into = c('aluguel', 'resto'), 
                sep = '/Mês') %>%
  select(-resto) %>%
  mutate(banheiros = str_replace(banheiros, pattern = 's ', replacement = ' '),
         vagas = str_replace(vagas, pattern = 's ', replacement = ' ')) %>% 
  mutate(aluguel = 
           str_replace(aluguel, pattern = '\\.', replacement = '')) %>%
  mutate(m2 = as.numeric(m2), quartos = as.numeric(quartos), 
         banheiros = as.numeric(banheiros), vagas = as.numeric(vagas),
         aluguel = as.numeric(aluguel))

data_tidy %>%
  filter(tipo == '    Sala/Conjunto    para Aluguel' | tipo == '    Apartamento com  Quarto para Aluguel') %>%
  ggplot(aes(x = m2, fill = tipo))+
  geom_histogram(bins = 15, color = 'black')+
  facet_grid( . ~ tipo, scales = 'free')+
  scale_fill_lancet()+
  theme_linedraw()+
  labs(y = 'Número de imóveis', x = 'm²', 
       title = 'Distribuição da metragem dos imóveis',
       caption = 'Imóveis da Bela Vista, São Paulo - SP disponíveis no site VivaReal')+
  theme(legend.position = 'none')

ggsave('dist_m2.png')

data_tidy %>% 
  mutate(preco_m2 = aluguel/m2) %>%
  filter(tipo == '    Apartamento com  Quarto para Aluguel') %>%
  ggplot(aes(x = preco_m2))+
  geom_histogram(fill = 'navy', bins = 20, color = 'black')+
  theme_linedraw()+
  labs(y = 'Número de imóveis', x = 'Preço/m²', 
       title = 'Distribuição do preço por metro quadrado',
       caption = 'Apartamentos residenciais da Bela Vista, São Paulo - SP disponíveis no site VivaReal')

ggsave('dist_preco.png')

write_csv(data_tidy, 'VivaReal-data.csv')








