class SubTree

        attr_accessor :rootNode, :depth, :leafNodes, :currentNode, :currentIndex, :currentNodeDepth
        #@@treeIdCounter=0
        
        def initialize(root_node)
                @rootNode = root_node
                @depth = 1 # we initialise with depth = 1
                @leafNodes = []
                @leafNodes << root_node
                @currentNode = root_node 
                @currentIndex = 0
                @currentNodeDepth = 1
                #@treeId=@@treeIdCounter=@@treeIdCounter+1
                @treeId=0 ## initialise to zero. we set the value to a unique value when a ff is formed
                @production_combinations={}
        end
        
        def to_s
                "[id=#{@treeId},#{@rootNode.lhs}[#{printSubTree()}]"
        end

        def setId()
                @treeId=(@@treeIdCounter=(@@treeIdCounter+1))
        end
        
        def printSubTree()
                #puts "+-- printSubTree():#{@treeId}:#{@rootNode} --+" if @@debug
                active_stack = []
                active_stack << @rootNode
                list_of_nodes = []
                while ((current_node = active_stack.pop) != nil) do
                        #puts "   current_node:#{current_node}, active_stack:#{active_stack}" if @@debug
                        list_of_nodes << "#{current_node.lhs}/#{current_node.rhsIndex}"
                        if current_node.childNodes.size > 0
                                #puts "   childNodes size > 0" if @@debug
                                current_node.childNodes.reverse.each do |_child|
                                        #puts "    _child: #{_child}" if @@debug
                                        (active_stack << _child) if _child != nil ## only add non-nil values
                                        #puts "    active_stack:#{active_stack}" if @@debug
                                end
                        end
                end
                #puts "--- printSubTree() ---" if @@debug
                return [@treeId,list_of_nodes]
        end
        
        def compareSubTree(other_sub_tree)
                puts "+--- eql ---+" if @@debug
                puts "other_sub_tree: #{other_sub_tree}" if @@debug
                match = true
                current_active_stack,other_active_stack=[],[]
                current_list_of_nodes,other_list_of_nodes=[],[]
                current_root_node = @rootNode
                other_root_node = other_sub_tree.rootNode
                current_active_stack << current_root_node
                other_active_stack << other_root_node
                while ((current_node = current_active_stack.pop) != nil) do
                        if ((other_node = other_active_stack.pop) != nil)
                                current_node_mini = "#{current_node.lhs}/#{current_node.rhsIndex}"
                                other_node_mini = "#{other_node.lhs}/#{other_node.rhsIndex}"
                                puts "c_n_mini: #{current_node_mini}, o_n_mini: #{other_node_mini}" if @@debug
                                if (current_node_mini == other_node_mini)
                                        current_list_of_nodes << current_node_mini
                                        other_list_of_nodes << other_node_mini
                                        #current_node_child_nodes,other_node_child_nodes=[],[]
                                        if (current_node.childNodes.size > 0)
                                                current_node.childNodes.each do |c_child|
                                                        (current_active_stack << c_child) if c_child != nil
                                                end
                                        end
                                        if (other_node.childNodes.size > 0)
                                                other_node.childNodes.each do |o_child|
                                                        (other_active_stack << o_child) if o_child != nil
                                                end
                                        end
                                        # not needed
                                        # now compare these two set of child nodes and they should match
                                else
                                        match = false
                                end
                                
                        else
                                puts "c_n_mini: #{current_node_mini}, o_n_mini: nil" if @@debug
                                match = false
                        end

                end
                puts "match: #{match}" if @@debug
                puts "current_list_of_nodes: #{current_list_of_nodes}" if @@debug
                puts "other_list_of_nodes:   #{other_list_of_nodes}" if @@debug
                return match
        end

        def eql? (anotherTree)
                return compareSubTree(anotherTree)
        end
end
