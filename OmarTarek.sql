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


---------------------------------------------Question and Question_Choices TABLES OPERATIONS #Start--------------------------------------------------------------------


--Create Login "tarekes68@gmail.com" with password = '12345';
--CREATE USER "Omar Tarek" FOR LOGIN "tarekes68@gmail.com";
--ALTER ROLE db_owner ADD MEMBER "Omar Tarek";
--TESTING DO NOT USE

CREATE PROCEDURE CreateQuestion @Body nvarchar(max) , @Type nvarchar(100) , @CorrectChoice int , @CourseID int , @Choice1 nvarchar(450) = null , @Choice2 nvarchar(450) = null , @Choice3 nvarchar(450) = null  , @Choice4 nvarchar(450) = null
AS
BEGIN -- Insertion process for Question and Question_Choices Table
	
	DECLARE @InstuctorID INT;
	DECLARE @InsertedQuestionID INT;
	SELECT  @InstuctorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();
	DECLARE @CourseException BIT = 0;
	DECLARE @ChoiceException BIT = 0;
	DECLARE @TypeException INT = 0;
	DECLARE @ClassInsException BIT = 0;

	IF EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CourseID AND InstructorID = @InstuctorID )
		SET @ClassInsException = 1; -- If the Instructor teaches the Course he entered , set the Exception flag to 1 , this ensures that only the Instructor who teaches this course can add to the question pool

	IF EXISTS(SELECT * FROM Course where ID = @CourseID)
		SET @CourseException = 1; -- If the Course exists, set the Exception flag to 1
	
	IF @CorrectChoice BETWEEN 1 AND 4
		SET @ChoiceException = 1; -- If Choice Value is between 1 to 4 range, set the Exception flag to 1

	IF @Type = 'Multiple' OR @Type = 'Bool' OR @Type = 'Text'
		SET @TypeException = 1; -- If Type value is 'Multiple' OR 'Bool' OR 'Text', set the Exception flag to 1

	IF @Type = 'Bool' AND @CorrectChoice NOT BETWEEN 1 AND 2
		SET @TypeException = 2; -- If Type value is 'BOOL', set the Exception flag to 2 to raise error that the correct choice value should be 1 or 2

	IF @Type = 'Text' AND @CorrectChoice != 1
		SET @TypeException = 3; -- If Type value is 'Text', set the Exception flag to 3 to raise error that the correct choice value should be 1

	IF @ChoiceException = 0
		print 'An error has occured, the Correct Choice Number value you entered is outside the allowed range (1 , 2 , 3 , 4)';
	ELSE IF @TypeException = 0
		print 'An error has occured, the Type you entered is outside the allowed range (Multiple , Bool , Text)';
	ELSE IF @TypeException = 2
		print 'An error has occured, Type Bool cannot have the correct choice outside the 1 , 2 values since the choices are automatically inserted as True , False'
	ELSE IF @TypeException = 3
		print 'An error has occured, Type Text cannot have the correct choice value be anything other than 1'
	ELSE IF @CourseException = 0
		print 'An error has occured, the Course ID you entered does not exist '
	ELSE IF @ClassInsException = 0
		print 'An Error has occured, you are not authorized to add this question to this course since you do not teach it'
	ELSE
		BEGIN
			IF @Type = 'Bool'
				BEGIN
					INSERT INTO Question VALUES (@Body , @Type , @CorrectChoice , @CourseID , @InstuctorID);
					SET @InsertedQuestionID = SCOPE_IDENTITY();
					INSERT INTO Question_Choices VALUES ( @InsertedQuestionID , 1 , 'True');
					INSERT INTO Question_Choices VALUES ( @InsertedQuestionID , 2 , 'False');
				END 
			ELSE IF @Choice1 IS NULL
				PRINT 'An error has occured, Type Text Requires that the first choice to be entered'
			ELSE IF @Type = 'Text'
				BEGIN
					INSERT INTO Question VALUES (@Body , @Type , @CorrectChoice , @CourseID , @InstuctorID);
					SET @InsertedQuestionID = SCOPE_IDENTITY();
					INSERT INTO Question_Choices VALUES ( @InsertedQuestionID , 1 , @Choice1);
				END
			ELSE IF @Choice1 IS NULL OR @Choice2 IS NULL OR @Choice3 IS NULL OR @Choice4 IS NULL
				PRINT 'An error has occured, Type Multiple Requires that all choices be entered'
			ELSE IF @Choice1 = @Choice2 OR @Choice1 = @Choice3 OR @Choice1 = @Choice4 OR @Choice2 = @Choice3 OR @Choice2 = @Choice4 OR @Choice3 = @Choice4
				PRINT 'An error has occured, you cannot insert duplicate choices for Multiple Type Question'
 			ELSE IF @Type = 'Multiple'
				BEGIN
					INSERT INTO Question VALUES (@Body , @Type , @CorrectChoice , @CourseID , @InstuctorID);
					SET @InsertedQuestionID = SCOPE_IDENTITY();
					INSERT INTO Question_Choices VALUES ( @InsertedQuestionID , 1 , @Choice1);
					INSERT INTO Question_Choices VALUES ( @InsertedQuestionID , 2 , @Choice2);
					INSERT INTO Question_Choices VALUES ( @InsertedQuestionID , 3 , @Choice3);
					INSERT INTO Question_Choices VALUES ( @InsertedQuestionID , 4 , @Choice4);
				END
		END
END;

EXEC CreateQuestion 'WTFF' , 'BOOL' , 1 , 2 

GO

CREATE VIEW QuestionData 
AS 
SELECT 
    q.ID, q.[Type], q.Body, 
    MAX(CASE WHEN qc.ChoiceNumber = 1 THEN qc.Choice END) as 'Choice 1',
    MAX(CASE WHEN qc.ChoiceNumber = 2 THEN qc.Choice END) as 'Choice 2',
    MAX(CASE WHEN qc.ChoiceNumber = 3 THEN qc.Choice END) as 'Choice 3',
    MAX(CASE WHEN qc.ChoiceNumber = 4 THEN qc.Choice END) as 'Choice 4',
    q.CorrectChoiceNumber as 'Correct Choice Number',
    q.CourseID, q.InstructorID
FROM 
    Question q 
INNER JOIN 
    Question_Choices qc ON q.ID = qc.QuestionID 
GROUP BY 
    q.ID, q.[Type], q.Body, q.CorrectChoiceNumber , q.CourseID, q.InstructorID;

GO

CREATE PROCEDURE ViewQuestions @ID INT = NULL , @Type NVARCHAR(100) = NULL , @CourseID INT = NULL , @InstructorID INT = NULL
AS
BEGIN -- Read process for both Question and Question_Choices Table
	SELECT * FROM QuestionData
	WHERE
	ID = COALESCE(@ID , ID) AND
	[Type] = COALESCE(@Type , [Type]) AND
	CourseID = COALESCE(@CourseID , CourseID) AND
	InstructorID = COALESCE(@InstructorID , InstructorID);

END

EXEC ViewQuestions;

GO

CREATE PROCEDURE DeleteQuestion @ID INT
AS
BEGIN -- Deletion Process for Question and Question_Choices Table 
	DECLARE @IDException BIT = 0;


	if exists(select * from Question where ID = @ID)
		set @IDException = 1; -- If the Question exists, set the exception flag to 1


	if @IDException = 0
		print 'An error has occured, The Question ID you entered does not exist in Student Table'
	else
		DELETE FROM Question WHERE ID = @ID;

END;

EXEC DeleteQuestion 1


GO


CREATE PROCEDURE UpdateQuestion @ID INT , @Body nvarchar(max) , @Type nvarchar(100) , @CorrectChoice int , @CourseID int , @Choice1 nvarchar(450) = null , @Choice2 nvarchar(450) = null , @Choice3 nvarchar(450) = null  , @Choice4 nvarchar(450) = null
AS
BEGIN -- Insertion process for Question and Question_Choices Table
	
	DECLARE @InstuctorID INT;
	SELECT  @InstuctorID = 1--ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();
	DECLARE @CourseException BIT = 0;
	DECLARE @ChoiceException BIT = 0;
	DECLARE @TypeException INT = 0;
	DECLARE @ClassInsException BIT = 0;
	DECLARE @IDException BIT = 0;


	IF EXISTS(SELECT * FROM Question where ID = @ID)
		SET @IDException = 1; -- If the Question exists, set the Exception flag to 1

	IF EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CourseID AND InstructorID = @InstuctorID )
		SET @ClassInsException = 1; -- If the Instructor teaches the Course he entered , set the Exception flag to 1 , this ensures that only the Instructor who teaches this course can add to the question pool

	IF EXISTS(SELECT * FROM Course where ID = @CourseID)
		SET @CourseException = 1; -- If the Course exists, set the Exception flag to 1
	
	IF @CorrectChoice BETWEEN 1 AND 4
		SET @ChoiceException = 1; -- If Choice Value is between 1 to 4 range, set the Exception flag to 1

	IF @Type = 'Multiple' OR @Type = 'Bool' OR @Type = 'Text'
		SET @TypeException = 1; -- If Type value is 'Multiple' OR 'Bool' OR 'Text', set the Exception flag to 1

	IF @Type = 'Bool' AND @CorrectChoice NOT BETWEEN 1 AND 2
		SET @TypeException = 2; -- If Type value is 'BOOL', set the Exception flag to 2 to raise error that the correct choice value should be 1 or 2

	IF @Type = 'Text' AND @CorrectChoice != 1
		SET @TypeException = 3; -- If Type value is 'Text', set the Exception flag to 3 to raise error that the correct choice value should be 1

	IF @IDException = 0
		print 'An error has occured, the question ID you entered does not exist ';
	ELSE IF @ChoiceException = 0
		print 'An error has occured, the Correct Choice Number value you entered is outside the allowed range (1 , 2 , 3 , 4)';
	ELSE IF @TypeException = 0
		print 'An error has occured, the Type you entered is outside the allowed range (Multiple , Bool , Text)';
	ELSE IF @TypeException = 2
		print 'An error has occured, Type Bool cannot have the correct choice outside the 1 , 2 values since the choices are automatically inserted as True , False'
	ELSE IF @TypeException = 3
		print 'An error has occured, Type Text cannot have the correct choice value be anything other than 1'
	ELSE IF @CourseException = 0
		print 'An error has occured, the Course ID you entered does not exist '
	ELSE IF @ClassInsException = 25
		print 'An Error has occured, you are not authorized to add this question to this course since you do not teach it'
	ELSE
		BEGIN
			IF @Type = 'Bool'
				BEGIN
					UPDATE Question 
					SET Body = @Body ,
					[Type] = @Type ,
					CorrectChoiceNumber = @CorrectChoice ,
					CourseID = @CourseID ,
					InstructorID = @InstuctorID WHERE ID = @ID ;
					UPDATE Question_Choices SET Choice = 'True' WHERE QuestionID = @ID AND ChoiceNumber = 1;
					UPDATE Question_Choices SET Choice = 'False' WHERE QuestionID = @ID AND ChoiceNumber = 2;
					UPDATE Question_Choices SET Choice = NULL WHERE QuestionID = @ID AND ChoiceNumber = 3;
					UPDATE Question_Choices SET Choice = NULL WHERE QuestionID = @ID AND ChoiceNumber = 4;
				END 
			ELSE IF @Choice1 IS NULL
				PRINT 'An error has occured, Type Text Requires that the first choice to be entered'
			ELSE IF @Type = 'Text'
				BEGIN
					UPDATE Question 
					SET Body = @Body ,
					[Type] = @Type ,
					CorrectChoiceNumber = @CorrectChoice ,
					CourseID = @CourseID ,
					InstructorID = @InstuctorID WHERE ID = @ID ;
					UPDATE Question_Choices SET Choice = @Choice1 WHERE QuestionID = @ID AND ChoiceNumber = 1;
					UPDATE Question_Choices SET Choice = NULL WHERE QuestionID = @ID AND ChoiceNumber = 2;
					UPDATE Question_Choices SET Choice = NULL WHERE QuestionID = @ID AND ChoiceNumber = 3;
					UPDATE Question_Choices SET Choice = NULL WHERE QuestionID = @ID AND ChoiceNumber = 4;
				END
			ELSE IF @Choice1 IS NULL OR @Choice2 IS NULL OR @Choice3 IS NULL OR @Choice4 IS NULL
				PRINT 'An error has occured, Type Multiple Requires that all choices be entered'
			ELSE IF @Choice1 = @Choice2 OR @Choice1 = @Choice3 OR @Choice1 = @Choice4 OR @Choice2 = @Choice3 OR @Choice2 = @Choice4 OR @Choice3 = @Choice4
				PRINT 'An error has occured, you cannot insert duplicate choices for Multiple Type Question'
 			ELSE IF @Type = 'Multiple'
				BEGIN
					UPDATE Question 
					SET Body = @Body ,
					[Type] = @Type ,
					CorrectChoiceNumber = @CorrectChoice ,
					CourseID = @CourseID ,
					InstructorID = @InstuctorID WHERE ID = @ID ;
					UPDATE Question_Choices SET Choice = @Choice1 WHERE QuestionID = @ID AND ChoiceNumber = 1;
					UPDATE Question_Choices SET Choice = @Choice2 WHERE QuestionID = @ID AND ChoiceNumber = 2;
					UPDATE Question_Choices SET Choice = @Choice3 WHERE QuestionID = @ID AND ChoiceNumber = 3;
					UPDATE Question_Choices SET Choice = @Choice4 WHERE QuestionID = @ID AND ChoiceNumber = 4;
				END
		END
END;


EXEC UpdateQuestion 3 ,'CHOOSE' , 'MULTIPLE' , 1 , 2 , '3ADSFA' , 'SDAASDF' , 'ASDFDSAF' , 'DSAFSFS'
EXEC ViewQuestions;


---------------------------------------------Question and Question_Choices TABLES OPERATIONS #End--------------------------------------------------------------------

