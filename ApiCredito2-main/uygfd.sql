
SELECT 
    r."Descripcion" AS Rol,
    m."Nombre" AS Menu
FROM "MenuRols" mr
JOIN "Rol" r ON mr."RolId" = r."Id"
JOIN "Menus" m ON mr."MenuId" = m."Id";

select*from "Usuarios"



INSERT INTO "Usuarios" 
("NombreApellidos", "Correo", "RolId", "Clave", "FechaRegistro")
VALUES 
('Admin Principal', 'admin@correo.com', 1, 'admin123', NOW());


Drop table "Usuarios"
Drop table "Menus"
Drop table "MenusRols"
Drop table "Menus"


INSERT INTO "Rol" ("Descripcion", "FechaRegistro")
VALUES ('Administrador', NOW());


INSERT INTO "Rol" ("Descripcion", "FechaRegistro")
VALUES ('Cliente', NOW());


INSERT INTO "Menus" ("Nombre", "Icono", "Url")
VALUES 
('DashBoard', 'dashboard', '/pages/dashboard'),
('Usuarios', 'group', '/pages/usuarios'),
('Clientes', 'fa-user', '/clientes'),
('Venta', 'currency_exchange', '/pages/venta'),
('Historial', 'edit_note', '/pages/historial_venta'),
('Reportes', 'receipt', '/pages/reportes')



INSERT INTO "MenuRols" ("MenuId", "RolId")
VALUES 
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1);


INSERT INTO "Usuarios" 
("NombreApellidos", "Correo", "RolId", "Clave", "FechaRegistro")
VALUES 
('Admin Principal', 'admin@correo.com', 1, 'admin123', NOW());


select * from "Usuarios"
