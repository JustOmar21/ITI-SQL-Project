---------------------------------------------STUDENT TABLE OPERATIONS #Start--------------------------------------------------------------------

CREATE PROCEDURE StudentInsert @Name nvarchar(max) , @Email nvarchar(450) , @DOB date , @IntakeID int , @TrackID int , @ClassID int
AS
BEGIN -- Insertion Process for Student Table 
	declare @TrackException bit = 0;
	declare @IntakeException bit = 0;
	declare @ClassException bit = 0;
	declare @EmailException bit = 0;

	if exists(select * from Student where Email = @Email)
		set @EmailException = 1; -- If the Email already exists, set the exception flag to 1, indicating that the inserted Email is not unique

	if exists(select * from Track where Track.ID = @TrackID)
		set @TrackException = 1; -- If the Track exists, set the exception flag to 1

	if exists(select * from Class where Class.ID = @ClassID)
		set @ClassException = 1; -- If the Class exists, set the exception flag to 1

	if exists(select * from Intake where Intake.ID = @IntakeID)
		set @IntakeException = 1; -- If the Intake exists, set the exception flag to 1

	if @IntakeException = 0
		print 'An error has occured, the Intake ID you entered does not exist in Intake Table'
	else if @TrackException = 0
		print 'An error has occured, the Track ID you entered does not exist in Track Table'
	else if @ClassException = 0
		print 'An error has occured, the Class ID you entered does not exist in Class Table'
	else if @EmailException = 1
		print 'An error has occured, the Email you entered already exists , enter a unique Email'
	else
		insert into Student values (@Name , @Email , @DOB , @IntakeID , @TrackID , @ClassID);

END;

EXEC StudentInsert 'Omar Tarek' , 'tarekes68@gmail.com' , '2001-6-12' , 3 , 1 , 2 ;

go

CREATE PROCEDURE StudentUpdate @ID int, @Name nvarchar(max) , @Email nvarchar(450) , @DOB date , @IntakeID int , @TrackID int , @ClassID int
AS
BEGIN -- Update Process for Student Table 
	declare @TrackException bit = 0;
	declare @IntakeException bit = 0;
	declare @ClassException bit = 0;
	declare @IDException bit = 0;
	declare @EmailException bit = 0;

	if exists(select * from Student where Email = @Email and ID != @ID)
		set @EmailException = 1; -- If the Email already exists and it is not the same as student being updated then, set the exception flag to 1, indicating that the inserted Email is not unique

	if exists(select * from Student where Student.ID = @ID)
		set @IDException = 1; -- If the Student exists, set the exception flag to 1

	if exists(select * from Track where Track.ID = @TrackID)
		set @TrackException = 1; -- If the Track exists, set the exception flag to 1

	if exists(select * from Class where Class.ID = @ClassID)
		set @ClassException = 1; -- If the Class exists, set the exception flag to 1

	if exists(select * from Intake where Intake.ID = @IntakeID)
		set @IntakeException = 1; -- If the Intake exists, set the exception flag to 1
	
	if @IDException = 0
		print 'An error has occured, The Student ID you entered does not exist in Student Table'
	else if @IntakeException = 0
		print 'An error has occured, the Intake ID you entered does not exist in Intake Table'
	else if @TrackException = 0
		print 'An error has occured, the Track ID you entered does not exist in Track Table'
	else if @ClassException = 0
		print 'An error has occured, the Class ID you entered does not exist in Class Table'
	else if @EmailException = 1
		print 'An error has occured, the Email you entered already exists , enter a unique Email'
	else
		UPDATE Student set [Name] = @Name , Email = @Email , DOB = @DOB , IntakeID = @IntakeID , TrackID = @TrackID , ClassID = @ClassID where ID = @ID;

END;

EXEC StudentUpdate 2 , 'Omar Tarek El-Sayed Ali Badawy' , 'tarekes68@gmail.com' , '2001-6-12' , 3 , 1 , 2 ;

GO

CREATE PROCEDURE StudentDelete @ID int
AS
BEGIN -- Deletion Process for Student Table 
	DECLARE @IDException BIT = 0;


	if exists(select * from Student where Student.ID = @ID)
		set @IDException = 1; -- If the Student exists, set the exception flag to 1


	if @IDException = 0
		print 'An error has occured, The Student ID you entered does not exist in Student Table'
	else
		DELETE FROM Student WHERE ID = @ID;

END;

EXEC StudentDelete 3

GO

CREATE VIEW StudentData AS SELECT * FROM Student;

GO

CREATE PROCEDURE ReadStudents @ID int = NULL, @Name nvarchar(max) = NULL, @Email nvarchar(450) = NULL, @DOB date = NULL, @IntakeID int = NULL, @TrackID int = NULL, @ClassID int = NULL
AS
BEGIN -- Reading Process for Student Table 
	SELECT * FROM StudentData 
	WHERE ID = COALESCE( @ID , ID) AND 
	[Name] = COALESCE( @Name , [Name] ) AND
	Email = COALESCE( @Email , Email ) AND
	DOB = COALESCE( @DOB , DOB ) AND
	IntakeID = COALESCE( @IntakeID , IntakeID ) AND
	TrackID = COALESCE( @TrackID , TrackID ) AND
	ClassID = COALESCE( @ClassID , ClassID );
END;

EXEC ReadStudents -- @Email = 'TAREKES68@GMail.com' with COALESCE function and default values for the parameters, the USER can search Student Table using various parameters;

GO

---------------------------------------------STUDENT TABLE OPERATIONS #END--------------------------------------------------------------------

