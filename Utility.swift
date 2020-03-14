import Foundation
import Glibc


func isValidChar(ch : Character) -> Bool    
{
    //checks the validity of a character in the context of a file name
    return ch.rangeofCharacterFromSet(Character.Unicode) || ch != '/' || ch != '\\';
}

func isValidFileName(filename : String) -> Bool 
{
    for c in filename{
        if !isValidChar(c){
            return false
        }
    }
    
    //Finding if the filename has .jpg or .jpeg
    //checks whether a string represents a valid JPEG file name
    var extPos = filename.index(of: ".jpg")
    
    if extPos == nil{
         extPos = filename.index(of: ".jpeg")
    }
    else if extPos + 4 == filename.count{
        return true
    }
    if extPos == nil{
        return false
    }
    return false
}

//checks whether a character represents a whitespace
func isWhiteSpace(ch : Character) -> Bool 
{
   let range = phrase.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet())
   return range == nil

//checks whether a string consists entirely of whitespaces
func isStringWithWhiteSpace(str : String) -> Bool 
{
     for c in str{
        if (!isWhiteSpace(c))
            return false;
     }
    return true;
}

