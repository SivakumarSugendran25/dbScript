 

ALTER PROCEDURE UpdateEmployeeEmail  
    @EmployeeID INT,  
    @NewEmail NVARCHAR(255)  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    UPDATE EmployeeTable  
    SET FullName = @NewEmail  
    WHERE ID = @EmployeeID;  
END
