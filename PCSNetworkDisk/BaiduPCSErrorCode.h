/*!
 @header BaiduPCSErrorCode.h
 @abstract all error code definition
 @author Baidu PCS SDK
 @version 1.00 2012/08/23 Creation (version info)
 */

#ifndef PCSDemo_BaiduPCSErrorCode_h
#define PCSDemo_BaiduPCSErrorCode_h

/*!
 @enum
 @abstract all error code definition
 @constant No_Error no error
 @constant Error_DefaultError 1. if the passed in parameter is invalid, for example, the source file does not exist<br> 2.some unknown error, such as exception <br>3.The error when parse the JSON response from PCS server
 @constant Error_Unsupported_API Unsupported open api
 @constant Error_No_Permission No permission to do this operation
 @constant Error_Unauthorized_IP Unauthorized client IP address
 @constant Error_DB_Query db query error
 @constant Error_DB_Connect db connect error
 @constant Error_DB_Result_Set_Empty db result set is empty
 @constant Error_Network network error
 @constant Error_Access_Server can not access server
 @constant Error_Param param error
 @constant Error_AppId_Empty app id is empty
 @constant Error_BCS bcs error
 @constant Error_Invalid_Bduss bduss is invalid
 @constant Error_User_Not_Login user is not login
 @constant Error_User_Not_Active user is not active
 @constant Error_User_Not_Authorized user is not authorized
 @constant Error_User_Not_Exist user not exists
 @constant Error_User_Already_Exist user already exists
 @constant Error_File_Name_Invaild file name is invalid
 @constant Error_File_Parent_Path_Not_Exist file parent path does not exist
 @constant Error_File_Not_Authorized file is not authorized
 @constant Error_Directory_Null directory is full
 @constant Error_File_Not_Exist file does not exist
 @constant Error_File_Deal_Failed file deal failed
 @constant Error_File_Create_Failed file create failed
 @constant Error_File_Copy_Failed file copy failed
 @constant Error_File_Delete_Failed file delete failed
 @constant Error_Get_File_Meta_Failed get file meta failed
 @constant Error_File_Move_Failed file move failed
 @constant Error_File_Rename_Failed file rename failed
 @constant Error_SuperFile_Create_Failed superfile create failed 
 @constant Error_SuperFile_Block_List_Empty superfile block list is empty
 @constant Error_SuperFile_Update_Failed superfile update failed
 @constant Error_Tag_Internal tag internal error
 @constant Error_Tag_Param tag param error
 @constant Error_Tag_Database tag database error
 @constant Error_Set_Quota_Denied access denied to set quota
 @constant Error_Quota_Support_2_Level quota only sopport 2 level directories
 @constant Error_Quota_Exceed exceed quota
 @constant Error_Quota_Bigger_Than_ParentDir the quota is bigger than one of its parent directorys
 @constant Error_Quota_Smaller_Than_SubDir the quota is smaller than one of its sub directorys
 @constant Error_Thumbnail_Failed thumbnail failed, internal error
 @constant Error_Invalid_Access_Token Access token invalid or no longer valid
 @constant Error_Signature signature error
 @constant Error_Object_Not_Exist object not exists
 @constant Error_ACL_Put acl put error
 @constant Error_ACL_Query acl query error
 @constant Error_ACL_Get acl get error
 @constant Error_ACL_Not_Exist acl not exists
 @constant Error_Bucket_Already_Exist bucket already exists
 @constant Error_Bad_Request bad request
 @constant Error_BaiduBS_Internal_Error baidubs internal error
 @constant Error_Not_Support not implement
 @constant Error_Access_Denied access denied
 @constant Error_Service_Unavailable service unavailable
 @constant Error_Retry service retry error
 @constant Error_Put_Object_Data put object data error
 @constant Error_Put_Object_Meta put object meta error
 @constant Error_Get_Object_Data get object data error
 @constant Error_Get_Object_Meta get object meta error
 @constant Error_Storage_Exceed_Limit storage exceed limit
 @constant Error_Request_Exceed_Limit request exceed limit
 @constant Error_Transfer_Exceed_Limit transfer exceed limit
 @constant Error_Response_Key_Illegal the value of KEY[VALUE] in pcs response headers is invalid
 @constant Error_Response_Key_Not_Exist no KEY in pcs response headers
 */
enum BaiduPCSErrorCode{

	No_Error = 0,
	
	Error_DefaultError = -1,
	
	Error_Unsupported_API = 3,
	
	Error_No_Permission = 4,
	
	Error_Unauthorized_IP = 5,
	
	Error_DB_Query = 31001,
	
	Error_DB_Connect = 31002,
	
	Error_DB_Result_Set_Empty = 31003,
	
	Error_Network = 31021,
	
	Error_Access_Server = 31022,
	
	Error_Param = 31023,
	
	Error_AppId_Empty = 31024,
	
	Error_BCS = 31025,
	
	Error_Invalid_Bduss = 31041,
	
	Error_User_Not_Login = 31042,
	
	Error_User_Not_Active = 31043,
	
	Error_User_Not_Authorized = 31044,
	
	Error_User_Not_Exist = 31045,
	
	Error_User_Already_Exist = 31046,
	
	Error_File_Already_Exist = 31061,
	
	Error_File_Name_Invaild = 31062,
	
	Error_File_Parent_Path_Not_Exist = 31063,
	
	Error_File_Not_Authorized = 31064,
	
	Error_Directory_Null = 31065,
	
	Error_File_Not_Exist = 31066,
	
	Error_File_Deal_Failed = 31067,
	
	Error_File_Create_Failed = 31068,
	
	Error_File_Copy_Failed = 31069,
	
    Error_File_Delete_Failed = 31070,
	
	Error_Get_File_Meta_Failed = 31071,
	
	Error_File_Move_Failed = 31072,
	
	Error_File_Rename_Failed = 31073,
	
	Error_SuperFile_Create_Failed = 31081,
	
	Error_SuperFile_Block_List_Empty = 31082,
	
	Error_SuperFile_Update_Failed = 31083,
	
	Error_Tag_Internal = 31101,
	
	Error_Tag_Param = 31102,
	
	Error_Tag_Database = 31103,
	
	Error_Set_Quota_Denied = 31110,
	
	Error_Quota_Support_2_Level = 31111,
	
	Error_Quota_Exceed = 31112,
	
	Error_Quota_Bigger_Than_ParentDir = 31113,
	
	Error_Quota_Smaller_Than_SubDir = 31114,
	
	Error_Thumbnail_Failed = 31141,
	
	Error_Invalid_Access_Token = 110,
	
	Error_Signature = 31201,
	
	Error_Object_Not_Exist = 31202,
	
	Error_ACL_Put = 31203,
	
	Error_ACL_Query = 31204,
	
	Error_ACL_Get = 31205,
	
	Error_ACL_Not_Exist = 31206,
	
	Error_Bucket_Already_Exist = 31207,
	
	Error_Bad_Request = 31208,
	
	Error_BaiduBS_Internal_Error = 31209,
	
	Error_Not_Support = 31210,
	
	Error_Access_Denied =31211,
	
	Error_Service_Unavailable = 31212,
	
	Error_Retry = 31213,
	
	Error_Put_Object_Data = 31214,
	
	Error_Put_Object_Meta = 31215,
	
	Error_Get_Object_Data = 31216,
	
	Error_Get_Object_Meta = 31217,
	
	Error_Storage_Exceed_Limit = 31218,
	
	Error_Request_Exceed_Limit = 31219,
	
	Error_Transfer_Exceed_Limit = 31220,
	
	Error_Response_Key_Illegal = 31298,
	
	Error_Response_Key_Not_Exist = 31299
    
};

#endif
