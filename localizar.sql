USE [database]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_localiza 'len('


CREATE procedure [dbo].[sp_localiza]  

	

 @FieldName Varchar(100)  
 ,@FieldName_2	varchar(100)	=	null

 As  
  
 Select Distinct  
 'Table' as ObjectType,  
 Substring(o.name,1,100) as ObjectName,  
 Substring(c.name,1,100) as SearchResult  
 From  
 sysobjects o  
 Inner Join syscolumns c On  
 o.id = c.id  
 Where   Upper(c.name) like '%' + Upper(@FieldName) + '%'  AND (@FieldName_2 IS NULL OR   Upper(c.name) like '%' + Upper(@FieldName_2) + '%' )
 And o.type = 'U'  
 And o.status >= 0  
 Union  
 select distinct  
 'Procedure' as ObjectType,  
 Substring(o.name,1,100) as ObjectName,  
 'String "' + RTrim(@FieldName) + '" Found !!!' as SearchResult  
 from  
 sysobjects o  
 inner join syscomments cm on  
 o.id = cm.id  
 where  
 o.type = 'P'  
 And o.status >= 0  
 and Upper(cm.text) like '%' + Upper(@FieldName) + '%'    AND (@FieldName_2 IS NULL OR   Upper(cm.text) like '%' + Upper(@FieldName_2) + '%' )
 Union  
 select distinct  
 'Trigger' as ObjectType,  
 Substring(o.name,1,100) as ObjectName,  
 'String "' + RTrim(@FieldName) + '" Found !!!' as SearchResult  
from  
 sysobjects o  
 inner join syscomments cm on  
 o.id = cm.id  
 where  
 o.type = 'TR'  
 And o.status >= 0  
 and Upper(cm.text) like '%' + Upper(@FieldName) + '%'    AND (@FieldName_2 IS NULL OR   Upper(cm.text) like '%' + Upper(@FieldName_2) + '%' )
 UNION  
 select distinct  
 'VIEW' as ObjectType,  
 Substring(o.name,1,100) as ObjectName,  
 'String "' + RTrim(@FieldName) + '" Found !!!' as SearchResult  
 from  
 sysobjects o  
 inner join syscomments cm on  
 o.id = cm.id  
 where  
 o.type = 'V'  
 And o.status >= 0  
 and Upper(cm.text) like '%' + Upper(@FieldName) + '%'   AND (@FieldName_2 IS NULL OR   Upper(cm.text) like '%' + Upper(@FieldName_2) + '%' )
UNION  
 select distinct  
 'FUNCTION' as ObjectType,  
 Substring(o.name,1,100) as ObjectName,  
 'String "' + RTrim(@FieldName) + '" Found !!!' as SearchResult  
 from  
 sysobjects o  
 inner join syscomments cm on  
 o.id = cm.id  
 where  
 o.type in ('FN','IF', 'TF')
 And o.status >= 0  
 and Upper(cm.text) like '%' + Upper(@FieldName) + '%'   AND (@FieldName_2 IS NULL OR   Upper(cm.text) like '%' + Upper(@FieldName_2) + '%' )

UNION  
 select distinct  
 'FOREIGN KEY' as ObjectType,  
 Substring(o.name,1,100) as ObjectName,  
 'String "' + RTrim(@FieldName) + '" Found !!!' as SearchResult  
 from  
 sysobjects o  
 inner join syscomments cm on  
 o.id = cm.id  
 where  
 o.type = 'F'
 And o.status >= 0  
 and Upper(cm.text) like '%' + Upper(@FieldName) + '%'   AND (@FieldName_2 IS NULL OR   Upper(cm.text) like '%' + Upper(@FieldName_2) + '%' )


UNION  
 select distinct  
 'DEFAULT' as ObjectType,  
 Substring(o.name,1,100) as ObjectName,  
 'String "' + RTrim(@FieldName) + '" Found !!!' as SearchResult  
 from  
 sysobjects o  
 inner join syscomments cm on  
 o.id = cm.id  
 where  
 o.type = 'F'
 And o.status >= 0  
 and Upper(cm.text) like '%' + Upper(@FieldName) + '%'   AND (@FieldName_2 IS NULL OR   Upper(cm.text) like '%' + Upper(@FieldName_2) + '%' )





UNION  
 select distinct  
 'PRIMARY KEY' as ObjectType,  
 Substring(o.name,1,100) as ObjectName,  
 'String "' + RTrim(@FieldName) + '" Found !!!' as SearchResult  
 from  
 sysobjects o  
 inner join syscomments cm on  
 o.id = cm.id  
 where  
 o.type = 'K'
 And o.status >= 0  
 and Upper(cm.text) like '%' + Upper(@FieldName) + '%'  
 Order By 1, 2, 3 


GO
