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
    status ENUM('submitted', 'reviewed', 'published', 'removed') NOT NULL DEFAULT 'submitted',
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS tags (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(25) NULL DEFAULT NULL,
    UNIQUE (title)
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
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (follower_id) REFERENCES users(id)
);

DELIMITER $$
CREATE PROCEDURE seeding()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 10000000 DO
        INSERT INTO users (username, income, is_active, created_at) VALUES (
            LEFT(MD5(RAND()), 25),
            FLOOR(RAND() * 100000),
            FLOOR(RAND() * 10) % 2,
            FROM_UNIXTIME(UNIX_TIMESTAMP('2022-01-01 01:00:00')+FLOOR(RAND()*31536000))
        );

        INSERT INTO comments (user_id, message, status) VALUES (
            i + 1,
            SUBSTRING(MD5(RAND()) FROM 1 FOR 100),
            ELT(0.5 + RAND() * 4, 'submitted', 'reviewed', 'published', 'removed')
        ),
        (
            i + 1,
            SUBSTRING(MD5(RAND()) FROM 1 FOR 100),
            ELT(0.5 + RAND() * 4, 'submitted', 'reviewed', 'published', 'removed')
        );
        SET i = i + 1;
    END WHILE;

    DECLARE j INT DEFAULT 0;
    WHILE j < 10000 DO
        INSERT INTO tags (title) VALUES (
            CONCAT('tag', i)
        );
        SET j = j + 1;
    END WHILE;
END$$
DELIMITER ;

CALL seeding();

DROP PROCEDURE seeding;