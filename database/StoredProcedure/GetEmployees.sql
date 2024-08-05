ALTER PROCEDURE GetEmployees
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ID, FullName
    FROM EmployeeTable;
END
