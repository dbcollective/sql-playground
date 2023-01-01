CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    username VARCHAR(25) NULL DEFAULT NULL,
    income DECIMAL NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TYPE COMMENT_STATUS AS ENUM ('submitted', 'reviewed', 'published', 'removed');

CREATE TABLE IF NOT EXISTS comments (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    message VARCHAR(140) NULL DEFAULT NULL,
    status COMMENT_STATUS NOT NULL DEFAULT 'submitted'
);

CREATE TABLE IF NOT EXISTS tags (
    id SERIAL NOT NULL PRIMARY KEY,
    title VARCHAR(25) NULL DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS comment_tag (
    comment_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    PRIMARY KEY(tag_id, comment_id)
);

CREATE INDEX IF NOT EXISTS comment_tag_comment_id_index 
ON comment_tag(comment_id);

CREATE TABLE IF NOT EXISTS followers (
    user_id BIGINT NOT NULL,
    follower_id BIGINT NOT NULL,
    PRIMARY KEY(user_id, follower_id)
);

CREATE INDEX IF NOT EXISTS followers_follower_id_index 
ON followers(follower_id);

-- https://antonz.org/random-table/
DO $$
DECLARE i INTEGER := 0;
BEGIN
    WHILE i < 1000 LOOP
        INSERT INTO users (username, income, is_active, created_at)
        WITH tmp AS (
            SELECT LEFT(MD5(RANDOM()::TEXT), 25), 
                FLOOR(RANDOM() * 100000),
                (ROUND(RANDOM())::INT)::BOOLEAN,
                TO_TIMESTAMP(ROUND(RANDOM() * (1356892200 - 1325356200)) + 1325356200)
            FROM generate_series(1, 1000)
        )
        SELECT * FROM tmp;
        i := i + 1;
    END LOOP;
END$$;

DO $$
DECLARE i INTEGER := 0;
BEGIN
    WHILE i < 1000 LOOP
        INSERT INTO comments (user_id, message, status)
        WITH tmp AS (
            SELECT FLOOR((RANDOM()*10000)+1),
                SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 100),
                (ARRAY['submitted', 'reviewed', 'published', 'removed'])[FLOOR(RANDOM() * 4 + 1)]::COMMENT_STATUS
            FROM generate_series(1, 1000)
        )
        SELECT * FROM tmp;
        i := i + 1;
    END LOOP;
END$$;

DO $$
BEGIN
    INSERT INTO tags (title)
    WITH tmp AS (
        SELECT generate_series AS x 
        FROM generate_series(1, 1000)
    )
    SELECT CONCAT('tag', LPAD(x::TEXT, 4, '0')) FROM tmp;
END$$;

DO $$
DECLARE i INTEGER := 0;
BEGIN
    WHILE i < 1000 LOOP
        INSERT INTO followers (user_id, follower_id)
        WITH tmp AS (
            SELECT FLOOR((RANDOM()*10000)+1),
                FLOOR((RANDOM()*10000)+1)
            FROM generate_series(1, 1000)
        )
        SELECT * FROM tmp;
        i := i + 1;
    END LOOP;
END$$;

DO $$
DECLARE i INTEGER := 0;
BEGIN
    WHILE i < 1000 LOOP
        INSERT INTO comment_tag (comment_id, tag_id)
        WITH tmp AS (
            SELECT FLOOR((RANDOM()*10000)+1),
                FLOOR((RANDOM()*100)+1)
            FROM generate_series(1, 1000)
        )
        SELECT * FROM tmp;
        i := i + 1;
    END LOOP;
END$$;