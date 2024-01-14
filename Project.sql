create table Intake 
(
	ID int primary key identity(1,1) ,
	[Name] nvarchar(100) not null ,
	Start_Time date not null ,
	End_Time date not null,
	check (Start_Time <  End_Time)
)

create table Branch
(
	ID int primary key identity(1,1) ,
	[Name] nvarchar(100) not null ,
	[Location] nvarchar(100) not null,
)

create table Department
(
	ID int primary key identity(1,1),
	[Name] nvarchar(100) not null,
	BranchID int not null,
	constraint fk_branch foreign key (BranchID) references Branch(ID)
)

create table Track
(
	ID int primary key identity(1,1),
	[Name] nvarchar(100) not null,
	[Description] nvarchar(max) ,
	DepartmentID int not null,
	constraint fk_department foreign key (DepartmentID) references Department(ID)
)

create table Class
(
	ID int primary key identity(1,1),
	[Name] nvarchar(100) not null,
	[Floor] int not null,
	BranchID int not null,
	constraint fk_ClassBranch foreign key (BranchID) references Branch(ID)
)

create table Student
(
	ID int primary key identity(1,1),
	[Name] nvarchar(max) not null,
	Email nvarchar(450) collate SQL_Latin1_General_CP1_CI_AS not null,
	DOB date not null,
	IntakeID int not null,
	TrackID int not null,
	ClassID int not null,
	constraint fk_StudentIntake foreign key (IntakeID) references Intake(ID),
	constraint fk_StudentTrack foreign key (TrackID) references Track(ID),
	constraint fk_StudentClass foreign key (ClassID) references Class(ID),
	constraint uq_Email unique (Email)
)

create table Instructor
(
	ID int primary key identity(1,1),
	[Name] nvarchar(300) not null,
	title nvarchar(300) not null,
	Email nvarchar(450) collate SQL_Latin1_General_CP1_CI_AS not null,
	DOB date not null ,
	Salary numeric(10,2) not null,
	constraint uq_InstructorEmail unique (Email)
)

create table Course
(
	ID int primary key identity(1,1),
	[Name] nvarchar(300) not null,
	[Description] nvarchar(max) ,
	Max_Degree numeric(5,2) not null default 100,
	Min_Degree numeric(5,2) not null default 40,
	check(Max_Degree > Min_Degree)
)

create table Question
(
	ID int primary key identity(1,1),
	Body nvarchar(max) not null,
	[Type] nvarchar(100) not null,
	CorrectChoiceNumber int ,
	CourseID int not null,
	InstructorID int not null,
	constraint fk_CourseQuestion foreign key (CourseID) references Course(ID),
	constraint fk_InstructorQuestion foreign key (InstructorID) references Instructor(ID),
	check(CorrectChoiceNumber = 1 or CorrectChoiceNumber = 2 or CorrectChoiceNumber = 3 or CorrectChoiceNumber = 4 ),
	check([Type] = 'Multiple' or [Type] = 'Bool' or [Type] = 'Text')
)

create table Question_Choices
(
	QuestionID int not null,
	ChoiceNumber int not null,
	Choice nvarchar(450) not null,
	constraint fk_QuestionChoice foreign key (QuestionID) references Question(ID),
	constraint pk_QuestionChoices primary key (QuestionID , ChoiceNumber),
	check(ChoiceNumber = 1 or ChoiceNumber = 2 or ChoiceNumber = 3 or ChoiceNumber = 4 )
)

create table Exam
(
	ID int primary key identity(1,1),
	title nvarchar(300) not null,
	[Type] nvarchar(100) not null,
	Start_Time date not null ,
	End_Time date not null,
	Total_Time numeric(3,2),
	[Year] int not null,
	CourseID int not null,
	InstructorID int not null,
	constraint fk_CourseExam foreign key (CourseID) references Course(ID),
	constraint fk_InstructorExam foreign key (InstructorID) references Instructor(ID),
	check (Start_Time <  End_Time)
)

create table Teaches_At
(
	CourseID int not null,
	ClassID int not null,
	InstructorID int not null,
	constraint fk_Teaches_At_Course foreign key (CourseID) references Course(ID),
	constraint fk_Teaches_At_Instructor foreign key (InstructorID) references Instructor(ID),
	constraint fk_Teaches_At_Class foreign key (ClassID) references Class(ID),
	constraint pk_CourseClassInstructor primary key ( CourseID , ClassID )
)

create table Student_Exam
(
	ID int primary key identity(1,1),
	StudentID int not null ,
	ExamID int not null,
	Degree numeric(5,2),
	constraint fk_Student_Exam_ExamID foreign key (ExamID) references Exam(ID),
	constraint fk_Student_Exam_StudentID foreign key (StudentID) references Student(ID),
	check(Degree >= 0)
)

create table Exam_Questions
(
	ID int primary key identity(1,1),
	QuestionID int not null ,
	ExamID int not null,
	Degree numeric(5,2),
	constraint fk_Exam_Question_ExamID foreign key (ExamID) references Exam(ID),
	constraint fk_Exam_Question_QuestionID foreign key (QuestionID) references Question(ID),
	check(Degree >= 0)
)

create table Student_Answer
(
	ID int primary key identity(1,1),
	ExamQuestionID int not null,
	StudentExamID int not null,
	Answer nvarchar(max),
	constraint fk_Answer_ExamQuestion foreign key (ExamQuestionID) references Exam_Questions(ID),
	constraint fk_Answer_StudentExam foreign key (StudentExamID) references Student_Exam(ID)
)
