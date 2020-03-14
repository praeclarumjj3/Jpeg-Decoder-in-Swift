import Foundation
import Glibc
//converts a zig-zag order, k, to it’s corresponding matrix index, (i,j)
func zzOrderToMatIndices(zzindex : Int) -> (first : Int ,second : Int)  {
    static let zzorder : [(first : Int ,second : Int)]= 
    [
        (0,0),
        (0,1), (1,0),         
        (2,0), (1,1), (0,2),
        (0,3), (1,2), (2,1), (3,0),
        (4,0), (3,1), (2,2), (1,3), (0,4),
        (0,5), (1,4), (2,3), (3,2), (4,1), (5,0),
        (6,0), (5,1), (4,2), (3,3), (2,4), (1,5), (0,6),
        (0,7), (1,6), (2,5), (3,4), (4,3), (5,2), (6,1), (7,0),
        (7,1), (6,2), (5,3), (4,4), (3,5), (2,6), (1,7),
        (2,7), (3,6), (4,5), (5,4), (6,3), (7,2),
        (7,3), (6,4), (5,5), (4,6), (3,7),
        (4,7), (5,6), (6,5), (7,4),
        (7,5), (6,6), (5,7),
        (6,7), (7,6),
        (7,7)
        ]

        return zzorder[zzindex];
}

//converts a matrix index, (i,j), to its corresponding order, k, in zig-zag ordering
func matInicesToZZOrder(row : Int , column : Int) -> Int {
    
    static matOrder : [[Int]] = 
    [
        [0,  1,  5,  6, 14, 15, 27, 28],
        [2,  4,  7, 13, 16, 26, 29, 42],
        [3,  8, 12, 17, 25, 30, 41, 43],
        [9, 11, 18, 24, 31, 40, 44, 53],
        [10, 19, 23, 32, 39, 45, 52, 54],
        [20, 22, 33, 38, 46, 51, 55, 60],
        [21, 34, 37, 47, 50, 56, 59, 61],
        [35, 36, 48, 49, 57, 58, 62, 63]
    ]
    
    return matOrder[row][column];
}

//convert a bit string representation to its corresponding value
func bitStringtoValue(bitStr : String) -> Int16 {
    
    if bitStr == ""{
        return 0x0000
    }
    
    var value : Int16 = 0x0000
    var sign : Character = bitStr[0]
    var factor : Int = sign == '0' ? -1 :1
    
    for i in 0...bitStr.count-1 {

        if bitStr[i] == sign{
            value += Int16(pow(2, bitStr.count - 1 - i))
        }
        i+=1
    }
    
    return factor * value
}

//get the category of a value
func getValueCategory(value : Int16) -> Int16 {
    
    if value == 0x0000
        return 0
    return log2(abs(value) : Double) + 1
}
