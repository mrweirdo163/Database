use QLGiaoVien
go

----------j-----------
CREATE PROCEDURE ExportTeachers
AS
BEGIN
    SELECT *
    FROM GIAOVIEN
END;

EXECUTE ExportTeachers


----------k----------
CREATE PROCEDURE CountTopicsForEachTeacher
AS
BEGIN
    SELECT GV.MAGV, GV.HOTEN, COUNT(DISTINCT TG.MADT) AS SoLuongDeTai
    FROM GIAOVIEN GV
    LEFT JOIN THAMGIADT TG ON GV.MAGV = TG.MAGV
    GROUP BY GV.MAGV, GV.HOTEN;
END;

EXECUTE CountTopicsForEachTeacher;


----------l----------
CREATE PROCEDURE CountRelativesForEachTeacher
AS
BEGIN
    SELECT GV.MAGV, GV.HOTEN, COUNT(DISTINCT TG.MADT) AS SoLuongDeTai, COUNT(DISTINCT NT.MAGV) AS SoLuongNguoiThan
    FROM GIAOVIEN GV
    LEFT JOIN THAMGIADT TG ON GV.MAGV = TG.MAGV
	LEFT JOIN NGUOITHAN NT ON GV.MAGV = NT.MAGV
    GROUP BY GV.MAGV, GV.HOTEN;
END;


EXECUTE CountRelativesForEachTeacher;


----------m-----------
CREATE PROCEDURE CheckTeacherExist
    @MaGV INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM GIAOVIEN
        WHERE MAGV = @MaGV
    )
    BEGIN
        PRINT N'Giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + ' tồn tại.';
    END
    ELSE
    BEGIN
        PRINT N'Giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + ' không tồn tại.';
    END
END;

EXEC CheckTeacherExist @MaGV = 015;


---------n-----------
CREATE PROCEDURE CheckTeacherRules
    @MaGV INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM GIAOVIEN GV
		INNER JOIN THAMGIADT TG ON GV.MAGV = TG.MAGV
		INNER JOIN DETAI DT ON TG.MADT = DT.MADT
		INNER JOIN GIAOVIEN GVCN ON DT.GVCNDT = GVCN.MAGV AND GV.MABM = GVCN.MABM
        WHERE GV.MAGV = @MaGV
    )
    BEGIN
        PRINT 'Giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + ' đáp ứng quy định.';
    END
    ELSE
    BEGIN
        PRINT 'Giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + ' không đáp ứng quy định.';
    END
END;


EXEC CheckTeacherRules @MaGV = 002;


---------o----------
CREATE PROCEDURE AssignAdditionalTask
    @MaGV INT,
    @MaDT INT,
    @SOTT INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM GIAOVIEN
        WHERE MAGV = @MaGV
    )
    BEGIN
        PRINT 'Giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + ' không tồn tại.';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM DETAI
        WHERE MADT = @MaDT
    )
    BEGIN
        PRINT 'Đề tài có mã ' + CAST(@MaDT AS NVARCHAR(10)) + ' không tồn tại.';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM THAMGIADT
        WHERE MAGV = @MaGV AND MADT = @MaDT AND STT = @SOTT
    )
    BEGIN
        PRINT 'Công việc số ' + CAST(@SOTT AS NVARCHAR(10)) + ' không tồn tại trong đề tài có mã ' + CAST(@MaDT AS NVARCHAR(10)) + '.';
        RETURN;
    END

    INSERT INTO THAMGIADT(MAGV, MADT, STT)
    VALUES (@MaGV, @MaDT, @SOTT);

    PRINT 'Đã thêm công việc số ' + CAST(@SOTT AS NVARCHAR(10)) + ' vào đề tài có mã ' + CAST(@MaDT AS NVARCHAR(10)) + ' cho giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + '.';
END;


EXEC AssignAdditionalTask @MaGV = 001, @MaDT = 002, @SOTT = 3;


---------p----------
CREATE PROCEDURE DeleteTeacher
    @MaGV INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM GIAOVIEN
        WHERE MAGV = @MaGV
    )
    BEGIN
        PRINT 'Giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + ' không tồn tại.';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM NGUOITHAN NT
        WHERE MAGV = @MaGV
    )
    BEGIN
        PRINT 'Giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + ' có thông tin người thân liên quan, không thể xóa.';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM THAMGIADT
        WHERE MAGV = @MaGV
    )
    BEGIN
        PRINT 'Giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + ' có liên quan đến các đề tài, không thể xóa.';
        RETURN;
    END

    DELETE FROM GIAOVIEN
    WHERE MAGV = @MaGV;

    PRINT 'Đã xóa giáo viên có mã ' + CAST(@MaGV AS NVARCHAR(10)) + '.';
END;


EXEC DeleteTeacher @MaGV = 002;


----------q-----------
CREATE PROCEDURE GetTeachersByDepartmentName
    @TENBM NVARCHAR(100)
AS
BEGIN
    SELECT GV.MAGV, GV.HOTEN,
           COUNT(DISTINCT TG.MADT) AS SoLuongDeTai,
           COUNT(DISTINCT NT.MAGV) AS SoLuongNguoiThan,
           COUNT(DISTINCT GVQL.MAGV) AS SoLuongQuanLi
    FROM GIAOVIEN GV
    LEFT JOIN THAMGIADT TG ON GV.MAGV = TG.MAGV
    LEFT JOIN NGUOITHAN NT ON GV.MAGV = NT.MAGV
    LEFT JOIN GIAOVIEN GVQL ON GV.MAGV = GVQL.GVQLCM
    INNER JOIN BOMON BM ON GV.MABM = BM.MABM
    WHERE BM.TENBM = @TENBM
    GROUP BY GV.MAGV, GV.HOTEN;
END;

EXEC GetTeachersByDepartmentName @TENBM = N'Hệ thống thông tin';


---------r---------
CREATE PROCEDURE CheckSalaryRules
    @MAGV_A INT,
    @MAGV_B INT
AS
BEGIN
    DECLARE @IsSupervisor BIT, @Salary_A MONEY, @Salary_B MONEY;

    -- Kiểm tra xem giáo viên A là trưởng bộ môn của giáo viên B
    SET @IsSupervisor = (
        SELECT CASE
                   WHEN EXISTS (
                              SELECT 1
                              FROM GIAOVIEN GV
								INNER JOIN BOMON BM ON GV.MABM = BM.MABM
                              WHERE MAGV = @MAGV_B AND BM.TRUONGBM = @MAGV_A
                          )
                       THEN 1
                   ELSE 0
               END
    );

    IF @IsSupervisor = 1
    BEGIN
        -- Lấy thông tin lương của giáo viên A
        SET @Salary_A = (
            SELECT LUONG
            FROM GIAOVIEN
            WHERE MAGV = @MAGV_A
        );

        -- Lấy thông tin lương của giáo viên B
        SET @Salary_B = (
            SELECT LUONG
            FROM GIAOVIEN
            WHERE MAGV = @MAGV_B
        );

        -- Kiểm tra quy định lương
        IF @Salary_A <= @Salary_B
        BEGIN
            PRINT 'Lương của giáo viên A (mã ' + CAST(@MAGV_A AS NVARCHAR(10)) + ') phải cao hơn lương của giáo viên B (mã ' + CAST(@MAGV_B AS NVARCHAR(10)) + ').';
        END
        ELSE
        BEGIN
            PRINT 'Lương của giáo viên A (mã ' + CAST(@MAGV_A AS NVARCHAR(10)) + ') đáp ứng quy định.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Giáo viên A (mã ' + CAST(@MAGV_A AS NVARCHAR(10)) + ') không là trưởng bộ môn của giáo viên B (mã ' + CAST(@MAGV_B AS NVARCHAR(10)) + ').';
    END
END;

EXEC CheckSalaryRules @MAGV_A = 002, @MAGV_B = 003;



----------s-------------
CREATE PROCEDURE AddNewTeacher
    @HOTENGV NVARCHAR(100),
    @Age INT,
    @Salary MONEY
AS
BEGIN
    -- Kiểm tra xem tên giáo viên có trùng hay không
    IF EXISTS (
        SELECT 1
        FROM GIAOVIEN
        WHERE HOTEN = @HOTENGV
    )
    BEGIN
        PRINT 'Tên giáo viên ' + @HOTENGV + ' đã tồn tại.';
        RETURN; -- Kết thúc stored procedure nếu tên giáo viên đã tồn tại
    END

    -- Kiểm tra tuổi giáo viên lớn hơn 18
    IF @Age <= 18
    BEGIN
        PRINT 'Giáo viên ' + @HOTENGV + ' phải có tuổi lớn hơn 18.';
        RETURN; -- Kết thúc stored procedure nếu tuổi giáo viên không hợp lệ
    END

    -- Kiểm tra lương giáo viên lớn hơn 0
    IF @Salary <= 0
    BEGIN
        PRINT 'Lương của giáo viên ' + @HOTENGV + ' phải lớn hơn 0.';
        RETURN; -- Kết thúc stored procedure nếu lương giáo viên không hợp lệ
    END

    INSERT INTO GIAOVIEN(HOTEN, NGSINH, LUONG)
    VALUES (@HOTENGV, @Age, @Salary);

    PRINT 'Đã thêm giáo viên ' + @HOTENGV + ' vào bảng Teachers.';
END;

EXEC AddNewTeacher @HOTENGV = N'Hồ Vĩnh Đình', @Age = 25, @Salary = 2000;


--------t---------
CREATE PROCEDURE AddNewTeacherWithRules
    @HOTEN NVARCHAR(100),
    @LUONG MONEY
AS
BEGIN
    DECLARE @MAGV_MOI INT;

    SELECT TOP 1 @MAGV_MOI = MAGV + 1
    FROM GIAOVIEN
    WHERE NOT EXISTS (
        SELECT 1
        FROM GIAOVIEN GV2
        WHERE GV2.MAGV = GIAOVIEN.MAGV + 1
    )
    ORDER BY MAGV;

    IF @MAGV_MOI IS NULL
    BEGIN
        -- Nếu không tìm thấy mã giáo viên mới thỏa mãn quy tắc, sẽ gán mã giáo viên tiếp theo là 1
        SET @MAGV_MOI = (
            SELECT ISNULL(MAX(MAGV), 0) + 1
            FROM GIAOVIEN
        );
    END

    INSERT INTO GIAOVIEN(MAGV, HOTEN, LUONG)
    VALUES (@MAGV_MOI, @HOTEN, @LUONG);

    PRINT 'Đã thêm giáo viên ' + @HOTEN + ' có mã ' + CAST(@MAGV_MOI AS NVARCHAR(10)) + ' vào bảng Teachers.';
END;

EXEC AddNewTeacherWithRules @HOTEN = N'Nguyễn Văn A', @LUONG = 3000;