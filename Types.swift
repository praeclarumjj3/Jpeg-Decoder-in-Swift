
enum RGBComponents
{
   case RED 
   case GREEN 
   case BLUE
}

struct Pixel
{
    var comp = [Int16](count : 3 , repeating : 0)
    init(){
        comp[0] = comp[1] = comp[2]  = 0
    }
    
    init(comp1 : Int16,
            comp2 : Int16 ,
            comp2 : Int16 )
    {
        comp[0] = comp1
        comp[1] = comp2
        comp[2] = comp3
    }
    
    // Store the intensity of the pixel
    
}


typealias PixelPtr = [[Pixel]]()

typealias HuffmanTable = [(first : Int,second : [UInt8])](count : 16 , repeating : (0 , []))


// Identifiers used to access a Huffman table based on
// the class and ID. E.g., To access the Huffman table
// for the DC coefficients of the CbCr component, we
// use `huff_table[HT_DC][HT_CbCr]`.
let  HT_DC : Int = 0
let  HT_AC : Int = 1
let  HT_Y : Int = 0
let  HT_CbCr : Int = 1


