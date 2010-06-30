package com.creatorsproject.ui
{
	/**
	 * Tickable objects recieve tick events form their parents. A tick event corresponds the instant before a screen
	 * blit start.  
	 * @author devin
	 * 
	 */	
	
	public interface ITickable
	{
		function tick():void;		
	}
}