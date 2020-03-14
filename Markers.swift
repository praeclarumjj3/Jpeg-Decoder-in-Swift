
// Null byte
let JFIF_BYTE_0 : UInt16 = 0x00

// JPEG-JFIF File Markers
// Refer to ITU-T.81 (09/92), page 32
let JFIF_BYTE_FF : UInt16 = 0xFF // All markers start with this as the MSB                  
let JFIF_SOF0 : UInt16 = 0xC0 // Start of Frame 0, Baseline DCT                           
let JFIF_SOF1 : UInt16 = 0xC1 // Start of Frame 1, Extended Sequential DCT               
let JFIF_SOF2 : UInt16 = 0xC2 // Start of Frame 2, Progressive DCT                       
let JFIF_SOF3 : UInt16 = 0xC3 // Start of Frame 3, Lossless (Sequential)                 
let JFIF_DHT : UInt16 = 0xC4 // Define Huffman Table                                    
let JFIF_SOF5 : UInt16 = 0xC5 // Start of Frame 5, Differential Sequential DCT           
let JFIF_SOF6 : UInt16 = 0xC6 // Start of Frame 6, Differential Progressive DCT          
let JFIF_SOF7 : UInt16 = 0xC7 // Start of Frame 7, Differential Loessless (Sequential)   
let JFIF_SOF9 : UInt16= 0xC9 // Extended Sequential DCT, Arithmetic Coding              
let JFIF_SOF10 : UInt16 = 0xCA // Progressive DCT, Arithmetic Coding                      
let JFIF_SOF11 : UInt16 = 0xCB // Lossless (Sequential), Arithmetic Coding                
let JFIF_SOF13 : UInt16 = 0xCD // Differential Sequential DCT, Arithmetic Coding          
let JFIF_SOF14 : UInt16 = 0xCE // Differential Progressive DCT, Arithmetic Coding         
let JFIF_SOF15 : UInt16 = 0xCF // Differential Lossless (Sequential), Arithmetic Coding   
let JFIF_SOI : UInt16 = 0xD8 // Start of Image                                          
let JFIF_EOI : UInt16 = 0xD9 // End of Image                                            
let JFIF_SOS : UInt16 = 0xDA // Start of Scan                                           
let JFIF_DQT : UInt16 = 0xDB // Define Quantization Table
let JFIF_APP0 : UInt16 = 0xE0 // Application Segment 0, JPEG-JFIF Image
let JFIF_COM : UInt16 = 0xFE // Comment

}