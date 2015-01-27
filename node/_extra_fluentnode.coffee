String::to_Safe_String   = ()-> @.replace(/[^a-z0-9.\-_]/gi, '-').lower()
String::only_Letters     = ()-> @.replace(/[^a-z]/gi, '-').lower()
String::only_Numbers     = ()-> @.replace(/[^0-9]/gi, '-').lower()
String::add_5_Letters    = ()-> @.add_5_Random_Letters()

String::temp_File = (contents)->
  @.assert_Is_Folder()
   .temp_Name_In_Folder()
   .file_Write(contents)
   .valueOf()             # needed or we will get a returned object (vs a string)

String::assert_File_Contents = (contents)->
  @.assert_File_Exists()
   .file_Contents()
   .assert_Is(contents)
  @.valueOf()

String::assert_Is_Folder = String::assert_That_Folder_Exists
String::assert_File_Delete = ()->
  @.file_Delete().assert_Is_True()
  @.valueOf()

String::folder_Name = ()->
  @.valueOf().file_Name()