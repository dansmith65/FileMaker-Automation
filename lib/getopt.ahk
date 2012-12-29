;------------------------------------------------
; getopt function
; http://www.autohotkey.com/board/topic/69772-getopt-command-line-option-parameter-function/
;------------------------------------------------
getopt(parms)
{
    
    parms := RegExReplace(parms , "([^\s])-", "$1<dash>")   ; change - to <dash> to avoid confusion 
    regex = (?<=[-|/])([a-zA-Z0-9]*)[ |:|=|"]*([\w|.|@|?|#|$|`%|=|*|,|<|>|^|'|{|}|\[|\]|;|(|)|_|&|+| |:|!|~|/|\\]*)["| ]*(.*)
    
    count:=0
    options:=Object()
    
    while parms != "" 
    {

        count++
        
        RegExMatch(parms,regex,data) 
        
        name := data1
        value := data2
        value := RegExReplace(value , "<dash>", "-")   ; change <dash> back to -
        
                
        if (value = "") {
            options[name] := 1
        } else {
            options[name] := value
        }

        parms := data3
    
    }
    
    ErrorLevel := count 
    
    Return options
    
}