-- init.sql
-- Otorgar permisos para la base de datos de desarrollo
GRANT ALL PRIVILEGES ON development.* TO 'the_user'@'%';

-- Otorgar permisos para la base de datos de prueba
GRANT ALL PRIVILEGES ON test.* TO 'the_user'@'%';

FLUSH PRIVILEGES;