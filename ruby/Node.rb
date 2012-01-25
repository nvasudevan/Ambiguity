class Node
	attr_accessor :parentNode, :childNodes
	attr_reader   :nodeId, :lhs, :rhs, :rhsIndex
	@@nodeIdCounter=0
	 
	def initialize(lhs,rhs,rhsIndex)
		 @lhs,@rhs,@rhsIndex=lhs,rhs,rhsIndex
		 @nodeId=@@nodeIdCounter=@@nodeIdCounter+1
		 @parentNode=nil
		 @childNodes=[]
	end
	
	def to_s 
		#'[id=' + nodeId.to_s + '] ' +  lhs + ' : ' + rhs 
		nodeId.to_s + ' : ' + lhs + ' : ' + rhs.to_s + ' : ' + rhsIndex.to_s
	end
end
