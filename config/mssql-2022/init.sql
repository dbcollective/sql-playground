IF DB_ID($(MSSQL_DATABASE)) IS NOT NULL
  SET NOEXEC ON

USE [master];
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = $(MSSQL_DATABASE))
BEGIN
  CREATE DATABASE [$(MSSQL_DATABASE)];
END
GO

USE [$(MSSQL_DATABASE)];
GO

IF NOT EXISTS(SELECT principal_id FROM sys.server_principals WHERE name = '$(MSSQL_USER)') BEGIN
    CREATE LOGIN $(MSSQL_USER) 
    WITH PASSWORD = '$(MSSQL_PASSWORD)'
END

IF NOT EXISTS(SELECT principal_id FROM sys.database_principals WHERE name = '$(MSSQL_USER)') BEGIN
    CREATE USER $(MSSQL_USER) FOR LOGIN $(MSSQL_USER)
END

ALTER SERVER ROLE sysadmin ADD MEMBER [$(MSSQL_USER)]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='users' and xtype='U')
    CREATE TABLE [users] (
        [id] [BIGINT] IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [username] [VARCHAR](25) NULL DEFAULT NULL,
        [income] [DECIMAL] NOT NULL DEFAULT 0,
        [is_active] [BIT] NOT NULL DEFAULT 1,
        [created_at] [DATETIME] NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
GO

IF OBJECT_ID(N'dbo.comments', N'U') IS NULL
CREATE TABLE comments (
    [id] [BIGINT] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [user_id] [BIGINT] NOT NULL,
    [message] [VARCHAR](140) NULL DEFAULT NULL,
    [status] [VARCHAR](15) NOT NULL CHECK (status IN('submitted', 'reviewed', 'published', 'removed')) DEFAULT 'submitted'
);
GO

IF OBJECT_ID(N'dbo.tags', N'U') IS NULL
CREATE TABLE tags (
    id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [title] [VARCHAR](25) NULL DEFAULT NULL
);
GO

IF OBJECT_ID(N'dbo.comment_tag', N'U') IS NULL
CREATE TABLE comment_tag (
    [comment_id] [BIGINT] NOT NULL,
    [tag_id] [INT] NOT NULL,
    CONSTRAINT pk_tags_comments PRIMARY KEY (tag_id, comment_id),
    INDEX comment_tag_comment_id_index NONCLUSTERED (comment_id)
);
GO

IF OBJECT_ID(N'dbo.followers', N'U') IS NULL
CREATE TABLE followers (
    [user_id] [BIGINT] NOT NULL,
    [follower_id] [BIGINT] NOT NULL,
    CONSTRAINT pk_useres_followers PRIMARY KEY (user_id, follower_id),
    INDEX followers_follower_id_index NONCLUSTERED (follower_id)
);
GO

DECLARE @i AS INT = 0
WHILE @i < 1000 BEGIN  
    WITH t1(w, x, y, z) AS (
        SELECT SUBSTRING(CONVERT(VARCHAR(40), NEWID()),0,24), 
            FLOOR(RAND() * 100000),
            CAST(FLOOR(RAND() * 10) AS INT) % 2,
            DATEADD(S, (ROUND(RAND() * (1356892200 - 1325356200), 0) + 1325356200), '1970-01-01')
        UNION ALL
        SELECT SUBSTRING(CONVERT(VARCHAR(40), NEWID()),0,24), 
            FLOOR(RAND() * 100000),
            CAST(FLOOR(RAND() * 10) AS INT) % 2,
            DATEADD(S, (ROUND(RAND() * (1356892200 - 1325356200), 0) + 1325356200), '1970-01-01')
        FROM t1
    )
    INSERT INTO users (username, income, is_active, created_at)
    SELECT TOP 1000 * FROM t1
    OPTION (MAXRECURSION 0);
    SET @i = @i + 1;
END;
GO

DECLARE @i AS INT = 0;
DECLARE @status INT = CEILING(RAND()*3);
WHILE @i < 1000 BEGIN  
    WITH t2(x, y, z) AS (
        SELECT FLOOR((RAND()*10000)+1),
            CONVERT(VARCHAR(40), NEWID()),
            CHOOSE(@status, 'submitted', 'reviewed', 'published', 'removed')
        UNION ALL
        SELECT FLOOR((RAND()*10000)+1),
            CONVERT(VARCHAR(40), NEWID()),
            CHOOSE(@status, 'submitted', 'reviewed', 'published', 'removed')
        FROM t2
    )
    INSERT INTO comments (user_id, message, status)
    SELECT TOP 1000 * FROM t2
    OPTION (MAXRECURSION 0);
    SET @i = @i + 1;
    SET @status = CEILING(RAND()*3);
END;
GO

WITH tmp(x) AS (
    SELECT 1
    UNION ALL
    SELECT x+1 
    FROM tmp
)
INSERT INTO tags (title)
SELECT TOP 1000 CONCAT('tag', RIGHT('000' + CONVERT(VARCHAR(4), x), 4)) 
FROM tmp
OPTION (MAXRECURSION 0);
GO

-- SQL SERVER DOES NOT SUPPORT "ON DUPLICATE KEY UPDATE", SO WE NEED TO INSERT ONE ROW EACH TIME 
DECLARE @i AS INT = 0
WHILE @i < 1000 BEGIN  
    WITH t3(x, y) AS (
        SELECT FLOOR((RAND()*10000)+1),
            FLOOR((RAND()*10000)+1)
        UNION ALL
        SELECT FLOOR((RAND()*10000)+1),
            FLOOR((RAND()*10000)+1)
        FROM t3
    )
    INSERT INTO followers (user_id, follower_id)
    SELECT TOP 1 * FROM t3
    WHERE NOT EXISTS (SELECT user_id FROM followers t2 WHERE t2.user_id = t3.x AND t2.follower_id = t3.y);
    SET @i = @i + 1;
END;
GO

DECLARE @i AS INT = 0
WHILE @i < 1000 BEGIN  
    WITH t4(x, y) AS (
        SELECT FLOOR((RAND()*10000)+1),
            FLOOR((RAND()*100)+1)
        UNION ALL
        SELECT FLOOR((RAND()*10000)+1),
            FLOOR((RAND()*100)+1)
        FROM t4
    )
    MERGE INTO comment_tag WITH (HOLDLOCK) AS TARGET
    USING (SELECT TOP 1
        x AS comment_id,
    y AS tag_id
    FROM t4) AS SOURCE
    (comment_id, tag_id)
    ON (TARGET.comment_id = SOURCE.comment_id
    AND TARGET.tag_id = SOURCE.tag_id)
    WHEN MATCHED
    THEN UPDATE
        SET tag_id = SOURCE.tag_id
    WHEN NOT MATCHED
    THEN INSERT (comment_id, tag_id)
        VALUES (SOURCE.comment_id, SOURCE.tag_id);
    SET @i = @i + 1;
END;
GO