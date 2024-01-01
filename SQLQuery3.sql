USE [SmartePDS_03112023_2]
GO

/****** Object:  View [dbo].[View_Digilocker]    Script Date: 01-01-2024 12:48:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_Digilocker]
AS
SELECT        RationCardId, HASHBYTES('MD5', CONVERT(VARCHAR(36), AadhaarNo)) AS AadhaarNo
FROM            FIC.MemberDetail
GO


