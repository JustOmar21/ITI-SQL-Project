--Instructor Table 



ALTER PROCEDURE InstructorInsert( @Name nvarchar(max), @Title nvarchar(max), @Email nvarchar(450), @DOB date, @Salary decimal(10, 2))
AS
BEGIN
    DECLARE @NameException BIT = 0;
    DECLARE @TitleException BIT = 0;
    DECLARE @EmailException BIT = 0;
	DECLARE @AgeException BIT = 0;
    DECLARE @SalaryException BIT = 0;

     -- Check name 
    IF LEN(@Name) > 0
        SET @NameException = 1;

    -- Check title 
    IF LEN(@Title) > 0
        SET @TitleException = 1;

    -- Check email 
    IF LEN(@Email) > 0 AND CHARINDEX('@', @Email) > 0 AND NOT EXISTS (SELECT * FROM Instructor WHERE Email = @Email)
        SET @EmailException = 1;

    -- Check age 
    IF @DOB < GETDATE()
        SET @AgeException = 1;

    -- Check salary 
    IF @Salary > 0
        SET @SalaryException = 1;

    -- Perform conditions
    IF @NameException = 0
        PRINT 'An error has occurred, please provide a valid name.';
    ELSE IF @TitleException = 0
        PRINT 'An error has occurred, please provide a valid title.';
    ELSE IF @EmailException = 0
        PRINT 'An error has occurred, please provide a valid Unique email address.';
    ELSE IF @AgeException = 0
        PRINT 'An error has occurred, please provide a valid age.';
    ELSE IF @SalaryException = 0
        PRINT 'An error has occurred, please provide a valid salary.';
    ELSE
		BEGIN
			INSERT INTO instructor
			VALUES (@Name, @Title, @Email, @DOB, @Salary);

			DECLARE @Password NVARCHAR(50) = '12345';
			DECLARE @DefaultDatabase NVARCHAR(255) = 'Examination System';
			DECLARE @SqlStatement NVARCHAR(MAX);
			-- Construct the dynamic SQL statement
			SET @SqlStatement = 'CREATE LOGIN ' + QUOTENAME(@Email) + ' WITH PASSWORD = ''' + @Password + ''', DEFAULT_DATABASE = ' + QUOTENAME(@DefaultDatabase) + ';';
			EXEC sp_executesql @SqlStatement;

			-- Create user and add to role
			SET @SqlStatement = 'CREATE USER ' + QUOTENAME(@Email) + ' FOR LOGIN ' + QUOTENAME(@Email) + ';';
			EXEC sp_executesql @SqlStatement;

			IF @Title Like '%Manager%'
				SET @SqlStatement = 'ALTER ROLE Manager ADD MEMBER ' + QUOTENAME(@Email) + ';';
			ELSE
				SET @SqlStatement = 'ALTER ROLE Instructor ADD MEMBER ' + QUOTENAME(@Email) + ';';

			EXEC sp_executesql @SqlStatement;
		END
END;
EXEC InstructorInsert 'Dalia Mohamed', 'Professor', 'daliam@gmail.com', '1997-12-15',15000.00;

GO
-- Update instructor 
ALTER PROCEDURE InstructorUpdate(@InstructorId int , @Name nvarchar(max), @Title nvarchar(max), @Email nvarchar(450), @DOB DATE, @Salary decimal(10, 2))
AS
BEGIN

	DECLARE @NameException BIT = 0;
    DECLARE @TitleException BIT = 0;
    DECLARE @EmailException BIT = 0;
	DECLARE @AgeException BIT = 0;
    DECLARE @SalaryException BIT = 0;

     -- Check name 
    IF LEN(@Name) > 0
        SET @NameException = 1;

    -- Check title 
    IF LEN(@Title) > 0
        SET @TitleException = 1;

    -- Check email 
    IF LEN(@Email) > 0 AND CHARINDEX('@', @Email) > 0 AND NOT EXISTS (SELECT * FROM Instructor WHERE Email = @Email AND ID != @InstructorId)
        SET @EmailException = 1;

    -- Check age 
    IF @DOB < GETDATE()
        SET @AgeException = 1;

    -- Check salary 
    IF @Salary > 0
        SET @SalaryException = 1;

    -- Perform conditions
    IF @NameException = 0
        PRINT 'An error has occurred, please provide a valid name.';
    ELSE IF @TitleException = 0
        PRINT 'An error has occurred, please provide a valid title.';
    ELSE IF @EmailException = 0
        PRINT 'An error has occurred, please provide a valid unique email address.';
    ELSE IF @AgeException = 0
        PRINT 'An error has occurred, please provide a valid age.';
    ELSE IF @SalaryException = 0
        PRINT 'An error has occurred, please provide a valid salary.';
    ELSE IF EXISTS (SELECT 1 FROM instructor WHERE Id = @InstructorId)
		BEGIN

			DECLARE @oldEmail nvarchar(450);
			SELECT @oldEmail = Email FROM Instructor WHERE ID = @InstructorId;

			EXEC DeleteLoginAndUser @EmailToDelete = @oldEmail
			UPDATE instructor
			SET
				name = @Name,
				title = @Title,
				email = @Email,
				DOB = @DOB,
				salary = @Salary
			WHERE
				Id = @InstructorId;

			DECLARE @Password NVARCHAR(50) = '12345';
			DECLARE @DefaultDatabase NVARCHAR(255) = 'Examination System';
			DECLARE @SqlStatement NVARCHAR(MAX);
			-- Construct the dynamic SQL statement
			SET @SqlStatement = 'CREATE LOGIN ' + QUOTENAME(@Email) + ' WITH PASSWORD = ''' + @Password + ''', DEFAULT_DATABASE = ' + QUOTENAME(@DefaultDatabase) + ';';
			EXEC sp_executesql @SqlStatement;

			-- Create user and add to role
			SET @SqlStatement = 'CREATE USER ' + QUOTENAME(@Email) + ' FOR LOGIN ' + QUOTENAME(@Email) + ';';
			EXEC sp_executesql @SqlStatement;

			IF @Title Like '%Manager%'
				SET @SqlStatement = 'ALTER ROLE Manager ADD MEMBER ' + QUOTENAME(@Email) + ';';
			ELSE
				SET @SqlStatement = 'ALTER ROLE Instructor ADD MEMBER ' + QUOTENAME(@Email) + ';';

			EXEC sp_executesql @SqlStatement;


			PRINT 'Instructor updated successfully.';
		END
    ELSE
		BEGIN
			PRINT 'Instructor with ID ' + CAST(@InstructorId AS nvarchar) + ' does not exist.';
		END
END;

EXEC InstructorUpdate 1, 'Aya Mohamed', 'Professor', 'aya22@gmail.com', '2001-12-21', 10000.00;

GO

-- Delete instructor
ALTER PROCEDURE InstructorDelete(@InstructorId INT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM instructor WHERE Id = @InstructorId)
    BEGIN
		DECLARE @oldEmail nvarchar(450);
		SELECT @oldEmail = Email FROM Instructor WHERE ID = @InstructorId;

		EXEC DeleteLoginAndUser @EmailToDelete = @oldEmail
        DELETE FROM instructor WHERE Id = @InstructorId;
        PRINT 'Instructor deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Instructor with ID ' + CAST(@InstructorId AS nvarchar) + ' does not exist.';
    END
END;
EXEC InstructorDelete 1;


-- View all instructors

GO

CREATE VIEW InstructorData
AS
SELECT * FROM Instructor

GO

CREATE PROCEDURE ViewInstructors @ID INT = NULL , @Email NVARCHAR(450) = NULL , @Title NVARCHAR(300) = NULL ,@Name NVARCHAR(300) = NULL
AS
BEGIN
    SELECT * FROM InstructorData
	WHERE
	ID = COALESCE(@ID , ID) AND
	Email LIKE COALESCE('%'+@Email +'%' , Email) AND
	title LIKE COALESCE('%'+@Title +'%' , title) AND
	[Name] LIKE COALESCE('%' + @Name + '%' , [Name])
END;

EXEC ViewInstructors;

--Teaches_At Table 
-- insert
GO

CREATE PROCEDURE TeachesAtInsert(@CourseID INT,@ClassID INT,@InstructorID INT)
AS
BEGIN
    DECLARE @CourseException BIT = 0;
    DECLARE @ClassException BIT = 0;
    DECLARE @InstructorException BIT = 0;

    -- Check CourseID 
    IF EXISTS (SELECT 1 FROM Course WHERE ID = @CourseID)
        SET @CourseException = 1;

    -- Check ClassID 
    IF EXISTS (SELECT 1 FROM Class WHERE ID = @ClassID)
        SET @ClassException = 1;

    -- Check InstructorID 
    IF EXISTS (SELECT 1 FROM Instructor WHERE ID = @InstructorID)
        SET @InstructorException = 1;

    -- Perform conditions
    IF @CourseException = 0
        PRINT 'An error has occurred, the Course ID does not exist in the Course Table.';
    ELSE IF @ClassException = 0
        PRINT 'An error has occurred, the Class ID does not exist in the Class Table.';
    ELSE IF @InstructorException = 0
        PRINT 'An error has occurred, the Instructor ID does not exist in the Instructor Table.';
    ELSE
		BEGIN
			INSERT INTO Teaches_At (courseID, classID, InstructorID)
			VALUES (@CourseID, @ClassID, @InstructorID);
			PRINT 'Teaching assignment inserted successfully.';
		END
    
END;

EXEC TeachesAtInsert 1, 1, 1;

GO

-- Update Teaches_At table
CREATE PROCEDURE TeachesAtUpdate( @CourseID INT, @ClassID INT, @InstructorID INT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Teaches_At WHERE courseID = @CourseID AND classID = @ClassID)
    BEGIN
        UPDATE Teaches_At
        SET InstructorID = @InstructorID
        WHERE courseID = @CourseID AND classID = @ClassID;

        PRINT 'Teaching assignment updated successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Teaching assignment does not exist for Course ID ' + CAST(@CourseID AS nvarchar) +
            ' and Class ID ' + CAST(@ClassID AS nvarchar) + '.';
    END
END;
EXEC TeachesAtUpdate 1, 1, 2;

GO
-- Delete from Teaches_At table
CREATE PROCEDURE TeachesAtDelete( @CourseID INT,@ClassID INT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Teaches_At WHERE courseID = @CourseID AND classID = @ClassID)
    BEGIN
        DELETE FROM Teaches_At WHERE courseID = @CourseID AND classID = @ClassID;
        PRINT 'Teaching assignment deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Teaching assignment does not exist for Course ID ' + CAST(@CourseID AS nvarchar) +
		' and Class ID ' + CAST(@ClassID AS nvarchar) + '.';
    END
END;

EXEC TeachesAtDelete 1, 1;

-- View all 

GO

CREATE VIEW TeachesAtData
AS
SELECT * FROM Teaches_At

GO

CREATE PROCEDURE ViewTeachingAssignments @CourseID INT = NULL, @ClassID INT = NULL, @InstructorID INT = NULL
AS
BEGIN
    SELECT * FROM TeachesAtData 
	WHERE
	ClassID = COALESCE(@ClassID , ClassID) AND
	CourseID = COALESCE(@CourseID , CourseID) AND
	InstructorID = COALESCE(@InstructorID , InstructorID)
END;

EXEC ViewTeachingAssignments;


-- Department Table
-- Insert

GO

CREATE PROCEDURE DepartmentInsert( @Name nvarchar(max),@BranchID INT)
AS
BEGIN
    DECLARE @BranchException BIT = 0;

    -- Check BranchID
    IF EXISTS (SELECT 1 FROM Branch WHERE ID = @BranchID)
        SET @BranchException = 1;

    IF @BranchException = 0
        PRINT 'An error has occurred, the Branch ID does not exist in the Branch Table.';
    ELSE
		BEGIN
			INSERT INTO Department (name, BranchID)
			VALUES (@Name, @BranchID);
			PRINT 'Department inserted successfully.';
		END
END;
EXEC DepartmentInsert 'Software Engnieering', 1;

GO
-- Update Department table
CREATE PROCEDURE DepartmentUpdate(@DepartmentID INT,@Name nvarchar(max),@BranchID INT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Department WHERE ID = @DepartmentID)
    BEGIN
        DECLARE @BranchException BIT = 0;

        -- Check BranchID
        IF EXISTS (SELECT 1 FROM Branch WHERE ID = @BranchID)
            SET @BranchException = 1;
        IF @BranchException = 0
            PRINT 'An error has occurred, the Branch ID does not exist in the Branch Table.';
        ELSE
            UPDATE Department
            SET name = @Name, BranchID = @BranchID
            WHERE ID = @DepartmentID;

        PRINT 'Department updated successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Department with ID ' + CAST(@DepartmentID AS nvarchar) + ' does not exist.';
    END
END;

EXEC DepartmentUpdate 1, 'Computer Science', 2;

GO


-- Delete from Department table
CREATE PROCEDURE DepartmentDelete( @DepartmentID INT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Department WHERE ID = @DepartmentID)
    BEGIN
        DELETE FROM Department WHERE ID = @DepartmentID;
        PRINT 'Department deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Department with ID ' + CAST(@DepartmentID AS nvarchar) + ' does not exist.';
    END
END;

EXEC DepartmentDelete 1;

GO

-- View all departments

CREATE VIEW DepartmentData
AS
SELECT * FROM Department;

GO

CREATE PROCEDURE ViewDepartments @DepartmentID INT = NULL ,@Name nvarchar(max) = NULL ,@BranchID INT = NULL
AS
BEGIN
    SELECT * FROM DepartmentData
	WHERE
	ID = COALESCE(@DepartmentID , ID) AND
	[Name] LIKE COALESCE ('%' + @Name + '%' , [Name]) AND
	BranchID = COALESCE ( @BranchID , BranchID )

END;

EXEC ViewDepartments;


-- Class Table
-- Insert

GO

CREATE PROCEDURE ClassInsert( @Name nvarchar(max) , @Floor int , @BranchID INT)
AS
BEGIN
    DECLARE @BranchException BIT = 0;

    -- Check BranchID
    IF EXISTS (SELECT 1 FROM Branch WHERE ID = @BranchID)
        SET @BranchException = 1;

    -- Perform conditions
    IF @BranchException = 0
        PRINT 'An error has occurred, the Branch ID does not exist in the Branch Table.';
    ELSE
		BEGIN
			INSERT INTO Class (name, floor, BranchID)
			VALUES (@Name, @Floor, @BranchID);
			PRINT 'Class inserted successfully.';
		END
END;

EXEC ClassInsert 'Room A', 1, 1;

GO

-- Update Class table
CREATE PROCEDURE ClassUpdate(@ClassID INT,@Name nvarchar(max),@Floor int,@BranchID INT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Class WHERE ID = @ClassID)
    BEGIN
        DECLARE @BranchException BIT = 0;

        -- Check BranchID
        IF EXISTS (SELECT 1 FROM Branch WHERE ID = @BranchID)
            SET @BranchException = 1;

        IF @BranchException = 0
            PRINT 'An error has occurred, the Branch ID does not exist in the Branch Table.';
        ELSE
            UPDATE Class
            SET name = @Name, floor = @Floor, BranchID = @BranchID
            WHERE ID = @ClassID;

        PRINT 'Class updated successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Class with ID ' + CAST(@ClassID AS nvarchar) + ' does not exist.';
    END
END;

EXEC ClassUpdate 1, 'Room B', 2, 2;


GO

-- Delete from Class table
CREATE PROCEDURE ClassDelete(@ClassID INT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Class WHERE ID = @ClassID)
    BEGIN
        DELETE FROM Class WHERE ID = @ClassID;
        PRINT 'Class deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Class with ID ' + CAST(@ClassID AS nvarchar) + ' does not exist.';
    END
END;

EXEC ClassDelete 1;

GO

-- View all classes

CREATE VIEW ClassData
AS SELECT * FROM Class

GO

CREATE PROCEDURE ViewClasses @ClassID INT = NULL ,@Name nvarchar(max) = NULL ,@Floor int = NULL , @BranchID INT = NULL
AS
BEGIN
    SELECT * FROM ClassData
	WHERE
	ID = COALESCE(@ClassID , ID) AND
	[Name] = COALESCE('%' + @Name + '%' , [Name] ) AND
	[Floor] = COALESCE(@Floor , [Floor]) AND
	BranchID = COALESCE(@BranchID , BranchID)
END;

EXEC ViewClasses;

-- Student_Answer Table

GO	
-- Insert & Update Student_Answer table
CREATE PROCEDURE ExamAnswer(@StudentExamID INT , @ExamQuestionsID INT , @Answer nvarchar(max))
AS
BEGIN

	DECLARE @QuestionDegree NUMERIC(5,2);
	DECLARE @QuestionID INT ;
	DECLARE @CorrectChoice INT;
	DECLARE @CurrentDegree NUMERIC(5,2);
	DECLARE @PrevAnswer INT;
	DECLARE @StudentID INT;
	SELECT @StudentID = StudentID FROM Student_Exam WHERE ID = @StudentExamID;
	DECLARE @CurrentStudentID INT;
	SELECT @CurrentStudentID = ID FROM Student WHERE Email = ORIGINAL_LOGIN();
	DECLARE @ExamID INT ;
	SELECT @ExamID = ExamID FROM Exam_Questions WHERE ID = @ExamQuestionsID;
	DECLARE @StartTime datetime ;
	SELECT @StartTime =	Start_Time FROM Exam WHERE ID = @ExamID;
	DECLARE @EndTime datetime ;
	SELECT @EndTime =	End_Time FROM Exam WHERE ID = @ExamID;
	IF @CurrentStudentID != @StudentID
		PRINT 'You are not authorized to answer this question as your ID does not match the authorized student'
	ELSE IF GETDATE() < @StartTime
		PRINT 'EXAM TIME HAS NOT STARTED'
	ELSE IF GETDATE() > @EndTime
		PRINT 'EXAM IS DONE'
    ELSE IF EXISTS (SELECT 1 FROM Student_Answer WHERE ExamQuestionID = @ExamQuestionsID AND StudentExamID = @StudentExamID)
		BEGIN

		
		SELECT @QuestionDegree = Degree FROM Exam_Questions WHERE ID = @ExamQuestionsID
		
		SELECT @QuestionID = QuestionID FROM Exam_Questions WHERE ID = @ExamQuestionsID
		
		SELECT @CorrectChoice = CorrectChoiceNumber FROM Question WHERE ID = @QuestionID
		
		SELECT @CurrentDegree = Degree FROM Student_Exam WHERE ID = @StudentExamID
		
		Select @PrevAnswer = Answer FROM Student_Answer WHERE ExamQuestionID = @ExamQuestionsID AND StudentExamID = @StudentExamID

		IF @Answer = @CorrectChoice AND @Answer != @PrevAnswer
			BEGIN
				SET @CurrentDegree = @CurrentDegree + @QuestionDegree
				UPDATE Student_Exam SET Degree = @CurrentDegree WHERE ID = @StudentExamID;
			END
		ELSE IF @Answer != @CorrectChoice AND @PrevAnswer = @CorrectChoice
			BEGIN
				SET @CurrentDegree = @CurrentDegree - @QuestionDegree
				UPDATE Student_Exam SET Degree = @CurrentDegree WHERE ID = @StudentExamID;
			END
        UPDATE Student_Answer
        SET Answer = @Answer
        WHERE ExamQuestionID = @ExamQuestionsID AND StudentExamID = @StudentExamID;


        END
    ELSE
    BEGIN
         DECLARE @ExamQuestionException BIT = 0;
		 DECLARE @StudentExamException BIT = 0;

		-- Check ExamQuestionsID
		IF EXISTS (SELECT 1 FROM Exam_Questions WHERE ID = @ExamQuestionsID)
			SET @ExamQuestionException = 1;

    -- Check StudentExamID
		IF EXISTS (SELECT 1 FROM Student_Exam WHERE ID = @StudentExamID)
			SET @StudentExamException = 1;


    -- Perform conditions
    IF @ExamQuestionException = 0
        PRINT 'An error has occurred, the ExamQuestionsID does not exist in the ExamQuestions Table.';
    ELSE IF @StudentExamException = 0
        PRINT 'An error has occurred, the StudentExamID does not exist in the StudentExam Table.';
    ELSE
        BEGIN
			SELECT @QuestionDegree = Degree FROM Exam_Questions WHERE ID = @ExamQuestionsID
			
			SELECT @QuestionID = QuestionID FROM Exam_Questions WHERE ID = @ExamQuestionsID
			
			SELECT @CorrectChoice = CorrectChoiceNumber FROM Question WHERE ID = @QuestionID
			
			SELECT @CurrentDegree = Degree FROM Student_Exam WHERE ID = @StudentExamID

			IF @CurrentDegree = NULL
				SET @CurrentDegree = 0;
			
			Select @PrevAnswer = Answer FROM Student_Answer WHERE ExamQuestionID = @ExamQuestionsID AND StudentExamID = @StudentExamID

			IF @Answer = @CorrectChoice
				SET @CurrentDegree = @CurrentDegree + @QuestionDegree;

			UPDATE Student_Exam SET Degree = @CurrentDegree WHERE ID = @StudentExamID;
			INSERT INTO Student_Answer VALUES (@ExamQuestionsID , @StudentExamID , @Answer)
		END
    END
END;


EXEC ExamAnswer 1, 1, 'Option B';

GO

CREATE VIEW StudentAnswer
AS
SELECT * FROM Student_Answer

GO

-- View all Student Answers
CREATE PROCEDURE ViewStudentAnswers @ExamQuestionID INT = NULL , @StudentExamID INT = NULL
AS
BEGIN
    SELECT * FROM StudentAnswer
	WHERE
	ExamQuestionID = COALESCE(@ExamQuestionID , ExamQuestionID) AND
	StudentExamID = COALESCE(@StudentExamID , StudentExamID)
	
END;

EXEC ViewStudentAnswers;
