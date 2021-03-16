Lexical scanning.


	ruby main.rb
	
	For example:
	
		IF
		
			Keyword
    		    
			IF
		        
		a=b
		
			Ident
    		    
			A
    		    
			Operator
        		
			=
        		
			Ident
				
			B
        		
		x=x+1
		
			Ident
        		
			X
            	
			Operator
            	
			=
            	
			Ident
            	
			X
            	
			Operator
            	
			+
            	
			Number
            	
			1
            	
		ELSE
		
			Keyword
        		
			ELSE
            	
		y=y+1
		
			Ident
            	
			Y
            	
			Operator
            	
			=
            	
			Ident
            	
			Y
            	
			Operator
            	
			+
            	
			Number
            	
			1
            	
		ENDIF
    	
			Keyword
                
			ENDIF
            	
		END
    	
			Keyword
                
			END
            	

	ruby 00_main.rb
	
	For example:

		ia=bx=x+1ly=y+1ee
		
		if('i') condition('a=b') do('x=x+1') else('l') do('y=y+1') endif('e') end('e')


	ruby 01_main.rb
	
	For example:
	
		IF
		
			....
			
		a=b
		
			....
			
		x=x+1
       	
			....
       		
		ELSE
       	
			....
       		
		y=y+1
        
			....
        	
		ENDIF
        
			....
        	
		END
        
			....
