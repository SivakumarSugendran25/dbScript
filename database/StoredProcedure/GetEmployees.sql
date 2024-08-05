ALTER PROCEDURE GetEmployees
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ID, FullName, Email
    FROM EmployeeTable;
END
