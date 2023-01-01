# SQL Playground with Docker

SQL Playground is a collection of docker containers of some commonly used Relational Databases. All the containers are preconfigured with some tables and millions of data will be pre-generated during the first installation. You can comare the indexing performance of different dataases and compare performance between thems.  


First pull the repository and run the below command to complete the installation:
!! Be sure that you copy the `.env.example` file to`.env` and change based on your local configuration !!
```
chmod +x ./play && ./play start
```

Database Description:
```console
+----------------+
| Tables_in_mydb |
+----------------+
| comment_tag    |
| comments       |
| followers      |
| tags           |
| users          |
+----------------+

-- table=users
+------------+---------------+------+-----+-------------------+-------------------+
| Field      | Type          | Null | Key | Default           | Extra             |
+------------+---------------+------+-----+-------------------+-------------------+
| id         | bigint        | NO   | PRI | NULL              | auto_increment    |
| username   | varchar(25)   | YES  |     | NULL              |                   |
| income     | decimal(10,0) | NO   |     | 0                 |                   |
| is_active  | tinyint(1)    | NO   |     | 1                 |                   |
| created_at | timestamp     | YES  |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
+------------+---------------+------+-----+-------------------+-------------------+

-- table=comments
+---------+----------------------------------------------------+------+-----+-----------+----------------+
| Field   | Type                                               | Null | Key | Default   | Extra          |
+---------+----------------------------------------------------+------+-----+-----------+----------------+
| id      | bigint                                             | NO   | PRI | NULL      | auto_increment |
| user_id | bigint                                             | NO   | MUL | NULL      |                |
| message | varchar(140)                                       | YES  |     | NULL      |                |
| status  | enum('submitted','reviewed','published','removed') | NO   |     | submitted |                |
+---------+----------------------------------------------------+------+-----+-----------+----------------+

-- table=tags
+-------+-------------+------+-----+---------+----------------+
| Field | Type        | Null | Key | Default | Extra          |
+-------+-------------+------+-----+---------+----------------+
| id    | bigint      | NO   | PRI | NULL    | auto_increment |
| title | varchar(25) | YES  | UNI | NULL    |                |
+-------+-------------+------+-----+---------+----------------+

-- table=comment_tag
+------------+--------+------+-----+---------+-------+
| Field      | Type   | Null | Key | Default | Extra |
+------------+--------+------+-----+---------+-------+
| comment_id | bigint | NO   | PRI | NULL    |       |
| tag_id     | bigint | NO   | PRI | NULL    |       |
+------------+--------+------+-----+---------+-------+

-- table=followers
+-------------+--------+------+-----+---------+-------+
| Field       | Type   | Null | Key | Default | Extra |
+-------------+--------+------+-----+---------+-------+
| user_id     | bigint | NO   | MUL | NULL    |       |
| follower_id | bigint | NO   | MUL | NULL    |       |
+-------------+--------+------+-----+---------+-------+
```

We also have a helpful bash script for your daily use.

```
# To start all container
./play start

# To restart all container
./play restart

# To stop all container
./play stop

# To SSH into a server and open mysql shell
./play mysql

# To SSH into a server and open percona shell
./play percona

# To SSH into a server and open postgres shell
./play postgres
```