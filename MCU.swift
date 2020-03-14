
// Alias for a 8x8 pixel block with integral values for its channels
typealias CompMatrices = [[[Int]]](count:8,repeating:[[Int]](count:8,repeating:[Int](count:3,repeating:0)))

//typedef std::array<std::array<std::array<int, 8>, 8>, 3> CompMatrices;

// Alias for a 8x8 matrix with integral elements

typealias Matrix8x8 = [[Int]](count:8 , repeating:[Int](count:8,repeating:0))

//typedef std::array< std::array< int, 8 >, 8 > Matrix8x8;

class MCU
{
    //the total number of MCUs in the image (this info is shared by all MCUs)
    static var m_MCUCount : Int = 0
    //the quantization tables used for quantization (this info is shared by all MCUs)
    static var m_QTables : [[UInt16]]?

    //the differences in DC consecutive coefficients per channel (this info is shared by all MCUs)
    static var m_DCDiff = [Int](count:3 , repeating :0) 

    //8 × 8 block of pixels that make up the MCU
    var m_block : CompMatrices?
    //the order of the MCU in the image
    var m_order : Int?
    //the MCU after performing IDCT
    var m_IDCTCoeffs = [[[Float](count:3,repeating:0)](count:8,repeating:0)](count:8,repeating:0)
    
    init() {
        
    }
    
    
    init(compRLE : [[Int](count : 3 , repeating :0)] , QTables : [[UInt16]])
{
    constructMCU(compRLE, QTables)
}
    //create the MCU from the specified run-length encoding and quantization tables
    func constructMCU(compRLE : [[Int]],QTables : [[UInt16]]) {

    self.m_QTables = QTables;
    
    self.m_MCUCount+=1
    m_order = m_MCUCount;
    
    print("Constructing MCU: \(m_order)..."  
    
    let component : [String] = ["Y (Luminance)", "Cb (Chrominance)", "Cr (Chrominance)" ]
    let type : [String] = [ "DC", "AC" ]    
    
    for compID in 0...2
    {
        // Initialize with all zeros
        var zzOrder : [Int] = [Int](count:64 , repeating :0)
        //std::array<int, 64> zzOrder;            
        //std::fill(zzOrder.begin(), zzOrder.end(), 0);
        int j = -1;
        
        for i in 0...compRLE[compID].count - 2
        {
            if compRLE[compID][i] == 0 && compRLE[compID][i + 1] == 0
                break;
            
            j += compRLE[compID][i] + 1 // Skip the number of positions containing zeros
            zzOrder[j] = compRLE[compID][i + 1];
            i += 2
        }
        
        // DC_i = DC_i-1 + DC-difference
        m_DCDiff[compID] += zzOrder[0]
        zzOrder[0] = m_DCDiff[compID]
        
        var QIndex : Int = compID == 0 ? 0 : 1
        for i in 0...63 {
            zzOrder[i] *= m_QTables[QIndex][i]
            i+=1
        }
        // Zig-zag order to 2D matrix order
        for i in 0..63
        {
            coords = zzOrderToMatIndices(i)
            m_block[compID][ coords.first ][ coords.second ] = zzOrder[i]
            i+=1
        }

        compID+=1
        }
    
    computeIDCT()
    performLevelShift()
    convertYCbCrToRGB()
    
    print("Finished constructing MCU: \(m_order)...")
    } 
    
    //get the pixel arrays for the pixels under this MCU
    func getAllMatrices() -> CompMatrices {
        return m_block
    }

    //compute IDCT
    func computeIDCT()
{
    print("Performing IDCT on MCU: \(m_order)..."
    
    for i in 0...2
    {
        for y in 0...7
        {
            for x in 0...7
            {
                var sum : Float = 0.0
                
                for u in 0...7
                {
                    for v in 0...7
                    {
                        var Cu : Float = u == 0 ? 1.0 / pow(2.0,0.5) : 1.0;
                        var Cv : Float= v == 0 ? 1.0 / pow(2.0,0.5) : 1.0;
                        
                        sum += Cu * Cv * m_block[i][u][v] * cos((2 * x + 1) * u * Double.pi / 16.0) * cos((2 * y + 1) * v * Double.pi / 16.0)
                        v+=1
                    }
                    u+=1
                }
                
                m_IDCTCoeffs[i][x][y] = 0.25 * sum
                x+=1
            }
            y+=1
        }
        i+=1
    }

    print("IDCT of MCU: \(m_order)  complete [OK]"
}
    
    //level shift the pixel data to center it within the pixel value range
   func performLevelShift()
{
    print("Performing level shift on MCU: \(m_order)..."
    
    for i in 0...2
    {
        for y in 0...7
        {
            for x in 0...7
            {
                m_block[i][y][x] = (m_IDCTCoeffs[i][y][x]).round(.down) + 128
                x+=1
            }
            y+=1
        }
        i+=1
    }
    
    print("Level shift on MCU: \(m_order) complete [OK]"
}
    
    //convert the MCU’s underlying pixels from the Y-Cb-Cr colour model to RGB colour model
    func convertYCbCrToRGB()
{
    print("Converting from Y-Cb-Cr colorspace to R-G-B colorspace for MCU: \(m_order)..."
    
    for y in 0...7
    {
        for x in 0...7
        {
            var Y : Float = m_block[0][y][x]
            var Cb : Float = m_block[1][y][x]
            var Cr : Float = m_block[2][y][x]
            
            var R : Int = (Y + 1.402 * (1.0 * Cr - 128.0)).round(.down)
            var G : Int = (Y - 0.344136 * (1.0 * Cb - 128.0) - 0.714136 * (1.0 * Cr - 128.0)).round(.down)
            var B : Int = (Y + 1.772 * (1.0 * Cb - 128.0)).round(.down)
            
            R = max(0, min(R, 255))
            G = max(0, min(G, 255))
            B = max(0, min(B, 255))
            
            m_block[0][y][x] = R
            m_block[1][y][x] = G
            m_block[2][y][x] = B

            x+=1
        }
        y+=1
    }
    
     print("Colorspace conversion for MCU: \(m_order) done [OK]"
}
    
    
}








