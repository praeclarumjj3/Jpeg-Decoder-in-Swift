//ALGORITHM FOR DECODING AN IMAGE
// 1 .Open JFIF file
// 2.  WHILE !EOF AND no-errors DO
// 3.     READ next byte
// 4.     IF byte EQUALS `ff` THEN
// 5.       READ next byte
// 6.       IF byte EQUALS a defined marker THEN
// 7.         parse marker data
// 8.       END-IF
// 9.     END-IF
// 10.  END-WHILE
// 11.  Decode scan data
// 12.  Construct `MCU`s from decoded data
// 13.  Construct `Image` from the MCUs
// 14.  Write back raw, uncompressed data to disk (in PPM format)

import Swift
import Foundation
import Glibc

class Decoder
{

        var m_filename : String
        var m_imageFile : InputStream?
        var m_image : Image?
        var m_QTables : [[UInt16]]?
        var m_huffmanTable = [[HuffmanTable]](repeating : [Int](repeating : 0 , count : 2) , count : 2)
        var mDHTsScanned = [(alpha : Int , beta : Int)]() 
        var m_huffmanTree = [[HuffmanTree]](repeating : [Int](repeating : 0 , count : 2) , count : 2)
        var m_scanData : String
        var m_MCU = [MCU]()

        enum ResultCode
        {
            case SUCCESS,
            case TERMINATE,
            case ERROR,
            case DECODE_INCOMPLETE,
            case DECODE_DONE
        };
        
        
        init() {

            print("Created 'Decoder object'.")        
        }
        

         init(filename : String) {

            print("Created 'Decoder object'.")        
        }

        
        deinit {
            close()
            print("Destroyed 'Decoder object'.") 
        }

        //open a JFIF file for decoding
        func open(filename : String) -> Bool {
            
            //m_imageFile.open(filename, std::ios::in | std::ios::binary);
            //m_imageFile.open()
            m_imagFile.read(filename)
    

    
    print("Opened JPEG image: \(filename)")
    
    m_filename = filename
    
    return true
        }

        //decode the image in the JFIF file
        func decodeImageFile() -> ResultCode {
            
    print("Started decoding process...")
    
    var byte : UInt8?
    var status : ResultCode = ResultCode.DECODE_DONE
    
    while (m_imageFile >> std::noskipws >> byte)
    {
        if byte == JFIF_BYTE_FF
        {
            m_imageFile >> std::noskipws >> byte;
            
            var code : ResultCode = parseSegmentInfo(byte)
            
            if code == ResultCode.SUCCESS
                continue
            else if code == ResultCode.TERMINATE
            {
                status = ResultCode.TERMINATE
                break
            }
            else if code == ResultCode.DECODE_INCOMPLETE
            {
                status = ResultCode.DECODE_INCOMPLETE
                break
            }
        }
        else
        {
            print("[ FATAL ] Invalid JFIF file! Terminating...")
            status = ResultCode.ERROR
            break
        }
    }
    
    if status == ResultCode.DECODE_DONE
    {
        decodeScanData()
        m_image.createImageFromMCUs(m_MCU)
        print("Finished decoding process [OK].")
    }
    else if status == ResultCode.TERMINATE
    {
        print("Terminated decoding process [NOT-OK].")
    }
    
    else if status == ResultCode.DECODE_INCOMPLETE
    {
        print("Decoding process incomplete [NOT-OK].")
    }
    
    return status
    }
    
    //write raw, uncompressed image data to disk in PPM format
    func dumpRawData() -> Bool {
        
        var extPos : Int = m_filename.firstIndex( of : ".jpg")
    
    if (extPos == nil)
        extPos = m_filename.firstIndex(of : ".jpeg")
    
    std::string targetFilename = m_filename[..<extPos] + ".ppm"
    m_image.dumpRawData(targetFilename)
    
    return true

    }

    func close() {

    m_imageFile.close()
    print("Closed image file: \(m_filename)") 
}


func parseSegmentInfo( byte : UInt8) -> ResultCode {
    
    if byte == JFIF_BYTE_0 || byte == JFIF_BYTE_FF{
        return ERROR
    }
    
    switch(byte)
    {
        case JFIF_SOI  : 
                        { 
                            print( "Found segment, Start of Image (FFD8)")
                            return ResultCode.SUCCESS
                        }

        case JFIF_APP0 : 
                        {
                            print( "Found segment, JPEG/JFIF Image Marker segment (APP0)")
                            parseAPP0Segment() 
                            return ResultCode.SUCCESS
                        }

        case JFIF_COM  : 
                        {
                            print( "Found segment, Comment(FFFE)" )
                            parseCOMSegment()
                            return ResultCode.SUCCESS
                        }
        case JFIF_DQT  : 
                        {
                            print( "Found segment, Define Quantization Table (FFDB)")
                            parseDQTSegment()
                            return ResultCode.SUCCESS
                        }
        case JFIF_SOF0 : 
                        {
                            print( "Found segment, Start of Frame 0: Baseline DCT (FFC0)")
                            return parseSOF0Segment()
                        }
        case JFIF_SOF1 : 
                        {
                            print("Found segment, Start of Frame 1: Extended Sequential DCT (FFC1), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF2 : 
                        {
                            print("Found segment, Start of Frame 2: Progressive DCT (FFC2), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF3 : 
                        {
                            print("Found segment, Start of Frame 3: Lossless Sequential (FFC3), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF5 : 
                        {
                            print("Found segment, Start of Frame 5: Differential Sequential DCT (FFC5), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF6 : 
                        {
                            print("Found segment, Start of Frame 6: Differential Progressive DCT (FFC6), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF7 : 
                        {
                            print("Found segment, Start of Frame 7: Differential lossless (Sequential) (FFC7), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF9 : 
                        {
                            print("Found segment, Start of Frame 9: Extended Sequential DCT, Arithmetic Coding (FFC9), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF10: 
                        {
                            print("Found segment, Start of Frame 10: Progressive DCT, Arithmetic Coding (FFCA), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF11: 
                        {
                            print("Found segment, Start of Frame 11: Lossless (Sequential), Arithmetic Coding (FFCB), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF13: 
                        {
                            print("Found segment, Start of Frame 13: Differentical Sequential DCT, Arithmetic Coding (FFCD), Not supported")
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF14: 
                        {
                            print("Found segment, Start of Frame 14: Differentical Progressive DCT, Arithmetic Coding (FFCE), Not supported") 
                            return ResultCode.TERMINATE
                        }
        case JFIF_SOF15: 
                        {
                            print("Found segment, Start of Frame 15: Differentical Lossless (Sequential), Arithmetic Coding (FFCF), Not supported") 
                            return ResultCode.TERMINATE
                        }
        case JFIF_DHT  : 
                        { 
                            print( "Found segment, Define Huffman Table (FFC4)")
                            parseDHTSegment()
                            return ResultCode.SUCCESS
                        }
        case JFIF_SOS  : 
                        
                        {print( "Found segment, Start of Scan (FFDA)")
                        parseSOSSegment()
                        return ResultCode.SUCCESS
                        }
    }
    
    return ResultCode.SUCCESS

}

func parseAPP0Segment() {
    

    print("Parsing JPEG/JFIF marker segment (APP-0)...")
    
    var lenByte : UInt16 = 0
    var byte : UInt8 = 0
    
    m_imageFile.read(Character(lenByte), 2)
    lenByte = htons(lenByte)
    var curPos : Int = m_imageFile.next()
    
    print("JFIF Application marker segment length:\(lenByte)")
    
    // Skip the 'JFIF\0' bytes
    m_imageFile.seekg(5, m_imageFile.next());
    
    var majVersionByte : UInt8?
    var minVersionByte : UInt8?
    m_imageFile >> std::noskipws >> majVersionByte >> minVersionByte;
    
    print("JFIF version: \((Int)majVersionByte << (Int)(minVersionByte >> 4) << (Int)(minVersionByte & 0x0F))")
    
    var majorVersion : String = String(majVersionByte)
    var minorVersion : String = String((int)(minVersionByte >> 4))
    minorVersion +=  String((int)(minVersionByte & 0x0F))
    
    var densityByte : UInt8 
    m_imageFile >> std::noskipws >> densityByte;
    
    var densityUnit : String = "";
    switch(densityByte)
    {
        case 0x00: {
            densityUnit = "Pixel Aspect Ratio"
             break
        }
        case 0x01: {
            densityUnit = "Pixels per inch (DPI)"
            break
        }
        case 0x02: {
            densityUnit = "Pixels per centimeter"
            break
        }
    }
    
    print("Image density unit: \(densityUnit)")
    
    var xDensity : UInt16 = 0
    var yDensity : UInt16 = 0
    
    m_imageFile.read(Character(xDensity), 2)
    m_imageFile.read(Character(yDensity), 2)
    
    xDensity = htons(xDensity)
    yDensity = htons(yDensity)
    
    print("Horizontal image density:\(xDensity)")
    print("Vertical image density:\(yDensity)")
    
    // Ignore the image thumbnail data
    var xThumb : UInt8 = 0
    var yThumb : UInt8 = 0
    m_imageFile >> std::noskipws >> xThumb >> yThumb
    m_imageFile.seekg(3 * xThumb * yThumb, m_imageFile.next())
    
    print("Finished parsing JPEG/JFIF marker segment (APP-0) [OK]")
}

func parseCOMSegment() {
    
    
    print("Parsing comment segment...")
    
    var lenByte : UInt16 = 0
    var byte : UInt8 = 0
    var comment : String?
    
    m_imageFile.read(Character(lenByte), 2)
    lenByte = htons(lenByte)
    var curPos : Int = m_imageFile.tellg()
    
    print("Comment segment length: \(lenByte)")
    
    for i in 0...lenByte - 3 
    {
        m_imageFile >> std::noskipws >> byte;
        
        if byte == JFIF_BYTE_FF
        {
            print("Unexpected start of marker at offest: \(curPos + i)")
            print("Comment segment content: \(comment)")
            return
        }
        
        comment.append(Character(byte))
        i+=1
    }
    
    print("Comment segment content:\(comment)")
    print("Finished parsing comment segment [OK]")
}

func parseDQTSegment(){


    print("Parsing quantization table segment...")
    
    var lenByte : UInt16 = 0 
    var PqTq : UInt8?
    var Qi : UInt8?
    
    m_imageFile.read(Character(lenByte), 2)
    lenByte = htons(lenByte)
    print("Quantization table segment length: \((int)lenByte)")
    
    lenByte -= 2
    
    for qt in 0...(int(lenByte) / 65)-1
    {
        m_imageFile >> std::noskipws >> PqTq;
        
        var precision : Int = PqTq >> 4 // Precision is always 8-bit for baseline DCT
        var QTtable : Int = PqTq & 0x0F // Quantization table number (0-3)
        
        print("Quantization Table Number: \(QTtable)")
        print("Quantization Table # \(QTtable) , precision: \(precision == 0 ? "8-bit" : "16-bit")")
        
        m_QTables.append([Int]())
        
        // Populate quantization table #QTtable            
        for i in 0...63
        {
            m_imageFile >> std::noskipws >> Qi;
            m_QTables[QTtable].append((UInt16)Qi)
            i+=1
        }
        qt+=1
    }
    
    print("Finished parsing quantization table segment [OK]")
}

func parseSOF0Segment() -> ResultCode {
    
    
    print("Parsing SOF-0 segment...")
    
    var lenByte : UInt16?
    var imgHeight : UInt16?
    var imgWidth : UInt16?
    var precision : UInt8?
    var compCount : UInt8?
    
    m_imageFile.read(Character(lenByte), 2)
    lenByte = htons(lenByte)
    
    print("SOF-0 segment length: \((int)lenByte)")
    
    m_imageFile >> std::noskipws >> precision;
    print("SOF-0 segment data precision: \((int)precision)")
    
    m_imageFile.read(Character(imgHeight), 2)
    m_imageFile.read(Character(imgWidth), 2)
    
    imgHeight = htons(imgHeight)
    imgWidth = htons(imgWidth)
    
    print("Image height: \((int)imgHeight)")
    print("Image width:  \((int)imgWidth)")
    
    m_imageFile >> std::noskipws >> compCount;
    
    print("No. of components: \((int)compCount)")
    
    var compID : UInt8 = 0
    var sampFactor : UInt8 = 0 
    var QTNo : UInt8 = 0
    
    var isNonSampled : Bool = true
    
    for i in 0...2
    {
        m_imageFile >> std::noskipws >> compID >> sampFactor >> QTNo;
        
        print("Component ID: \(Int(compID))")
        print("Sampling Factor, Horizontal: \(Int(sampFactor >> 4)), Vertical: \(Int(sampFactor & 0x0F))")
        print("Quantization table no.: \(Int(QTNo))")
        
        if (sampFactor >> 4) != 1 || (sampFactor & 0x0F) != 1
        {
            isNonSampled = false
            }
        i+=1
    }
    
    if !isNonSampled
    {
        print("Chroma subsampling not yet supported!")
        print("Chroma subsampling is not 4:4:4, terminating...")
        return ResultCode.TERMINATE
    }
    
    print("Finished parsing SOF-0 segment [OK]")        
    m_image.width = imgWidth
    m_image.height = imgHeight
    
    return ResultCode.SUCCESS
}

func parseDHTSegment() {
    
    
    print("Parsing Huffman table segment...")
    
    var len : UInt16?
    m_imageFile.read(Character(len), 2)
    len = htons(len)
    
    print("Huffman table length: \(Int(len))")
    
    var segmentEnd : Int = Int(m_imageFile.next()) + len - 2
    
    while (m_imageFile.tellg() < segmentEnd)
    {
        var htinfo : UInt8
        m_imageFile >> std::noskipws >> htinfo;
        
        var HTType : Int = Int((htinfo & 0x10) >> 4)
        var HTNumber : Int = Int(htinfo & 0x0F)
        
        print("Huffman table type: \(HTType)")
        print("Huffman table #: \(HTNumber)")
        
        var totalSymbolCount : Int = 0
        var symbolCount : UInt8?
        
        for i in 1...16
        {
            m_imageFile >> std::noskipws >> symbolCount;
            m_huffmanTable[HTType][HTNumber][i-1].first = Int(symbolCount)
            totalSymbolCount += Int(symbolCount)
        }
        
        // Load the symbols
        var syms : Int = 0
        for i in 0...totalSymbolCount - 1 
        {
            // Read the next symbol, and add it to the
            // proper slot in the Huffman table.
            //
            // Depending upon the symbol count, say n, for the current
            // symbol length, insert the next n symbols in the symbol
            // list to it's proper spot in the Huffman table. This means,
            // if symbol counts for symbols of lengths 1, 2 and 3 are 0,
            // 5 and 2 respectively, the symbol list will contain 7
            // symbols, out of which the first 5 are symbols with length
            // 2, and the remaining 2 are of length 3.
            var code : UInt8
            m_imageFile >> std::noskipws >> code;
            
            if m_huffmanTable[HTType][HTNumber][i].first == 0
            {
                while (m_huffmanTable[HTType][HTNumber][i].first == 0){
                    i+=1
                }
            }
            
            m_huffmanTable[HTType][HTNumber][i].second.append(code)
            sysm+=1
            
            if m_huffmanTable[HTType][HTNumber][i].first == m_huffmanTable[HTType][HTNumber][i].second.count{
                i+=1
            }
        }
        
        print("Printing symbols for Huffman table (\(HTType) , \(HTNumber))...")
        
        var totalCodes : Int = 0
        for i in 0...15 
        {
            var codeStr : String = ""
            for symbol in m_huffmanTable[HTType][HTNumber][i].second
            {
                std::stringstream ss;
                ss << "0x" << std::hex << std::setfill('0') << std::setw(2) << std::setprecision(16) << (int)symbol;
                codeStr += ss.str() + " ";
                totalCodes++;
            }
            
            print("Code length: \(i+1), Symbol count:\(m_huffmanTable[HTType][HTNumber][i].second.count) ,Symbols: \(codeStr)")
            i+=1
        }
        
        print("Total Huffman codes for Huffman table(Type: \(HTType),#: \(HTNumber)): \(totalCodes)")
        
        m_huffmanTree[HTType][HTNumber].constructHuffmanTree(m_huffmanTable[HTType][HTNumber])
        var htree = m_huffmanTree[HTType][HTNumber].getTree()
        print("Huffman codes:-")
        inOrder(htree)
    }
    
    print("Finished parsing Huffman table segment [OK]")
}

func parseSOSSegment() {
    

    print("Parsing SOS segment...")
    
    var len : UInt16?
    
    m_imageFile.read(Character(len), 2)
    len = htons(len)
    
    print("SOS segment length:\(len)")
    
    var compCount : UInt8? // Number of components
    var compInfo UInt16? // Component ID and Huffman table used
    
    m_imageFile >> std::noskipws >> compCount;
    
    if (compCount < 1 || compCount > 4)
    {
        print("Invalid component count in image scan: \((int)compCount), terminating decoding process..."
        return
    }
    
    print("Number of components in scan data: \(Int(compCount))")
    
    for i in 0...compCount - 1
    {
        m_imageFile.read(Character(compInfo), 2)
        compInfo = htons(compInfo)
        
        var cID : UInt8 = compInfo >> 8 // 1st byte denotes component ID 
        
        // 2nd byte denotes the Huffman table used:
        // Bits 7 to 4: DC Table #(0 to 3)
        // Bits 3 to 0: AC Table #(0 to 3)
        var DCTableNum : UInt8 = (compInfo & 0x00f0) >> 4
        var ACTableNum : UInt8 = (compInfo & 0x000f) 
        
        print("Component ID: \(Int(cID)) , DC Table #: \(Int(DCTableNum)) , AC Table #: \(Int(ACTableNum))")
        i+=1
    }
    
    // Skip the next three bytes
    for i = 0...2 
    {
        var byte : UInt8?
        m_imageFile >> std::noskipws >> byte;
    }
    
    print("Finished parsing SOS segment [OK]")
    
    scanImageData()
}


func scanImageData() {
    
    
    print("Scanning image data...")
    
    var byte : UInt8
    
    while (m_imageFile >> std::noskipws >> byte)
    {
        if byte == JFIF_BYTE_FF
        {
            var prevByte : UInt8 = byte
            
            m_imageFile >> std::noskipws >> byte;
            
            if byte == JFIF_EOI
            {
                print("Found segment, End of Image (FFD9)")
                return
            }
            
            std::bitset<8> bits1(prevByte);
            logFile << "0x" << std::hex << std::setfill('0') << std::setw(2)
                                        << std::setprecision(8) << (int)prevByte
                                        << ", Bits: " << bits1 << std::endl;
                                        
            m_scanData.append(String(bits1))
        }
        
        std::bitset<8> bits(byte);
        logFile << "0x" << std::hex << std::setfill('0') << std::setw(2)
                                    << std::setprecision(8) << (int)byte
                                    << ", Bits: " << bits << std::endl;
        
        m_scanData.append(String(bits))
    }
    
    print("Finished scanning image data [OK]")
}

void Decoder::byteStuffScanData()
{
    if m_scanData.isEmpty
    {
        print(" [ FATAL ] Invalid image scan data")
        return
    }
    
    print("Byte stuffing image scan data...")
    
    for i in 0...m_scanData.count - 8
    {
        var byte : String = m_scanData[i..<(i+8)]
        
        if byte == "11111111"
        {
            if i + 8 < m_scanData.count - 8
            {
                var nextByte : String = m_scanData[(i+8)..<(i+16)]
                
                if nextByte == "00000000"
                {
                    m_scanData.remove(i + 8..<8)
                }
                else continue
            }
            else
                continue
        }
        i += 8
    }
    
    print("Finished byte stuffing image scan data [OK]")
}

func decodeScanData() {

    if m_scanData.isEmpty
    {
        print(" [ FATAL ] Invalid image scan data")
        return
    }
    
    byteStuffScanData()
    
    print("Decoding image scan data...")
    
    var component : [String] = ["Y (Luminance)", "Cb (Chrominance)", "Cr (Chrominance)" ]
    var type : [String] = ["DC", "AC" ]        
    
    var MCUCount : Int= (m_image.width * m_image.height) / 64
    
    m_MCU.removeAll()
    logFile << "MCU count: " << MCUCount << std::endl;
    
    var k : Int = 0 // The index of the next bit to be scanned
    
    for i in 0...MCUCount - 1; ++i)
    {
        print("Decoding MCU-\(i + 1)...")
        
        // The run-length coding after decoding the Huffman data
        var RLE = [[Int]](count:3,repeating: [Int](count 3 , repeating: 0))            
        
        // For each component Y, Cb & Cr, decode 1 DC
        // coefficient and then decode 63 AC coefficients.
        //
        // NOTE:
        // Since a signnificant portion of a RLE for a
        // component contains a trail of 0s, AC coefficients
        // are decoded till, either an EOB (End of block) is
        // encountered or 63 AC coefficients have been decoded.
        
        for compID in 0...2 
        {
            var bitsScanned : String = "" // Initially no bits are scanned
            
            // Firstly, decode the DC coefficient
            print("Decoding MCU-\(i + 1) : \(component[compID]) / \(type[HT_DC])")
            
            var HuffTableID : Int = compID == 0 ? 0 : 1
            
            while (1)
            {       
                bitsScanned += m_scanData[k]
                var value = m_huffmanTree[HT_DC][HuffTableID].contains(bitsScanned)
                
                if (!isStringWhiteSpace(value))
                {
                    if value != "EOB"
                    {   
                        var zeroCount :Int = UInt8(std::stoi(value)) >> 4 ;
                        var category :Int = UInt8(std::stoi(value)) & 0x0F;
                        var DCCoeff  :Int= bitStringtoValue(m_scanData[k + 1..<category)
                        
                        k += category + 1
                        bitsScanned = ""
                        
                        RLE[compID].append(zeroCount)
                        RLE[compID].append(DCCoeff)
                        
                        break
                    }
                    
                    else
                    {
                        bitsScanned = ""
                        k+=1
                        
                        RLE[compID].append(0)
                        RLE[compID].append(0)
                        
                        break
                    }
                }
                else
                    k+=1
            }
            
            // Then decode the AC coefficients
            print("Decoding MCU-\(i + 1) : \(component[compID]) /\(type[HT_AC])")
            bitsScanned = ""
            int ACCodesCount = 0
                            
            while (1)
            {   
                // If 63 AC codes have been encountered, this block is done, move onto next block                    
                if (ACCodesCount  == 63)
                {
                    break
                }
                
                // Append the k-th bit to the bits scanned so far
                bitsScanned += m_scanData[k]
                auto value = m_huffmanTree[HT_AC][HuffTableID].contains(bitsScanned)
                
                if (!isStringWhiteSpace(value))
                {
                    if value != "EOB"
                    {
                        var zeroCount : Int = UInt8(std::stoi(value)) >> 4 
                        var category : Int = UInt8(std::stoi(value)) & 0x0F
                        var ACCoeff : Int = bitStringtoValue(m_scanData[k + 1..<category])
                        
                        k += category + 1
                        bitsScanned = ""
                        
                        RLE[compID].append(zeroCount)
                        RLE[compID].append(ACCoeff)
                        
                        ACCodesCount += zeroCount + 1
                    }
                    
                    else
                    {
                        bitsScanned = ""
                        k+=1
                        
                        RLE[compID].append(0)
                        RLE[compID].append(0)
                        
                        break
                    }
                }
                
                else
                    k+=1
            }
            
            // If both the DC and AC coefficients are EOB, truncate to (0,0)
            if RLE[compID].count == 2
            {
                var allZeros : Bool = true
                
                for rVal in RLE[compID]
                {
                    if rVal != 0
                    {
                        allZeros = false
                        break
                    }
                }
                
                // Remove the extra (0,0) pair
                if allZeros
                {
                    RLE[compID].removeLast()
                    RLE[compID].removeLast()
                }
            }
            compID+=1
        }
        
        // Construct the MCU block from the RLE &
        // quantization tables to a 8x8 matrix
        m_MCU.append(MCU(RLE, m_QTables))
        
        print("Finished decoding MCU-\(i + 1) [OK]")
    }
    
    // The remaining bits, if any, in the scan data are discarded as
    // they're added byte align the scan data.
    
    print("Finished decoding image scan data [OK]")
}

}
