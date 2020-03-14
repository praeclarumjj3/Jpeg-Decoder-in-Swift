
class Image
{

  var width : Int?  // the width of the image in pixels
  var height : Int? //the height of the image in pixels
  var m_pixelPtr : PixelPtr? //the 2D array of pixels of the image where the pixel intensities are discrete
        
        init() {
           var self.width : Int = 0
           var self.height : Int= 0
           var self.m_pixelPtr : PixelPtr = nil
           print("Created new Image object") 
        }
        
    //create an image from a list of MCUs
    func createImageFromMCUs(MCUS : [MCU])
{
    print("Creating Image from MCU array...")
    
    var mcuNum : Int = 0
    
    var jpegWidth : Int = width % 8 == 0 ? width : width + 8 - (width % 8)
    var jpegHeight : Int = height % 8 == 0 ? height : height + 8 - (height % 8)
    
    // Create a pixel pointer of size (Image width) x (Image height)
    //m_pixelPtr = [[Pixel]](jpegHeight, std::vector<Pixel>(jpegWidth, Pixel()));
    var m_pixelPtr : PixelPtr = [[Pixel]](repeating : [Pixel](repeating : Pixel() , count :jpegwidth ), count : jpegHeight)
    
    // Populate the pixel pointer based on data from the specified MCUs
    for y in 0...jpegHeight - 8
    {
        for x in 0...jpegHeight - 8
        {
            var pixelBlock = MCUs[mcuNum].getAllMatrices()
            
            for v in 0...7 
            {
                for u in 0...7
                {
                    self.m_pixelPtr[y + v][x + u].comp[0] = pixelBlock[0][v][u] // R
                    self.m_pixelPtr[y + v][x + u].comp[1] = pixelBlock[1][v][u] // G
                    self.m_pixelPtr[y + v][x + u].comp[2] = pixelBlock[2][v][u] // B
                    u+=1
                }
                v+=1
            }

            x+=8
            mcuNum+=1
        }
        y += 8
    }
    
    // Trim the image width to nearest multiple of 8
    if width != jpegWidth
    {
        for row in 0...m_pixelPtr[row].count - 1{
            for c in 0...7 - width % 8 {
                m_pixelPtr[row].remove(at : m_pixelPtr[row].count - 1 )
                c+=1
            }
            row+=1
        }
    }
    
    // Trim the image height to nearest multiple of 8
    if height != jpegHeight
    {
        for c in 0...7 - height % 8 {
            m_pixelPtr.remove(at : m_pixelPtr.count - 1)
            c+=1
        }
    }        

    print("Finished created Image from MCU [OK]")
}


// Write the raw, uncompressed image data to specified file on the disk. The data written is in PPM format
func dumpRawData(filename : String) -> Bool
{
    if m_pixelPtr == nil
    {
        print("Unable to create file \(filename) , Invalid pixel pointer")
        return false
    }
    

    let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
    
    // if !dumpFile.is_open() || !dumpFile.good()
    // {
    //     print("Unable to create dump file \(filename).")
    //     return false
    // }
    
    UInt8("P6").write(to: fileURL, atomically: true, encoding: String.Encoding.utf8) 
    //dumpFile << "# PPM dump created using libKPEG: https://github.com/TheIllusionistMirage/libKPEG" << std::endl;
    UInt8(String(width)+","+String(height)).write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
    UInt8(255).write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
    
    for row in m_pixelPtr
    {
        for pixel in row{

            (UInt8(pixel.comp[RGBComponents.RED])).write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            (UInt8(pixel.comp[RGBComponents.GREEN])).write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            (UInt8(pixel.comp[RGBComponents.BLUE])).write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        
        }
    }
    
    print("Raw image data written to file: \(filename)")
    // dumpFile.close()
    return true
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
         
}



