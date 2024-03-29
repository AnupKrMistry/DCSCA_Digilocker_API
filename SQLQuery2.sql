USE [SmartePDS_03112023_2]
GO
/****** Object:  StoredProcedure [Apix].[SP_DigiLockerRCDetails]    Script Date: 01-01-2024 12:47:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Apix].[SP_DigiLockerRCDetails]
	@RationCardNo VARCHAR(20),
	@AadhaarNo VARCHAR(100)
	
AS
BEGIN
	
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @Adhno VARBINARY(MAX) = CONVERT(VARBINARY(MAX), '0x' + @AadhaarNo);
--SELECT * FROM FIC.MemberDetail WHERE HASHBYTES('MD5', AadhaarNo) =@AadhaarNo
	

	--DECLARE @n INT = (SELECT TOP 1 RationCardId FROM FIC.MemberDetail WHERE SUBSTRING(HASHBYTES('MD5', AadhaarNo), 3, LEN(HASHBYTES('MD5', AadhaarNo))) = @AadhaarNo);
	--DECLARE @mRCNo VARCHAR(50) = (SELECT TOP 1 ManualRCNo FROM FIC.RationCard WHERE RationCardId = @n);
	DECLARE @mRCNo VARCHAR(50) = (SELECT TOP 1 RationCardId FROM FIC.RationCard WHERE ManualRCNo = @RationCardNo);
	DECLARE @n INT = (SELECT count(*) FROM view_digilocker WHERE RationCardId = @mRCNo and  AadhaarNo = CONVERT(VARBINARY(MAX), '0x' + @AadhaarNo , 1));
	--DECLARE @n INT = (
 --   SELECT COUNT(*)
 --   FROM FIC.MemberDetail
 --   WHERE RationCardId = @mRCNo
 --   AND HASHBYTES('MD5', AadhaarNo) = CONVERT(VARBINARY(32), '0x' + @AadhaarNo, 1));


	IF (@mRCNo IS NULL)
	BEGIN
	   SELECT 'Ration Card Not Found' ;
	   RETURN 0;
	END

	IF (@n <= 0)
	BEGIN
	   SELECT  @n;
	  RETURN 'Member Not Found';
	END

	IF(@n >= 1)
	begin
		Select 
			 M.NameEnglish As member_name
			 ,CASE
				WHEN M.MaritalStatusMCId = 70 AND M.GenderMCId = 32 THEN M.SpouseName
				ELSE M.FatherName
			END AS FatherSpouseName
		   ,RS.NameEnglish As relationship
		   ,(DATEDIFF(YEAR,M.DOB,GETDATE())) As Age
		   ,LEFT(G.NameEnglish, 1)  As  gender
		   , CASE
				WHEN RS.Code = '1' THEN 'I'--'Self'
				WHEN RS.Code = '4' THEN 'M'--'Mother'
				WHEN RS.Code = '5' THEN 'F'--'Father'
				WHEN RS.Code = '7' THEN 'H'--'Husband'
				WHEN RS.Code = '6' THEN 'W'--'Wife'
				WHEN RS.Code = '8' THEN 'S'--'Son'
				WHEN RS.Code = '9' THEN 'D'--'Daughter'
				ELSE 'O'
			END AS RelationShipPfx
			,CASE
				WHEN M.MaritalStatusMCId = '69' THEN '1'--'Unmarried'
				WHEN M.MaritalStatusMCId = '70' THEN '2'--'Married'
				WHEN M.MaritalStatusMCId = '71' THEN '3'--'Widow / Widower'
				WHEN M.MaritalStatusMCId = '72' THEN '4'--'Divorced'
				WHEN M.MaritalStatusMCId = '73' THEN '5'--'Separated'
				ELSE ''
			END AS MaritalStatus
		    ,G.NameEnglish As  gender
		    ,Convert(nvarchar,M.DOB,34) As dob
			,iif(len(Isnull(M.MobileNo,''))=10,M.MobileNo,'') As mobile_no
			,iif(len(Isnull(M.AadhaarNo, '')) = 12, M.AadhaarNo,'') as AadhaarNo
			
			,Adr.HouseNo as HouseNo,
			Adr.Locality as Locality,
			Adr.VillageTown as VillageTown,
			Adr.Tehsil as Tehsil,
			Adr.DistrictEnglish as District,
			ISNULL(Adr.Pincode, '') as Pincode,
			iif(HASHBYTES('MD5', CONVERT(VARCHAR(MAX), M.AadhaarNo)) = CONVERT(VARBINARY(MAX), '0x' + @AadhaarNo , 1),1,0) as IssueTo
			From FIC.RationCard R
				Left outer join FIC.MemberDetail M on M.RationCardId=R.RationCardId 
				Left outer join [Master].MastersCollection G on G.MastersCollectionId=M.GenderMCId
				Left outer join [Master].MastersCollection RS on RS.MastersCollectionId=M.RelationHOFMCId
				INNER JOIN [Common].[AddressView] Adr ON Adr.BPId = R.BPId AND Adr.DocId = R.RationCardId AND Adr.AddressTypePropId = 112
		Where 
				  R.ManualRCNo = @RationCardNo
			  and R.RationCardId in (Select A.RationcardId from FIC.ActiveFIC A)
			  and R.FPSId in (Select F.FPSUniqueId from Report.FPSView F)
		order by 
		M.SrNo,
		R.ManualRCNo
	END

END


--select HASHBYTES('MD5', CONVERT(VARCHAR(36), '885522702266'))

--Select * from [Master].MastersCollection where BusinessProcessId = 1028