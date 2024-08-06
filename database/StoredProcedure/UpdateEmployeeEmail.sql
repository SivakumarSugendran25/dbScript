 

ALTER PROCEDURE UpdateEmployeeEmail  
    @EmployeeID INT,  
    @NewEmail NVARCHAR(255)  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    UPDATE EmployeeTable  
    SET Email = @NewEmail  
    WHERE ID = @EmployeeID;  
END
