
--Exam Table 

-- Insert Exam
ALTER PROCEDURE ExamInsert @Title nvarchar(300) , @Type nvarchar(100) , @Start_Time datetime , @End_Time datetime , @Year int, @CourseID int
AS
BEGIN
	declare @CourseException bit = 0;
	declare @InstructorException bit = 0;
	declare @TimeException bit = 0;
	declare @Total_TimeHours numeric(3,2);
	declare @YearException bit = 0;
	declare @TypeException bit = 0;
	declare @ClassInsException bit = 0;
	DECLARE @InstructorID INT;
	SELECT  @InstructorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();

	set @Total_TimeHours = DATEDIFF(HOUR, @Start_Time , @End_Time);

	IF EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CourseID AND InstructorID = @InstructorID )
		SET @ClassInsException = 1; -- If the Instructor teaches the Course he entered , set the Exception flag to 1 , this ensures that only the Instructor who teaches this course can add to the question pool


	if Year(@Start_Time) = Year(@End_Time) AND Year(@Start_Time) = @Year
		set @YearException = 1;

	if exists(select * from Course where Course.ID = @CourseID)
		set @CourseException = 1; -- If the Course exists, set the exception flag to 1

	if exists(select * from Instructor where Instructor.ID = @InstructorID  )
		set @InstructorException = 1; -- If the Instructor exists, set the exception flag to 1

	IF @Start_Time >= @End_Time
		set @TimeException = 1; -- check if Start_Time is less than End_Time

	if @Type != 'Normal' AND @Type != 'Corrective'
		set @TypeException = 1

	if @CourseException = 0
		print 'An error has occured, the Course ID you entered does not exist in Course Table'
	ELSE IF @ClassInsException = 0
		print 'An Error has occured, you are not authorized to add this question to this course since you do not teach it'
	else if @InstructorException = 0
		print 'An error has occured, the Instructor ID you entered does not exist in Instructor Table'
	else if @TimeException = 1
		print 'An error has occured, Start_Time must be less than End_Time.'
	else if @YearException = 0
		print 'An error has occured, The year on Start Time , End Time and Year Variables must be the same'
	else if @TypeException = 1
		print 'An error has occured, you cannot insert a type that is not Normal OR Corrective'
	else if not @Title <> ''
		print 'An error has occured, you cannot insert a Title that is empty';
	else if not @Type <> ''
		print 'An error has occured, you cannot insert a Type that is empty';
	else
		insert into Exam values (@Title , @Type , @Start_Time , @End_Time , @Total_TimeHours , @Year , @CourseID , @InstructorID);

END;

EXEC ExamInsert 'OOP Exam' , 'multiple' , '2024-1-20' , '2024-1-25' , 3 , 1 , 2 ;

go

-- Update Exam
ALTER PROCEDURE ExamUpdate @ID int, @Title nvarchar(300) , @Type nvarchar(100) , @Start_Time datetime , @End_Time datetime , @Year int, @CourseID int
AS
BEGIN
	declare @CourseException bit = 0;
	declare @InstructorException bit = 0;
	declare @TimeException bit = 0;
	declare @Total_TimeHours numeric(3,2);
	declare @YearException bit = 0;
	declare @TypeException bit = 0;
	declare @ClassInsException bit = 0;
	DECLARE @InstructorID INT;
	SELECT  @InstructorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();

	set @Total_TimeHours = DATEDIFF(HOUR, @Start_Time , @End_Time);

	IF EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CourseID AND InstructorID = @InstructorID )
		SET @ClassInsException = 1; -- If the Instructor teaches the Course he entered , set the Exception flag to 1 , this ensures that only the Instructor who teaches this course can add to the question pool


	if Year(@Start_Time) = Year(@End_Time) AND Year(@Start_Time) = @Year
		set @YearException = 1;

	if exists(select * from Course where Course.ID = @CourseID)
		set @CourseException = 1; -- If the Course exists, set the exception flag to 1

	if exists(select * from Instructor where Instructor.ID = @InstructorID  )
		set @InstructorException = 1; -- If the Instructor exists, set the exception flag to 1

	IF @Start_Time >= @End_Time
		set @TimeException = 1; -- check if Start_Time is less than End_Time

	if @Type != 'Normal' AND @Type != 'Corrective'
		set @TypeException = 1

	if not exists( select * from Exam where ID = @ID )
		print 'An error has occured, the Exam ID you entered does not exist'
	ELSE IF @ClassInsException = 0
		print 'An Error has occured, you are not authorized to update this question to this course since you do not teach it'
	else if @CourseException = 0
		print 'An error has occured, the Course ID you entered does not exist in Course Table'
	else if @InstructorException = 0
		print 'An error has occured, the Instructor ID you entered does not exist in Instructor Table'
	else if @TimeException = 1
		print 'An error has occured, Start_Time must be less than End_Time.'
	else if @YearException = 0
		print 'An error has occured, The year on Start Time , End Time and Year Variables must be the same'
	else if @TypeException = 1
		print 'An error has occured, you cannot insert a type that is not Normal OR Corrective'
	else if not @Title <> ''
		print 'An error has occured, you cannot insert a Title that is empty';
	else if not @Type <> ''
		print 'An error has occured, you cannot insert a Type that is empty';
	else IF EXISTS (SELECT 1 FROM Exam WHERE ID = @ID)
    BEGIN
        UPDATE Exam
        SET
            title = @Title,
            [type] = @Type,
            start_time = @Start_Time,
            end_time = @End_Time,
            [year] = @Year,
			CourseID = @CourseID,
			InstructorID = @InstructorID
        WHERE
            ID = @ID;

        PRINT 'Exam updated successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Exam with ID ' + CAST(@ID AS nvarchar) + ' does not exist.';
    END
END;

EXEC ExamUpdate 1, 'SQL Exam', 'true and false', '2024-1-22', '2024-1-25' , 5 , 1 , 2;

GO

-- Delete Exam
ALTER PROCEDURE ExamDelete @ID int
AS
BEGIN 
	DECLARE @IDException BIT = 0;
	DECLARE @ClassInsException BIT = 0;
	DECLARE @CourseID INT;
	DECLARE @InstuctorID INT;
	SELECT  @InstuctorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();
	SELECT @CourseID = CourseID FROM Exam WHERE ID = @ID;


	if exists(select * from Exam where Exam.ID = @ID)
		set @IDException = 1; -- If the Exam exists, set the exception flag to 1

	IF EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CourseID AND InstructorID = @InstuctorID )
		SET @ClassInsException = 1; -- If the Instructor teaches the Course he entered , set the Exception flag to 1 , this ensures that only the Instructor who teaches this course can add to the question pool



	if @IDException = 0
		print 'An error has occured, The Exam ID you entered does not exist in Exam Table'
	ELSE IF @ClassInsException = 0
		print 'An Error has occured, you are not authorized to delete this question to this course since you do not teach it'
	else
		DELETE FROM Exam WHERE ID = @ID;

END;

EXEC ExamDelete 1

GO

-- Read Exam
CREATE VIEW ExamData AS SELECT * FROM Exam;

GO

ALTER PROCEDURE ReadExam @ID int = NULL,@Title nvarchar(300) = NULL, @Type nvarchar(100) = NULL, @Start_Time datetime = NULL, @End_Time datetime = NULL, @Year int = NULL, @CourseID int = NULL, @InstructorID int = NULL
AS
BEGIN 
	SELECT * FROM ExamData 
	WHERE ID = COALESCE( @ID , ID) AND 
	Title LIKE COALESCE( '%' + @Title + '%' , Title ) AND
	[Type] = COALESCE( @Type , [Type] ) AND
	Start_Time = COALESCE( @Start_Time , Start_Time ) AND
	End_Time = COALESCE( @End_Time , End_Time ) AND
	[Year] = COALESCE( @Year , [Year] ) AND
	CourseID = COALESCE( @CourseID , CourseID ) AND
	InstructorID = COALESCE( @InstructorID , InstructorID );
END;

EXEC ReadExam
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- select top 10 * from Student order by newid()
--Exam_Question Table

-- Insert Exam_Questions
ALTER PROCEDURE Exam_QuestionsInsert @Mode NVARCHAR(100) , @ExamID int , @QuestionID int = null , @Degree numeric(5,2) = null 
AS
BEGIN
	
	DECLARE @CoursesID INT ;
	SELECT @CoursesID = CourseID FROM Exam WHERE ID = @ExamID 

	DECLARE @InstuctorID INT;
	SELECT  @InstuctorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();

	IF NOT EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CoursesID AND InstructorID = @InstuctorID )
		PRINT 'You are not authorized to add question to this exam'
	ELSE IF @Mode != 'Auto' AND @Mode != 'Manual'
		print 'You can only choose Auto or Manual Mode'
	ELSE IF NOT EXISTS(SELECT * FROM Exam WHERE ID = @ExamID)
		PRINT 'The exam ID you entered is does not exist'
	ELSE IF @Mode = 'Auto' AND EXISTS (SELECT * FROM Exam_Questions WHERE ExamID = @ExamID)
		PRINT 'You cannot use Auto Mode since there are already questions in the exam'
	ELSE IF @Mode = 'Auto' AND NOT EXISTS (SELECT * FROM Exam_Questions WHERE ExamID = @ExamID)
		BEGIN
			declare @CourseID int;
			select @CourseID = Exam.CourseID from Exam where Exam.ID = @ExamID;
			declare @QuestionCount int;
			declare @UniDegree numeric(5,2);
			declare @counter int = 0;

			select @UniDegree = Max_Degree from Course where ID = @CourseID;

			set @UniDegree = @UniDegree / 10 ;

			select @QuestionCount = count(*) from Question where CourseID = @CourseID;

			if @QuestionCount < 10
				print 'This operation cannot be done in Auto Mode because not enough questions exist for this course'
			else
				while @counter < 10
					begin
						insert into Exam_Questions values ((select top 1 ID from Question where ID not in (select QuestionID from Exam_Questions where ExamID = @ExamID ) order by NEWID()) , @ExamID , @UniDegree)
					end
				
		END

	ELSE IF (SELECT COUNT(*) FROM Exam_Questions WHERE ExamID = @ExamID) >= 10
		PRINT 'An error has occured, the exam you are trying to add to has already reached its max limit of 10 Questions'
	ELSE IF @Degree = null or @QuestionID = null or @Degree <= 0
		print 'An error has occured, none of Degree and Question ID can be null AND degree cannot be equal or lower than 0 '
	ELSE
		BEGIN
			declare @QuestionException bit = 0;
			declare @ExamException bit = 0;


			if exists(select * from Question where Question.ID = @QuestionID)
				set @QuestionException = 1; -- If the Question exists, set the exception flag to 1

			if exists(select * from Exam where Exam.ID = @ExamID  )
				set @ExamException = 1; -- If the Exam exists, set the exception flag to 1


			if @QuestionException = 0
				print 'An error has occured, the Question ID you entered does not exist in Question Table'
			else if @ExamException = 0
				print 'An error has occured, the Exam ID you entered does not exist in Exam Table'
			else
				insert into Exam_Questions values (@QuestionID , @ExamID , @Degree);
	END
END;

EXEC Exam_QuestionsInsert 1, 1 , 50;

go

-- Update Exam_Questions
ALTER PROCEDURE Exam_QuestionsUpdate @ID int, @QuestionID int , @ExamID int , @Degree numeric(5,2) 
AS
BEGIN

	DECLARE @CoursesID INT ;
	SELECT @CoursesID = CourseID FROM Exam WHERE ID = @ExamID 

	DECLARE @InstuctorID INT;
	SELECT  @InstuctorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();

	IF NOT EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CoursesID AND InstructorID = @InstuctorID )
		PRINT 'You are not authorized to update this question from this exam'
	ELSE IF EXISTS (SELECT 1 FROM Exam_Questions WHERE ID = @ID)
		BEGIN
			declare @QuestionException bit = 0;
			declare @ExamException bit = 0;



			if exists(select * from Question where Question.ID = @QuestionID)
				set @QuestionException = 1; -- If the Question exists, set the exception flag to 1

			if exists(select * from Exam where Exam.ID = @ExamID  )
				set @ExamException = 1; -- If the Exam exists, set the exception flag to 1


			if @QuestionException = 0
				print 'An error has occured, the Question ID you entered does not exist in Question Table'
			else if @ExamException = 0
				print 'An error has occured, the Exam ID you entered does not exist in Exam Table'
			else if @Degree <= 0
				print 'An error has occured, the Degree you entered cannot be equal or lower than zero'
			else
				UPDATE Exam_Questions SET QuestionID = @QuestionID , ExamID = @ExamID , Degree = @Degree WHERE ID = @ID;
		END
    ELSE
    BEGIN
        PRINT 'Exam_Questions with ID ' + CAST(@ID AS nvarchar) + ' does not exist.';
    END
END;

EXEC Exam_QuestionsUpdate 1, 2, 2, 45;

GO

-- Delete Exam_Questions
ALTER PROCEDURE Exam_QuestionsDelete @ID int
AS
BEGIN 
	DECLARE @IDException BIT = 0;


	if exists(select * from Exam_Questions where Exam_Questions.ID = @ID)
		set @IDException = 1; -- If the Exam_Questions exists, set the exception flag to 1


	DECLARE @CoursesID INT ;
	DECLARE @ExamID INT;
	SELECT @ExamID = ExamID FROM Exam_Questions WHERE ID = @ID
	SELECT @CoursesID = CourseID FROM Exam WHERE ID = @ExamID 

	DECLARE @InstuctorID INT;
	SELECT  @InstuctorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();

	IF NOT EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CoursesID AND InstructorID = @InstuctorID )
		PRINT 'You are not authorized to delete this question from the exam'
	ELSE if @IDException = 0
		print 'An error has occured, The Exam_Questions ID you entered does not exist in Exam_Questions Table'
	else
		DELETE FROM Exam_Questions WHERE ID = @ID;

END;

EXEC Exam_QuestionsDelete 1

GO

-- Read Exam_Questions
CREATE VIEW Exam_QuestionsData 
AS
SELECT 
    eq.ExamID , q.ID, q.[Type], q.Body, 
    MAX(CASE WHEN qc.ChoiceNumber = 1 THEN qc.Choice END) as 'Choice 1',
    MAX(CASE WHEN qc.ChoiceNumber = 2 THEN qc.Choice END) as 'Choice 2',
    MAX(CASE WHEN qc.ChoiceNumber = 3 THEN qc.Choice END) as 'Choice 3',
    MAX(CASE WHEN qc.ChoiceNumber = 4 THEN qc.Choice END) as 'Choice 4',
    q.CorrectChoiceNumber as 'Correct Choice Number',
	eq.Degree
    
FROM 
    Question q 
INNER JOIN 
    Question_Choices qc ON q.ID = qc.QuestionID 
INNER JOIN
	Exam_Questions eq ON q.ID = eq.QuestionID
INNER JOIN
	Exam E ON EQ.ExamID = E.ID
GROUP BY 
    q.ID, q.[Type], q.Body, q.CorrectChoiceNumber , q.CourseID, q.InstructorID , eq.Degree , eq.ExamID;


GO

CREATE PROCEDURE ReadExam_Questions @ExamID int
AS
BEGIN 
	SELECT * FROM Exam_QuestionsData 
	WHERE ExamID = @ExamID
END;

EXEC ReadExam_Questions 1;
GO


----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Student_Exam Table

-- Insert Student_Exam
ALTER PROCEDURE Student_ExamInsert @StudentID int , @ExamID int
AS
BEGIN
	declare @StudentException bit = 0;
	declare @ExamException bit = 0;
	DECLARE @InstuctorID INT;
	SELECT  @InstuctorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();
	declare @MaxDegree numeric(5,2);
	declare @MinDegree numeric(5,2);
	declare @CourseID INT ;
	select @CourseID = CourseID from Exam where ID = @ExamID
	select @MaxDegree = Max_Degree from Course where ID = @CourseID
	select @MinDegree = Min_Degree from Course where ID = @CourseID

	if exists(select * from Student where Student.ID = @StudentID)
		set @StudentException = 1; -- If the Student exists, set the exception flag to 1

	if exists(select * from Exam where Exam.ID = @ExamID  )
		set @ExamException = 1; -- If the Exam exists, set the exception flag to 1



	if @StudentException = 0
		print 'An error has occured, the Student ID you entered does not exist in Student Table'
	else if @ExamException = 0
		print 'An error has occured, the Exam ID you entered does not exist in Exam Table'
	else if (select count(*) from Exam_Questions where ExamID = @ExamID) != 10
		print 'An error has occured, you cannot assign this exam since the exam does not contain 10 questions'
	else if (select sum(Degree) from Exam_Questions where ExamID = @ExamID) < @MinDegree
		print 'An error has occured, you cannot assign this exam since the questions degree in the exam does not exceed the miniumn Degree for passing'
	else if (select sum(Degree) from Exam_Questions where ExamID = @ExamID) > @MaxDegree
		print 'An error has occured, you cannot assign this exam since the questions degree in the exam does exceed the maximum Degree'
	else if not EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CourseID AND InstructorID = @InstuctorID )
		print 'An error has occured, you are not authorized to assign students to this exam'
	else
		insert into Student_Exam values (@StudentID , @ExamID , NULL);

END;

EXEC Student_ExamInsert 1, 1 , 50;

go

-- Update Student_Exam
ALTER PROCEDURE Student_ExamUpdate @ID int, @StudentID int , @ExamID int
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Student_Exam WHERE ID = @ID)
    BEGIN
        declare @StudentException bit = 0;
		declare @ExamException bit = 0;
		DECLARE @InstuctorID INT;
		SELECT  @InstuctorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();
		declare @MaxDegree numeric(5,2);
		declare @MinDegree numeric(5,2);
		declare @CourseID INT ;
		select @CourseID = CourseID from Exam where ID = @ExamID
		select @MaxDegree = Max_Degree from Course where ID = @CourseID
		select @MinDegree = Min_Degree from Course where ID = @CourseID

		if exists(select * from Student where Student.ID = @StudentID)
			set @StudentException = 1; -- If the Student exists, set the exception flag to 1

		if exists(select * from Exam where Exam.ID = @ExamID  )
			set @ExamException = 1; -- If the Exam exists, set the exception flag to 1



		if @StudentException = 0
			print 'An error has occured, the Student ID you entered does not exist in Student Table'
		else if @ExamException = 0
			print 'An error has occured, the Exam ID you entered does not exist in Exam Table'
		else if (select count(*) from Exam_Questions where ExamID = @ExamID) != 10
			print 'An error has occured, you cannot assign this exam since the exam does not contain 10 questions'
		else if (select sum(Degree) from Exam_Questions where ExamID = @ExamID) < @MinDegree
			print 'An error has occured, you cannot assign this exam since the questions degree in the exam does not exceed the miniumn Degree for passing'
		else if (select sum(Degree) from Exam_Questions where ExamID = @ExamID) > @MaxDegree
			print 'An error has occured, you cannot assign this exam since the questions degree in the exam does exceed the maximum Degree'
		else if not EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CourseID AND InstructorID = @InstuctorID )
			print 'An error has occured, you are not authorized to assign students to this exam'
		else if (select Degree from Student_Exam where ID = @ID) = NULL
			PRINT 'An error has occured, this student is performing or already performed this game, you cannot modifiy his degree any longer'
		else
			UPDATE Student_Exam SET StudentID = @StudentID , ExamID = @ExamID WHERE ID = @ID;
	END
    ELSE
    BEGIN
        PRINT 'Student_Exam with ID ' + CAST(@ID AS nvarchar) + ' does not exist.';
    END
END;

EXEC Student_ExamUpdate 1, 2, 2, 45;

GO

-- Delete Student_Exam
ALTER PROCEDURE Student_ExamDelete @ID int
AS
BEGIN 
	DECLARE @IDException BIT = 0;
	DECLARE @InstuctorID INT;
	SELECT  @InstuctorID = ID FROM Instructor WHERE Email = ORIGINAL_LOGIN();
	declare @CourseID INT ;
	DECLARE @ExamID INT ;
	SELECT @ExamID = ExamID FROM Student_Exam WHERE ID = @ID 
	select @CourseID = CourseID from Exam where ID = @ExamID

	if exists(select * from Student_Exam where Student_Exam.ID = @ID)
		set @IDException = 1; -- If the Student_Exam exists, set the exception flag to 1


	IF NOT EXISTS(SELECT * FROM Teaches_At WHERE CourseID = @CourseID AND InstructorID = @InstuctorID )
		PRINT 'You are not authorized to delete this Student from the exam'
	ELSE if @IDException = 0
		print 'An error has occured, The Student_Exam ID you entered does not exist in Student_Exam Table'
	else
		DELETE FROM Student_Exam WHERE ID = @ID;

END;

EXEC Student_ExamDelete 1

GO

-- Read Student_Exam
CREATE VIEW Student_ExamData 
AS
SELECT SE.ID , SE.ExamID , SE.StudentID , S.[Name] , E.title , E.[Type] , E.Start_Time , E.Total_Time , SE.Degree
FROM 
Student_Exam SE INNER JOIN Exam E ON E.ID = SE.ExamID
INNER JOIN Student S ON SE.StudentID = S.ID;

GO

CREATE PROCEDURE ReadStudent_Exam @ID int = NULL,@StudentID int = NULL, @ExamID int = NULL
AS
BEGIN 
	SELECT * FROM Student_ExamData 
	WHERE ID = COALESCE( @ID , ID) AND 
	StudentID = COALESCE( @StudentID , StudentID ) AND
	ExamID  = COALESCE( @ExamID  , ExamID  )
END;

GO

CREATE PROCEDURE CheckMyExams @ExamID int = NULL
AS
BEGIN 

	DECLARE @StudentID INT;
	SELECT @StudentID = ID FROM Student WHERE Email = ORIGINAL_LOGIN();
	SELECT * FROM Student_ExamData 
	WHERE
	StudentID = @StudentID AND
	ExamID  = COALESCE( @ExamID  , ExamID  )
END;

EXEC ReadStudent_Exam;
EXEC CheckMyExams;
GO



----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Track Table

-- Insert Track
CREATE PROCEDURE TrackInsert @Name nvarchar(300) , @Description nvarchar(max), @DepartmentID int
AS
BEGIN
	declare @DepartmentException bit = 0;

	
	if exists(select * from Department where Department.ID = @DepartmentID)
		set @DepartmentException = 1; -- If the Department exists, set the exception flag to 1

	if @DepartmentException = 0
		print 'An error has occured, the Department ID you entered does not exist in Department Table'
	else if not @Name <> ''
		print 'An error has occured, the Name you entered cannot be empty'
	else
		insert into Track values (@Name, @Description , @DepartmentID );

END;

EXEC TrackInsert '.net' , 'Description of Dept' , 1 ;

go

-- Update Track
CREATE PROCEDURE TrackUpdate @ID int, @Name nvarchar(100) ,  @Description nvarchar(max), @DepartmentID int 
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Track WHERE ID = @ID)
    BEGIN
        declare @DepartmentException bit = 0;

	
	if exists(select * from Department where Department.ID = @DepartmentID)
		set @DepartmentException = 1; -- If the Department exists, set the exception flag to 1

	if @DepartmentException = 0
		print 'An error has occured, the Department ID you entered does not exist in Department Table'
	else if not @Name <> ''
		print 'An error has occured, the Name you entered cannot be empty'
	else
		UPDATE Track SET [Name] = @Name, [Description] = @Description , DepartmentID = @DepartmentID WHERE ID = @ID;
    END
    ELSE
    BEGIN
        PRINT 'Track with ID ' + CAST(@ID AS nvarchar) + ' does not exist.';
    END
END;

EXEC TrackUpdate 1, 'php', 'Description of Dept' , 2;

GO

-- Delete Track
CREATE PROCEDURE TrackDelete @ID int
AS
BEGIN 
	DECLARE @IDException BIT = 0;


	if exists(select * from Track where Track.ID = @ID)
		set @IDException = 1; -- If the Track exists, set the exception flag to 1


	if @IDException = 0
		print 'An error has occured, The Track ID you entered does not exist in Track Table'
	else
		DELETE FROM Track WHERE ID = @ID;

END;

EXEC TrackDelete 1

GO

-- Read Track
CREATE VIEW TrackData AS SELECT * FROM Track;

GO

CREATE PROCEDURE ReadTrack @ID int = NULL, @Name nvarchar(100) = NULL ,@Description nvarchar(max) = NULL, @DepartmentID int = NULL 
AS
BEGIN 
	SELECT * FROM TrackData 
	WHERE ID = COALESCE( @ID , ID) AND 
	[Name] = COALESCE( @Name , [Name] ) AND
	[Description] = COALESCE( @Description , [Description] ) AND
	DepartmentID = COALESCE( @DepartmentID  , DepartmentID );
END;

EXEC ReadTrack
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Course Table

-- Insert Course
CREATE PROCEDURE CourseInsert @Name nvarchar(100) , @Description nvarchar(max), @Max_Degree numeric(5,2), @Min_Degree numeric(5,2)
AS
BEGIN
	declare @DegreeException  bit = 0;

	IF @Max_Degree >= @Min_Degree
		set @DegreeException = 1; -- check if Max_Degree is less than Min_Degree


	if @DegreeException = 1
		print 'Max_Degree must be less than Min_Degree.'
	else if @Max_Degree <=0 OR @Min_Degree < 0
		print 'Max Degree cannot be zero or less AND Min Degree cannot be less than zero' 
	else if not @Name <> ''
		print 'Name cannot be empty'
	else
		insert into Course values (@Name , @Description , @Max_Degree , @Min_Degree );

END;

EXEC CourseInsert 'Java Script' , 'Description of Course' , 50, 25;

go

-- Update Course
CREATE PROCEDURE CourseUpdate @ID int, @Name nvarchar(100) ,  @Description nvarchar(max), @Max_Degree numeric(5,2), @Min_Degree numeric(5,2) 
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Course WHERE ID = @ID)
    BEGIN
        declare @DegreeException  bit = 0;

	IF @Max_Degree >= @Min_Degree
		set @DegreeException = 1; -- check if Max_Degree is less than Min_Degree


	if @DegreeException = 1
		print 'Max_Degree must be less than Min_Degree.'
	else if @Max_Degree <=0 OR @Min_Degree < 0
		print 'Max Degree cannot be zero or less AND Min Degree cannot be less than zero' 
	else if not @Name <> ''
		print 'Name cannot be empty'
	else
		UPDATE Course SET [Name] = @Name , [Description] = @Description , Max_Degree = @Max_Degree , Min_Degree = @Min_Degree WHERE ID = @ID;
    END
    ELSE
    BEGIN
        PRINT 'Course with ID ' + CAST(@ID AS nvarchar) + ' does not exist.';
    END
END;

EXEC CourseUpdate 1, 'Html', 'Description of Course' , 30 , 15;

GO

-- Delete Course
CREATE PROCEDURE CourseDelete @ID int
AS
BEGIN 
	DECLARE @IDException BIT = 0;


	if exists(select * from Course where Course.ID = @ID)
		set @IDException = 1; -- If the Course exists, set the exception flag to 1


	if @IDException = 0
		print 'An error has occured, The Course ID you entered does not exist in Course Table'
	else
		DELETE FROM Course WHERE ID = @ID;

END;

EXEC CourseDelete 1

GO

-- Read Course
CREATE VIEW CourseData AS SELECT * FROM Course;

GO

CREATE PROCEDURE ReadCourse @ID int = NULL, @Name nvarchar(100) = NULL ,@Description nvarchar(max) = NULL
AS
BEGIN 
	SELECT * FROM CourseData 
	WHERE ID = COALESCE( @ID , ID) AND 
	[Name] = COALESCE( @Name , [Name] ) AND
	[Description] = COALESCE( @Description , [Description] )
END;

EXEC ReadCourse;
GO



----------------------------------------------------------------------------------------------------------------------------------------------------------------------
