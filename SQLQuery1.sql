USE [SmartePDS_03112023_2]
GO
/****** Object:  StoredProcedure [Apix].[SP_DigiLocker_RCHeaderFPSDetails]    Script Date: 01-01-2024 12:46:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Apix].[SP_DigiLocker_RCHeaderFPSDetails]
	@RationCardNo VARCHAR(12)
AS
BEGIN
	
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TOP 1
    R.ManualRCNo AS RationCardNo,
    CASE
        WHEN R.RCTypeMCId = '1' THEN 'APL'
        WHEN R.RCTypeMCId = '2' THEN 'PHH'
        WHEN R.RCTypeMCId = '3' THEN 'AAY'
        ELSE 'No RC Type'
    END AS RCType,
	M.AadhaarNo as AadhaarNo,
    R.ApplicantName AS HOF,
	Convert(nvarchar,M.DOB,34) As DOB,
	(DATEDIFF(YEAR,M.DOB,GETDATE())) As Age,
	 CASE
        WHEN M.GenderMCId = '31' THEN 'M'--'Male'
        WHEN M.GenderMCId = '32' THEN 'F'--'Female'
        WHEN M.GenderMCId = '33' THEN 'T'--'Transgender'
        ELSE ''
    END AS Gender,
	CASE
        WHEN M.MaritalStatusMCId = '69' THEN '1'--'Unmarried'
		WHEN M.MaritalStatusMCId = '70' THEN '2'--'Married'
		WHEN M.MaritalStatusMCId = '71' THEN '3'--'Widow / Widower'
		WHEN M.MaritalStatusMCId = '72' THEN '4'--'Divorced'
		WHEN M.MaritalStatusMCId = '73' THEN '5'--'Separated'
        ELSE ''
    END AS MaritalStatus,
    CASE
        WHEN M.MaritalStatusMCId = 70 AND M.GenderMCId = 32 THEN M.SpouseName
        ELSE M.FatherName
    END AS FatherSpouseName,
	'I'  As  RelationShip,
    CONVERT(VARCHAR, R.ApplicationDate, 34) AS IssueDate,
    (Adr.HouseNo + ', ' + Adr.Locality + ', ' + Adr.VillageTown + ', ' + Adr.Tehsil + ', ' + Adr.DistrictEnglish) AS RCAddress,
	Adr.HouseNo as HouseNo,
	Adr.Locality as Locality,
	Adr.VillageTown as VillageTown,
	Adr.Tehsil as Tehsil,
	Adr.DistrictEnglish as District,
	ISNULL(Adr.Pincode, '') as Pincode,
	M.MobileNo as MobileNo,
    H.ShopName AS FPSName,
    R.FPSId AS FPSId,
    ISNULL(A.Locality + ', ', '') + ISNULL(A.VillageTown + ', ', '') + ISNULL(A.Tehsil + ', ', '') + ISNULL(A.DistrictEnglish, '') AS FPSAddress,
	(select count(*) from FIC.MemberDetail where RationCardId = R.RationCardId) AS memberCount
FROM
    FIC.RationCard R
LEFT OUTER JOIN FPS.Header H ON H.FPSUniqueId = R.FPSId
LEFT OUTER JOIN [Master].FPSAddressView AS A ON H.HeaderId = A.HeaderId
LEFT OUTER JOIN FIC.MemberDetail M ON M.RationCardId = R.RationCardId
--LEFT OUTER JOIN [Master].MastersCollection RS on RS.MastersCollectionId=M.RelationHOFMCId
INNER JOIN [Common].[AddressView] Adr ON Adr.BPId = R.BPId AND Adr.DocId = R.RationCardId AND Adr.AddressTypePropId = 112
WHERE
    ManualRCNo = @RationCardNo
	and SrNo = 1
--GROUP BY
--R.RationCardId,
--    R.ManualRCNo,
--    R.ApplicantName,
--    R.RCTypeMCId,
--    R.ApplicationDate,
--    Adr.HouseNo,
--    Adr.Locality,
--    Adr.VillageTown,
--    Adr.Tehsil,
--    Adr.DistrictEnglish,
--    H.ShopName,
--    R.FPSId,
--    A.Locality,
--    A.VillageTown,
--    A.Tehsil,
--    A.DistrictEnglish,
--    M.MaritalStatusMCId,
--    M.GenderMCId,
--    M.SpouseName,
--    M.FatherName,
--	R.UpdateDate
ORDER BY
    R.UpdateDate DESC;


END


