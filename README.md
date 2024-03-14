Exercícios:
1) Criar uma database chamada academia, com 3 tabelas como seguem:
Aluno
|Codigo_aluno|Nome|
Atividade
|Codigo|Descrição|IMC|
Atividade
codigo descricao imc
----------- ----------------------------------- --------
1 Corrida + Step 18.5
2 Biceps + Costas + Pernas 24.9
3 Esteira + Biceps + Costas + Pernas 29.9
4 Bicicleta + Biceps + Costas + Pernas 34.9
5 Esteira + Bicicleta 39.9
Atividadesaluno
|Codigo_aluno|Altura|Peso|IMC|Atividade|
IMC = Peso (Kg) / Altura2 (M)
Atividade: Buscar a PRIMEIRA atividade referente ao IMC imediatamente acima do calculado.
Exemplo, se o IMC for igual a 27, deve-se fazer a atividade para IMC = 29.9
* Caso o IMC seja maior que 40, utilizar o código 5.
Criar uma Stored Procedure (sp_alunoatividades), com as seguintes regras:
- Se, dos dados inseridos, o código for nulo, mas, existirem nome, altura, peso, deve-se inserir um
novo registro nas tabelas aluno e aluno atividade com o imc calculado e as atividades pelas
regras estabelecidas acima.
- Se, dos dados inseridos, o nome for (ou não nulo), mas, existirem código, altura, peso, deve-se
verificar se aquele código existe na base de dados e atualizar a altura, o peso, o imc calculado e
as atividades pelas regras estabelecidas acima.
2) Para fazer um cadastro de cliente, conforme diagrama abaixo, o CPF deve ser válido.
Criar uma procedure que permita fazer o insert, update e delete de um cliente garantindo que:
- Para insert, o CPF deve ser válido e não pode ser 11 números repetidos 
(11111111111, 22222222222, etc)
- Para update, não se pode alterar o CPF
Criar um Maven Project que ofereça o CRUD de cliente (Insert, Update e Delete pela chamada 
de procedure e Select One e Select All). Mensagens de sucesso, erro, bem como o cliente 
consultado ou a lista de clientes, devem ser exibidos no JSP como JSTL.
Preencher a tabela com dados para testes e usar o https://www.4devs.com.br/gerador_de_cpf
para gerar CPF válidos com finalidade de teste.
