class StackNode
	attr_accessor :activeNode, :index, :depth
	 
	def initialize(activeNode,index=nil,depth=nil)
		 @activeNode,@index,@depth = activeNode,index,depth
	end
	
	def to_s 
		@activeNode.to_s + ' : index=' + ((index != nil) ? index.to_s : "") + ', depth=' + ((depth != nil) ? depth.to_s : "")
	end
end
