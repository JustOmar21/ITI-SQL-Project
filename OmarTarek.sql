CREATE PROCEDURE StudentInsert @Name nvarchar(max) , @Email nvarchar(450) , @DOB date , @IntakeID int , @TrackID int , @ClassID int
AS
BEGIN
	declare @TrackException bit = 0;
	declare @IntakeException bit = 0;
	declare @ClassException bit = 0;

	if exists(select * from Track where Track.ID = @TrackID)
		set @TrackException = 1;

	if exists(select * from Class where Class.ID = @ClassID)
		set @ClassException = 1;

	if exists(select * from Intake where Intake.ID = @IntakeID)
		set @IntakeException = 1;

	if @IntakeException = 0
		print 'An error has occured, the Intake ID you entered does not exist in Intake Table'
	else if @TrackException = 0
		print 'An error has occured, the Track ID you entered does not exist in Track Table'
	else if @ClassException = 0
		print 'An error has occured, the Class ID you entered does not exist in Class Table'
	else
		insert into Student values (@Name , @Email , @DOB , @IntakeID , @TrackID , @ClassID);

END;


EXEC StudentInsert 'Omar Tarek' , 'tarekes68@gmail.com' , '2001-6-12' , 2 , 1 , 1 ;
