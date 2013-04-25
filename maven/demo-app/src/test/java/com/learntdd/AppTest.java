package com.learntdd;

import org.junit.Test;
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;
import org.mockito.InOrder ;

public class AppTest
{
    
    
    @Test
    public void testFoo()
    {
        App app = new App();
        String message = "testFoo";
        String[] s = {"vijay", "gatadi"} ;
        app.main(s);
        app.setMessage(message);        
        assertEquals(message, app.getMessage());                  
    }
    
    @Test
    public void verifyingBehaviour()
    {
        App app = spy(new App());
        app.handle(); 
                   
        //verifty whether app.getMessage() has been called        
        verify(app).getMessage() ;
        //verify whether app.setMessage with paramter as anyString called twice
        verify(app, times(2)).setMessage(anyString());        
    }
    
    @Test
    public void verifyExactNumberOfInvocations()
    {
        App app = spy(new App());
        app.handle(); 
        
        //verify whether app.getMessage() is called once
        verify(app).getMessage() ;
        //verify whether app.setMessage( any string) is called twice
        verify(app, times(2)).setMessage(anyString());
        //verify whether sum (anyInt, 10) is called once
        verify(app, times(1)).sum(anyInt(), eq(10));
        //verify whether sum(100, 200) is called once
        verify(app, times(1)).sum(100,200);
    }
    
    @Test
    public void stubMethodUsingDoReturnWhen()
    {
        App app = spy(new App()); 
        app.handle();
                
        doReturn(500).when(app).sum(anyInt(), anyInt());
        assertEquals(500, app.sum(10,20));       
    }
    
    @Test
    public void stubMethodUsingWhenThenReturn()
    {
        App app = spy(new App()); 
        app.handle();
        
        //acutally executes app.sub() function, so don't use this with spy
        //use doReturn(500).when(app).sub(10,20);
        when(app.sub(10,20)).thenReturn(500);        
        assertEquals(500, app.sub(10,20));       
    }
    
    @Test
    public void verifyOrderOfInvocation()
    {
        App app = spy(new App());
        app.handle();
        InOrder order = inOrder(app);
        
        order.verify(app).getMessage();
        order.verify(app).setMessage(anyString());        
    }
    
    
    
}



