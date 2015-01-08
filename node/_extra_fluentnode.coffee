String::to_Safe_String   = ()-> @.replace(/[^a-z0-9.\-_]/gi, '').lower()
String::only_Letters     = ()-> @.replace(/[^a-z]/gi, '').lower()
String::only_Numbers     = ()-> @.replace(/[^0-9]/gi, '').lower()