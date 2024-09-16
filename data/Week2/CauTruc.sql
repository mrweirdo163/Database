create database QLGiaoVien
go

use QLGiaoVien
go

create table GIAOVIEN (
	MAGV char (5), 
	HOTEN nvarchar(40), 
	LUONG float, 
	PHAI nchar(3), 
	NGSINH datetime, 
	DIACHI nvarchar(100), 
	GVQLCM char(5), 
	MABM nchar(5),

	CONSTRAINT pk_GIAOVIEN PRIMARY KEY (MAGV)
)

create table GV_DT (
	MAGV char(5), 
	DIENTHOAI char(12),

	CONSTRAINT pk_GV_DT PRIMARY KEY (MAGV, DIENTHOAI)
)

create table BOMON (
	MABM nchar(5),
	TENBM nvarchar(40), 	 
	PHONG char(5),
	DIENTHOAI char(12), 
	TRUONGBM char(5), 
	MAKHOA char(4), 	
	NGAYNHANCHUC datetime,


	CONSTRAINT pk_BOMON PRIMARY KEY (MABM)
)
create table KHOA (
	MAKHOA char(4), 
	TENKHOA nvarchar(40), 
	NAMTL int, 
	PHONG char(5), 
	DIENTHOAI char(12), 	
	TRUONGKHOA char(5), 
	NGAYNHANCHUC datetime,


	CONSTRAINT pk_KHOA PRIMARY KEY (MAKHOA)	
)

create table DETAI (
	MADT char(3), 
	TENDT nvarchar(100), 
	CAPQL nvarchar(40), 
	KINHPHI float, 
	NGAYBD datetime, 
	NGAYKT datetime, 	
	MACD nchar(4),
	GVCNDT char(5),
	
	
	CONSTRAINT pk_DETAI PRIMARY KEY (MADT)
)

create table CHUDE (
	MACD nchar(4), 
	TENCD nvarchar(50),

	CONSTRAINT pk_CHUDE PRIMARY KEY (MACD)
)
create table CONGVIEC (
	MADT char(3), 
	SOTT int, 
	TENCV nvarchar(40), 
	NGAYBD datetime, 
	NGAYKT datetime,


	CONSTRAINT pk_CONGVIEC PRIMARY KEY (MADT, SOTT) 
)

create table THAMGIADT (
	MAGV char(5), 
	MADT char(3), 
	STT int, 
	PHUCAP float , 
	KETQUA nvarchar(40),


	CONSTRAINT pk_THAMGIADT PRIMARY KEY (MAGV, MADT, STT)
)

create table NGUOITHAN (
	MAGV char(5), 
	TEN nvarchar(20), 
	NGSINH datetime, 
	PHAI nchar(3),

	CONSTRAINT pk_NGUOITHAN PRIMARY KEY (MAGV, TEN)
)

alter table GIAOVIEN add
	constraint FK_GIAOVIEN_BOMON foreign key (MABM) references BOMON (MABM),
	constraint FK_GIAOVIEN_GIAOVIEN foreign key (GVQLCM) references GIAOVIEN (MAGV)

alter table KHOA add 
	constraint FK_KHOA_GIAOVIEN foreign key (TRUONGKHOA) references GIAOVIEN (MAGV)

alter table BOMON add 
	constraint FK_BOMON_KHOA foreign key (MAKHOA) references KHOA(MAKHOA),
	constraint FK_BOMON_GIAOVIEN foreign key (TRUONGBM) references GIAOVIEN (MAGV)

alter table NGUOITHAN add
	constraint FK_NGUOITHAN_GIAOVIEN foreign key (MAGV)references GIAOVIEN (MAGV)

alter table THAMGIADT add
	constraint FK_PHANCONG_GIAOVIEN foreign key (MAGV)references GIAOVIEN (MAGV),
	constraint FK_PHANCONG_CONGVIEC foreign key (MADT, STT)references CONGVIEC(MADT, SOTT)

alter table DETAI add
	constraint FK_DETAI_CHUDE foreign key (MACD)references CHUDE (MACD)

alter table DETAI add
	constraint FK_DETAI_GIAOVIEN foreign key (GVCNDT)references GIAOVIEN (MAGV)

alter table GV_DT add
	constraint FK_DIENTHOAI_GIAOVIEN foreign key (MAGV)references GIAOVIEN (MAGV)

alter table CONGVIEC add 	
	constraint FK_CONGVIEC_DETAI foreign key (MADT)references DETAI (MADT)