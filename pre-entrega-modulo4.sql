create database PREENTREGA_4;
 

create table clientes(
idcliente serial primary key not null,
nombre_completo varchar(500) not null,
direccion varchar(500),
edad int
);

create table productos(
idproducto serial primary key not null,
nombre_producto varchar(500) not null,
categoria varchar(500) not null
);

create table ventas(
idventa serial primary key not null,
fecha_venta timestamp not null,
idcliente int not null references clientes(idcliente),
idproducto int not null references productos(idproducto),
cantidad int not null,
importe decimal(50,2) not null check (importe_total > 0)
);

insert into clientes
(nombre_completo, direccion, edad)
values
('Luz Salto', 'Soldado de la frontera 5235', 24),
('Maria Arguello', 'Av Martiniano Leguizamon 4652', 48),
('Nahuel Ferraro', 'Soldado de la frontera 5236' , 25),
('Daniel Salto', 'Luis Alberto Herrera 486', 52),
('Denice Recalde', 'Laarrazabal 147', 25);

insert into productos
(nombre_producto, categoria)
values 
('Perfume', 'Perfumeria'),
('Labial', 'Maquillaje'),
('Desodorante', 'Perfumeria'),
('Mascara de pestañas', 'Maquillaje'),
('Serum','Skincare');

insert into ventas
(fecha_venta, idcliente, idproducto, cantidad, importe)
values 
('2026-09-11', 2, 2, 2, 100.25),
('2026-09-15', 3, 1, 5, 500.85),
('2026-09-18', 3, 2, 1, 25),
('2026-09-18', 4, 3, 3, 525.50),
('2026-09-20', 5, 5, 2, 350);

select * from clientes;

select * from productos;

select * from ventas;


--RENTABILIDAD POR CATEGORIA
--Este codigo une la tabla de ventas y productos
--Muestra categoria, suma de cantidad y promedio de importe_total, para compras mayores a 1000

select 
p.categoria,
SUM(v.cantidad),
AVG(v.cantidad * v.importe) as importe_total
from ventas as v
inner join productos as p
on v.idproducto = p.idproducto
group by p.categoria -- aca agrupo por categoria
having AVG(v.cantidad * v.importe) > 500; --aca defino que me muestre los que el promedio son mayores a 500

--CLIENTES SIN COMPRAS
--este codigo pide que me traiga los clientes sin compras y con coalesce le pido que me ponga en 0 el idventa e importe

select 
c.nombre_completo ,
coalesce(v.idventa, 0) as id_venta,
coalesce((v.cantidad * v.importe), 0) as importe
from clientes as c
left join ventas as v
on c.idcliente = v.idcliente 
where v.idventa is null;

--RANKING DE COMPRAS
-- este codigo conecta las tablas clientes, producto y ventas, para mostrar los productos favoritos de cada cliente y su ultima transaccion

with ranking_compras as(
select 
c.idcliente ,
c.nombre_completo,
p.nombre_producto ,
count(*) as veces_comprado ,
max(v.fecha_venta) as ultima_transaccion ,
ROW_NUMBER() OVER (
            PARTITION BY c.idcliente 
            ORDER BY COUNT(*) DESC, MAX(v.fecha_venta) DESC
        ) AS rn
from ventas as v
inner join productos as p
on v.idproducto = p.idproducto
inner join clientes as c
on c.idcliente = v.idcliente 
group by c.idcliente, c.nombre_completo, p.idproducto, p.nombre_producto )

select 
nombre_completo ,
nombre_producto as producto_fav , 
ultima_transaccion
from ranking_compras 
where rn = 1
