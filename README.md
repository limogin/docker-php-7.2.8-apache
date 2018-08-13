# docker-php-7-2-8-apache
Container for php 7.2.8 for use for lamp web apps

## Example for preparing a LAMP project with docker-compose

`docker-compose-sample.yml`

```
php:
  image: limogin/php-7-2-8-apache
  container_name: web-container 
  restart: always
  ports:
    - "8080:80"
  volumes:
    - "./app:/var/www/html/:rw"
    - "./backup:/backup/:rw"
  links:
    - mysql
  environment:
    DOCKERENV: dev 
    SITE:      mydomain.com
    SITE1:     mydomain.com
    SITE2:     myanotherdomain.com

mysql:
  image: mysql:latest
  container_name: mysql-container
  restart: always
  volumes:
    - "./data:/var/lib/mysql"
    - "./mysql/mysql.conf.d:/etc/mysql/mysql.conf.d"
  environment:
    MYSQL_ROOT_PASSWORD: [root-password]
    MYSQL_DATABASE: [database-name]
    MYSQL_USER: [database-user-name]
    MYSQL_PASSWORD: [database-password]
```

### The folders where the applications would be found

````
./app/mydomain.com/www/
./app/myanotherdomain.com/www/
````

### It should be enough

`sudo docker-compose up -d`
