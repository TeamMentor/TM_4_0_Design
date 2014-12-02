require 'fluentnode'

class IO_Actions

    copy_File: (source_File, target_File_Or_Folder, callback)=>
        if target_File_Or_Folder.folder_Exists()
            target_File_Or_Folder = target_File_Or_Folder.path_Combine(source_File.file_Name())
        else
            target_File_Or_Folder.file_Parent_Folder().folder_Create()
        source_File.file_Contents().saveAs(target_File_Or_Folder)

        callback() if callback

    copy_Files: ([source_Files], target_Folder, callback)=>
        for source_File in source_Files
            target_File = target_Folder.path_Combine(source_File.file_Name())
        callback() if callback

    copy_Folder: (source_Folder, target_Folder, callback)=>
        target_Folder.folder_Create()
        for child_folder in source_Folder.folders()
            @copy_Folder(child_folder, target_Folder.path_Combine(child_folder.file_Name()), null)
        for file in source_Folder.files()
            @copy_File(file,target_Folder,null)
        callback() if callback

    file_Copy: @::copy_File
    files_Copy: @copy_File
    #IO_Actions::file_Copy = IO_Actions::copy_File


module.exports = IO_Actions