if process.cwd().contains('.dist')
  root_Folder = process.cwd().path_Combine '../../../'
else
  root_Folder = process.cwd().path_Combine '../../'

tm_Cache = root_Folder.path_Combine '.tmCache'
global.config =
  jade_Compilation:
    enabled: false
  tm_design :
    folder_Jade_Files       : root_Folder.path_Combine 'code/TM_4_Jade'
    folder_Jade_Compilation : tm_Cache.path_Combine 'jade_Compilation'