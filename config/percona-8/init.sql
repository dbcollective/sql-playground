CREATE TABLE IF NOT EXISTS users (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(25) NULL DEFAULT NULL,
    income DECIMAL NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS comments (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    message VARCHAR(140) NULL DEFAULT NULL,
    status ENUM('submitted', 'reviewed', 'published', 'removed') NOT NULL DEFAULT 'submitted'
);

CREATE TABLE IF NOT EXISTS tags (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(25) NULL DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS comment_tag (
    comment_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    PRIMARY KEY(tag_id, comment_id),
    INDEX(comment_id)
);

CREATE TABLE IF NOT EXISTS followers (
    user_id BIGINT NOT NULL,
    follower_id BIGINT NOT NULL,
    PRIMARY KEY(user_id, follower_id),
    INDEX (follower_id)
);

DELIMITER $$
CREATE PROCEDURE users_seeding()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 1000 DO
        INSERT INTO users (username, income, is_active, created_at)
        WITH RECURSIVE data(w, x, y, z) AS (
            SELECT LEFT(MD5(RAND()), 25), 
                FLOOR(RAND() * 100000),
                FLOOR(RAND() * 10) % 2,
                FROM_UNIXTIME(ROUND(RAND() * (1356892200 - 1325356200)) + 1325356200)
            UNION ALL
            SELECT LEFT(MD5(RAND()), 25), 
                FLOOR(RAND() * 100000),
                FLOOR(RAND() * 10) % 2,
                FROM_UNIXTIME(ROUND(RAND() * (1356892200 - 1325356200)) + 1325356200)
            FROM data
            LIMIT 1000
        )
        SELECT * FROM data;
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE comments_seeding()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 1000 DO
        INSERT INTO comments (user_id, message, status)
        WITH RECURSIVE data(x, y, z) AS (
            SELECT FLOOR((RAND()*10000)+1),
                SUBSTRING(MD5(RAND()) FROM 1 FOR 100),
                ELT(0.5 + RAND() * 4, 'submitted', 'reviewed', 'published', 'removed')
            UNION ALL
            SELECT FLOOR((RAND()*10000)+1),
                SUBSTRING(MD5(RAND()) FROM 1 FOR 100),
                ELT(0.5 + RAND() * 4, 'submitted', 'reviewed', 'published', 'removed')
            FROM data
            LIMIT 1000
        )
        SELECT * FROM data;
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE tag_seeding()
BEGIN
    INSERT INTO tags (title)
    WITH RECURSIVE tmp(x) AS (
        SELECT 1
        UNION ALL
        SELECT x+1 
        FROM tmp
        LIMIT 1000
    ) 
    SELECT CONCAT('tag', LPAD(x, 4, 0)) FROM tmp;

END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE followers_seeding()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 1000 DO
        INSERT INTO followers (user_id, follower_id)
        WITH RECURSIVE data(x, y) AS (
            SELECT FLOOR((RAND()*10000)+1),
                FLOOR((RAND()*10000)+1)
            UNION ALL
            SELECT FLOOR((RAND()*10000)+1),
                FLOOR((RAND()*10000)+1)
            FROM data
            LIMIT 1000
        )
        SELECT * FROM data
        ON DUPLICATE KEY UPDATE
        followers.follower_id = VALUES(followers.follower_id);
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE comment_tag_seeding()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 1000 DO
        INSERT INTO comment_tag (comment_id, tag_id)
        WITH RECURSIVE data(x, y) AS (
            SELECT FLOOR((RAND()*10000)+1),
                FLOOR((RAND()*100)+1)
            UNION ALL
            SELECT FLOOR((RAND()*10000)+1),
                FLOOR((RAND()*100)+1)
            FROM data
            LIMIT 1000
        )
        SELECT * FROM data
        ON DUPLICATE KEY UPDATE
        comment_tag.tag_id = VALUES(comment_tag.tag_id);
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL users_seeding();
CALL comments_seeding();
CALL tag_seeding();
CALL followers_seeding();
CALL comment_tag_seeding();

DROP PROCEDURE users_seeding;
DROP PROCEDURE comments_seeding;
DROP PROCEDURE tag_seeding;
DROP PROCEDURE followers_seeding;
DROP PROCEDURE comment_tag_seeding;