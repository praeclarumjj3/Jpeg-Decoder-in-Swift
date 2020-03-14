struct Node
{
    var root : Bool? //boolean value to indiciate whether the node is a root node
    var leaf : Bool? //boolean value to indicate whether the node is a leaf node
    var code : String? //the Huffman code corresponding to the node
    var value : UInt16? //the symbol value of a leaf node in the Huffman tree
    //Pointers
    var lChild : Node? //left child of the node
    var rChild : Node? //right child of the node
    var parent : Node? //parent of the node

    init() {
        root = false 
        leaf = false 
        code = ""
        value = 0x00 
        lChild = nil
        rChild = nil
        parent = nil 
    }

    init( _code : String , _val : UInt16){
        root = false
        leaf = false
        code = _code
        value = _val
        lChild = nil
        rChild = nil
        parent = nil
    }
}

// Alias for a node
typealias NodePtr = Node

//create an new binary tree
func createRootNode(value : UInt16) -> NodePtr {

    var root : NodePtr = Node("" , value)
    root.root = true
    return root
}

//helper function to create a node
func createNode() -> NodePtr {
    
    return Node()
}

//add a left child for the specified node
func insertLeft(node : NodePtr , value : UInt16) {
    
    if  node == nil
        return;
    
    if node.lChild != nil
    {
        print("Given node already has a left child, skipping insertion")
        return
    }
    
    var lNode : NodePtr = createNode()
    lNode.parent = node
    node.lChild = lNode
    
    lNode.code = node.code + "0"
    lNode.value = value
}

//add a right child for the specified node
func insertRight(node : NodePtr , value : UInt16){

    if node == nil
        return;
    
    if node.rChild != nil
    {
        print("Given node already has a right child, skipping insertion")
        return
    }
    
    NodePtr rNode = createNode()
    rNode.parent = node
    node.rChild = rNode
    
    rNode.code = node.code + "1"
    rNode.value = value
}

//get the node at the immediate right & at the same level to the specified node
func getRightLevelNode(node : NodePtr) -> NodePtr {
    
    if  node == nil{
        return nil
    }
    
    // Node is the left child of its parent, then the parent's
    // right child is its right level order node.
    if node.parent != nil && node.parent.lChild == node{
        return node.parent.rChild
    }
    
    // Else node is the right child of its parent, then traverse
    // back the tree and find its right level order node
    var count : Int = 0
    var nptr : NodePtr = node
    while  nptr.parent != nil && nptr.parent.rChild == nptr
    {
        nptr = nptr.parent
        count+=1
    }
    
    if nptr.parent == nil{
        return nil
    }
    
    nptr = nptr.parent.rChild
    
    var i : Int = 1
    while count > 0 
    {
        nptr = nptr.lChild
        count-=1
    }
    
    return nptr        
}

//perform inorder traversal of the Huffman tree with specified root node
func inOrder( node : NodePtr )
{
    if node == nil{ 
        return
    }
    inOrder(node.lChild)
    
    if node.code != "" && node.leaf 
        //logFile << "Symbol: 0x" << std::hex << std::setfill('0') << std::setw(2) << std::setprecision(16) << node->value << ", Code: " << node->code << std::endl;
        print("Symbol : 0x \(node.value) ,Code: \(node.code)")
    
    inOrder(node.rChild)
}

//Huffman trees are just binary trees.
//You start at the root of the tree, and start assigning symbols from the leftmost node,
//moving within the same depth towards the rightmost node.
//While doing so, if the current node is not the right most node, 
//we simply add children to all the remaining nodes in the same level.
//Then we start the process again from the current node.
//CLASS
class HuffmanTree
{
    var m_root : NodePtr?
    
    init(){
        m_root = nil
     }
     
     init( htable : HuffmanTable){
            constructHuffmanTree(htable)
        }


    // creates a Huffman tree out of a Huffman table
    func constructHuffmanTree( htable : HuffmanTable)
    {
    
    print("Constructing Huffman tree with specified Huffman table...") 
    
    m_root = createRootNode( 0x0000 )
    insertLeft( m_root, 0x0000 )
    insertRight( m_root, 0x0000 )
    inOrder( m_root )
    NodePtr leftMost = m_root.lChild
    
    for i in 1..16
    {
        // If the count is zero, add left & right children for all unassigned leaf nodes.
        if htable[i - 1].first == 0
        { var nptr : NodePtr = leftMost
            while nptr != nil
            {
                insertLeft( nptr, 0x0000 )
                insertRight( nptr, 0x0000 )
                nptr = getRightLevelNode( nptr )
            }
            
            leftMost = leftMost.lChild
            i+=1
        }   
        
        // Else assign codes to nodes starting from leftmost leaf in the tree.
        else
        {
            while leftMost!=nil
            {
                var huffVal : Int = htable[i - 1].second
                leftMost.value = huffVal
                leftMost.leaf = true
                leftMost = getRightLevelNode( leftMost );
            }
            
            insertLeft( leftMost, 0x0000 )
            insertRight( leftMost, 0x0000 )
            
            var nptr: NodePtr = getRightLevelNode( leftMost )
            leftMost = leftMost.lChild
            
            while nptr != nil
            {
                insertLeft( nptr, 0x0000 )
                insertRight( nptr, 0x0000 )
                
                nptr = getRightLevelNode( nptr )
            }
        }
    }
    
    print("Finished building Huffman tree [OK]")
}
    
    
    //get the root node of the Huffman tree
    func getTree(parameters) -> NodePtr {
        return m_root
        
    }

    // NOTE: String is used as the return type because 0x0000 and 0xFFFF
    // are both values that are used in the normal range. So using them is not 
    // possible to indicate special conditions (e.g., code not found in tree)
    
    //checks whether a given Huffman code is present in the tree or not
    func contains(huffCode : String) -> String
    {

         if isStringWhiteSpace( huffCode ) 
    {
        print( "[ FATAL ] Invalid huffman code, possibly corrupt JFIF data stream!")
        return ""
    }
    
    var i : Int = 0
    var nptr : NodePtr = m_root

    repeat {
        if huffCode[i] == '0' 
            nptr = nptr.lChild
        else
            nptr = nptr.rChild
        
        if nptr != nil && nptr.leaf && nptr.code == huffCode
        {
            if nptr.value == 0x0000{
                return "EOB"
            }
            return String(nptr.value) 
        }
        i+=1
    } while (nptr != nullptr && i < huffCode.count)

    return ""

    }
    
}

  




