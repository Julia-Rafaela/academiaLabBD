CREATE DATABASE academia
GO
USE academia 


CREATE TABLE aluno (
codigoAluno		INT			      NOT NULL, 
nome			VARCHAR (30)      NULL
PRIMARY KEY (codigoAluno)
)
GO

DECLARE @codigoAluno INT = 1;
DECLARE @nome VARCHAR(30);

WHILE (@codigoAluno <= 50)
BEGIN
    SET @nome = 'Aluno ' + CAST(@codigoAluno AS VARCHAR(5));  
    INSERT INTO aluno (codigoAluno, nome) VALUES (@codigoAluno, @nome);   
    SET @codigoAluno = @codigoAluno + 1;
END

SELECT * FROM aluno

CREATE TABLE atividade(
codigo					INT					NOT NULL,
descricao				VARCHAR(100)			NULL,
IMC						DECIMAL (7,2)	    NULL,
PRIMARY KEY (codigo)	
)
GO

INSERT INTO atividade VALUES
(1, 'Corrida + Step', 18.5),
(2, 'Biceps + Costas + Pernas', 24.9),
(3, 'Esteira + Biceps + Costas + Pernas', 29.9),
(4, 'Bicicleta + Biceps + Costas + Pernas', 34.9),
(5, 'Esteira + Bicicleta', 39.9);
GO

CREATE TABLE atividadesAluno(
codigoAluno				INT				    NOT NULL,
altura					DECIMAL (7,2)		NULL,
peso					DECIMAL (7,2)		NULL,
IMC						DECIMAL (7,2)	    NULL,
atividade               INT					NOT NULL,
PRIMARY KEY (codigoAluno,atividade),
FOREIGN KEY (codigoAluno) REFERENCES aluno(codigoAluno), 
FOREIGN KEY (atividade) REFERENCES atividade(codigo)
)
GO


CREATE PROCEDURE sp_alunoatividades
    @codigoAluno INT = NULL,
    @nome VARCHAR(30) = NULL,
    @altura DECIMAL(7,2) = NULL,
    @peso DECIMAL(7,2) = NULL
AS
BEGIN
    DECLARE @IMC DECIMAL(7,2)
    DECLARE @atividade INT

    -- Calcular IMC
    IF @altura IS NOT NULL AND @peso IS NOT NULL
    BEGIN
        SET @IMC = @peso / POWER(@altura / 100, 2)

        -- Encontrar a primeira atividade referente ao IMC imediatamente acima do calculado
        SELECT TOP 1 @atividade = codigo
        FROM atividade
        WHERE IMC >= @IMC
        ORDER BY IMC ASC;

        -- Se o IMC for maior que 40, utilizar o código 5
        IF @IMC > 40
        BEGIN
            SET @atividade = 5
        END

        -- Verificar se é uma inserção ou uma atualização
        IF @codigoAluno IS NULL
        BEGIN
            -- Inserir na tabela aluno
            INSERT INTO aluno (codigoAluno, nome) VALUES ((SELECT ISNULL(MAX(codigoAluno), 0) + 1 FROM aluno), @nome)
            SET @codigoAluno = SCOPE_IDENTITY()
        END

        -- Inserir ou atualizar na tabela atividadesAluno
        IF @codigoAluno IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM aluno WHERE codigoAluno = @codigoAluno)
            BEGIN
                IF EXISTS (SELECT 1 FROM atividadesAluno WHERE codigoAluno = @codigoAluno)
                BEGIN
                    UPDATE atividadesAluno
                    SET altura = @altura,
                        peso = @peso,
                        IMC = @IMC,
                        atividade = @atividade
                    WHERE codigoAluno = @codigoAluno
                END
                ELSE
                BEGIN
                    INSERT INTO atividadesAluno (codigoAluno, altura, peso, IMC, atividade)
                    VALUES (@codigoAluno, @altura, @peso, @IMC, @atividade)
                END
            END
        END
    END
END
GO

-- Verificar se a tabela atividadesAluno existe no banco de dados
IF OBJECT_ID('atividadesAluno', 'U') IS NOT NULL
BEGIN
    PRINT 'A tabela atividadesAluno existe.';
END
ELSE
BEGIN
    PRINT 'A tabela atividadesAluno não existe.';
END

EXEC sp_alunoatividades 
    @nome = 'João', 
    @altura = 180, 
    @peso = 80

-- Chamar a stored procedure para atualizar um aluno existente e suas atividades
EXEC sp_alunoatividades 
    @codigoAluno = 12, 
    @altura = 170, 
    @peso = 75

-- Chamar a stored procedure para inserir um novo aluno e suas atividades sem especificar o nome
EXEC sp_alunoatividades 
    @altura = 160, 
    @peso = 65


DROP FUNCTION VerificarCPF
CREATE FUNCTION VerificarCPF (@CPF VARCHAR(11))
RETURNS BIT
AS
BEGIN
    DECLARE @Resultado BIT

    SET @CPF = REPLACE(REPLACE(REPLACE(@CPF, '.', ''), '-', ''), '/', '')

    -- Verificar se o CPF tem 11 dígitos numéricos
    IF LEN(@CPF) <> 11 OR @CPF NOT LIKE '[0-9]%'
    BEGIN
        SET @Resultado = 0
    END
    ELSE
    BEGIN
        DECLARE @Soma INT
        DECLARE @Resto INT
        DECLARE @Digito1 INT
        DECLARE @Digito2 INT

        SET @Soma = 0
        SET @Digito1 = 0
        SET @Digito2 = 0

        -- Verificar o primeiro dígito verificador
        SET @Soma = 10 * CAST(SUBSTRING(@CPF, 1, 1) AS INT) +
                    9 * CAST(SUBSTRING(@CPF, 2, 1) AS INT) +
                    8 * CAST(SUBSTRING(@CPF, 3, 1) AS INT) +
                    7 * CAST(SUBSTRING(@CPF, 4, 1) AS INT) +
                    6 * CAST(SUBSTRING(@CPF, 5, 1) AS INT) +
                    5 * CAST(SUBSTRING(@CPF, 6, 1) AS INT) +
                    4 * CAST(SUBSTRING(@CPF, 7, 1) AS INT) +
                    3 * CAST(SUBSTRING(@CPF, 8, 1) AS INT) +
                    2 * CAST(SUBSTRING(@CPF, 9, 1) AS INT)
        SET @Resto = @Soma % 11
        IF @Resto < 2
        BEGIN
            SET @Digito1 = 0
        END
        ELSE
        BEGIN
            SET @Digito1 = 11 - @Resto
        END

        -- Verificar o segundo dígito verificador
        SET @Soma = 11 * CAST(SUBSTRING(@CPF, 1, 1) AS INT) +
                    10 * CAST(SUBSTRING(@CPF, 2, 1) AS INT) +
                    9 * CAST(SUBSTRING(@CPF, 3, 1) AS INT) +
                    8 * CAST(SUBSTRING(@CPF, 4, 1) AS INT) +
                    7 * CAST(SUBSTRING(@CPF, 5, 1) AS INT) +
                    6 * CAST(SUBSTRING(@CPF, 6, 1) AS INT) +
                    5 * CAST(SUBSTRING(@CPF, 7, 1) AS INT) +
                    4 * CAST(SUBSTRING(@CPF, 8, 1) AS INT) +
                    3 * CAST(SUBSTRING(@CPF, 9, 1) AS INT) +
                    2 * @Digito1
        SET @Resto = @Soma % 11
        IF @Resto < 2
        BEGIN
            SET @Digito2 = 0
        END
        ELSE
        BEGIN
            SET @Digito2 = 11 - @Resto
        END

        -- Verificar se os dígitos calculados são iguais aos fornecidos
        IF CAST(SUBSTRING(@CPF, 10, 1) AS INT) = @Digito1 AND
           CAST(SUBSTRING(@CPF, 11, 1) AS INT) = @Digito2
        BEGIN
            SET @Resultado = 1
        END
        ELSE
        BEGIN
            SET @Resultado = 0
        END
    END

    RETURN @Resultado
END

DECLARE @CPF VARCHAR(11) = '38942231896'
DECLARE @ResultadoValidacao BIT

-- Chamar a função para validar o CPF
SET @ResultadoValidacao = dbo.VerificarCPF(@CPF)

-- Verificar o resultado
IF @ResultadoValidacao = 1
BEGIN
    PRINT 'CPF válido'
END
ELSE
BEGIN
    PRINT 'CPF inválido'
END