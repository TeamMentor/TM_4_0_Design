require 'fluentnode'

class IO_Actions

    copy_File: (source, target, callback)=>
        source.file_Contents().saveAs(target)
        callback()

    file_Copy = @copy_File

module.exports = IO_Actions