alter table Restaurant_Pagospring ADD GeneraCobranza Char(1)
GO
alter table Restaurant_Pagos ADD GeneraCobranza Char(1)
go
UPDATE Restaurant_Pagospring SET GeneraCobranza ='S'


