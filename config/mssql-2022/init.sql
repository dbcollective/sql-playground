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